import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/guardian_share.dart';
import '../utils/app_language.dart';
import '../utils/trip_metrics.dart';
import 'companion_theme.dart';

/// Uses the owner's existing GPS session. Opening/closing this view never starts
/// another stream or changes the sharing audience.
class ActiveTripMap extends StatefulWidget {
  final String mode, audience;
  final LatLng current;
  final List<LatLng> route;
  final LatLng? destination, start;
  final DateTime startedAt, observedAt;
  final DateTime? plannedReturn;
  final double distanceKm, accuracy;
  final bool sharing, isHiking, preparing;
  final List<Widget> backgroundLayers;
  final VoidCallback onDetails;
  final Future<void> Function() onSos, onEnd, onAudience;
  const ActiveTripMap({super.key, required this.mode, required this.audience,
    required this.current, required this.route, this.destination, this.start,
    required this.startedAt, required this.observedAt, this.plannedReturn,
    required this.distanceKm, required this.accuracy, required this.sharing, this.isHiking=false, this.preparing=false,
    this.backgroundLayers = const [], required this.onDetails, required this.onSos,
    required this.onEnd, required this.onAudience});
  @override State<ActiveTripMap> createState() => _ActiveTripMapState();
}
class _ActiveTripMapState extends State<ActiveTripMap> with LanguageAware<ActiveTripMap> {
  final map = MapController();
  bool follow = true, ready = false, busy = false;
  Timer? clock;
  @override void initState() { super.initState(); clock = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); }); }
  @override void dispose() { clock?.cancel(); map.dispose(); super.dispose(); }
  @override void didUpdateWidget(covariant ActiveTripMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (ready && follow && widget.current != oldWidget.current) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ready && follow) map.move(widget.current, map.camera.zoom);
      });
    }
  }
  bool get locked => busy || widget.preparing;
  String time(DateTime value) {
    final local = value.toLocal();
    return '${local.month}/${local.day} ${local.hour.toString().padLeft(2,'0')}:${local.minute.toString().padLeft(2,'0')}:${local.second.toString().padLeft(2,'0')}';
  }
  Future<void> action(Future<void> Function() callback) async {
    if (locked) return;
    setState(() => busy = true);
    try { await callback(); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AppText('처리하지 못했습니다. 연결 상태를 확인하고 다시 시도하세요.'))); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> end() async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: AppText('이동을 종료할까요?'), content: AppText('이 기기의 이동 기록과 위치 공유를 종료합니다. 오프라인이면 서버 반영이 지연될 수 있습니다.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx,false), child: AppText('취소')), FilledButton(onPressed: () => Navigator.pop(ctx,true), child: AppText('이동 종료'))],
    ));
    if (yes == true && mounted) await action(widget.onEnd);
  }
  void fit() {
    if (!ready) return;
    final points = [...widget.route, widget.current, if (widget.start != null) widget.start!, if (widget.destination != null) widget.destination!];
    setState(() => follow = false);
    if (points.every((p) => p == points.first)) { map.move(points.first,16); return; }
    map.fitCamera(CameraFit.bounds(bounds: LatLngBounds.fromPoints(points), padding: const EdgeInsets.all(48), maxZoom: 17));
  }
  Widget info(String title, String value) => Padding(padding: const EdgeInsets.only(right: 18, bottom: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
    AppText(title, style: const TextStyle(fontSize: 13, color: Color(0xFF53675F))), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  ]));
  @override Widget build(BuildContext context) {
    final now = DateTime.now();
    final duration = TripMetrics.elapsed(widget.startedAt,now);
    final stale = TripMetrics.stale(widget.observedAt,now);
    final remaining = widget.destination == null ? null : const Distance().as(LengthUnit.Meter,widget.current,widget.destination!)/1000;
    return Theme(data: companionLightTheme(), child: PopScope(canPop: false,
      onPopInvokedWithResult: (didPop, result) { if (!didPop && !locked) widget.onDetails(); },
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false,
          title: AppText(widget.mode, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [const LanguageButton(), IconButton(tooltip: AppLanguage.t('상세 메뉴'), onPressed: locked ? null : widget.onDetails, icon: const Icon(Icons.tune))]),
        body: LayoutBuilder(builder: (context, constraints) => Column(children: [
          Material(color: const Color(0xFFF0F7F3), child: Padding(padding: const EdgeInsets.symmetric(horizontal:16,vertical:8), child: Row(children: [
            Icon(stale ? Icons.gps_not_fixed : Icons.fiber_manual_record, color: stale ? Colors.orange : const Color(0xFF176B53), size:18), const SizedBox(width:8),
            Expanded(child: AppText(stale ? 'GPS 갱신 지연 · 마지막 위치' : '이동 기록 중 · 기기 GPS', style: const TextStyle(fontWeight:FontWeight.bold))),
            AppText(widget.sharing ? '공유 켜짐' : '나만 기록'),
          ]))),
          Expanded(child: Stack(children: [
            FlutterMap(mapController: map, options: MapOptions(initialCenter: widget.current,initialZoom:16,maxZoom:19,
              onMapReady: () { ready = true; }, onPositionChanged: (_, gesture) { if (gesture && follow) setState(() => follow = false); }), children: [
              TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName:'com.orqube.orqube_safe_hiking'),
              ...widget.backgroundLayers,
              if(widget.route.length>1)PolylineLayer(polylines:[Polyline(points:widget.route,strokeWidth:5,color:const Color(0xFF176BEE))]),
              MarkerLayer(markers:[
                if(widget.start!=null)Marker(point:widget.start!,child:Tooltip(message:AppLanguage.t('출발점'),child:const Icon(Icons.flag_circle,size:36,color:Color(0xFF176B53)))),
                if(widget.destination!=null)Marker(point:widget.destination!,child:Tooltip(message:AppLanguage.t('목적지'),child:const Icon(Icons.location_on,size:44,color:Colors.deepOrange))),
                Marker(point:widget.current,child:Tooltip(message:AppLanguage.t(stale?'마지막 GPS 위치':'현재 위치'),child:Icon(Icons.person_pin_circle,size:46,color:stale?Colors.orange:const Color(0xFF176BEE)))),
              ]),
              const RichAttributionWidget(attributions:[TextSourceAttribution('OpenStreetMap contributors')]),
            ]),
            Positioned(right:12,top:12,child:Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
              FilledButton.icon(onPressed:(){if(!ready)return;setState(()=>follow=true);map.move(widget.current,map.camera.zoom);},icon:const Icon(Icons.my_location),label:AppText(follow?'내 위치 따라가는 중':'내 위치 따라가기')),
              const SizedBox(height:8),OutlinedButton.icon(style:OutlinedButton.styleFrom(backgroundColor:Colors.white),onPressed:fit,icon:const Icon(Icons.route),label:AppText('전체 동선 보기')),
            ])),
          ])),
          Container(color:Colors.white,constraints:BoxConstraints(maxHeight:constraints.maxHeight*0.42),child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(16,12,16,4),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Wrap(children:[info('이동 시간',duration),info('이동 거리','${widget.distanceKm.toStringAsFixed(2)} km'),
              if(remaining!=null)info('목적지 직선거리','${remaining.toStringAsFixed(2)} km'),
              if(widget.plannedReturn!=null)info(widget.isHiking?'귀환 예정':'공유 종료 예정',time(widget.plannedReturn!)),
            ]),
            if(widget.isHiking&&widget.start!=null)AppText(AppLanguage.f('출발점 좌표: {lat}, {lng}',{'lat':widget.start!.latitude.toStringAsFixed(5),'lng':widget.start!.longitude.toStringAsFixed(5)})),
            Text('${AppLanguage.t('GPS 시각')} ${time(widget.observedAt)} · ±${widget.accuracy.toStringAsFixed(0)} m',style:const TextStyle(fontSize:13)),
            Row(children:[Expanded(child:Text('${AppLanguage.t('공유 대상')}: ${widget.sharing?widget.audience:AppLanguage.t('없음')}',maxLines:2,overflow:TextOverflow.ellipsis)),TextButton(onPressed:locked?null:()=>action(widget.onAudience),child:AppText('변경'))]),
            ValueListenableBuilder<ShareDelivery>(valueListenable:GuardianShare.delivery,builder:(context,delivery,_)=>AppText(!widget.sharing?'위치는 다른 사람에게 전송하지 않습니다.':delivery.failed?'서버 전송 실패 · 상대방은 이전 위치를 볼 수 있습니다.':delivery.confirmedAt==null?'서버 전송 확인 중 · 수신 완료와 다릅니다.':AppLanguage.f('서버 저장 확인: {time} · 상대방 수신 여부는 별도입니다.',{'time':time(delivery.confirmedAt!)}),style:const TextStyle(fontSize:13,height:1.5))),
          ]))),
          SafeArea(top:false,child:Padding(padding:const EdgeInsets.fromLTRB(16,8,16,8),child:Row(children:[
            Expanded(child:FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:const Color(0xFFBD2436),minimumSize:const Size(0,56)),onPressed:locked?null:()=>action(widget.onSos),icon:const Icon(Icons.sos),label:AppText('SOS'))),const SizedBox(width:12),
            Expanded(child:FilledButton.icon(style:FilledButton.styleFrom(minimumSize:const Size(0,56)),onPressed:locked?null:end,icon:const Icon(Icons.stop_circle_outlined),label:AppText('이동 종료'))),
          ]))),
          if(locked)const LinearProgressIndicator(minHeight:2),
        ])),
      ),
    ));
  }
}
