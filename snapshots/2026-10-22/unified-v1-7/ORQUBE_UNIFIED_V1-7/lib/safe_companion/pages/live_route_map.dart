import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/app_language.dart';
import '../utils/live_tracking.dart';
class LiveRouteMap extends StatefulWidget {
  final Map<String,dynamic> data;
  final bool cached;
  final DateTime now;
  const LiveRouteMap({super.key, required this.data, required this.cached, required this.now});
  @override State<LiveRouteMap> createState() => _LiveRouteMapState();
}
class _LiveRouteMapState extends State<LiveRouteMap> with SingleTickerProviderStateMixin {
  final map = MapController();
  late final AnimationController animation;
  LatLng? from, to;
  bool follow = true, ready = false;
  LatLng? point(Map<String,dynamic> data) {
    final lat = data['latitude'], lng = data['longitude'];
    if (lat is! num || lng is! num || !lat.isFinite || !lng.isFinite || lat.abs()>90 || lng.abs()>180) return null;
    return LatLng(lat.toDouble(), lng.toDouble());
  }
  TrackingFreshness get freshness => trackingFreshness(active: widget.data['active'] == true,
    now: widget.now, updatedAt: (widget.data['updatedAt'] as Timestamp?)?.toDate(),
    expiresAt: (widget.data['expiresAt'] as Timestamp?)?.toDate(), cached: widget.cached);
  LatLng? get displayed => from == null || to == null ? to : interpolateFix(from!, to!, animation.value);
  List<LatLng> get route => ((widget.data['route'] as List?) ?? []).whereType<GeoPoint>().map((p) => LatLng(p.latitude,p.longitude)).toList();
  @override void initState() {
    super.initState(); to = point(widget.data); from = to;
    animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..value = 1;
    animation.addListener(() {
      if (ready && follow && displayed != null && freshness == TrackingFreshness.fresh) {
        map.move(displayed!, map.camera.zoom);
      }
    });
  }
  @override void didUpdateWidget(covariant LiveRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = point(widget.data);
    if (next != null && (to == null || next.latitude != to!.latitude || next.longitude != to!.longitude)) {
      from = displayed ?? next; to = next;
      if (freshness == TrackingFreshness.fresh && const Distance().as(LengthUnit.Meter, from!, next) < 2000) {
        animation.forward(from: 0);
      } else { animation.value = 1; }
    }
    if (freshness != TrackingFreshness.fresh && animation.isAnimating) {
      animation.stop(); from = to; animation.value = 1;
    }
  }
  @override void dispose() { animation.dispose(); map.dispose(); super.dispose(); }
  void fitRoute() {
    if (!ready || to == null) return;
    final points = [...route, to!];
    if (points.length > 1 && points.any((p) => const Distance().as(LengthUnit.Meter, points.first, p) > 1)) {
      map.fitCamera(CameraFit.bounds(bounds: LatLngBounds.fromPoints(points), padding: const EdgeInsets.all(40), maxZoom: 17));
    } else { map.move(to!, 16); }
  }
  @override Widget build(BuildContext context) {
    final status = freshness;
    if (status == TrackingFreshness.expired || status == TrackingFreshness.stopped || to == null) {
      ready = false;
      return Card(child: Padding(padding: const EdgeInsets.all(24), child: AppText(status == TrackingFreshness.stopped ? '위치 공유가 종료되었습니다.' : '위치 공유가 만료되었습니다. 상대방의 공유 상태를 확인하세요.')));
    }
    final fresh = status == TrackingFreshness.fresh;
    final label = switch(status) {
      TrackingFreshness.fresh => '위치 갱신 중',
      TrackingFreshness.cached => '저장된 위치 · 서버 연결 확인 필요',
      _ => '위치 수신 지연 · 마지막 위치 표시',
    };
    final updated = (widget.data['updatedAt'] as Timestamp?)?.toDate();
    final age = updated == null ? null : widget.now.difference(updated).inSeconds.clamp(0, 999999);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        AppText('실시간 이동 지도', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Chip(avatar: Icon(fresh ? Icons.sensors : Icons.schedule, color: fresh ? Colors.green : Colors.orange), label: AppText(label)),
      ]),
      AppText(AppLanguage.f('마지막 서버 수신: {time}', {'time': updated?.toLocal().toString() ?? '—'})),
      if (age != null) Text('${age}s', style: const TextStyle(color: Color(0xFF52675D))),
      const SizedBox(height: 12),
      SizedBox(height: MediaQuery.sizeOf(context).width < 600 ? 360 : 460,
        child: ClipRRect(borderRadius: BorderRadius.circular(22), child: FlutterMap(
          mapController: map,
          options: MapOptions(initialCenter: to!, initialZoom: 16, onPositionChanged: (_, hasGesture) {
            if (hasGesture && follow) setState(() => follow = false);
          }, onMapReady: () { ready = true; if (!follow) fitRoute(); }),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.orqube.orqube_safe_hiking'),
            PolylineLayer(polylines: [Polyline(points: route, strokeWidth: 6, color: const Color(0xFF176BEE))]),
            if (route.isNotEmpty) MarkerLayer(markers: [Marker(point: route.first, child: const Icon(Icons.trip_origin, color: Color(0xFF176B53), size: 28))]),
            AnimatedBuilder(animation: animation, builder: (_, __) => MarkerLayer(markers: [Marker(point: displayed ?? to!, width: 52, height: 52, child: Container(decoration: BoxDecoration(color: fresh ? const Color(0xFF176B53) : Colors.orange.shade800, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]), child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 34)))])),
            const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
          ],
        ))),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        FilledButton.icon(onPressed: () { setState(() => follow = true); if (ready && displayed != null) map.move(displayed!, map.camera.zoom); }, icon: const Icon(Icons.my_location), label: AppText('상대방 따라가기')),
        OutlinedButton.icon(onPressed: () { setState(() => follow = false); fitRoute(); }, icon: const Icon(Icons.route), label: AppText('전체 경로 보기')),
      ]),
      AppText('파란 선은 최근 이동 경로입니다. 통신이 지연되면 마지막 좌표에서 멈춥니다.', style: const TextStyle(height: 1.6)),
    ]);
  }
}
