import '../services/trip_tracking.dart';
import 'active_trip_map.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/guardian_share.dart';
import '../utils/app_language.dart';
import 'audience_picker.dart';
import 'companion_theme.dart';
import 'orqube_domain_button.dart';
import 'guardian_page.dart';

class LocationSharePage extends StatefulWidget {
  const LocationSharePage({super.key});
  @override State<LocationSharePage> createState()=>_LocationSharePageState();
}
class _LocationSharePageState extends State<LocationSharePage> with LanguageAware<LocationSharePage> {
  final tracking = TripTracking.instance;
  @override void initState() {
    super.initState();
    tracking.addListener(changed);
    if (tracking.active && tracking.mode == 'location' && tracking.uid == FirebaseAuth.instance.currentUser?.uid) restore();
  }
  void restore() {
    sharing=tracking.sharing; fullMap=tracking.active; sessionUid=tracking.uid;
    startedAt=tracking.startedAt; until=tracking.sharingUntil; lastPosition=tracking.position;
    points..clear()..addAll(tracking.route); distanceKm=tracking.distanceKm;
    startPoint=points.isEmpty?null:points.first;
    names=tracking.details['names'] as String? ?? '';
  }
  void changed() {
    if (!mounted || tracking.mode!='location') return;
    setState(() { if(tracking.active) {final showingMap=fullMap;restore();fullMap=showingMap;} else {sharing=false;fullMap=false;} });
  }
  DateTime? until;
  final points=<LatLng>[];bool sharing=false,busy=false;String names='',message='';
  bool fullMap=false; DateTime? startedAt; Position? lastPosition; double distanceKm=0; String? sessionUid; LatLng? startPoint;
  Future<void> start()async{
    if(busy)return;
    if(tracking.active){setState(()=>message='진행 중인 이동을 홈에서 확인하고 종료한 뒤 새로 시작하세요.');return;}
    setState(()=>busy=true);
    try{
      final user=FirebaseAuth.instance.currentUser;
      if(user==null||!user.emailVerified)throw StateError('Verification required');
      final selection=await chooseAudience(context,hiking:false);
      if(!mounted||selection==null||selection.live.isEmpty)return;
      if(!await Geolocator.isLocationServiceEnabled())throw StateError('GPS disabled');
      var permission=await Geolocator.checkPermission();
      if(permission==LocationPermission.denied)permission=await Geolocator.requestPermission();
      if(permission==LocationPermission.denied||permission==LocationPermission.deniedForever)throw StateError('Permission required');
      final position=await Geolocator.getCurrentPosition(locationSettings:const LocationSettings(accuracy:LocationAccuracy.high)).timeout(const Duration(seconds:15));
      if(!mounted||FirebaseAuth.instance.currentUser?.uid!=user.uid)return;
      GuardianShare.beginSession();
      setState((){sharing=true;fullMap=true;sessionUid=user.uid;startedAt=DateTime.now();lastPosition=null;startPoint=null;distanceKm=0;names=selection.names;until=DateTime.now().add(const Duration(minutes:30));points.clear();message='';});
      final expiresAt=until;
      await tracking.start(owner:user.uid,tripMode:'location',sessionCollection:'',
        startTime:startedAt!,initialRoute:[],initialDistance:0,metadata:{'names':names},initialPosition:position);
      tracking.setSharing(true,until:expiresAt);

    }catch(_){if(mounted)setState(()=>message='공유를 시작하지 못했습니다. 로그인·이메일 인증·위치 권한·인터넷을 확인하세요.');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> stop() async {
    if(tracking.active && tracking.mode=='location') await tracking.stop();
    if(mounted)setState((){sharing=false;fullMap=false;});
  }
  Future<void> change()async{
    try{
      final selection=await chooseAudience(context,hiking:false);
      if(!mounted||selection==null)return;
      if(selection.live.isEmpty){await stop();return;}
      setState(()=>names=selection.names);
      tracking.updateDetails({'names':names});
    }catch(_){if(mounted)setState(()=>message='변경하지 못했습니다. 연결 상태와 권한을 확인한 뒤 다시 시도하세요.');}
  }
  @override void dispose(){tracking.removeListener(changed);super.dispose();}
  Future<void> sos() async {
    final p=lastPosition;
    if(p==null)return;
    final mapUrl='https://www.google.com/maps?q=${p.latitude},${p.longitude}';
    final text='${AppLanguage.t('SOS · 마지막 GPS 좌표')}\n${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}\n${p.timestamp.toLocal()}\n$mapUrl';
    await showModalBottomSheet<void>(context:context,isScrollControlled:true,builder:(ctx)=>SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      AppText('SOS · 마지막 GPS 좌표',style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
      AppText('자동 신고나 구조 요청 전송이 아닙니다. 표시된 GPS 시각을 확인하고 필요하면 현지 긴급전화로 직접 연락하세요.'),
      SelectableText(text),
      FilledButton.icon(onPressed:()async{final box=ctx.findRenderObject() as RenderBox?;await Share.share(text,sharePositionOrigin:box==null?null:box.localToGlobal(Offset.zero)&box.size);},icon:const Icon(Icons.share),label:AppText('SOS 좌표 보내기')),
      OutlinedButton(onPressed:()=>Clipboard.setData(ClipboardData(text:text)),child:AppText('좌표 복사')),
    ]))));
  }
  @override Widget build(BuildContext context) {
    if(sharing&&fullMap&&lastPosition!=null&&startedAt!=null) {
      return ActiveTripMap(mode:'위치 공유',audience:names,current:LatLng(lastPosition!.latitude,lastPosition!.longitude),route:List.of(points),start:startPoint,
        startedAt:startedAt!,observedAt:lastPosition!.timestamp,plannedReturn:until,distanceKm:distanceKm,accuracy:lastPosition!.accuracy,sharing:sharing,
        onDetails:()=>setState(()=>fullMap=false),onSos:sos,onEnd:stop,onAudience:change);
    }
    return Theme(data:companionLightTheme(),child:Scaffold(
    appBar:AppBar(title:AppText('위치 공유'),actions:[if(sharing)IconButton(tooltip:AppLanguage.t('이동 지도 보기'),onPressed:()=>setState(()=>fullMap=true),icon:const Icon(Icons.map_outlined)),OrqubeDomainButton(),const LanguageButton()]),
    body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:900),child:ListView(padding:const EdgeInsets.all(20),children:[
      AppText('가족·친구와 30분 위치 공유',style:const TextStyle(fontSize:26,fontWeight:FontWeight.bold)),
      AppText('산행이나 귀가를 시작하지 않아도 선택한 사람에게 현재 위치와 최근 경로를 공유합니다. 이 화면을 나가도 공유는 계속되며, 공유 중지 또는 30분 만료 시 종료됩니다.'),
      const SizedBox(height:16),
      if(points.isNotEmpty)SizedBox(height:380,child:FlutterMap(options:MapOptions(initialCenter:points.last,initialZoom:16),children:[
        TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName:'com.orqube.orqube_safe_hiking'),
        PolylineLayer(polylines:[Polyline(points:List.of(points),strokeWidth:5,color:const Color(0xFF176BEE))]),
        MarkerLayer(markers:[Marker(point:points.last,child:const Icon(Icons.person_pin_circle,size:40,color:Color(0xFF176B53)))]),
        const RichAttributionWidget(attributions:[TextSourceAttribution('OpenStreetMap contributors')]),
      ])),
      if(sharing)...[AppText('공유 대상'),Text(names),if(until!=null)Text(until!.toLocal().toString()),
        OutlinedButton(onPressed:change,child:AppText('공유 대상 변경'))],
      if(message.isNotEmpty)AppText(message),
      FilledButton.icon(onPressed:busy?null:sharing?stop:start,icon:Icon(sharing?Icons.stop_circle_outlined:Icons.share_location),label:AppText(sharing?'공유 중지':'공유 대상 선택 · 시작')),
      TextButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>GuardianPage())),child:AppText('내 사람·모임')),
      AppText('표시된 지도는 이 기기의 GPS 기록입니다. 상대방의 수신 완료를 뜻하지 않습니다. 통신·절전·앱 종료 시 갱신이 중단될 수 있습니다.'),
    ]))),
  ));
  }
}
