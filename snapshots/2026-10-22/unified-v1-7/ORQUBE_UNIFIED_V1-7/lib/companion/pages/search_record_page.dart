import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import '../services/hiking_search_record.dart';
import '../utils/app_language.dart';

class SearchRecordPage extends StatefulWidget {
  final String? targetUid;
  const SearchRecordPage({super.key, this.targetUid});
  @override State<SearchRecordPage> createState() => _SearchRecordPageState();
}
class _SearchRecordPageState extends State<SearchRecordPage> {
  Map<String,dynamic>? record;
  String error = '';
  Timer? timer;
  StreamSubscription<DocumentSnapshot<Map<String,dynamic>>>? subscription;
  DateTime? retainUntil;
  bool cached = false;
  @override void initState() { super.initState(); load(); timer = Timer.periodic(const Duration(seconds: 1), (_) {
    if (mounted && retainUntil != null && !DateTime.now().isBefore(retainUntil!)) setState(() { record = null; error = '수색 참고자료 조회가 만료되었습니다.'; });
  }); }
  Future<void> load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => error = '로그인이 필요합니다.'); return; }
    if (widget.targetUid == null) {
      final data = await HikingSearchRecord.read(uid);
      if (mounted) setState(() { record = data; error = data == null ? '저장된 산행 기록이 없습니다.' : ''; });
      return;
    }
    subscription = FirebaseFirestore.instance.collection('hiking_search_records').doc(widget.targetUid).snapshots(includeMetadataChanges: true).listen((row) {
      if (!mounted) return;
      final data = row.data();
      final until = (data?['retainUntil'] as Timestamp?)?.toDate();
      if (data == null || data['active'] != true || until == null || !DateTime.now().isBefore(until)) {
        setState(() { record = null; error = '공유된 수색 참고자료가 없거나 만료되었습니다.'; }); return;
      }
      final points = (data['route'] as List? ?? []).cast<Map>().map((p) => {
        'lat': p['latitude'], 'lng': p['longitude'], 'time': (p['observedAt'] as Timestamp).toDate().toUtc().toIso8601String(),
      }).toList();
      setState(() {
        cached = row.metadata.isFromCache; retainUntil = until;
        record = {'startedAt': (data['startedAt'] as Timestamp).toDate().toUtc().toIso8601String(),
          'plannedReturnAt': (data['plannedReturnAt'] as Timestamp?)?.toDate().toUtc().toIso8601String(),
          'points': points, 'droppedPoints': data['droppedPoints'], 'serverUpdatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toUtc().toIso8601String()};
        error = '';
      });
    }, onError: (Object _) { if (mounted) setState(() { record = null; error = '접근 권한 또는 통신을 확인하세요.'; }); });
  }
  @override void dispose() { timer?.cancel(); subscription?.cancel(); super.dispose(); }
  String labelTime(dynamic raw) => raw is String ? DateTime.tryParse(raw)?.toLocal().toString() ?? raw : '—';
  String summary(Map<String,dynamic> r) {
    final points = (r['points'] as List? ?? []).cast<Map>();
    final p = points.isEmpty ? null : points.last;
    return 'ORQUBE | SEARCH REFERENCE\nRecorded observations, not live tracking or automatic rescue dispatch.\n'
      'Trip start: ${r['startedAt']}\nPlanned return: ${r['plannedReturnAt']}\n'
      'Last GPS observation: ${p?['time']}\nLatitude: ${p?['lat']}\nLongitude: ${p?['lng']}\n'
      'Points in export: ${points.length}\nDiscarded earlier points: ${r['droppedPoints'] ?? 0}\n'
      'https://www.google.com/maps?q=${p?['lat']},${p?['lng']}\n';
  }
  Future<void> export() async {
    final r = record; if (r == null) return;
    try {
      final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(searchGeoJson(r)));
      await Share.shareXFiles([XFile.fromData(Uint8List.fromList(bytes), mimeType: 'application/geo+json', name: 'ORQUBE_search_route.geojson')],
        fileNameOverrides: ['ORQUBE_search_route.geojson'], text: summary(r));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AppText('파일 공유 실패 · 요약 복사를 이용하세요.')));
    }
  }
  @override Widget build(BuildContext context) {
    final r = record;
    final points = (r?['points'] as List? ?? []).cast<Map>();
    final route = points.map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble())).toList();
    return Theme(data: ThemeData(fontFamily: 'OrqubeHangul', useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B53)), scaffoldBackgroundColor: const Color(0xFFF4F7F5)),
      child: Scaffold(appBar: AppBar(title: AppText('산행 수색 참고자료'), actions: const [LanguageButton()]), body: ListView(padding: const EdgeInsets.all(20), children: [
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppText('마지막 기록 · 현재 위치 아님', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          AppText('통신두절 이후의 현재 위치는 알 수 없습니다. 아래 시간과 좌표는 마지막 GPS 기록입니다. 자동 구조 요청은 전송하지 않습니다.'),
          if (cached) AppText('저장된 자료 · 서버 연결 확인 필요'),
          if (error.isNotEmpty) AppText(error),
          if (r != null) ...[
            AppText('산행 시작'), Text(labelTime(r['startedAt'])),
            AppText('귀환 예정'), Text(labelTime(r['plannedReturnAt'])),
            AppText('마지막 GPS 기록'), Text(points.isEmpty ? '—' : labelTime(points.last['time'])),
            if (points.isNotEmpty) SelectableText('${points.last['lat']}, ${points.last['lng']}'),
            if (r['serverUpdatedAt'] != null) ...[AppText('마지막 서버 수신'), Text(labelTime(r['serverUpdatedAt']))],
            if (retainUntil != null) ...[AppText('보호자 조회 기한'), Text(retainUntil!.toLocal().toString())],
            AppText(AppLanguage.f('{count}개 관측점 · 이전 {dropped}개 삭제', {'count': '${points.length}', 'dropped': '${r['droppedPoints'] ?? 0}'})),
          ],
        ]))),
        if (route.isNotEmpty) SizedBox(height: 380, child: FlutterMap(key: ValueKey('${route.length}_${route.last}'), options: MapOptions(initialCenter: route.last, initialZoom: 15,
          initialCameraFit: route.length > 1 && route.any((p) => p != route.first) ? CameraFit.bounds(bounds: LatLngBounds.fromPoints(route), padding: const EdgeInsets.all(30), maxZoom: 17) : null), children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.orqube.orqube_safe_hiking'),
          PolylineLayer(polylines: [Polyline(points: route, color: Colors.orange.shade800, strokeWidth: 5)]),
          MarkerLayer(markers: [Marker(point: route.last, child: const Icon(Icons.location_on, size: 40, color: Colors.deepOrange))]),
          const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
        ])),
        if (r != null) ...[
          FilledButton.icon(onPressed: points.isEmpty ? null : export, icon: const Icon(Icons.file_download_outlined), label: AppText('경로 파일 내보내기')),
          OutlinedButton.icon(onPressed: () => Clipboard.setData(ClipboardData(text: summary(r))), icon: const Icon(Icons.copy), label: AppText('수색 요약 복사')),
          AppText('내보낸 파일은 앱에서 회수할 수 없습니다. 필요한 수색 담당자에게만 직접 전달하세요.'),
        ],
        if (widget.targetUid == null) ...[
          ValueListenableBuilder<String>(valueListenable: HikingSearchRecord.status, builder: (_, value, __) => AppText(value)),
          OutlinedButton(onPressed: () async {
            final uid = FirebaseAuth.instance.currentUser?.uid; if (uid == null) return;
            await HikingSearchRecord.retryFor(uid); await load();
          }, child: AppText('서버 반영 재시도')),
          TextButton(onPressed: () async {
            final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: AppText('기기 기록과 서버 자료 삭제'), content: AppText('서버 삭제가 완료되어야 기기 기록도 삭제합니다. 이미 내보낸 파일은 삭제되지 않습니다.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: AppText('취소')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: AppText('삭제'))]));
            final uid = FirebaseAuth.instance.currentUser?.uid; if (yes != true || uid == null) return;
            try { await HikingSearchRecord.eraseLocal(uid); await load(); }
            catch (_) { if (mounted) setState(() => error = '서버 삭제 대기 · 인터넷 연결 후 재시도하세요.'); }
          }, child: AppText('기기 기록과 서버 자료 삭제')),
        ],
      ])));
  }
}
