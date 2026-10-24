// ORQUBE V17.2.2 LOCATION BUTTON PATCH
// 내 위치·경기장 등록 버튼을 모든 화면 폭에서 항상 표시
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../utils/orqube_i18n.dart';

enum OrqubeMapMode { airsoft, safeHome, safeHiking }

class AirsoftMapPage extends StatefulWidget {
  final OrqubeMapMode initialMode;

  const AirsoftMapPage({super.key, this.initialMode = OrqubeMapMode.airsoft});

  @override
  State<AirsoftMapPage> createState() => _AirsoftMapPageState();
}

class _AirsoftMapPageState extends State<AirsoftMapPage> {
  String _t(String ko, String en) => OrqubeI18n.currentPair(ko, en);
  static const _bg = Color(0xFF03040B);
  static const _panel = Color(0xFF0A0B18);
  static const _purple = Color(0xFF8B2CF6);
  static const _lime = Color(0xFFD7FF35);
  static const _cyan = Color(0xFF39D9FF);

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _mapController = MapController();

  Position? _position;
  bool _locating = false;
  bool _sharing = false;
  bool _savingPlace = false;
  DateTime? _sharingUntil;
  Timer? _shareTimer;
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

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _shareTimer?.cancel();
    _positionSubscription?.cancel();
    _trackingPollTimer?.cancel();
    super.dispose();
  }

  Future<Position?> _currentPosition() async {
    if (mounted) setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _message('기기의 위치 서비스를 먼저 켜주세요.');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _message('현재 위치를 사용하려면 위치 권한이 필요합니다.');
        return null;
      }
      if (permission == LocationPermission.deniedForever) {
        _message('설정에서 ORQUBE의 위치 권한을 허용해주세요.');
        await Geolocator.openAppSettings();
        return null;
      }

      final result = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return result;
      setState(() => _position = result);
      _mapController.move(LatLng(result.latitude, result.longitude), 15);
      return result;
    } catch (e) {
      _message('현재 위치를 확인하지 못했습니다: $e');
      return null;
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _registerField() async {
    final user = _auth.currentUser;
    if (user == null) {
      _message('로그인 후 경기장을 등록할 수 있습니다.');
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
            title: const Text(
              '현재 위치를 경기장으로 등록',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(nameController, '경기장 이름', Icons.sports_mma_rounded),
                  const SizedBox(height: 12),
                  _field(addressController, '주소 또는 지역', Icons.place_rounded),
                  const SizedBox(height: 12),
                  _field(
                    descriptionController,
                    '시설 설명·주차·안전수칙',
                    Icons.description_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '위도 ${position.latitude.toStringAsFixed(6)}  ·  '
                    '경도 ${position.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.trim().length < 2) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('경기장 이름을 2자 이상 입력해주세요.')),
                    );
                    return;
                  }
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('등록'),
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
      _message('경기장이 등록되었습니다. 관리자 승인 전에는 등록자에게만 표시될 수 있습니다.');
    } on FirebaseException catch (e) {
      _message('경기장 등록 실패: ${e.message ?? e.code}');
    } catch (e) {
      _message('경기장 등록 실패: $e');
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: _cyan),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
      ),
    );
  }

  Future<void> _startSafetyShare() async {
    final user = _auth.currentUser;
    if (user == null) {
      _message('로그인 후 안전 위치 공유를 사용할 수 있습니다.');
      return;
    }
    final position = await _currentPosition();
    if (position == null || !mounted) return;

    final agreed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: _panel,
            title: const Text(
              '안전 위치 공유',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              '현재 위치를 30분 동안 운영자와 허용된 안전 담당자에게 공유합니다. '
              '상대 팀 추적에는 사용할 수 없으며 언제든 종료할 수 있습니다.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('동의하고 시작'),
              ),
            ],
          ),
    );
    if (agreed != true) return;

    final until = DateTime.now().add(const Duration(minutes: 30));
    await _db.collection('airsoft_live_locations').doc(user.uid).set({
      'uid': user.uid,
      'displayName': user.displayName ?? user.email ?? 'ORQUBE USER',
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'shareMode': _modeKey,
      'emergency': false,
      'updatedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(until),
    });

    _shareTimer?.cancel();
    _shareTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _refreshShare(),
    );
    if (!mounted) return;
    setState(() {
      _sharing = true;
      _sharingUntil = until;
    });
    _message('$_modeTitle 안전 위치 공유가 30분 동안 시작되었습니다.');
  }

  Future<void> _refreshShare() async {
    if (!_sharing || _sharingUntil == null) return;
    if (DateTime.now().isAfter(_sharingUntil!)) {
      await _stopSafetyShare();
      return;
    }
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _db.collection('airsoft_live_locations').doc(user.uid).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _stopSafetyShare() async {
    final user = _auth.currentUser;
    _shareTimer?.cancel();
    if (user != null) {
      await _db.collection('airsoft_live_locations').doc(user.uid).delete();
    }
    if (!mounted) return;
    setState(() {
      _sharing = false;
      _sharingUntil = null;
    });
    _message('안전 위치 공유가 종료되었습니다.');
  }

  Future<void> _sendSos() async {
    final user = _auth.currentUser;
    if (user == null) {
      _message('로그인 후 SOS를 사용할 수 있습니다.');
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
                const ListTile(
                  title: Text(
                    '긴급 상황 선택',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    '현재 위치가 안전 담당자에게 전달됩니다.',
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
                    leading: const Icon(
                      Icons.sos_rounded,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      value,
                      style: const TextStyle(color: Colors.white),
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
            title: const Text(
              'SOS 전송 확인',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              '“$type” 상황으로 현재 위치를 긴급 전송합니다.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('취소'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('SOS 전송'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

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
    });
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
        DateTime.now().add(const Duration(hours: 2)),
      ),
    });
    _message('SOS가 접수되었습니다. 안전한 장소에서 운영자의 연락을 기다려주세요.');
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
        _message('길찾기 앱을 사용할 수 없습니다.');
        return;
      }
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _message('길찾기 앱을 열지 못했습니다.');
      }
    } catch (e) {
      debugPrint('Directions launch error: $e');
      _message('길찾기 실행 중 오류가 발생했습니다.');
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
        return '에어소프트 경기';
      case OrqubeMapMode.safeHome:
        return '안심귀가';
      case OrqubeMapMode.safeHiking:
        return '안전산행';
    }
  }

  String get _modeGuide {
    switch (_mode) {
      case OrqubeMapMode.airsoft:
        return '기존 경기장 지도, 장소 등록, 길찾기와 안전 기능을 그대로 사용합니다.';
      case OrqubeMapMode.safeHome:
        return '사용자가 직접 시작한 경우에만 위치가 공유됩니다. 목적지·보호자 공유·예상 도착시간 기능을 확장할 수 있는 기본 구조입니다.';
      case OrqubeMapMode.safeHiking:
        return '사용자가 직접 시작한 경우에만 위치가 공유됩니다. 산행 경로·예상 귀환시간·경로 이탈 안내 기능을 확장할 수 있는 기본 구조입니다.';
    }
  }

  Widget _modeSelector() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF111326),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<OrqubeMapMode>(
          segments: const [
            ButtonSegment(
              value: OrqubeMapMode.airsoft,
              icon: Icon(Icons.sports_mma_rounded),
              label: Text('에어소프트'),
            ),
            ButtonSegment(
              value: OrqubeMapMode.safeHome,
              icon: Icon(Icons.home_rounded),
              label: Text('안심귀가'),
            ),
            ButtonSegment(
              value: OrqubeMapMode.safeHiking,
              icon: Icon(Icons.hiking_rounded),
              label: Text('안전산행'),
            ),
          ],
          selected: {_mode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            setState(() => _mode = selection.first);
          },
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.black
                      : Colors.white70,
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected)
                      ? _lime
                      : Colors.white.withValues(alpha: 0.04),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      color: const Color(0xFF0D1020),
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _modeTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _modeGuide,
                  style: const TextStyle(
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
        'accept-language': 'ko',
        'countrycodes': 'kr',
      });
      final response = await http
          .get(
            uri,
            headers:
                kIsWeb
                    ? const {'Accept': 'application/json'}
                    : const {
                      'User-Agent': 'ORQUBE/22.14 (contact: www.orqubic.com)',
                      'Accept': 'application/json',
                    },
          )
          .timeout(const Duration(seconds: 12));
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
                  title: Text(
                    _t('목적지 주소 검색', 'Search Destination'),
                    style: const TextStyle(
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: _t('도로명·지번·장소명', 'Address or place'),
                            hintText: _t(
                              '예: 서울역, 대전시청',
                              'Example: Seoul Station',
                            ),
                            errorText: errorText,
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: const OutlineInputBorder(),
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
                        const SizedBox(height: 12),
                        Text(
                          _t(
                            '또는 창을 닫은 뒤 지도에서 목적지를 한 번 누르세요.',
                            'Or close this window and tap the destination on the map.',
                          ),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12.5,
                          ),
                        ),
                        if (searching) ...[
                          const SizedBox(height: 14),
                          const LinearProgressIndicator(),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(_t('취소', 'Cancel')),
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
                      icon: const Icon(Icons.place_rounded),
                      label: Text(_t('검색·선택', 'Search')),
                    ),
                  ],
                ),
          ),
    );

    addressController.dispose();
    if (selected == null || !mounted) return;
    setState(() => _destination = selected);
    _mapController.move(selected, 15);
    await _recalculateEta(position);
    _message(_t('목적지가 설정되었습니다.', 'Destination has been set.'));
  }

  Future<void> _toggleModeSession() async {
    if (_sessionStartedAt != null) {
      await _endModeSession();
      return;
    }
    await _startModeSession();
  }

  Future<void> _startModeSession() async {
    final user = _auth.currentUser;
    if (user == null) {
      _message(_t('로그인 후 사용할 수 있습니다.', 'Please sign in to use this feature.'));
      return;
    }

    // 누르는 즉시 활성 상태를 표시하고, 위치 추적 준비가 실패하면 원상 복귀합니다.
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _sessionStartedAt = now;
        _routeRecording = _mode == OrqubeMapMode.safeHiking;
        _routePoints.clear();
      });
    }

    final position = await _currentPosition();
    if (position == null) {
      if (mounted)
        setState(() {
          _sessionStartedAt = null;
          _routeRecording = false;
        });
      return;
    }

    // 목적지가 있으면 현재 위치와의 거리로 ETA를 계산합니다.
    // 목적지가 없는 안전산행은 기본 귀환 예정시간을 4시간 뒤로 설정합니다.
    await _recalculateEta(position);
    final eta =
        _returnEta ??
        (_mode == OrqubeMapMode.safeHiking
            ? now.add(const Duration(hours: 4))
            : null);
    final collection =
        _mode == OrqubeMapMode.safeHome
            ? 'safe_home_sessions'
            : 'hiking_sessions';
    await _db.collection(collection).doc(user.uid).set({
      'uid': user.uid,
      'mode': _modeKey,
      'active': true,
      'startedAt': FieldValue.serverTimestamp(),
      'latitude': position.latitude,
      'longitude': position.longitude,
      if (_destination != null) 'destinationLat': _destination!.latitude,
      if (_destination != null) 'destinationLng': _destination!.longitude,
      if (eta != null) 'eta': Timestamp.fromDate(eta),
      'stationaryAlert': _stationaryAlert,
      'routeDeviationAlert': _routeDeviationAlert,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (!mounted) return;
    setState(() {
      _sessionStartedAt = now;
      _returnEta = eta;
      _routeRecording = _mode == OrqubeMapMode.safeHiking;
    });
    await _startContinuousTracking(collection, user.uid);
    _message(
      _mode == OrqubeMapMode.safeHome
          ? _t('안심귀가 이동 모드가 시작되었습니다.', 'Safe Return tracking has started.')
          : _t('안전산행 모드가 시작되었습니다.', 'Safe Hiking tracking has started.'),
    );
    await _launchExternalNavigation();
  }

  Future<void> _launchExternalNavigation() async {
    final destination = _destination;
    if (destination == null) {
      _message(
        _t(
          '위치 추적은 시작되었습니다. 내비게이션을 사용하려면 먼저 목적지를 선택해 주세요.',
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
      settings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 2),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'ORQUBE 안전 위치 추적',
          notificationText: '안심귀가 또는 안전산행 위치를 기록하고 있습니다.',
          enableWakeLock: true,
        ),
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    }

    DateTime? lastAppliedAt;
    LatLng? lastAppliedPoint;

    Future<void> applyPosition(Position position) async {
      if (!mounted || _sessionStartedAt == null) return;

      final point = LatLng(position.latitude, position.longitude);
      final movedMeters =
          lastAppliedPoint == null
              ? double.infinity
              : const Distance().as(LengthUnit.Meter, lastAppliedPoint!, point);

      // 동일 좌표가 반복되더라도 일정 시간마다 화면과 서버 상태를 갱신합니다.
      final enoughTimePassed =
          lastAppliedAt == null ||
          DateTime.now().difference(lastAppliedAt!) >=
              const Duration(seconds: 1);
      if (movedMeters < 0.2 && !enoughTimePassed) return;

      lastAppliedAt = DateTime.now();
      lastAppliedPoint = point;

      setState(() {
        _position = position;
        if (_routePoints.isEmpty ||
            const Distance().as(LengthUnit.Meter, _routePoints.last, point) >=
                1) {
          _routePoints.add(point);
          if (_routePoints.length > 2000) _routePoints.removeAt(0);
        }
      });

      // 현재 위치가 바뀔 때마다 지도 중심도 함께 이동합니다.
      _mapController.move(point, 16);
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
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
            'speed': position.speed,
            'heading': position.heading,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (_) {}
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
    _trackingPollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_pollingPosition || !mounted || _sessionStartedAt == null) return;
      _pollingPosition = true;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
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
    final collection =
        _mode == OrqubeMapMode.safeHome
            ? 'safe_home_sessions'
            : 'hiking_sessions';

    // 두 번째 클릭 즉시 버튼을 비활성 색상으로 되돌립니다.
    // Firestore나 위치 스트림 종료가 지연되어도 버튼이 흰색으로 고정되지 않습니다.
    if (mounted) {
      setState(() {
        _sessionStartedAt = null;
        _returnEta = null;
        _remainingDistanceKm = null;
        _etaCalculating = false;
        _routeRecording = false;
        _routePoints.clear();
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
        await _db.collection(collection).doc(user.uid).set({
          'active': false,
          'endedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // 화면의 종료 상태는 유지하고 서버 저장 실패만 안내합니다.
        _message(
          _t(
            '화면 추적은 종료되었습니다. 서버 종료 기록은 네트워크 연결 후 다시 반영됩니다.',
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
    if (_mode == OrqubeMapMode.airsoft) return const SizedBox.shrink();
    final safeHome = _mode == OrqubeMapMode.safeHome;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF090C18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                safeHome ? Icons.shield_rounded : Icons.terrain_rounded,
                color: _lime,
              ),
              const SizedBox(width: 8),
              Text(
                safeHome
                    ? _t('안심귀가 기능', 'Safe Return')
                    : _t('안전산행 기능', 'Safe Hiking'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                'ETA $_etaLabel',
                style: const TextStyle(
                  color: _cyan,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
              _miniAction(
                Icons.share_location_rounded,
                safeHome
                    ? _t('보호자 공유', 'Share with Guardian')
                    : _t('위치 공유', 'Share Location'),
                _sharing ? _stopSafetyShare : _startSafetyShare,
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
              _miniAction(Icons.sos_rounded, 'SOS', _sendSos, danger: true),
              _miniAction(
                Icons.stop_circle_outlined,
                _t('종료', 'Stop'),
                _endModeSession,
                danger: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (safeHome)
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
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
              title: Text(
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
      label: Text(label),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final current =
        _position == null
            ? null
            : LatLng(_position!.latitude, _position!.longitude);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: LayoutBuilder(
          builder:
              (context, constraints) => Text(
                _t(
                  '에어소프트 경기 · 안심귀가 · 안전산행',
                  'Airsoft · Safe Return · Safe Hiking',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: MediaQuery.sizeOf(context).width < 600 ? 18 : 20,
                ),
              ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, viewport) {
          final mobile = viewport.maxWidth < 720;
          final mapHeight =
              mobile
                  ? (viewport.maxHeight * 0.62).clamp(420.0, 620.0)
                  : (viewport.maxHeight * 0.68).clamp(520.0, 820.0);
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                _modeSelector(),
                _modeInformation(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                              label: _locating ? '위치 확인 중' : '내 위치',
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
                                      ? (_savingPlace ? '등록 중' : '장소 등록')
                                      : (_destination == null
                                          ? '목적지 등록'
                                          : '목적지 변경'),
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
                              label: _sharing ? '공유 종료' : '30분 위치 공유',
                              onPressed:
                                  _sharing
                                      ? _stopSafetyShare
                                      : _startSafetyShare,
                              backgroundColor: const Color(0xFF5D3BB5),
                            ),
                          ),
                          SizedBox(
                            width: buttonWidth,
                            child: _actionButton(
                              icon: Icons.sos_rounded,
                              label: '긴급 SOS',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  color: const Color(0xFF111326),
                  child: Text(
                    _mode == OrqubeMapMode.airsoft
                        ? '사용법: ‘내 위치’로 GPS 위치를 확인하고, ‘장소 등록’으로 경기장을 신청합니다. ‘30분 위치 공유’와 ‘긴급 SOS’는 기존 방식 그대로 작동합니다.'
                        : '지도에서 원하는 지점을 누르거나 ‘목적지 등록’을 눌러 목적지를 지정할 수 있습니다. 위치 기능은 사용자가 직접 시작해야만 작동하며, 긴급 시에는 ‘긴급 SOS’를 사용하세요.',
                    style: const TextStyle(
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
                    stream: _db.collection('airsoft_places').snapshots(),
                    builder: (context, snapshot) {
                      final markers = <Marker>[];
                      if (_mode == OrqubeMapMode.airsoft) {
                        for (final doc in snapshot.data?.docs ?? const []) {
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
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black45,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
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
                            child: const Icon(
                              Icons.flag_circle_rounded,
                              color: _lime,
                              size: 46,
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
                            child: const Icon(
                              Icons.person_pin_circle_rounded,
                              color: _cyan,
                              size: 50,
                            ),
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter:
                                  current ?? const LatLng(36.5, 127.8),
                              initialZoom: current == null ? 6.5 : 15,
                              maxZoom: 19,
                              onTap: (_, point) async {
                                if (_mode == OrqubeMapMode.airsoft) return;
                                setState(() {
                                  _destination = point;
                                  _destinationAddress = null;
                                });
                                final position = _position;
                                if (position != null)
                                  await _recalculateEta(position);
                                _message(
                                  _t(
                                    '선택한 지점이 목적지로 등록되었습니다.',
                                    'The selected point is now the destination.',
                                  ),
                                );
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.orqube_app',
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
                              const RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution(
                                    'OpenStreetMap contributors',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (snapshot.hasError)
                            Positioned(
                              left: 12,
                              right: 12,
                              top: 12,
                              child: _notice(
                                '경기장 정보를 불러오지 못했습니다: ${snapshot.error}',
                                Colors.redAccent,
                              ),
                            )
                          else if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const Positioned(
                              left: 12,
                              right: 12,
                              top: 12,
                              child: LinearProgressIndicator(),
                            )
                          else if ((snapshot.data?.docs.isEmpty ?? true))
                            Positioned(
                              left: 12,
                              right: 12,
                              top: 12,
                              child: _notice(
                                '등록된 경기장이 없습니다. “경기장 등록”으로 첫 장소를 추가하세요.',
                                _purple,
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
                              child: const Icon(Icons.my_location_rounded),
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
        minimumSize: const Size(0, 42),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: Text(
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Text(
          text,
          style: const TextStyle(
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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sports_mma_rounded, color: _lime),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (data['address'] ?? data['region'] ?? '주소 정보 없음')
                        .toString(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if ((data['description'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      data['description'].toString(),
                      style: const TextStyle(
                        color: Colors.white60,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _directions(point);
                      },
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('이 경기장으로 길찾기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
