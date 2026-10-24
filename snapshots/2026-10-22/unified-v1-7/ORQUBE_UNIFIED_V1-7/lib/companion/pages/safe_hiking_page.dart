import 'active_trip_map.dart';
import 'trip_start_wizard.dart';
import '../services/people_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audience_picker.dart';
import 'hiking_detailed_guide_page.dart';
import '../services/hiking_search_record.dart';
import 'search_record_page.dart';
import 'orqube_domain_button.dart';
import '../utils/app_language.dart';
// ORQUBE V17.4.0 SAFE HIKING FINAL OFFLINE
// FINAL OFFLINE ADD-ON 2026-08-13: saved map + guardian / planned return / share-until-end / safe descent
// 기존 에어소프트·안심귀가 기능은 유지하고 안전산행의 오프라인 GPS 안전 기능을 보강
// - GPS 경로/출발점/좌표/고도/오차/거리 표시
// - 출발점 귀환 기준점 제공
// - 서버 통신 실패 시에도 산행 시작이 막히지 않도록 로컬 GPS 추적 우선
// - SOS는 서버 확인 여부와 무관하게 현 위치 좌표를 사용자에게 남김
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/offline_hiking_map_store.dart';
import '../utils/orqube_i18n.dart';
import 'public_help_center_page.dart';
import 'hiking_account_page.dart';
import 'guardian_page.dart';
import '../services/guardian_share.dart';

enum OrqubeMapMode { airsoft, safeHome, safeHiking }

class SafeHikingPage extends StatefulWidget {
  final OrqubeMapMode initialMode;

  SafeHikingPage({super.key, this.initialMode = OrqubeMapMode.safeHiking});

  @override
  State<SafeHikingPage> createState() => _SafeHikingPageState();
}

class _SafeHikingPageState extends State<SafeHikingPage> with LanguageAware<SafeHikingPage> {
  String _t(String ko, String en) => AppLanguage.changed.value == 'ko' ? ko : AppLanguage.t(ko) != ko ? AppLanguage.t(ko) : OrqubeI18n.currentPair(ko, en);

  String _sosDisplay(String value) {
    switch (value) {
      case '길을 잃었습니다': return _t('길을 잃었습니다', 'I am lost');
      case '부상을 입었습니다': return _t('부상을 입었습니다', 'I am injured');
      case '장비 문제가 발생했습니다': return _t('장비 문제가 발생했습니다', 'Equipment problem');
      case '차량 지원이 필요합니다': return _t('차량 지원이 필요합니다', 'Vehicle assistance needed');
      case '기타 긴급 상황': return _t('기타 긴급 상황', 'Other emergency');
      default: return value;
    }
  }
  static final _bg = Color(0xFF03040B);
  static final _panel = Color(0xFF0A0B18);
  static final _purple = Color(0xFF8B2CF6);
  static final _lime = Color(0xFFD7FF35);
  static final _cyan = Color(0xFF39D9FF);

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _mapController = MapController();

  Position? _position;
  bool _locating = false;
  bool _sharing = false;
  bool _savingPlace = false;
  DateTime? _sharingUntil;
  Timer? _shareTimer;
  StreamSubscription<User?>? _authSubscription;
  int _accountEpoch = 0;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _trackingPollTimer;
  bool _pollingPosition = false;
  late OrqubeMapMode _mode;
  LatLng? _destination;
  DateTime? _sessionStartedAt;
  DateTime? _returnEta;
  bool _routeRecording = false;
  bool _stationaryAlert = false;
  bool _routeDeviationAlert = false;
  double? _remainingDistanceKm;
  bool _etaCalculating = false;
  final List<LatLng> _routePoints = <LatLng>[];
  String? _destinationAddress;

  // 안전산행 2차 보호자/귀환 계획 정보.
  // 기존 GPS·지도·라우팅 로직과 분리해 1차 안정 기능을 훼손하지 않습니다.
  String _guardianName = '';
  String _guardianContact = '';
  DateTime? _plannedReturnAt;
  bool _safeDescentReported = false;

  // 안전산행 오프라인 보조 정보. GPS는 모바일 데이터가 없어도 기기 위치
  // 서비스가 켜져 있으면 계속 사용할 수 있으므로 서버보다 먼저 유지합니다.
  LatLng? _hikeStartPoint;
  double _routeDistanceKm = 0;
  DateTime? _lastRouteSnapshotAt;

  // 안전산행 앱 전용: 사용자가 산행 전에 현재 보이는 지도를 한 장의
  // 지오리퍼런스 PNG로 저장해 인터넷이 끊긴 뒤에도 GPS/경로 아래에 표시합니다.
  final GlobalKey _offlineMapCaptureKey = GlobalKey();
  final OfflineHikingMapStore _offlineMapStore = OfflineHikingMapStore();
  OfflineHikingMapSnapshot? _offlineMapSnapshot;
  bool _savingOfflineMap = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _authSubscription = _auth.authStateChanges().listen((user) {
      _accountEpoch++;
      _shareTimer?.cancel();
      _positionSubscription?.cancel();
      _trackingPollTimer?.cancel();
      if (mounted) setState(() {
        _sharing = false; _sharingUntil = null; _sessionStartedAt = null;
        _routeRecording = false; _routePoints.clear(); _position = null;
        _hikeStartPoint = null; _guardianName = ''; _guardianContact = '';
        _plannedReturnAt = null; _routeDistanceKm = 0;
      });
      if (user != null) {
        // Legacy phone contacts are not shared-account connections.
        unawaited(HikingSearchRecord.retryFor(user.uid));
      }
    });
    unawaited(_loadOfflineHikingMap());
  }

  @override
  void dispose() {
    if (_sharing) unawaited(GuardianShare.stop().catchError((Object _) {}));
    _authSubscription?.cancel();
    _shareTimer?.cancel();
    _positionSubscription?.cancel();
    _trackingPollTimer?.cancel();
    super.dispose();
  }

  Future<Position?> _currentPosition() async {
    if (mounted) setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _message(_t('기기의 위치 서비스를 먼저 켜주세요.', 'Turn on the device location service first.'));
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _message(_t('현재 위치를 사용하려면 위치 권한이 필요합니다.', 'Location permission is required to use your current location.'));
        return null;
      }
      if (permission == LocationPermission.deniedForever) {
        _message(_t('설정에서 ORQUBE의 위치 권한을 허용해주세요.', 'Allow ORQUBE location permission in Settings.'));
        await Geolocator.openAppSettings();
        return null;
      }

      final result = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return result;
      setState(() => _position = result);
      _moveLegacyMap(LatLng(result.latitude, result.longitude), 15);
      return result;
    } catch (e) {
      _message('${_t('현재 위치를 확인하지 못했습니다:', 'Could not get current location:')} $e');
      return null;
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _registerField() async {
    final user = _auth.currentUser;
    if (user == null) {
      _message(_t('로그인 후 경기장을 등록할 수 있습니다.', 'Sign in to register a field.'));
      return;
    }

    final position = _position ?? await _currentPosition();
    if (position == null || !mounted) return;

    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();

    final shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: _panel,
            title: AppText(
              _t('현재 위치를 경기장으로 등록', 'Register Current Location as Field'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(nameController, _t('경기장 이름', 'Field name'), Icons.sports_mma_rounded),
                  SizedBox(height: 12),
                  _field(addressController, _t('주소 또는 지역', 'Address or region'), Icons.place_rounded),
                  SizedBox(height: 12),
                  _field(
                    descriptionController,
                    _t('시설 설명·주차·안전수칙', 'Facilities · parking · safety rules'),
                    Icons.description_rounded,
                    maxLines: 3,
                  ),
                  SizedBox(height: 12),
                  AppText(
                    '${_t('위도', 'Latitude')} ${position.latitude.toStringAsFixed(6)}  ·  '
                    '${_t('경도', 'Longitude')} ${position.longitude.toStringAsFixed(6)}',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [if (_sessionStartedAt != null) IconButton(tooltip:AppLanguage.t('이동 지도 보기'),onPressed:()=>setState(()=>_showTripMap=true),icon:Icon(Icons.map_outlined)), OrqubeDomainButton(), LanguageButton(),
          IconButton(icon: Icon(Icons.person_outline), tooltip: AppLanguage.t('로그인 / 계정'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HikingAccountPage()))),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: AppText(_t('취소', 'Cancel')),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.trim().length < 2) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: AppText(_t('경기장 이름을 2자 이상 입력해주세요.', 'Enter at least 2 characters for the field name.'))),
                    );
                    return;
                  }
                  Navigator.pop(dialogContext, true);
                },
                child: AppText(_t('등록', 'Register')),
              ),
            ],
          ),
    );

    if (shouldSave != true) {
      nameController.dispose();
      addressController.dispose();
      descriptionController.dispose();
      return;
    }

    if (mounted) setState(() => _savingPlace = true);
    try {
      await _db.collection('airsoft_places').add({
        'ownerUid': user.uid,
        'ownerName': user.displayName ?? user.email ?? 'ORQUBE USER',
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'description': descriptionController.text.trim(),
        'type': 'field',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'location': GeoPoint(position.latitude, position.longitude),
        'approved': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _message(_t('경기장이 등록되었습니다. 관리자 승인 전에는 등록자에게만 표시될 수 있습니다.', 'The field was registered. Before admin approval, it may be visible only to you.'));
    } on FirebaseException catch (e) {
      _message('${_t('경기장 등록 실패:', 'Field registration failed:')} ${e.message ?? e.code}');
    } catch (e) {
      _message('${_t('경기장 등록 실패:', 'Field registration failed:')} $e');
    } finally {
      nameController.dispose();
      addressController.dispose();
      descriptionController.dispose();
      if (mounted) setState(() => _savingPlace = false);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: _cyan),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white12),
        ),
      ),
    );
  }

  Future<void> _loadOfflineHikingMap() async {
    if (!_offlineMapStore.supported) return;
    final snapshot = await _offlineMapStore.load();
    if (!mounted) return;
    setState(() => _offlineMapSnapshot = snapshot);
  }

  Future<void> _saveVisibleOfflineHikingMap() async {
    if (_mode != OrqubeMapMode.safeHiking) return;
    if (!_offlineMapStore.supported || kIsWeb) {
      _message(_t('오프라인 지도 저장은 모바일 앱에서 사용할 수 있습니다.', 'Offline map saving is available in the mobile app.'));
      return;
    }
    if (_savingOfflineMap) return;

    if (mounted) setState(() => _savingOfflineMap = true);
    try {
      // 저장 이미지와 좌표 경계를 정확히 맞추기 위해 저장 시 지도는 북쪽을 위로 둡니다.
      _mapController.rotate(0);
      await Future<void>.delayed(Duration(milliseconds: 250));
      await WidgetsBinding.instance.endOfFrame;
      final renderObject = _offlineMapCaptureKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        _message(_t('지도 화면을 아직 저장할 수 없습니다. 잠시 후 다시 눌러주세요.', 'The map is not ready to save yet. Try again shortly.'));
        return;
      }

      final bounds = _mapController.camera.visibleBounds;
      final deviceRatio = MediaQuery.devicePixelRatioOf(context);
      final pixelRatio = deviceRatio.clamp(1.0, 2.0).toDouble();
      final image = await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        _message(_t('지도 이미지 저장에 실패했습니다.', 'Failed to save the map image.'));
        return;
      }

      final saved = await _offlineMapStore.save(
        pngBytes: byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
        north: bounds.north,
        south: bounds.south,
        east: bounds.east,
        west: bounds.west,
      );
      if (!mounted) return;
      if (saved == null) {
        _message(_t('오프라인 지도 저장에 실패했습니다.', 'Failed to save the offline map.'));
        return;
      }
      setState(() => _offlineMapSnapshot = saved);
      _message(_t('현재 보이는 지도를 오프라인 안전지도로 저장했습니다.', 'The visible map was saved for offline safety use.'));
    } catch (e) {
      debugPrint('Offline hiking map save error: $e');
      _message(_t('오프라인 지도 저장 중 오류가 발생했습니다.', 'An error occurred while saving the offline map.'));
    } finally {
      if (mounted) setState(() => _savingOfflineMap = false);
    }
  }

  Future<void> _deleteOfflineHikingMap() async {
    if (!_offlineMapStore.supported) return;
    await _offlineMapStore.delete();
    if (!mounted) return;
    setState(() => _offlineMapSnapshot = null);
    _message(_t('저장된 오프라인 지도를 삭제했습니다.', 'The saved offline map was deleted.'));
  }

  String get _offlineMapStatusLabel {
    final snapshot = _offlineMapSnapshot;
    if (snapshot == null) return _t('지도 미저장', 'Map not saved');
    final t = snapshot.savedAt.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }

  Future<void> _configureGuardian() async {
    if (_sharing) {
      await _selectAudience();
    } else {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => GuardianPage()));
    }
  }
  Set<String> _searchAudience = {};
  Future<bool> _selectAudience() async {
    try {
      final selected = await chooseAudience(context, hiking: _mode == OrqubeMapMode.safeHiking);
      if (!mounted || selected == null) return false;
      setState(() { _guardianName = selected.names; _guardianContact = ''; _searchAudience = selected.search; });
      final uid = _auth.currentUser?.uid;
      if (_sharing && selected.live.isEmpty) { await _stopSafetyShare(); return false; }
      if (_sharing && uid != null && _mode == OrqubeMapMode.safeHiking) {
        if (selected.search.isEmpty) await HikingSearchRecord.stop(uid);
        else await HikingSearchRecord.consent(uid);
      }
      return selected.live.isNotEmpty;
    } catch (_) {
      if (mounted) _message('공유 대상을 읽지 못했습니다. 새 보안 규칙과 연결 상태를 확인하세요.');
      return false;
    }
  }

  String _plannedReturnLabel([DateTime? value]) {
    final time = value ?? _plannedReturnAt;
    if (time == null) return _t('미설정', 'Not set');
    final now = DateTime.now();
    final datePrefix =
        time.year == now.year && time.month == now.month && time.day == now.day
            ? _t('오늘', 'Today')
            : '${time.month}/${time.day}';
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$datePrefix $h:$m';
  }

  Future<void> _selectPlannedReturnTime() async {
    final now = DateTime.now();
    final savedReturn = _plannedReturnAt;
    final initial = savedReturn != null && savedReturn.isAfter(now)
        ? savedReturn
        : now.add(Duration(hours: 4));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(Duration(days: 14)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    final planned = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (!planned.isAfter(now)) {
      _message(_t('귀환 예정시간은 현재 시각 이후로 설정해 주세요.', 'Set the planned return time after the current time.'));
      return;
    }

    setState(() {
      _plannedReturnAt = planned;
      if (_mode == OrqubeMapMode.safeHiking && _destination == null) {
        _returnEta = planned;
      }
    });

    final user = _auth.currentUser;
    if (user != null && _sessionStartedAt != null && _mode == OrqubeMapMode.safeHiking) {
      await HikingSearchRecord.plan(user.uid, planned);
      try {
        await _db.collection('hiking_sessions').doc(user.uid).set({
          'uid': user.uid,
          'plannedReturnAt': Timestamp.fromDate(planned),
          'eta': Timestamp.fromDate(planned),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(Duration(seconds: 4));
      } catch (_) {}
    }
    _message('${_t('귀환 예정시간을 설정했습니다:', 'Planned return time set:')} ${_plannedReturnLabel(planned)}');
  }

  Future<void> _shareGuardianStatus({required bool completed}) async {
    final position = _position;
    final user = _auth.currentUser;
    if (position == null || user == null) return;
    final mapUrl = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    final guardian = _guardianName.isEmpty ? _t('보호자', 'Guardian') : _guardianName;
    final text = completed
        ? '$guardian ${AppLanguage.f('ORQUBE {mode} 이동을 종료했습니다. 현재 좌표: {url}', {'mode': _modeTitle, 'url': mapUrl})}'
        : '$guardian ${AppLanguage.f('ORQUBE {mode} 현재 좌표입니다. 귀환 예정: {time} · 지도: {url}', {'mode': _modeTitle, 'time': _plannedReturnLabel(), 'url': mapUrl})}';
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, backgroundColor: _panel,
      builder: (sheetContext) => SafeArea(child: SingleChildScrollView(
        padding: EdgeInsets.all(24), child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('보호자에게 위치 보내기', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 12),
            AppText('현재 좌표를 담은 메시지입니다. 실시간 추적 링크가 아닙니다. 수신자를 확인한 후 직접 전송하세요.', style: TextStyle(color: Colors.white70, height: 1.6)),
            SizedBox(height: 16),
            Container(width: double.infinity, padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Color(0xFF142438), borderRadius: BorderRadius.circular(14)),
              child: SelectableText(text, style: TextStyle(color: Colors.white, height: 1.6))),
            SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _cyan, foregroundColor: Colors.black),
              onPressed: () async {
                try {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                  _message('위치 문구를 복사했습니다. 카카오톡 또는 문자에 붙여넣고 직접 보내세요.');
                } catch (_) { _message('복사하지 못했습니다. 위 문구를 선택해 직접 복사하세요.'); }
              }, icon: Icon(Icons.copy), label: AppText('문구 복사 · 카카오톡에 붙여넣기')),
            SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () async {
                final contact = _guardianContact.replaceAll(RegExp(r'[^0-9+]'), '');
                final body = Uri.encodeComponent(text);
                final separator = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS ? '&' : '?';
                final uri = Uri.parse('sms:$contact' + separator + 'body=$body');
                try {
                  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
                  if (!opened) { _message('문자 앱을 열지 못했습니다. 문구 복사를 이용하세요.'); return; }
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                  _message('문자 작성 요청을 보냈습니다. 수신 번호와 내용을 확인하고 직접 전송하세요.');
                } catch (_) { _message('이 기기에서 문자 앱을 열 수 없습니다. 문구 복사를 이용하세요.'); }
              }, icon: Icon(Icons.sms_outlined), label: AppText('문자로 보내기 · 휴대전화')),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () async {
                try {
                  await Share.share(text, subject: 'ORQUBE $_modeTitle');
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                  _message('공유 화면에서 수신자를 선택해 전송하세요. 앱은 전달 완료를 확인하지 않습니다.');
                } catch (_) { _message('공유 화면을 열지 못했습니다. 문구 복사를 이용하세요.'); }
              }, icon: Icon(Icons.share), label: AppText('카카오톡 등으로 공유 · 앱 선택')),
            SizedBox(height: 8),
            AppText('카카오톡 공유 버튼은 기기의 일반 공유 화면을 엽니다. 카카오톡 설치 여부에 따라 목록에 표시됩니다. PC에서 공유 목록이 비면 문구 복사를 이용하세요. 전송한 메시지는 산행 종료 후에도 수신자에게 남습니다.', style: TextStyle(color: Colors.white60, height: 1.6)),
          ],
        ))),
    );
  }

  Future<void> _reportSafeDescent() async {
    if (_mode != OrqubeMapMode.safeHiking) return;
    if (_sessionStartedAt == null) {
      _message(_t('진행 중인 안전산행이 없습니다.', 'There is no active Safe Hiking session.'));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _panel,
        title: AppText(
          _t('안전하게 하산했습니다', 'I Arrived Safely'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: AppText(
          _t(
            '산행을 안전하게 마쳤습니까? 확인하면 위치 공유와 GPS 세션이 함께 종료되고 안전 하산 상태가 기록됩니다.',
            'Did you finish the hike safely? Confirming stops location sharing and GPS tracking and records a safe completion.',
          ),
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: AppText(_t('취소', 'Cancel')),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: Icon(Icons.verified_rounded),
            label: AppText(_t('안전 하산 확인', 'Confirm Safe Arrival')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final position = _position ?? await _currentPosition();
    final user = _auth.currentUser;
    setState(() => _safeDescentReported = true);

    if (user != null) {
      try {
        await _db.collection('hiking_sessions').doc(user.uid).set({
          'uid': user.uid,
          'status': 'safe_completed',
          'safeDescent': true,
          'safeDescentAt': FieldValue.serverTimestamp(),
          if (position != null) 'finalLatitude': position.latitude,
          if (position != null) 'finalLongitude': position.longitude,
          'guardianName': _guardianName,
          'guardianContact': _guardianContact,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(Duration(seconds: 4));
      } catch (_) {
        // 로컬 종료는 계속 진행합니다.
      }
    }

    await _endModeSession();
    if (position != null) {
      await _shareGuardianStatus(completed: true);
    }
    _message(_t('안전 하산으로 기록하고 산행을 종료했습니다.', 'Safe arrival recorded and the hiking session has ended.'));
  }

  Future<void> _startSafetyShare({bool fromWizard = false, Position? startPosition}) async {
    final user = _auth.currentUser;
    if (user == null) {
      _message(_t('로그인 후 안전 위치 공유를 사용할 수 있습니다.', 'Sign in to use safety location sharing.'));
      return;
    }

    if (!user.emailVerified) {
      _message(_t('이메일 인증이 필요합니다.', 'Email verification is required.'));
      return;
    }
    final hikingUntilEnd = _mode != OrqubeMapMode.airsoft;
    if (hikingUntilEnd && _sessionStartedAt == null) {
      _message(_t('먼저 산행 또는 귀가 시작을 눌러 주세요.', 'Start a hike or return trip first.'));
      return;
    }
    if (!fromWizard && !await _selectAudience()) return;
    if (!mounted || _auth.currentUser?.uid != user.uid) return;

    final position = startPosition ?? await _currentPosition();
    if (position == null || !mounted) return;

    final agreed = fromWizard ? true : await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _panel,
        title: AppText(
          hikingUntilEnd
              ? _t('이동 종료까지 보호자 위치 공유', 'Share Until Trip Ends')
              : _t('안전 위치 공유', 'Safety Location Sharing'),
          style: TextStyle(color: Colors.white),
        ),
        content: AppText(
          hikingUntilEnd
              ? _t(
                  '현재 위치와 최근 이동 경로를 서버에 저장하고, 보호자 연결 화면에서 내가 승인한 계정에 공개합니다. 전화번호만으로 조회할 수 없습니다. 이동 종료 또는 공유 중지 시 접근을 차단합니다. 인터넷 단절 시 종료 반영이 지연될 수 있으며 마지막 갱신 2분 뒤 보호자 조회가 만료됩니다.',
                  'Your location will be shared until the hike is ended or you tap “I Arrived Safely.” GPS recording continues offline, but remote delivery can be delayed until connectivity returns.',
                )
              : _t(
                  '현재 위치를 30분 동안 운영자와 허용된 안전 담당자에게 공유합니다. 상대 팀 추적에는 사용할 수 없으며 언제든 종료할 수 있습니다.',
                  'Your current location will be shared for 30 minutes with operators and authorized safety staff. It cannot be used to track opposing teams and can be stopped at any time.',
                ),
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: AppText(_t('취소', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: AppText(_t('동의하고 시작', 'Agree and Start')),
          ),
        ],
      ),
    );
    if (agreed != true || _auth.currentUser?.uid != user.uid) return;
    if (_mode == OrqubeMapMode.safeHiking) {
      if (_searchAudience.isNotEmpty) await HikingSearchRecord.consent(user.uid);
      else await HikingSearchRecord.stop(user.uid);
    }

    // 안전산행은 종료 이벤트로 공유를 끄며, expiresAt은 서버에 오래 남는
    // 유령 위치를 막기 위한 안전장치입니다. 추적 중에는 계속 갱신됩니다.
    final until = hikingUntilEnd
        ? DateTime.now().add(Duration(hours: 24))
        : DateTime.now().add(Duration(minutes: 30));
    var serverWriteAccepted = true;
    try {
      await _db.collection('airsoft_live_locations').doc(user.uid).set({
        'uid': user.uid,
        'displayName': user.displayName ?? user.email ?? 'ORQUBE USER',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'shareMode': _modeKey,
        'emergency': false,
        'shareUntilSessionEnd': hikingUntilEnd,
        if (hikingUntilEnd) 'guardianName': _guardianName,
        if (hikingUntilEnd) 'guardianContact': _guardianContact,
        if (hikingUntilEnd && _plannedReturnAt != null)
          'plannedReturnAt': Timestamp.fromDate(_plannedReturnAt!),
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(until),
      }).timeout(Duration(seconds: 4));
    } catch (_) {
      serverWriteAccepted = false;
    }

    _shareTimer?.cancel();
    if (!hikingUntilEnd) {
      _shareTimer = Timer.periodic(
        Duration(minutes: 1),
        (_) => _refreshShare(),
      );
    }
    if (!mounted) return;
    setState(() {
      GuardianShare.beginSession();
      _sharing = true;
      _sharingUntil = hikingUntilEnd ? null : until;
    });

    unawaited(GuardianShare.publish(position.latitude, position.longitude, _routePoints, _modeKey));
    if (hikingUntilEnd) {
      try {
        await _db.collection('hiking_sessions').doc(user.uid).set({
          'uid': user.uid,
          'sharingActive': true,
          'shareUntilSessionEnd': true,
          'guardianName': _guardianName,
          'guardianContact': _guardianContact,
          if (_plannedReturnAt != null)
            'plannedReturnAt': Timestamp.fromDate(_plannedReturnAt!),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(Duration(seconds: 4));
      } catch (_) {}
    }

    _message(
      serverWriteAccepted
          ? (hikingUntilEnd
              ? _t('산행 종료까지 위치 공유가 시작되었습니다.', 'Location sharing is active until the hike ends.')
              : '$_modeTitle ${_t('안전 위치 공유가 시작되었습니다. 통신 상태에 따라 전달이 지연될 수 있습니다.', 'safety location sharing has started. Delivery may be delayed depending on connectivity.')}')
          : _t('GPS 기록은 계속됩니다. 현재 통신이 원활하지 않아 실시간 위치 공유는 지연될 수 있습니다.', 'GPS recording continues. Real-time location sharing may be delayed because connectivity is currently unstable.'),
    );

    if (hikingUntilEnd && !fromWizard) {
      await _shareGuardianStatus(completed: false);
    }
  }

  Future<void> _refreshShare() async {
    if (!_sharing) return;
    if (_mode != OrqubeMapMode.safeHiking && _sharingUntil == null) return;
    if (_sharingUntil != null && DateTime.now().isAfter(_sharingUntil!)) {
      await _stopSafetyShare();
      return;
    }
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _db.collection('airsoft_live_locations').doc(user.uid).set({
        'uid': user.uid,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        if (_mode == OrqubeMapMode.safeHiking)
          'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(hours: 24))),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _stopSafetyShare() async {
    final searchUid = _auth.currentUser?.uid;
    if (_mode == OrqubeMapMode.safeHiking && searchUid != null) await HikingSearchRecord.stop(searchUid);
    if (mounted) setState(() => _sharing = false);
    try { await GuardianShare.stop(); } catch (_) {}

    final user = _auth.currentUser;
    _shareTimer?.cancel();
    if (user != null) {
      try {
        await _db
            .collection('airsoft_live_locations')
            .doc(user.uid)
            .delete()
            .timeout(Duration(seconds: 4));
      } catch (_) {
        // 네트워크가 없더라도 기기 쪽 공유 상태는 즉시 종료합니다.
      }
      if (_mode == OrqubeMapMode.safeHiking) {
        try {
          await _db.collection('hiking_sessions').doc(user.uid).set({
            'uid': user.uid,
            'sharingActive': false,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)).timeout(Duration(seconds: 4));
        } catch (_) {}
      }
    }
    if (!mounted) return;
    setState(() {
      _sharing = false;
      _sharingUntil = null;
    });
    _message(_t('기기 위치 공유를 종료했습니다. 오프라인이면 서버 종료 반영이 지연될 수 있습니다.', 'Local sharing stopped; server updates may be delayed offline.'));
  }

  Future<void> _sendSos() async {
    final user = _auth.currentUser;
    if (user == null) {
      _message(_t('로그인 후 SOS를 사용할 수 있습니다.', 'Sign in to use SOS.'));
      return;
    }
    final position = await _currentPosition();
    if (position == null || !mounted) return;

    final type = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _panel,
      builder:
          (sheetContext) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: AppText(
                    _t('긴급 상황 선택', 'Select Emergency'),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: AppText(
                    _t('현재 위치가 안전 담당자에게 전달됩니다.', 'Your current location will be sent to safety staff.'),
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                ...[
                  '길을 잃었습니다',
                  '부상을 입었습니다',
                  '장비 문제가 발생했습니다',
                  '차량 지원이 필요합니다',
                  '기타 긴급 상황',
                ].map(
                  (value) => ListTile(
                    leading: Icon(
                      Icons.sos_rounded,
                      color: Colors.redAccent,
                    ),
                    title: AppText(
                      _sosDisplay(value),
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.pop(sheetContext, value),
                  ),
                ),
              ],
            ),
          ),
    );
    if (type == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: _panel,
            title: AppText(
              _t('SOS 전송 확인', 'Confirm SOS'),
              style: TextStyle(color: Colors.white),
            ),
            content: AppText(
              '“${_sosDisplay(type)}” ${_t('현재 위치를 긴급 전송합니다.', 'Your current location will be sent as an emergency.')}',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: AppText(_t('취소', 'Cancel')),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: AppText(_t('SOS 전송', 'Send SOS')),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    var serverWriteAccepted = true;
    try {
      await _db.collection('airsoft_sos').add({
        'uid': user.uid,
        'displayName': user.displayName ?? user.email ?? 'ORQUBE USER',
        'type': type,
        'serviceMode': _modeKey,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(Duration(seconds: 4));
      await _db.collection('airsoft_live_locations').doc(user.uid).set({
        'uid': user.uid,
        'displayName': user.displayName ?? user.email ?? 'ORQUBE USER',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'shareMode': '${_modeKey}_emergency',
        'emergency': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(Duration(hours: 2)),
        ),
      }).timeout(Duration(seconds: 4));
    } catch (_) {
      serverWriteAccepted = false;
    }

    if (!mounted) return;
    await _showSosLocationReceipt(
      type: type,
      position: position,
      serverWriteAccepted: serverWriteAccepted,
    );
  }

  Future<void> _showSosLocationReceipt({
    required String type,
    required Position position,
    required bool serverWriteAccepted,
  }) async {
    final coordinate =
        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _panel,
        title: AppText(
          _t('SOS 위치 정보', 'SOS Location Information'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              serverWriteAccepted
                  ? _t('SOS 정보가 기기에 기록되어 서버 전송을 시도했습니다. 통신 상태에 따라 실제 전달이 지연될 수 있습니다.', 'SOS information was recorded on the device and a server send was attempted. Actual delivery may be delayed depending on connectivity.')
                  : _t('현재 데이터 통신이 원활하지 않습니다. 아래 좌표를 직접 확인하고 가능한 통신 수단으로 전달하세요.', 'Data connectivity is currently unstable. Check the coordinates below and share them through any available communication method.'),
              style: TextStyle(color: Colors.white70, height: 1.45),
            ),
            SizedBox(height: 14),
            AppText(_sosDisplay(type), style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            SelectableText(
              coordinate,
              style: TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 6),
            AppText(
              '${_t('GPS 오차 약', 'GPS accuracy about')} ±${position.accuracy.toStringAsFixed(0)}m · ${_t('고도', 'Altitude')} ${position.altitude.toStringAsFixed(0)}m',
              style: TextStyle(color: Colors.white60, fontSize: 12.5),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: coordinate));
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: AppText(_t('현재 위치 좌표를 복사했습니다.', 'Current location coordinates copied.'))),
                );
              }
            },
            icon: Icon(Icons.copy_rounded),
            label: AppText(_t('좌표 복사', 'Copy Coordinates')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText(_t('확인', 'OK')),
          ),
        ],
      ),
    );
  }

  LatLng? _latLng(Map<String, dynamic> data) {
    final geo = data['location'];
    if (geo is GeoPoint) return LatLng(geo.latitude, geo.longitude);
    final lat = data['latitude'] ?? data['lat'];
    final lng = data['longitude'] ?? data['lng'] ?? data['lon'];
    if (lat is num && lng is num) return LatLng(lat.toDouble(), lng.toDouble());
    return null;
  }

  Future<void> _directions(LatLng point) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${point.latitude},${point.longitude}',
    );
    try {
      if (!await canLaunchUrl(uri)) {
        _message(_t('길찾기 앱을 사용할 수 없습니다.', 'Directions app is unavailable.'));
        return;
      }
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _message(_t('길찾기 앱을 열지 못했습니다.', 'Could not open the directions app.'));
      }
    } catch (e) {
      debugPrint('Directions launch error: $e');
      _message(_t('길찾기 실행 중 오류가 발생했습니다.', 'An error occurred while launching directions.'));
    }
  }

  String get _modeKey {
    switch (_mode) {
      case OrqubeMapMode.airsoft:
        return 'airsoft';
      case OrqubeMapMode.safeHome:
        return 'safe_home';
      case OrqubeMapMode.safeHiking:
        return 'safe_hiking';
    }
  }

  String get _modeTitle {
    switch (_mode) {
      case OrqubeMapMode.airsoft:
        return _t('에어소프트 경기', 'Airsoft Match');
      case OrqubeMapMode.safeHome:
        return _t('안심귀가', 'Safe Return');
      case OrqubeMapMode.safeHiking:
        return _t('안전산행', 'Safe Hiking');
    }
  }

  String get _modeGuide {
    switch (_mode) {
      case OrqubeMapMode.airsoft:
        return _t('기존 경기장 지도, 장소 등록, 길찾기와 안전 기능을 그대로 사용합니다.', 'Use the existing field map, place registration, directions, and safety features.');
      case OrqubeMapMode.safeHome:
        return _t('사용자가 직접 시작한 경우에만 위치가 공유됩니다. 목적지·보호자 공유·예상 도착시간 기능을 확장할 수 있는 기본 구조입니다.', 'Location is shared only when the user starts it. This provides the base for destination, guardian sharing, and ETA features.');
      case OrqubeMapMode.safeHiking:
        return _t('안전산행은 산행 경로·귀환 계획을 기록합니다. 기기 우선 저장, 통신 복구 후 재전송, 동의한 보호자의 마지막 기록 조회, 경로 파일 내보내기를 제공합니다. 사용 순서와 통신두절 시 한계는 상세 안내에서 확인하세요.', 'When hiking starts, the device keeps showing the start point and GPS route. Even without Internet, a GPS fix lets you check coordinates, altitude, distance, and direction to the start.');
    }
  }

  Widget _modeSelector() => SizedBox.shrink();

  Widget _modeInformation() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
      color: Color(0xFF0D1020),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _mode == OrqubeMapMode.airsoft
                ? Icons.map_rounded
                : _mode == OrqubeMapMode.safeHome
                ? Icons.shield_rounded
                : Icons.terrain_rounded,
            color: _cyan,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  _modeTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 3),
                AppText(
                  _modeGuide,
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.45,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<LatLng?> _searchDestinationAddress(String query) async {
    final text = query.trim();
    if (text.isEmpty) return null;
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': text,
        'format': 'jsonv2',
        'limit': '1',
        'accept-language': OrqubeI18n.searchLanguageTag,
        'countrycodes': 'kr',
      });
      final response = await http
          .get(
            uri,
            headers:
                kIsWeb
                    ? {'Accept': 'application/json'}
                    : {
                      'User-Agent': 'ORQUBE/22.14 (contact: www.orqubic.com)',
                      'Accept': 'application/json',
                    },
          )
          .timeout(Duration(seconds: 12));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) return null;
      final first = decoded.first;
      if (first is! Map) return null;
      final lat = double.tryParse('${first['lat']}');
      final lon = double.tryParse('${first['lon']}');
      if (lat == null || lon == null) return null;
      _destinationAddress = '${first['display_name'] ?? text}';
      return LatLng(lat, lon);
    } catch (_) {
      return null;
    }
  }

  Future<void> _selectDestination() async {
    final position = _position ?? await _currentPosition();
    if (position == null || !mounted) return;
    final addressController = TextEditingController(
      text: _destinationAddress ?? '',
    );
    bool searching = false;
    String? errorText;

    final selected = await showDialog<LatLng>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  backgroundColor: _panel,
                  title: AppText(
                    _t('목적지 주소 검색', 'Search Destination'),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  content: SizedBox(
                    width: 430,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: addressController,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: _t('도로명·지번·장소명', 'Address or place'),
                            hintText: _t(
                              '예: 서울역, 대전시청',
                              'Example: Seoul Station',
                            ),
                            errorText: errorText,
                            prefixIcon: Icon(Icons.search_rounded),
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) async {
                            if (searching) return;
                            setDialogState(() {
                              searching = true;
                              errorText = null;
                            });
                            final point = await _searchDestinationAddress(
                              addressController.text,
                            );
                            if (!dialogContext.mounted) return;
                            if (point == null) {
                              setDialogState(() {
                                searching = false;
                                errorText = _t(
                                  '주소를 찾지 못했습니다.',
                                  'Address not found.',
                                );
                              });
                            } else {
                              Navigator.pop(dialogContext, point);
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        AppText(
                          _t(
                            '또는 창을 닫은 뒤 지도에서 목적지를 한 번 누르세요.',
                            'Or close this window and tap the destination on the map.',
                          ),
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12.5,
                          ),
                        ),
                        if (searching) ...[
                          SizedBox(height: 14),
                          LinearProgressIndicator(),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: AppText(_t('취소', 'Cancel')),
                    ),
                    FilledButton.icon(
                      onPressed:
                          searching
                              ? null
                              : () async {
                                setDialogState(() {
                                  searching = true;
                                  errorText = null;
                                });
                                final point = await _searchDestinationAddress(
                                  addressController.text,
                                );
                                if (!dialogContext.mounted) return;
                                if (point == null) {
                                  setDialogState(() {
                                    searching = false;
                                    errorText = _t(
                                      '주소를 찾지 못했습니다.',
                                      'Address not found.',
                                    );
                                  });
                                } else {
                                  Navigator.pop(dialogContext, point);
                                }
                              },
                      icon: Icon(Icons.place_rounded),
                      label: AppText(_t('검색·선택', 'Search')),
                    ),
                  ],
                ),
          ),
    );

    addressController.dispose();
    if (selected == null || !mounted) return;
    setState(() => _destination = selected);
    _moveLegacyMap(selected, 15);
    await _recalculateEta(position);
    _message(_t('목적지가 설정되었습니다.', 'Destination has been set.'));
  }

  bool _showTripMap = false;
  bool _startingTrip = false;
  void _moveLegacyMap(LatLng point, double zoom) {
    if (_showTripMap) return;
    try { _mapController.move(point,zoom); } catch (_) { /* The detail map may not yet be mounted. */ }
  }
  Future<void> _toggleModeSession() async {
    if (_startingTrip) return;
    if (_sessionStartedAt != null) {
      await _endModeSession();
      return;
    }
    if (_mode == OrqubeMapMode.airsoft) { await _startModeSession(); return; }
    setState(() => _startingTrip = true);
    try {
      if (_auth.currentUser == null) {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => HikingAccountPage()));
      }
      final user = _auth.currentUser;
      if (!mounted || user == null) return;
      final saved = _mode == OrqubeMapMode.safeHiking ? await HikingSearchRecord.read(user.uid) : null;
      if (!mounted) return;
      final setup = await Navigator.push<TripSetup>(context, MaterialPageRoute(builder: (_) => TripStartWizard(
        hiking: _mode == OrqubeMapMode.safeHiking,
        hasSavedRecord: saved != null && (saved['points'] as List? ?? []).isNotEmpty,
        destination: _destination, plannedReturn: _plannedReturnAt,
        searchAddress: (query) async {
          final previous = _destinationAddress;
          final result = await _searchDestinationAddress(query);
          _destinationAddress = previous;
          return result;
        },
      )));
      if (!mounted || setup == null || _auth.currentUser?.uid != user.uid) return;
      final prefs = await SharedPreferences.getInstance();
      final stored = await prefs.setString('trip_consent_v1_${user.uid}', jsonEncode({
        'version':'2.1', 'privacy':true, 'location':true, 'mode':_modeKey,
        'sharing':setup.share, 'searchViewers':setup.audience?.search.length ?? 0,
        'confirmedAt':DateTime.now().toUtc().toIso8601String(),
      }));
      if (!stored) throw StateError('Consent save failed');
      if (!mounted || _auth.currentUser?.uid != user.uid) return;
      setState(() {
        _destination = setup.destination; _destinationAddress = setup.destinationName;
        _plannedReturnAt = setup.plannedReturn;
        _guardianName = setup.audience?.names ?? ''; _guardianContact = '';
        _searchAudience = setup.audience?.search ?? {};
      });
      if (setup.resume && saved != null) {
        await _resumeSearchRecord(user.uid,saved,startPosition:setup.position);
        _guardianName = setup.audience?.names ?? '';
        _plannedReturnAt = setup.plannedReturn;
        _returnEta = setup.plannedReturn;
        await HikingSearchRecord.plan(user.uid,setup.plannedReturn);
      } else {
        await _startModeSession(startPosition:setup.position,skipRecovery:true,guided:true);
      }
      if (!mounted || _sessionStartedAt == null || _auth.currentUser?.uid != user.uid) return;
      setState(() => _showTripMap = true);
      if (setup.share && setup.audience != null) {
        if (!user.emailVerified) throw StateError('Email verification required');
        // Remove the previous trip's search record before granting a new audience.
        if (_mode == OrqubeMapMode.safeHiking && setup.audience!.search.isNotEmpty) {
          final ref = _db.collection('hiking_search_records').doc(user.uid);
          await ref.get(GetOptions(source:Source.server)).timeout(Duration(seconds:5));
          await ref.delete().timeout(Duration(seconds:5));
        }
        await PeopleService.setAudience(setup.audience!.live,setup.audience!.search);
        await _startSafetyShare(fromWizard:true,startPosition:setup.position);
      } else {
        unawaited(GuardianShare.stop().catchError((Object _) {}));
      }
    } catch (_) {
      if (mounted) _message(_sessionStartedAt == null ? '준비를 완료하지 못했습니다. 연결 상태와 권한을 확인한 뒤 다시 시작하세요.' : '이동 기록은 시작했지만 공유 설정은 확인하지 못했습니다. 공유 대상 변경 또는 위치 공유에서 다시 확인하세요.');
    } finally {
      if (mounted) setState(() { _startingTrip = false; if (_sessionStartedAt != null) _showTripMap = true; });
    }
  }

  Future<void> _resumeSearchRecord(String uid, Map<String,dynamic> saved, {Position? startPosition}) async {
    final points = (saved['points'] as List).cast<Map>();
    final position = startPosition ?? await _currentPosition();
    if (!mounted || position == null || _auth.currentUser?.uid != uid) return;
    await HikingSearchRecord.resume(uid);
    if (!mounted || _auth.currentUser?.uid != uid) return;
    setState(() {
      _sessionStartedAt = DateTime.parse(saved['startedAt'] as String).toLocal();
      _plannedReturnAt = DateTime.tryParse(saved['plannedReturnAt'] as String? ?? '')?.toLocal();
      _returnEta = _plannedReturnAt;
      _guardianName = saved['guardianName'] as String? ?? '';
      _routePoints.clear();
      _routePoints.addAll(points.skip(points.length > 4000 ? points.length - 4000 : 0)
        .map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble())));
      _hikeStartPoint = LatLng((points.first['lat'] as num).toDouble(), (points.first['lng'] as num).toDouble());
      _routeDistanceKm = 0;
      for (var i = 1; i < _routePoints.length; i++) { _routeDistanceKm += const Distance().as(LengthUnit.Meter, _routePoints[i-1], _routePoints[i]) / 1000; }
      _position = position; _routeRecording = true; _sharing = false;
    });
    await _startContinuousTracking('hiking_sessions', uid);
    if (mounted) _message('기록을 이어갑니다. 중단된 시간은 기록되지 않으며 위치 공유는 다시 동의해야 합니다.');
  }

  Future<void> _startModeSession({Position? startPosition, bool skipRecovery = false, bool guided = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      _message(_t('로그인 후 사용할 수 있습니다.', 'Please sign in to use this feature.'));
      return;
    }

    if (_mode == OrqubeMapMode.safeHiking && !skipRecovery) {
      final saved = await HikingSearchRecord.read(user.uid);
      if (!mounted) return;
      if (saved != null && (saved['points'] as List? ?? []).isNotEmpty) {
        final action = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
          title: AppText('저장된 산행 기록'),
          content: AppText('이전 기록을 이어가거나 새 산행을 시작할 수 있습니다. 새 산행은 이 기기의 이전 기록을 교체합니다. 필요한 경로를 먼저 내보내세요.'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: AppText('취소')),
            TextButton(onPressed: () => Navigator.pop(ctx, 'new'), child: AppText('새 산행 시작')),
            FilledButton(onPressed: () => Navigator.pop(ctx, 'resume'), child: AppText('기록 이어가기'))]));
        if (!mounted || _auth.currentUser?.uid != user.uid || action == null) return;
        if (action == 'resume') { await _resumeSearchRecord(user.uid, saved); return; }
      }
    }

    // 버튼을 누르는 즉시 로컬 활성 상태로 전환합니다. 안전산행의 핵심 GPS 기록은
    // 인터넷/Firestore 응답을 기다리지 않습니다.
    final epoch = _accountEpoch;
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _sessionStartedAt = now;
        _routeRecording = _mode != OrqubeMapMode.airsoft;
        _routePoints.clear();
        _routeDistanceKm = 0;
        _lastRouteSnapshotAt = null;
        if (_mode == OrqubeMapMode.safeHiking) _hikeStartPoint = null;
      });
    }

    final position = startPosition ?? await _currentPosition();
    if (position == null) {
      if (mounted) {
        setState(() {
          _sessionStartedAt = null;
          _routeRecording = false;
        });
      }
      return;
    }

    if (!mounted || epoch != _accountEpoch || _auth.currentUser?.uid != user.uid) return;
    final startPoint = LatLng(position.latitude, position.longitude);
    if (mounted) {
      setState(() {
        if (_mode == OrqubeMapMode.safeHiking) _hikeStartPoint = startPoint;
        _routePoints
          ..clear()
          ..add(startPoint);
        _routeDistanceKm = 0;
      });
    }

    // 목적지 ETA와 별도로 안전산행의 귀환 예정시간을 유지합니다.
    // 사용자가 미리 정하지 않은 경우에만 기존 안정본과 동일하게 4시간 뒤를 기본값으로 둡니다.
    await _recalculateEta(position);
    final savedReturn = _plannedReturnAt;
    final plannedReturn =
        _mode == OrqubeMapMode.safeHiking
            ? (savedReturn != null && savedReturn.isAfter(now)
                ? savedReturn
                : now.add(Duration(hours: 4)))
            : null;
    final eta = _mode == OrqubeMapMode.safeHiking ? plannedReturn : _returnEta;
    final collection =
        _mode == OrqubeMapMode.safeHome
            ? 'safe_home_sessions'
            : 'hiking_sessions';

    if (mounted) {
      setState(() {
        _sessionStartedAt = now;
        _returnEta = eta;
        if (_mode == OrqubeMapMode.safeHiking) {
          _plannedReturnAt = plannedReturn;
          _safeDescentReported = false;
        }
        _routeRecording = _mode != OrqubeMapMode.airsoft;
      });
    }

    if (_mode == OrqubeMapMode.safeHiking) {
      try {
        await HikingSearchRecord.start(user.uid, startedAt: now, plannedReturnAt: plannedReturn, guardianName: _guardianName);
        await HikingSearchRecord.append(user.uid, position);
      } catch (_) { if (mounted) _message('기기 저장 실패 · 저장 공간을 확인하세요.'); }
    }
    // GPS 스트림을 서버 저장보다 먼저 시작합니다.
    await _startContinuousTracking(collection, user.uid);

    var serverWriteAccepted = true;
    try {
      await _db.collection(collection).doc(user.uid).set({
        'uid': user.uid,
        'mode': _modeKey,
        'active': true,
        'startedAt': FieldValue.serverTimestamp(),
        'clientStartedAt': Timestamp.fromDate(now),
        'latitude': position.latitude,
        'longitude': position.longitude,
        if (_mode == OrqubeMapMode.safeHiking)
          'startLatitude': position.latitude,
        if (_mode == OrqubeMapMode.safeHiking)
          'startLongitude': position.longitude,
        if (_destination != null) 'destinationLat': _destination!.latitude,
        if (_destination != null) 'destinationLng': _destination!.longitude,
        if (eta != null) 'eta': Timestamp.fromDate(eta),
        if (_mode == OrqubeMapMode.safeHiking && plannedReturn != null)
          'plannedReturnAt': Timestamp.fromDate(plannedReturn),
        if (_mode == OrqubeMapMode.safeHiking) 'guardianName': _guardianName,
        if (_mode == OrqubeMapMode.safeHiking) 'guardianContact': _guardianContact,
        if (_mode == OrqubeMapMode.safeHiking) 'safeDescent': false,
        if (_mode == OrqubeMapMode.safeHiking) 'status': 'active',
        'stationaryAlert': _stationaryAlert,
        'routeDeviationAlert': _routeDeviationAlert,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(Duration(seconds: 4));
    } catch (_) {
      serverWriteAccepted = false;
    }

    _message(
      _mode == OrqubeMapMode.safeHome
          ? _t('안심귀가 이동 모드가 시작되었습니다.', 'Safe Return tracking has started.')
          : (serverWriteAccepted
              ? _t(
                  _t('안전산행 모드가 시작되었습니다. GPS 경로는 데이터 통신이 없어도 계속 기록됩니다.', 'Safe Hiking has started. GPS route recording continues without mobile data.'),
                  'Safe Hiking started. GPS route recording continues even without mobile data.',
                )
              : _t(
                  _t('안전산행 GPS 기록이 시작되었습니다. 현재 서버 통신이 원활하지 않아 공유는 지연될 수 있습니다.', 'Safe Hiking GPS recording has started. Sharing may be delayed because server connectivity is unstable.'),
                  'Safe Hiking GPS recording started. Server sharing may be delayed while offline.',
                )),
    );

    // 기존 자동 내비게이션 동작은 유지합니다. 외부 지도 앱이 오프라인이면
    // ORQUBE 화면으로 돌아와 기록된 경로와 출발점 정보를 사용할 수 있습니다.
    if (!guided) await _launchExternalNavigation();
  }

  Future<void> _launchExternalNavigation() async {
    final destination = _destination;
    if (destination == null) {
      _message(
        _t(
          _t('위치 추적은 시작되었습니다. 내비게이션을 사용하려면 먼저 목적지를 선택해 주세요.', 'Location tracking has started. Select a destination first to use navigation.'),
          'Tracking has started. Select a destination to open navigation.',
        ),
      );
      return;
    }

    final travelMode =
        _mode == OrqubeMapMode.safeHiking ? 'walking' : 'driving';
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}&travelmode=$travelMode',
    );

    try {
      if (!await canLaunchUrl(webUri)) {
        _message(_t('내비게이션 앱을 사용할 수 없습니다.', 'Navigation app is unavailable.'));
        return;
      }
      final opened = await launchUrl(
        webUri,
        mode:
            kIsWeb
                ? LaunchMode.platformDefault
                : LaunchMode.externalApplication,
      );
      if (!opened) {
        _message(
          _t('내비게이션 앱을 열 수 없습니다.', 'Unable to open the navigation app.'),
        );
      }
    } catch (e) {
      debugPrint('Navigation launch error: $e');
      _message(_t('내비게이션 실행 중 오류가 발생했습니다.', 'Failed to launch navigation.'));
    }
  }

  Future<void> _startContinuousTracking(String collection, String uid) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _trackingPollTimer?.cancel();
    _trackingPollTimer = null;
    _pollingPosition = false;

    // Flutter Web(모바일 브라우저 포함)에서는 AndroidSettings를 전달하면
    // 브라우저의 watchPosition 갱신이 멈추는 기기가 있습니다. 웹은 일반
    // LocationSettings를 사용하고, Android 앱에서만 foreground 설정을 사용합니다.
    final LocationSettings settings;
    if (kIsWeb) {
      settings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: Duration(seconds: 2),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: 'ORQUBE Safe Companion',
          notificationText: 'Trip recording active. Stop the trip in the app to end recording.',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    } else {
      settings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    }

    DateTime? lastAppliedAt;
    LatLng? lastAppliedPoint;

    Future<void> applyPosition(Position position) async {
      if (!mounted || _sessionStartedAt == null || _auth.currentUser?.uid != uid) return;

      if (_mode == OrqubeMapMode.safeHiking) {
        try { await HikingSearchRecord.append(uid, position); }
        catch (_) { if (mounted) _message('기기 저장 실패 · 저장 공간을 확인하세요.'); }
      }
      final point = LatLng(position.latitude, position.longitude);
      final movedMeters =
          lastAppliedPoint == null
              ? double.infinity
              : Distance().as(LengthUnit.Meter, lastAppliedPoint!, point);

      // 동일 좌표가 반복되더라도 일정 시간마다 화면과 서버 상태를 갱신합니다.
      final enoughTimePassed =
          lastAppliedAt == null ||
          DateTime.now().difference(lastAppliedAt!) >=
              Duration(seconds: 1);
      if (movedMeters < 0.2 && !enoughTimePassed) return;

      lastAppliedAt = DateTime.now();
      lastAppliedPoint = point;

      final routeStepMeters =
          _mode == OrqubeMapMode.safeHiking ? 5.0 : 1.0;
      final shouldAppendRoute =
          _routePoints.isEmpty ||
          Distance().as(LengthUnit.Meter, _routePoints.last, point) >=
              routeStepMeters;
      final segmentMeters =
          shouldAppendRoute && _routePoints.isNotEmpty
              ? Distance().as(LengthUnit.Meter, _routePoints.last, point)
              : 0.0;

      setState(() {
        _position = position;
        if (shouldAppendRoute) {
          _routePoints.add(point);
          _routeDistanceKm += segmentMeters / 1000.0;
          if (_routePoints.length > 4000) _routePoints.removeAt(0);
        }
      });

      // 현재 위치가 바뀔 때마다 지도 중심도 함께 이동합니다.
      _moveLegacyMap(point, 16);
      if (_sharing) {
        unawaited(GuardianShare.publish(position.latitude, position.longitude, _routePoints, _modeKey));
      }
      await _recalculateEta(position);

      try {
        await _db.collection(collection).doc(uid).set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'speed': position.speed,
          'heading': position.heading,
          'active': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        if (_sharing) {
          await _db.collection('airsoft_live_locations').doc(uid).set({
            'uid': uid,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
            'speed': position.speed,
            'heading': position.heading,
            if (_mode != OrqubeMapMode.airsoft)
              'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(hours: 24))),
            if (_mode == OrqubeMapMode.safeHiking) 'shareUntilSessionEnd': true,
            if (_mode == OrqubeMapMode.safeHiking) 'guardianName': _guardianName,
            if (_mode == OrqubeMapMode.safeHiking) 'guardianContact': _guardianContact,
            if (_mode == OrqubeMapMode.safeHiking && _plannedReturnAt != null)
              'plannedReturnAt': Timestamp.fromDate(_plannedReturnAt!),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (_) {}

      // 안전산행 경로는 5분 간격으로 현재 세션 문서에도 스냅샷을 남깁니다.
      // Android/iOS Firestore의 로컬 캐시가 활성화된 경우 통신 복구 후 동기화될 수
      // 있으며, 네트워크 실패가 GPS 화면 기록을 방해하지 않도록 비동기로 처리합니다.
      if (_mode == OrqubeMapMode.safeHiking && _routePoints.isNotEmpty) {
        final now = DateTime.now();
        if (_lastRouteSnapshotAt == null ||
            now.difference(_lastRouteSnapshotAt!) >= Duration(minutes: 5)) {
          _lastRouteSnapshotAt = now;
          final encodedRoute = _routePoints
              .map((p) =>
                  '${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}')
              .join(';');
          unawaited(
            _db
                .collection(collection)
                .doc(uid)
                .set({
                  'routeSnapshotEncoded': encodedRoute,
                  'routeDistanceKm': _routeDistanceKm,
                  'clientRouteSavedAt': Timestamp.fromDate(now),
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true))
                .timeout(Duration(seconds: 4))
                .catchError((_) {}),
          );
        }
      }
    }

    // 스트림은 세션이 끝날 때까지 끊지 않습니다. 이전 코드는 5초마다 스트림을
    // 취소하고 다시 연결해 일부 Samsung Internet/Chrome 기기에서 GPS watch가
    // 계속 초기화되는 문제가 있었습니다.
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (position) => unawaited(applyPosition(position)),
      onError: (Object error) {
        // 아래 보조 폴링이 계속 현재 위치를 요청합니다.
      },
      cancelOnError: false,
    );

    // 스트림 갱신이 느린 모바일 브라우저를 위한 보조 폴링입니다.
    // 스트림을 취소하지 않고 별도로 현재 좌표만 요청합니다.
    _trackingPollTimer = Timer.periodic(Duration(seconds: 3), (_) async {
      if (_pollingPosition || !mounted || _sessionStartedAt == null) return;
      _pollingPosition = true;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            timeLimit: Duration(seconds: 10),
          ),
        );
        await applyPosition(position);
      } catch (_) {
        // 다음 주기에 재시도합니다.
      } finally {
        _pollingPosition = false;
      }
    });
  }

  Future<void> _endModeSession() async {
    final user = _auth.currentUser;
    if (_mode == OrqubeMapMode.safeHiking && user != null) await HikingSearchRecord.stop(user.uid, finish: true);
    final collection =
        _mode == OrqubeMapMode.safeHome
            ? 'safe_home_sessions'
            : 'hiking_sessions';

    // 두 번째 클릭 즉시 버튼을 비활성 색상으로 되돌립니다.
    // Firestore나 위치 스트림 종료가 지연되어도 버튼이 흰색으로 고정되지 않습니다.
    if (mounted) {
      setState(() {
        _sessionStartedAt = null;
        _showTripMap = false;
        _returnEta = null;
        _remainingDistanceKm = null;
        _etaCalculating = false;
        _routeRecording = false;
        // 안전산행은 종료 후에도 화면을 나가기 전까지 마지막 경로와 출발점을
        // 남겨 두어 통신이 없는 상황에서 귀환 참고자료로 사용할 수 있게 합니다.
        if (_mode != OrqubeMapMode.safeHiking) {
          _routePoints.clear();
          _routeDistanceKm = 0;
        }
      });
    }

    _trackingPollTimer?.cancel();
    _trackingPollTimer = null;
    final subscription = _positionSubscription;
    _positionSubscription = null;
    await subscription?.cancel();

    if (_sharing) await _stopSafetyShare();

    if (user != null && _mode != OrqubeMapMode.airsoft) {
      try {
        final encodedRoute =
            _mode == OrqubeMapMode.safeHiking
                ? _routePoints
                    .map((p) =>
                        '${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}')
                    .join(';')
                : null;
        await _db.collection(collection).doc(user.uid).set({
          'active': false,
          if (_mode == OrqubeMapMode.safeHiking) 'sharingActive': false,
          if (_mode == OrqubeMapMode.safeHiking)
            'status': _safeDescentReported ? 'safe_completed' : 'ended',
          if (_mode == OrqubeMapMode.safeHiking) 'safeDescent': _safeDescentReported,
          'endedAt': FieldValue.serverTimestamp(),
          if (encodedRoute != null) 'routeSnapshotEncoded': encodedRoute,
          if (_mode == OrqubeMapMode.safeHiking)
            'routeDistanceKm': _routeDistanceKm,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(Duration(seconds: 4));
      } catch (_) {
        // 화면의 종료 상태는 유지하고 서버 저장 실패만 안내합니다.
        _message(
          _t(
            _t('화면 추적은 종료되었습니다. 서버 종료 기록은 네트워크 연결 후 다시 반영됩니다.', 'On-screen tracking has stopped. The server end record will sync after network connectivity returns.'),
            'Tracking stopped on this device. The server record will update when the network is available.',
          ),
        );
        return;
      }
    }
    _message(_t('안전 모드가 종료되었습니다.', 'Safety tracking has stopped.'));
  }

  Future<void> _recalculateEta(Position position) async {
    final destination = _destination;
    if (destination == null) {
      if (mounted) {
        setState(() {
          _remainingDistanceKm = null;
          if (_mode == OrqubeMapMode.safeHome) _returnEta = null;
        });
      }
      return;
    }

    if (mounted) setState(() => _etaCalculating = true);
    final meters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      destination.latitude,
      destination.longitude,
    );
    final distanceKm = meters / 1000.0;
    // 안심귀가는 평균 보행 4.5km/h, 안전산행은 평균 산행 3.0km/h 기준입니다.
    final speedKmh = _mode == OrqubeMapMode.safeHiking ? 3.0 : 4.5;
    final minutes = ((distanceKm / speedKmh) * 60).ceil().clamp(1, 24 * 60);
    final eta = DateTime.now().add(Duration(minutes: minutes));
    if (!mounted) return;
    setState(() {
      _remainingDistanceKm = distanceKm;
      _returnEta = eta;
      _etaCalculating = false;
    });
  }

  double? get _distanceFromHikeStartKm {
    final start = _hikeStartPoint;
    final position = _position;
    if (start == null || position == null) return null;
    return Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          start.latitude,
          start.longitude,
        ) /
        1000.0;
  }

  double? get _bearingToHikeStart {
    final start = _hikeStartPoint;
    final position = _position;
    if (start == null || position == null) return null;
    final bearing = Geolocator.bearingBetween(
      position.latitude,
      position.longitude,
      start.latitude,
      start.longitude,
    );
    return (bearing + 360) % 360;
  }

  String _compassDirection(double? bearing) {
    if (bearing == null) return '--';
    const names = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) ~/ 45) % 8;
    return names[index];
  }

  String get _elapsedHikeLabel {
    final started = _sessionStartedAt;
    if (started == null) return '--:--';
    final duration = DateTime.now().difference(started);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String get _coordinateLabel {
    final position = _position;
    if (position == null) return '--';
    return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
  }

  Future<void> _copyOfflineSafetyInfo() async {
    final position = _position;
    if (position == null) {
      _message(_t('먼저 현재 위치를 확인해 주세요.', 'Check your current location first.'));
      return;
    }
    final distance = _distanceFromHikeStartKm;
    final bearing = _bearingToHikeStart;
    final text = <String>[
      'ORQUBE SAFE HIKING',
      'GPS: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
      'Altitude: ${position.altitude.toStringAsFixed(0)}m',
      'Accuracy: ±${position.accuracy.toStringAsFixed(0)}m',
      'Recorded route: ${_routeDistanceKm.toStringAsFixed(2)}km',
      if (_hikeStartPoint != null)
        'Start GPS: ${_hikeStartPoint!.latitude.toStringAsFixed(6)}, ${_hikeStartPoint!.longitude.toStringAsFixed(6)}',
      if (distance != null)
        'Start point: ${distance.toStringAsFixed(2)}km / ${_compassDirection(bearing)} ${bearing!.toStringAsFixed(0)}°',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    _message(_t('오프라인 안전 정보를 복사했습니다.', 'Offline safety information copied.'));
  }

  Future<void> _returnToHikeStart() async {
    final start = _hikeStartPoint;
    if (start == null) {
      _message(_t('산행 시작 후 출발점이 자동 저장됩니다.', 'The start point is saved when hiking begins.'));
      return;
    }
    setState(() {
      _destination = start;
      _destinationAddress = _t('산행 출발점', 'Hiking start point');
    });
    final position = _position;
    if (position != null) await _recalculateEta(position);
    _moveLegacyMap(start, 15);
    _message(
      _t(
        '출발점을 귀환 기준점으로 설정했습니다. 청록색으로 기록된 실제 이동 경로를 참고하세요.',
        'The hiking start point is now the return reference. Follow the recorded cyan breadcrumb route.',
      ),
    );
  }

  String get _etaLabel {
    if (_etaCalculating) return _t('계산 중...', 'Calculating...');
    final eta = _returnEta;
    if (eta == null) {
      return _mode == OrqubeMapMode.safeHiking
          ? _t('귀환시간 미설정', 'Return time not set')
          : _t('목적지 미설정', 'Destination not set');
    }
    final h = eta.hour.toString().padLeft(2, '0');
    final m = eta.minute.toString().padLeft(2, '0');
    final distance = _remainingDistanceKm;
    if (distance == null) return '$h:$m';
    return '$h:$m · ${distance.toStringAsFixed(distance < 10 ? 1 : 0)}km';
  }

  Widget _safetyPanel() {
    if (_mode == OrqubeMapMode.airsoft) return SizedBox.shrink();
    final safeHome = _mode == OrqubeMapMode.safeHome;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      color: Color(0xFF090C18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                safeHome ? Icons.shield_rounded : Icons.terrain_rounded,
                color: _lime,
              ),
              SizedBox(width: 8),
              AppText(
                safeHome
                    ? _t('안심귀가 기능', 'Safe Return')
                    : _t('안전산행 기능', 'Safe Hiking'),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              AppText(
                'ETA $_etaLabel',
                style: TextStyle(
                  color: _cyan,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _miniAction(
                Icons.my_location_rounded,
                _t('현재 위치', 'Current Location'),
                () async {
                  await _currentPosition();
                },
              ),
              _miniAction(
                Icons.flag_rounded,
                _t('목적지 선택', 'Select Destination'),
                _selectDestination,
              ),
              _miniAction(
                safeHome ? Icons.directions_walk_rounded : Icons.hiking_rounded,
                _sessionStartedAt != null
                    ? (safeHome ? _t('이동 중', 'Moving') : _t('산행 중', 'Hiking'))
                    : (safeHome
                        ? _t('이동 시작', 'Start Moving')
                        : _t('산행 시작', 'Start Hiking')),
                _toggleModeSession,
                active: _sessionStartedAt != null,
              ),
              if (!safeHome)
                _miniAction(
                  Icons.person_pin_circle_rounded,
                  _guardianName.isEmpty
                      ? AppLanguage.t('내 사람·모임')
                      : AppLanguage.t('내 사람·모임'),
                  _configureGuardian,
                ),
              if (!safeHome)
                _miniAction(
                  Icons.schedule_rounded,
                  _plannedReturnAt == null
                      ? _t('귀환 예정시간', 'Return Time')
                      : _plannedReturnLabel(),
                  _selectPlannedReturnTime,
                ),
              _miniAction(
                Icons.share_location_rounded,
                safeHome
                    ? _t('보호자 공유', 'Share with Guardian')
                    : (_sharing
                        ? _t('공유 중', 'Sharing')
                        : _t('산행 종료까지 공유', 'Share Until Hike Ends')),
                _sharing ? _stopSafetyShare : _startSafetyShare,
                active: _sharing,
              ),
              if (!safeHome)
                _miniAction(
                  Icons.route_rounded,
                  _routeRecording
                      ? _t('경로 기록 중', 'Recording Route')
                      : _t('경로 기록', 'Record Route'),
                  _toggleModeSession,
                  active: _routeRecording,
                ),
              if (!safeHome)
                _miniAction(
                  Icons.verified_rounded,
                  _t('안전하게 하산했습니다', 'I Arrived Safely'),
                  _reportSafeDescent,
                  active: _safeDescentReported,
                ),
              _miniAction(Icons.sos_rounded, 'SOS', _sendSos, danger: true),
              _miniAction(
                Icons.stop_circle_outlined,
                _t('종료', 'Stop'),
                _endModeSession,
                danger: true,
              ),
            ],
          ),
          if (!safeHome) _offlineMapPrepCard(),
          if (!safeHome) _hikingSafetyPlanCard(),
          if (!safeHome) _offlineHikingCard(),
          SizedBox(height: 8),
          if (safeHome)
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: AppText(
                _t('장시간 정지 감지', 'Long Stop Detection'),
                style: TextStyle(color: Colors.white70),
              ),
              value: _stationaryAlert,
              onChanged: (v) => setState(() => _stationaryAlert = v),
              activeColor: _lime,
            )
          else
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: AppText(
                _t('경로 이탈 알림', 'Route Deviation Alert'),
                style: TextStyle(color: Colors.white70),
              ),
              value: _routeDeviationAlert,
              onChanged: (v) => setState(() => _routeDeviationAlert = v),
              activeColor: _lime,
            ),
        ],
      ),
    );
  }

  Widget _offlineMapPrepCard() {
    final saved = _offlineMapSnapshot != null;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cyan.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cyan.withValues(alpha: .55), width: 1.2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final status = Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: saved
                  ? _lime.withValues(alpha: .12)
                  : Colors.white.withValues(alpha: .05),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: saved
                    ? _lime.withValues(alpha: .45)
                    : Colors.white24,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  saved ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: saved ? _lime : Colors.white60,
                  size: 16,
                ),
                SizedBox(width: 6),
                AppText(
                  saved
                      ? '${_t('지도 저장됨', 'Map saved')} · $_offlineMapStatusLabel'
                      : _t('산행 전 저장 필요', 'Save before hiking'),
                  style: TextStyle(
                    color: saved ? _lime : Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );

          final saveButton = FilledButton.icon(
            onPressed: _savingOfflineMap ? null : _saveVisibleOfflineHikingMap,
            icon: _savingOfflineMap
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Icon(Icons.download_for_offline_rounded),
            label: AppText(
              _savingOfflineMap
                  ? _t('지도 저장 중...', 'Saving map...')
                  : _t('오프라인 지도 저장', 'Save Offline Map'),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _cyan,
              foregroundColor: Colors.black,
              minimumSize: Size(narrow ? double.infinity : 210, 46),
              textStyle: TextStyle(fontWeight: FontWeight.w900),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.download_for_offline_rounded, color: _cyan, size: 24),
                  SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          _t('산행 전 오프라인 지도 준비', 'Prepare Offline Map Before Hiking'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        AppText(
                          kIsWeb
                              ? _t(
                                  'Chrome에서는 위치와 화면을 확인할 수 있습니다. 실제 오프라인 지도 저장은 휴대폰 앱에서 실행하세요.',
                                  'Chrome can be used to check the screen and location. Save the actual offline map in the mobile app.',
                                )
                              : _t(
                                  '인터넷이 연결된 곳에서 필요한 산행 구간을 지도에 보이게 한 뒤 아래 버튼을 누르세요. 현재 보이는 범위가 휴대폰에 저장됩니다.',
                                  'While online, frame the hiking area you need on the map, then tap the button below. The visible area is saved on your phone.',
                                ),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.8,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (narrow) ...[
                status,
                SizedBox(height: 9),
                SizedBox(width: double.infinity, child: saveButton),
              ] else
                Row(
                  children: [
                    status,
                    Spacer(),
                    saveButton,
                  ],
                ),
              if (saved) ...[
                SizedBox(height: 8),
                AppText(
                  _t(
                    '저장 완료: 인터넷이 끊기면 저장 지도 위에 현재 GPS, 청록색 이동경로, 출발점이 계속 표시됩니다.',
                    'Saved: if Internet disconnects, current GPS, the cyan route, and the start point continue to appear over the saved map.',
                  ),
                  style: TextStyle(
                    color: _lime,
                    fontSize: 11.2,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _hikingSafetyPlanCard() {
    final guardianSet = _guardianName.isNotEmpty;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF131221),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _purple.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety_rounded, color: _lime, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: AppText(
                  _t('산행 안전 계획', 'Hiking Safety Plan'),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
              AppText(
                _sharing
                    ? _t('위치 공유 중', 'Sharing active')
                    : _t('공유 대기', 'Share ready'),
                style: TextStyle(
                  color: _sharing ? _lime : Colors.white54,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _offlineMetric(
                Icons.person_rounded,
                _t('보호자', 'Guardian'),
                guardianSet ? _guardianName : _t('미설정', 'Not set'),
              ),
              _offlineMetric(
                Icons.schedule_rounded,
                _t('귀환 예정', 'Planned Return'),
                _plannedReturnLabel(),
              ),
              _offlineMetric(
                Icons.share_location_rounded,
                _t('공유 방식', 'Sharing Mode'),
                _sharing
                    ? _t('산행 종료까지', 'Until hike ends')
                    : _t('사용자 시작 대기', 'Waiting to start'),
              ),
            ],
          ),
          SizedBox(height: 8),
          AppText(
            _t(
              '산행 종료 시 ‘안전하게 하산했습니다’를 누르면 위치 공유와 GPS 추적이 함께 종료되고 안전 하산 상태가 기록됩니다.',
              'At the end of the hike, tap “I Arrived Safely” to stop location sharing and GPS tracking together and record a safe completion.',
            ),
            style: TextStyle(color: Colors.white54, fontSize: 11.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _offlineHikingCard() {
    final position = _position;
    final startDistance = _distanceFromHikeStartKm;
    final bearing = _bearingToHikeStart;
    final startGuide =
        startDistance == null
            ? '--'
            : '${startDistance.toStringAsFixed(startDistance < 10 ? 2 : 1)}km · ${_compassDirection(bearing)} ${bearing!.toStringAsFixed(0)}°';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF101727),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cyan.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.offline_bolt_rounded, color: _cyan, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: AppText(
                  _t('오프라인 안전 정보', 'Offline Safety'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _lime.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _lime.withValues(alpha: .4)),
                ),
                child: AppText(
                  _t('GPS 사용', 'GPS READY'),
                  style: TextStyle(
                    color: _lime,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _offlineMetric(
                Icons.gps_fixed_rounded,
                _t('현재 좌표', 'Coordinates'),
                _coordinateLabel,
              ),
              _offlineMetric(
                Icons.height_rounded,
                _t('고도', 'Altitude'),
                position == null ? '--' : '${position.altitude.toStringAsFixed(0)}m',
              ),
              _offlineMetric(
                Icons.gps_not_fixed_rounded,
                _t('GPS 오차', 'GPS Accuracy'),
                position == null ? '--' : '±${position.accuracy.toStringAsFixed(0)}m',
              ),
              _offlineMetric(
                Icons.route_rounded,
                _t('기록 거리', 'Recorded'),
                '${_routeDistanceKm.toStringAsFixed(2)}km',
              ),
              _offlineMetric(
                Icons.flag_circle_rounded,
                _t('출발점 방향', 'Start Point'),
                startGuide,
              ),
              _offlineMetric(
                Icons.timer_outlined,
                _t('경과 시간', 'Elapsed'),
                _elapsedHikeLabel,
              ),
              _offlineMetric(
                Icons.map_rounded,
                _t('저장 지도', 'Saved Map'),
                _offlineMapStatusLabel,
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _returnToHikeStart,
                icon: Icon(Icons.assistant_navigation),
                label: AppText(_t('출발점 귀환', 'Return to Start')),
                style: OutlinedButton.styleFrom(foregroundColor: _lime),
              ),
              OutlinedButton.icon(
                onPressed: _copyOfflineSafetyInfo,
                icon: Icon(Icons.copy_all_rounded),
                label: AppText(_t('안전정보 복사', 'Copy Safety Info')),
                style: OutlinedButton.styleFrom(foregroundColor: _cyan),
              ),
              FilledButton.icon(
                onPressed: _savingOfflineMap ? null : _saveVisibleOfflineHikingMap,
                icon: _savingOfflineMap
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.download_for_offline_rounded),
                label: AppText(
                  _savingOfflineMap
                      ? _t('지도 저장 중...', 'Saving map...')
                      : _t('현재 지도 저장', 'Save Visible Map'),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _cyan,
                  foregroundColor: Colors.black,
                ),
              ),
              if (_offlineMapSnapshot != null)
                OutlinedButton.icon(
                  onPressed: _savingOfflineMap ? null : _deleteOfflineHikingMap,
                  icon: Icon(Icons.delete_outline_rounded),
                  label: AppText(_t('저장 지도 삭제', 'Delete Saved Map')),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                ),
            ],
          ),
          SizedBox(height: 8),
          AppText(
            _t(
              '산행 전에 지도를 원하는 범위로 이동·확대/축소한 뒤 ‘현재 지도 저장’을 누르세요. 저장된 지도는 앱 기기에 남아 인터넷이 끊겨도 배경으로 표시되고, 그 위에 현재 GPS·청록색 이동경로·출발점이 계속 갱신됩니다. 주소검색·원격 공유·SOS 서버 전달은 통신 복구 전까지 지연될 수 있습니다.',
              'Before hiking, pan and zoom to the area you need and tap “Save Visible Map”. The saved map remains on the device and is shown offline while current GPS, the cyan breadcrumb, and the start point keep updating above it. Address search, remote sharing, and SOS server delivery may wait for connectivity to return.',
            ),
            style: TextStyle(color: Colors.white54, fontSize: 11.5, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _offlineMetric(IconData icon, String label, String value) {
    return Container(
      width: 165,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: _cyan, size: 17),
          SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label, style: TextStyle(color: Colors.white54, fontSize: 10.5)),
                SizedBox(height: 2),
                AppText(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniAction(
    IconData icon,
    String label,
    Future<void> Function() action, {
    bool danger = false,
    bool active = false,
  }) {
    return OutlinedButton.icon(
      onPressed: action,
      icon: Icon(icon, size: 17),
      label: AppText(label),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            active ? _bg : (danger ? Colors.redAccent : Colors.white),
        backgroundColor: active ? Colors.white : Colors.transparent,
        side: BorderSide(
          color:
              active
                  ? Colors.white
                  : (danger
                      ? Colors.redAccent.withValues(alpha: .6)
                      : Colors.white24),
        ),
      ),
    );
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AppText(text)));
  }

  Future<void> _openAccount() async {
    if (_sessionStartedAt != null) await _endModeSession();
    if (_sharing) await _stopSafetyShare();
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => HikingAccountPage(onClearLocal: () async {
      await _offlineMapStore.delete();
      if (mounted) setState(() {
        _offlineMapSnapshot = null; _routePoints.clear(); _position = null;
        _hikeStartPoint = null; _guardianName = ''; _guardianContact = '';
        _plannedReturnAt = null;
      });
    })));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final current =
        _position == null
            ? null
            : LatLng(_position!.latitude, _position!.longitude);

    if (_showTripMap && _sessionStartedAt != null && _position != null) {
      final offline = _offlineMapSnapshot;
      final offlineImage = offline == null ? null : _offlineMapStore.imageProvider(offline);
      return ActiveTripMap(
        mode: _modeTitle, audience: _guardianName, current: current!,
        route: List<LatLng>.of(_routePoints), destination: _destination,
        start: _hikeStartPoint ?? (_routePoints.isEmpty ? null : _routePoints.first),
        startedAt: _sessionStartedAt!, observedAt: _position!.timestamp,
        plannedReturn: _mode == OrqubeMapMode.safeHiking ? _plannedReturnAt : null,
        distanceKm: _routeDistanceKm, accuracy: _position!.accuracy, sharing: _sharing,
        isHiking: _mode == OrqubeMapMode.safeHiking, preparing: _startingTrip,
        backgroundLayers: [if (_mode == OrqubeMapMode.safeHiking && offline != null && offlineImage != null)
          OverlayImageLayer(overlayImages:[OverlayImage(bounds:LatLngBounds(LatLng(offline.south,offline.west),LatLng(offline.north,offline.east)),imageProvider:offlineImage)])],
        onDetails: () => setState(() => _showTripMap = false),
        onAudience: () async { if (_sharing) { await _selectAudience(); } else { await _startSafetyShare(); } },
        onSos: _sendSos, onEnd: _endModeSession,
      );
    }
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: LayoutBuilder(
          builder:
              (context, constraints) => AppText(
                _t(
                  'ORQUBE $_modeTitle',
                  'ORQUBE $_modeTitle',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: MediaQuery.sizeOf(context).width < 600 ? 18 : 20,
                ),
              ),
        ),
        actions: [if (_sessionStartedAt != null) IconButton(tooltip:AppLanguage.t('이동 지도 보기'),onPressed:()=>setState(()=>_showTripMap=true),icon:Icon(Icons.map_outlined)), OrqubeDomainButton(), LanguageButton(),
          IconButton(tooltip: AppLanguage.t('보호자 연결 · 위치 확인'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GuardianPage())), icon: Icon(Icons.people_alt)),
          StreamBuilder<User?>(
            stream: _auth.userChanges(),
            builder: (context, snapshot) => TextButton.icon(
              onPressed: _openAccount,
              icon: Icon(Icons.account_circle_outlined, size: 20),
              label: AppText(_auth.currentUser == null ? '로그인' : '내 계정',
                style: TextStyle(fontWeight: FontWeight.w900)),
              style: TextButton.styleFrom(foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10)),
            ),
          ),

          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PublicHelpCenterPage(
                    language: OrqubeI18n.currentLanguage,
                  ),
                ),
              );
            },
            icon: Icon(Icons.menu_book_rounded, size: 19),
            label: AppText(
              _t('사용설명서', 'GUIDE'),
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: TextButton.styleFrom(
              foregroundColor: _lime,
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
          SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(10), child: ValueListenableBuilder<ShareDelivery>(
        valueListenable: GuardianShare.delivery,
        builder: (context, delivery, _) => AppText(!_sharing ? '위치 공유 상태: 공유 안 함' : delivery.failed ? '위치 전송 실패 · 인터넷과 위치 권한을 확인하세요.' : delivery.confirmedAt == null ? '위치 공유 상태: 서버 전송 확인 중' : '위치 공유 중 · 마지막 서버 저장: ${delivery.confirmedAt!.toLocal()}', style: const TextStyle(color: Colors.white, fontSize: 13)),
      ))),
      body: LayoutBuilder(
        builder: (context, viewport) {
          final mobile = viewport.maxWidth < 720;
          final mapHeight =
              mobile
                  ? (viewport.maxHeight * 0.62).clamp(420.0, 620.0)
                  : (viewport.maxHeight * 0.68).clamp(520.0, 820.0);
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                if (_startingTrip) Padding(padding: EdgeInsets.all(16), child: Column(children:[LinearProgressIndicator(),AppText('설정을 적용하고 있습니다. 잠시 기다려주세요.')])),
                Padding(padding: EdgeInsets.fromLTRB(16, 20, 16, 8), child: Container(
                  width: double.infinity, padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF123B50), Color(0xFF17233D)]), borderRadius: BorderRadius.circular(20)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AppText(_mode == OrqubeMapMode.safeHome ? '안전하게 귀가할 준비가 되셨나요?' : '산행을 시작할 준비가 되셨나요?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    AppText(_mode == OrqubeMapMode.safeHome ? '로그인 → 내 위치 확인 → 목적지 선택 → 귀가 시작. 승인된 보호자와 공유하려면 위치 공유를 켜주세요.' : '로그인 → 내 위치 확인 → 산행 시작. 승인된 보호자와 공유하려면 위치 공유를 켜주세요.', style: TextStyle(color: Colors.white70, height: 1.6)),
                    SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: _cyan, foregroundColor: Color(0xFF07111F), minimumSize: Size(200, 54)),
                      onPressed: _startingTrip ? null : _toggleModeSession,
                      icon: Icon(_sessionStartedAt == null ? Icons.hiking : Icons.stop_circle_outlined),
                      label: AppText(_sessionStartedAt == null ? AppLanguage.f('{mode} 시작', {'mode': _modeTitle}) : (_mode == OrqubeMapMode.safeHome ? '귀가 완료 · 종료' : '산행 종료'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                )),
                Padding(padding: EdgeInsets.all(12), child: Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AppText(_sessionStartedAt == null ? AppLanguage.f('{mode} 기록 • 시작 대기', {'mode': _modeTitle}) : AppLanguage.f('{mode} 기록 • 진행 중', {'mode': _modeTitle}), style: TextStyle(fontWeight: FontWeight.bold)),
                  AppText(_sharing ? '서버 위치 저장 • 활성 (전달·수신 확인과 다름)' : '서버 위치 공유 • 비활성'),
                  AppText(AppLanguage.f('공유 대상: {name} • 자동 알림 미지원', {'name': _guardianName.isEmpty ? AppLanguage.t('미설정') : _guardianName})),
                  AppText('개인 이동 기록은 본인 계정에 저장됩니다. 별도로 승인한 보호자는 위치 공유 중 현재 위치와 최근 경로를 볼 수 있습니다. 아래 문자·메신저 버튼은 현재 좌표를 직접 보내는 기능입니다.', style: TextStyle(height: 1.5)),
                  TextButton.icon(onPressed: _sharing ? _selectAudience : null, icon: Icon(Icons.people_alt_outlined), label: AppText('공유 대상 변경')),
                  TextButton.icon(onPressed: _position == null ? null : () => _shareGuardianStatus(completed: _sessionStartedAt == null), icon: Icon(Icons.share), label: AppText('보호자에게 현재 위치 직접 보내기')),
                ])))),
                if (_mode == OrqubeMapMode.safeHiking) Padding(padding: EdgeInsets.all(12), child: Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AppText('오프라인 기록 · 수색 참고자료', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HikingDetailedGuidePage())), icon: Icon(Icons.menu_book_outlined), label: AppText('안전산행 상세 안내')),
                  AppText('기기에 경로를 저장하고 동의한 자료는 통신 복구 후 재전송합니다. 앱 강제 종료 중에는 새 위치가 기록되지 않습니다.'),
                  ValueListenableBuilder<String>(valueListenable: HikingSearchRecord.status, builder: (_, value, __) => AppText(value)),
                  OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchRecordPage())), icon: Icon(Icons.route), label: AppText('저장된 기록과 내보내기')),
                ])))),
                _modeSelector(),
                _modeInformation(),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                  color: _panel,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 720;
                      final buttonWidth =
                          compact
                              ? (constraints.maxWidth - 8) / 2
                              : (constraints.maxWidth - 24) / 4;

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            width: buttonWidth,
                            child: _actionButton(
                              icon:
                                  _locating
                                      ? Icons.hourglass_top_rounded
                                      : Icons.my_location_rounded,
                              label: _locating ? _t('위치 확인 중', 'Locating...') : _t('내 위치', 'My Location'),
                              onPressed: _locating ? null : _currentPosition,
                              backgroundColor: _cyan,
                              foregroundColor: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: buttonWidth,
                            child: _actionButton(
                              icon: Icons.add_location_alt_rounded,
                              label:
                                  _mode == OrqubeMapMode.airsoft
                                      ? (_savingPlace ? _t('등록 중', 'Registering...') : _t('장소 등록', 'Register Place'))
                                      : (_destination == null
                                          ? _t('목적지 등록', 'Set Destination')
                                          : _t('목적지 변경', 'Change Destination')),
                              onPressed:
                                  _savingPlace
                                      ? null
                                      : () {
                                        if (_mode == OrqubeMapMode.airsoft) {
                                          _registerField();
                                        } else {
                                          _selectDestination();
                                        }
                                      },
                              backgroundColor: _purple,
                            ),
                          ),
                          SizedBox(
                            width: buttonWidth,
                            child: _actionButton(
                              icon:
                                  _sharing
                                      ? Icons.location_off_rounded
                                      : Icons.health_and_safety_rounded,
                              label: _sharing
                                  ? _t('공유 종료', 'Stop Sharing')
                                  : (_mode != OrqubeMapMode.airsoft
                                      ? _t('이동 종료까지 보호자 위치 공유', 'Share Until Trip Ends')
                                      : _t('30분 위치 공유', 'Share Location 30 min')),
                              onPressed:
                                  _sharing
                                      ? _stopSafetyShare
                                      : _startSafetyShare,
                              backgroundColor: Color(0xFF5D3BB5),
                            ),
                          ),
                          SizedBox(
                            width: buttonWidth,
                            child: _actionButton(
                              icon: Icons.sos_rounded,
                              label: _t('긴급 SOS', 'Emergency SOS'),
                              onPressed: _sendSos,
                              backgroundColor: Colors.redAccent,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  color: Color(0xFF111326),
                  child: AppText(
                    _mode == OrqubeMapMode.airsoft
                        ? _t('사용법: ‘내 위치’로 GPS 위치를 확인하고, ‘장소 등록’으로 경기장을 신청합니다. ‘30분 위치 공유’와 ‘긴급 SOS’는 기존 방식 그대로 작동합니다.', 'How to use: check your GPS with My Location and request a field with Register Place. 30-minute sharing and Emergency SOS work as before.')
                        : (_mode == OrqubeMapMode.safeHiking
                            ? _t('안전산행은 보호자와 귀환 예정시간을 설정한 뒤 ‘산행 시작’을 누를 수 있습니다. 위치 공유는 산행 종료까지 유지되며, 데이터 통신이 끊겨도 기기 GPS 경로 기록은 계속됩니다. 하산 후에는 ‘안전하게 하산했습니다’를 눌러 종료하세요.', 'In Safe Hiking, set a guardian and planned return time, then start the hike. Location sharing can stay active until the hike ends, while device GPS route recording continues even if data disconnects. Tap “I Arrived Safely” after descending.')
                            : _t('지도에서 원하는 지점을 누르거나 ‘목적지 등록’을 눌러 목적지를 지정할 수 있습니다. 위치 기능은 사용자가 직접 시작해야만 작동하며, 긴급 시에는 ‘긴급 SOS’를 사용하세요.', 'Tap a point on the map or Set Destination. Location features run only when you start them; use Emergency SOS when needed.')),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
                _safetyPanel(),
                SizedBox(
                  height: mapHeight,
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream:
                        _mode == OrqubeMapMode.airsoft
                            ? _db.collection('airsoft_places').snapshots()
                            : null,
                    builder: (context, snapshot) {
                      final markers = <Marker>[];
                      if (_mode == OrqubeMapMode.airsoft) {
                        for (final doc in snapshot.data?.docs ?? []) {
                          final data = doc.data();
                          final point = _latLng(data);
                          if (point == null) continue;
                          final name =
                              (data['name'] ?? 'AIRSOFT PLACE').toString();
                          markers.add(
                            Marker(
                              point: point,
                              width: 56,
                              height: 56,
                              child: Tooltip(
                                message: name,
                                child: GestureDetector(
                                  onTap: () => _showPlace(name, data, point),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _purple,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _lime,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black45,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.sports_mma_rounded,
                                      color: _lime,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }
                      if (_destination != null) {
                        markers.add(
                          Marker(
                            point: _destination!,
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.flag_circle_rounded,
                              color: _lime,
                              size: 46,
                            ),
                          ),
                        );
                      }
                      if (_mode == OrqubeMapMode.safeHiking &&
                          _hikeStartPoint != null) {
                        markers.add(
                          Marker(
                            point: _hikeStartPoint!,
                            width: 44,
                            height: 44,
                            child: Tooltip(
                              message: _t('산행 출발점', 'Hiking start point'),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _lime.withValues(alpha: .92),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: Icon(
                                  Icons.flag_outlined,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      if (current != null) {
                        markers.add(
                          Marker(
                            point: current,
                            width: 52,
                            height: 52,
                            child: Icon(
                              Icons.person_pin_circle_rounded,
                              color: _cyan,
                              size: 50,
                            ),
                          ),
                        );
                      }

                      final offlineSnapshot = _offlineMapSnapshot;
                      final offlineMapProvider =
                          offlineSnapshot == null
                              ? null
                              : _offlineMapStore.imageProvider(offlineSnapshot);

                      return Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter:
                                  current ?? LatLng(36.5, 127.8),
                              initialZoom: current == null ? 6.5 : 15,
                              maxZoom: 19,
                              onTap: (_, point) async {
                                if (_mode == OrqubeMapMode.airsoft) return;
                                setState(() {
                                  _destination = point;
                                  _destinationAddress = null;
                                });
                                final position = _position;
                                if (position != null) {
                                  if (_sharing) {
        unawaited(GuardianShare.publish(position.latitude, position.longitude, _routePoints, _modeKey));
      }
      await _recalculateEta(position);
                                }
                                _message(
                                  _t(
                                    _t(
                                      '선택한 지점이 목적지로 등록되었습니다.',
                                      'The selected point was set as the destination.',
                                    ),
                                    'The selected point is now the destination.',
                                  ),
                                );
                              },
                            ),
                            children: [
                              // 오프라인 저장 시 경로/현재위치가 사진에 굳지 않도록
                              // 배경 타일 레이어만 별도로 캡처합니다.
                              RepaintBoundary(
                                key: _offlineMapCaptureKey,
                                child: TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.orqube_app',
                                ),
                              ),
                              if (_mode == OrqubeMapMode.safeHiking &&
                                  offlineSnapshot != null &&
                                  offlineMapProvider != null)
                                OverlayImageLayer(
                                  overlayImages: [
                                    OverlayImage(
                                      bounds: LatLngBounds(
                                        LatLng(
                                          offlineSnapshot.south,
                                          offlineSnapshot.west,
                                        ),
                                        LatLng(
                                          offlineSnapshot.north,
                                          offlineSnapshot.east,
                                        ),
                                      ),
                                      imageProvider: offlineMapProvider,
                                    ),
                                  ],
                                ),
                              if (_routePoints.length >= 2)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: List<LatLng>.unmodifiable(
                                        _routePoints,
                                      ),
                                      strokeWidth: 5,
                                      color: _cyan,
                                    ),
                                  ],
                                ),
                              MarkerLayer(markers: markers),
                              RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution(
                                    'OpenStreetMap contributors',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (_mode == OrqubeMapMode.airsoft && snapshot.hasError)
                            Positioned(
                              left: 12,
                              right: 12,
                              top: 12,
                              child: _notice(
                                '${_t('경기장 정보를 불러오지 못했습니다:', 'Could not load field information:')} ${snapshot.error}',
                                Colors.redAccent,
                              ),
                            )
                          else if (_mode == OrqubeMapMode.airsoft &&
                              snapshot.connectionState == ConnectionState.waiting)
                            Positioned(
                              left: 12,
                              right: 12,
                              top: 12,
                              child: LinearProgressIndicator(),
                            )
                          else if (_mode == OrqubeMapMode.airsoft &&
                              (snapshot.data?.docs.isEmpty ?? true))
                            Positioned(
                              left: 12,
                              right: 12,
                              top: 12,
                              child: _notice(
                                _t('등록된 경기장이 없습니다. “경기장 등록”으로 첫 장소를 추가하세요.', 'No registered fields yet. Add the first place with Field Registration.'),
                                _purple,
                              ),
                            ),
                          if (_mode == OrqubeMapMode.safeHiking)
                            Positioned(
                              left: 12,
                              bottom: 14,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color(0xDD07101B),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _cyan.withValues(alpha: .45)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.gps_fixed_rounded, color: _cyan, size: 15),
                                    SizedBox(width: 6),
                                    AppText(
                                      _offlineMapSnapshot == null
                                          ? _t('청록색 = 실제 GPS 이동경로', 'Cyan = recorded GPS breadcrumb')
                                          : _t('저장 지도 + 청록색 GPS 이동경로', 'Saved map + cyan GPS breadcrumb'),
                                      style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_mode == OrqubeMapMode.safeHiking)
                            Positioned(
                              right: 14,
                              bottom: 82,
                              child: FloatingActionButton.small(
                                heroTag: 'map-save-offline',
                                tooltip: _t('현재 지도 저장', 'Save Visible Map'),
                                backgroundColor: _cyan,
                                foregroundColor: Colors.black,
                                onPressed: _savingOfflineMap ? null : _saveVisibleOfflineHikingMap,
                                child: _savingOfflineMap
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                    : Icon(Icons.download_for_offline_rounded),
                              ),
                            ),
                          Positioned(
                            right: 14,
                            bottom: 26,
                            child: FloatingActionButton.small(
                              heroTag: 'map-current-location',
                              backgroundColor: _panel,
                              foregroundColor: _cyan,
                              onPressed: _locating ? null : _currentPosition,
                              child: Icon(Icons.my_location_rounded),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    Color foregroundColor = Colors.white,
  }) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: Size(0, 42),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: AppText(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: MediaQuery.sizeOf(context).width < 600 ? 13.5 : 14,
        ),
      ),
    );
  }

  Widget _notice(String text, Color color) {
    return Material(
      color: color.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: AppText(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showPlace(String name, Map<String, dynamic> data, LatLng point) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panel,
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sports_mma_rounded, color: _lime),
                      SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  AppText(
                    (data['address'] ?? data['region'] ?? _t('주소 정보 없음', 'No address information'))
                        .toString(),
                    style: TextStyle(color: Colors.white70),
                  ),
                  if ((data['description'] ?? '').toString().isNotEmpty) ...[
                    SizedBox(height: 10),
                    AppText(
                      data['description'].toString(),
                      style: TextStyle(
                        color: Colors.white60,
                        height: 1.5,
                      ),
                    ),
                  ],
                  SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _directions(point);
                      },
                      icon: Icon(Icons.directions_rounded),
                      label: AppText(_t('이 경기장으로 길찾기', 'Directions to this Field')),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
