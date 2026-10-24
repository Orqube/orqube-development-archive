import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_language.dart';
import 'companion_theme.dart';
import 'orqube_domain_button.dart';
import 'hiking_account_page.dart';
import 'people_manager.dart';
import 'live_route_map.dart';
import 'search_record_page.dart';

class GuardianPage extends StatefulWidget {
  const GuardianPage({super.key});
  @override State<GuardianPage> createState()=>_GuardianPageState();
}
class _GuardianPageState extends State<GuardianPage> with LanguageAware<GuardianPage> {
  StreamSubscription<DocumentSnapshot<Map<String,dynamic>>>? subscription;
  StreamSubscription<User?>? authSubscription;
  Timer? retryTimer;
  bool retryNeeded=false;
  Timer? timer; String? watching; Map<String,dynamic>? location;
  String? authUid=FirebaseAuth.instance.currentUser?.uid;
  String message=''; bool cached=false; DateTime now=DateTime.now(); int generation=0;
  final scroll=ScrollController();
  @override void initState(){super.initState();authSubscription=FirebaseAuth.instance.userChanges().listen((user){if(authUid!=user?.uid){authUid=user?.uid;generation++;subscription?.cancel();retryNeeded=false;watching=null;location=null;message='';}if(mounted)setState((){});});retryTimer=Timer.periodic(const Duration(seconds:15),(_){if(retryNeeded&&watching!=null)watch(watching!);});timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted&&location!=null)setState(()=>now=DateTime.now());});}
  Future<void> watch(String uid)async{
    retryNeeded=false;
    final token=++generation;await subscription?.cancel();
    if(!mounted||token!=generation)return;
    setState((){watching=uid;cached=false;location=null;message='위치 수신 대기 중입니다.';});
    subscription=FirebaseFirestore.instance.collection('safety_shares').doc(uid).snapshots(includeMetadataChanges:true).listen((row){
      if(!mounted||token!=generation)return;
      setState((){location=row.data();cached=row.metadata.isFromCache;now=DateTime.now();message=row.exists?'':'상대방이 아직 공유를 시작하지 않았습니다.';});
    },onError:(Object _){if(mounted&&token==generation)setState((){retryNeeded=true;location=null;message='상대가 나를 공유 대상으로 선택했는지 확인하세요. 종료·만료·연결 해제 또는 통신 문제일 수도 있습니다.';});});
    if(scroll.hasClients)await scroll.animateTo(0,duration:const Duration(milliseconds:300),curve:Curves.easeOut);
  }
  @override void dispose(){generation++;subscription?.cancel();timer?.cancel();retryTimer?.cancel();authSubscription?.cancel();scroll.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final user=FirebaseAuth.instance.currentUser;
    return Theme(data:companionLightTheme(),child:Scaffold(
      appBar:AppBar(title:AppText('내 사람·모임'),actions:[OrqubeDomainButton(),const LanguageButton()]),
      body:user==null?Center(child:FilledButton(onPressed:()async{await Navigator.push(context,MaterialPageRoute(builder:(_)=>HikingAccountPage()));if(mounted)setState((){});},child:AppText('로그인 후 이용'))):Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:960),child:ListView(controller:scroll,padding:const EdgeInsets.all(20),children:[
        if(watching!=null)...[
          if(location!=null)Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            AppText(location!['active']==true?'위치 공유 상태: 공유 중 · 수신 시간 확인':'위치 공유 상태: 종료'),
            AppText('마지막 서버 수신: ${(location!['updatedAt'] as Timestamp?)?.toDate().toLocal().toString() ?? '—'}'),
            if(cached)AppText('저장된 정보입니다. 서버 연결을 확인하세요.'),
          ]))),
          if(location!=null)LiveRouteMap(key:ValueKey(watching),data:location!,cached:cached,now:now),
          if(message.isNotEmpty)Card(child:Padding(padding:const EdgeInsets.all(18),child:AppText(message))),
          OutlinedButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>SearchRecordPage(targetUid:watching))),icon:const Icon(Icons.hiking),label:AppText('마지막 산행 기록 · 수색 참고자료')),
          OutlinedButton.icon(onPressed:()=>watch(watching!),icon:const Icon(Icons.refresh),label:AppText('위치 다시 받기')),
          const Divider(height:30),
        ],
        PeopleManager(key:ValueKey(user.uid),onWatch:watch),
      ]))),
    ));
  }
}
