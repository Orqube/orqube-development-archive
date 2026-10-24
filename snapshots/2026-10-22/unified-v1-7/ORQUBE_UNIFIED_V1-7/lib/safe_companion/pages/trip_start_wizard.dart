import '../utils/trip_setup_validation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/app_language.dart';
import 'audience_picker.dart';
import 'companion_theme.dart';
import 'guardian_page.dart';
import 'hiking_detailed_guide_page.dart';

class TripSetup {
  final Position position;
  final LatLng? destination;
  final String destinationName;
  final DateTime plannedReturn;
  final AudienceSelection? audience;
  final bool share, resume;
  const TripSetup({required this.position,required this.destination,required this.destinationName,
    required this.plannedReturn,required this.audience,required this.share,required this.resume});
}
class TripStartWizard extends StatefulWidget {
  final bool hiking;
  final bool hasSavedRecord;
  final LatLng? destination;
  final DateTime? plannedReturn;
  final Future<LatLng?> Function(String query) searchAddress;
  const TripStartWizard({super.key,required this.hiking,required this.hasSavedRecord,
    required this.searchAddress,this.destination,this.plannedReturn});
  @override State<TripStartWizard> createState()=>_TripStartWizardState();
}
class _TripStartWizardState extends State<TripStartWizard> with LanguageAware<TripStartWizard> {
  int step=0;bool busy=false,understood=false,privacy=false,locationConsent=false;
  bool share=false,resume=false,noDestination=false;
  Position? position;LatLng? destination;AudienceSelection? audience;
  late DateTime planned;
  final address=TextEditingController();final scroll=ScrollController();String error='';
  static const titles=['이용 안내','동의 확인','내 위치 확인','목적지·귀환 계획','공유 대상 설정','최종 확인'];
  @override void initState(){super.initState();destination=widget.destination;planned=widget.plannedReturn??DateTime.now().add(const Duration(hours:4));}
  @override void dispose(){address.dispose();scroll.dispose();super.dispose();}
  Future<void> gps()async{
    setState((){busy=true;error='';});
    try{
      if(!await Geolocator.isLocationServiceEnabled())throw StateError('GPS disabled');
      var permission=await Geolocator.checkPermission();
      if(permission==LocationPermission.denied)permission=await Geolocator.requestPermission();
      if(permission==LocationPermission.denied||permission==LocationPermission.deniedForever)throw StateError('Permission denied');
      final fix=await Geolocator.getCurrentPosition(locationSettings:const LocationSettings(accuracy:LocationAccuracy.high)).timeout(const Duration(seconds:20));
      if(mounted)setState(()=>position=fix);
    }catch(_){if(mounted)setState(()=>error='위치를 확인하지 못했습니다. 기기 위치 서비스와 앱 위치 권한을 확인하고 다시 눌러주세요.');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> search()async{
    if(address.text.trim().isEmpty)return;
    setState((){busy=true;error='';});
    try{
      final found=await widget.searchAddress(address.text.trim()).timeout(const Duration(seconds:15));
      if(!mounted)return;
      setState((){destination=found;noDestination=false;if(found==null)error='목적지를 찾지 못했습니다. 주소를 바꾸거나 지도에서 직접 선택하세요.';});
    }catch(_){if(mounted)setState(()=>error='목적지를 찾지 못했습니다. 주소를 바꾸거나 지도에서 직접 선택하세요.');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> changeReturn()async{
    final date=await showDatePicker(context:context,initialDate:planned.isBefore(DateTime.now())?DateTime.now():planned.isAfter(DateTime.now().add(const Duration(days:7)))?DateTime.now().add(const Duration(days:7)):planned,firstDate:DateTime.now(),lastDate:DateTime.now().add(const Duration(days:7)));
    if(date==null||!mounted)return;
    final time=await showTimePicker(context:context,initialTime:TimeOfDay.fromDateTime(planned));
    if(time==null||!mounted)return;
    setState(()=>planned=DateTime(date.year,date.month,date.day,time.hour,time.minute));
  }
  bool get ready => tripStepReady(step:step,understood:understood,privacy:privacy,
    locationConsent:locationConsent,hasPosition:position!=null,hiking:widget.hiking,
    hasDestination:destination!=null,routeOnly:noDestination,futureReturn:planned.isAfter(DateTime.now()),
    share:share,hasRecipients:audience!=null&&audience!.live.isNotEmpty);

  void next(){
    if(!ready||busy)return;
    if(step==5){
      if(position==null||DateTime.now().difference(position!.timestamp)>const Duration(minutes:5)){
        setState((){step=2;error='위치를 확인한 지 시간이 지났습니다. 내 위치를 다시 확인해주세요.';});return;
      }
      if(widget.hiking&&!planned.isAfter(DateTime.now())){setState(()=>step=3);return;}
      Navigator.pop(context,TripSetup(position:position!,destination:noDestination?null:destination,
        destinationName:address.text.trim(),plannedReturn:planned,audience:share?audience:null,share:share,resume:resume));return;
    }
    setState((){step++;error='';});if(scroll.hasClients)scroll.jumpTo(0);
  }
  Widget text(String value)=>AppText(value,style:const TextStyle(fontSize:17,height:1.8));
  Widget card(Widget child)=>Card(margin:const EdgeInsets.symmetric(vertical:8),child:Padding(padding:const EdgeInsets.all(20),child:child));
  List<Widget> content(){
    switch(step){
      case 0:return[
        text(widget.hiking?'몇 단계만 따라 하면 산행 준비가 끝납니다. 설명을 읽고 동의·위치·목적지·공유 대상을 차례로 확인하세요.':'몇 단계만 따라 하면 귀가 준비가 끝납니다. 설명을 읽고 동의·위치·목적지·공유 대상을 차례로 확인하세요.'),
        card(text('가족·친구와 연결되어 있어도 자동으로 위치가 공개되지 않습니다. 마지막 단계에서 확인하고 시작해야 이동 기록과 공유를 시작합니다.')),
        if(widget.hiking)TextButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const HikingDetailedGuidePage())),icon:const Icon(Icons.menu_book),label:AppText('안전산행 상세 안내')),
        if(widget.hasSavedRecord)...[
          card(Column(children:[text('저장된 산행 기록이 있습니다. 새 기록은 기존 기기 기록을 교체합니다. 필요한 기록은 기존 메뉴에서 먼저 내보내세요.'),SwitchListTile(contentPadding:EdgeInsets.zero,title:AppText('기록 이어가기'),value:resume,onChanged:(yes)=>setState(()=>resume=yes))])),
        ],
        CheckboxListTile(contentPadding:EdgeInsets.zero,title:AppText('안내를 이해했습니다.'),value:understood,onChanged:(yes)=>setState(()=>understood=yes??false)),
      ];
      case 1:return[
        card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[AppText('개인정보 처리 안내',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),text('로그인은 Firebase 인증을 사용합니다. 이동 중 좌표·시간·경로와 계획을 기능 이용을 위해 기기 또는 서버에 저장합니다. 지도·주소 검색 서비스에는 요청 좌표나 검색어가 전달될 수 있습니다. 기록 삭제는 내 계정과 저장된 기록 메뉴에서 할 수 있습니다.')])),
        CheckboxListTile(contentPadding:EdgeInsets.zero,title:AppText('개인정보 처리 안내를 읽고 동의합니다.'),value:privacy,onChanged:(yes)=>setState(()=>privacy=yes??false)),
        card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[AppText('위치 이용 동의',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),text('내 위치 확인 버튼을 누를 때 기기의 위치 권한을 요청합니다. 앱 종료·절전·GPS 불량으로 기록이 중단될 수 있습니다. 상대방에게 공유하려면 이후 단계에서 직접 선택해야 합니다. 자동 구조 요청이나 현재 위치 보장은 제공하지 않습니다.')])),
        CheckboxListTile(contentPadding:EdgeInsets.zero,title:AppText('이번 이동의 위치 이용에 동의합니다.'),value:locationConsent,onChanged:(yes)=>setState(()=>locationConsent=yes??false)),
      ];
      case 2:return[
        text('아래 버튼을 눌러 위치 권한을 허용하고 GPS 위치를 확인하세요. 다음 단계로 가기 전에 좌표와 정확도를 확인합니다.'),
        FilledButton.icon(onPressed:busy?null:gps,icon:const Icon(Icons.my_location),label:AppText(position==null?'내 위치 확인':'내 위치 다시 확인')),
        if(position!=null)card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[AppText('내 위치 확인 완료'),SelectableText('${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}',style:const TextStyle(fontSize:18)),AppText(AppLanguage.f('GPS 정확도 약 {meters}m',{'meters':position!.accuracy.toStringAsFixed(0)}))])),
      ];
      case 3:return[
        text(widget.hiking?'산행 목적지를 검색하거나 지도에서 누르세요. 정해진 목적지가 없으면 경로만 기록을 선택할 수 있습니다.':'귀가할 주소나 장소를 검색한 뒤 지도에서 목적지가 맞는지 확인하세요. 지도에서 원하는 지점을 직접 누를 수도 있습니다.'),
        TextField(controller:address,style:const TextStyle(fontSize:18),textInputAction:TextInputAction.search,onChanged:(_){if(destination!=null)setState(()=>destination=null);},onSubmitted:(_)=>search(),decoration:InputDecoration(labelText:AppLanguage.t('주소 또는 장소명'),border:const OutlineInputBorder())),
        const SizedBox(height:10),OutlinedButton.icon(onPressed:busy?null:search,icon:const Icon(Icons.search),label:AppText('목적지 검색')),
        SizedBox(height:260,child:ClipRRect(borderRadius:BorderRadius.circular(18),child:FlutterMap(
          key:ValueKey(destination),options:MapOptions(initialCenter:destination??LatLng(position!.latitude,position!.longitude),initialZoom:14,onTap:(_,point)=>setState((){destination=point;noDestination=false;address.clear();})),children:[
            TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName:'com.orqube.orqube_safe_hiking'),
            if(destination!=null)MarkerLayer(markers:[Marker(point:destination!,child:const Icon(Icons.flag,color:Colors.deepOrange,size:36))]),
            const RichAttributionWidget(attributions:[TextSourceAttribution('OpenStreetMap contributors')]),
          ]))),
        if(destination!=null)SelectableText('${destination!.latitude.toStringAsFixed(6)}, ${destination!.longitude.toStringAsFixed(6)}'),
        if(widget.hiking)...[
          CheckboxListTile(contentPadding:EdgeInsets.zero,title:AppText('목적지 없이 경로만 기록'),value:noDestination,onChanged:(yes)=>setState(()=>noDestination=yes??false)),
          card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[AppText('귀환 예정시간'),Text(planned.toLocal().toString(),style:const TextStyle(fontSize:19)),TextButton.icon(onPressed:changeReturn,icon:const Icon(Icons.schedule),label:AppText('귀환 예정시간 변경'))])),
        ],
      ];
      case 4:return[
        text('이번 이동을 가족·친구와 공유할지 선택하세요. 공유하지 않아도 내 이동 기록을 시작할 수 있습니다.'),
        SwitchListTile(contentPadding:EdgeInsets.zero,title:AppText('가족·친구에게 위치 공유'),value:share,onChanged:(yes)=>setState(()=>share=yes)),
        if(share)...[
          OutlinedButton.icon(onPressed:()async{try{final selected=await chooseAudience(context,hiking:widget.hiking,apply:false);if(mounted&&selected!=null)setState(()=>audience=selected);}catch(_){if(mounted)setState(()=>error='공유 대상을 읽지 못했습니다. 새 보안 규칙과 연결 상태를 확인하세요.');}},icon:const Icon(Icons.people_alt_outlined),label:AppText('공유 대상 선택')),
          if(audience!=null)card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(audience!.names,style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold)),if(widget.hiking)AppText(AppLanguage.f('마지막 기록 조회 허용: {count}명',{'count':'${audience!.search.length}'}))])),
          TextButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const GuardianPage())),icon:const Icon(Icons.person_add_alt_1),label:AppText('사람 추가·모임 관리')),
          text('새 사람은 상대방이 초대를 수락해야 선택할 수 있습니다. 모임은 연결된 사람을 묶어 고르는 기능입니다.'),
        ],
      ];
      default:return[
        text('아래 내용을 확인한 뒤 시작하세요. 이전을 누르면 설정을 바꿀 수 있습니다.'),
        card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          AppText(widget.hiking?'안전산행':'안심귀가',style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
          if(widget.hasSavedRecord)AppText(resume?'기록 이어가기':'새 산행 시작'),
          const SizedBox(height:12),AppText('내 위치'),SelectableText('${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}'),
          const SizedBox(height:12),AppText('목적지'),if(noDestination)AppText('목적지 없이 경로만 기록')else if(destination!=null)Text(address.text.trim().isNotEmpty?address.text.trim():'${destination!.latitude.toStringAsFixed(6)}, ${destination!.longitude.toStringAsFixed(6)}'),
          if(widget.hiking)...[const SizedBox(height:12),AppText('귀환 예정시간'),Text(planned.toLocal().toString())],
          const SizedBox(height:12),AppText('공유 대상'),if(share)Text(audience?.names??'')else AppText('공유 없이 내 기록만 시작'),
          if(widget.hiking&&share)AppText(AppLanguage.f('마지막 기록 조회 허용: {count}명',{'count':'${audience?.search.length??0}'})),
        ])),
        text('뒤로 가거나 취소하면 이동·공유는 시작되지 않습니다. 이미 별도로 보낸 초대나 수락은 유지됩니다.'),
      ];
    }
  }
  @override Widget build(BuildContext context)=>Theme(data:companionLightTheme(),child:PopScope(canPop:!busy,child:Scaffold(
    appBar:AppBar(title:AppText(widget.hiking?'산행 시작 도우미':'귀가 시작 도우미'),actions:[const LanguageButton()]),
    body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:720),child:Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(20,12,20,8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        AppText(AppLanguage.f('{step} / 6 · {title}',{'step':'${step+1}','title':AppLanguage.t(titles[step])}),style:const TextStyle(fontSize:21,fontWeight:FontWeight.bold)),const SizedBox(height:12),LinearProgressIndicator(value:(step+1)/6,minHeight:7),
      ])),
      Expanded(child:ListView(controller:scroll,padding:const EdgeInsets.fromLTRB(20,8,20,24),children:[...content(),if(busy)const LinearProgressIndicator(),if(error.isNotEmpty)Card(color:const Color(0xFFFFF1E5),child:Padding(padding:const EdgeInsets.all(16),child:text(error)))])),
    ]))),
    bottomNavigationBar:SafeArea(top:false,child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[
      Expanded(child:OutlinedButton(onPressed:busy?null:()=>step==0?Navigator.pop(context):setState((){step--;error='';}),style:OutlinedButton.styleFrom(minimumSize:const Size(0,56)),child:AppText(step==0?'취소':'이전'))),
      const SizedBox(width:12),Expanded(flex:2,child:FilledButton(onPressed:busy||!ready?null:next,style:FilledButton.styleFrom(minimumSize:const Size(0,56)),child:AppText(step==5?(widget.hiking?'산행 시작하고 지도 보기':'귀가 시작하고 지도 보기'):'다음',style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)))),
    ]))),
  )));
}
