import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/live_debate_service.dart';

class LiveDebateRoomPage extends StatefulWidget {
  const LiveDebateRoomPage({super.key});
  @override
  State<LiveDebateRoomPage> createState() => _LiveDebateRoomPageState();
}
class _LiveDebateRoomPageState extends State<LiveDebateRoomPage> {
  final _topic=TextEditingController(), _code=TextEditingController(), _text=TextEditingController();
  String _roomId=''; int _minutes=10; bool _busy=false; Timer? _timer;
  @override
  void initState(){super.initState();_timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted&&_roomId.isNotEmpty)setState((){});});}
  @override
  void dispose(){_timer?.cancel();_topic.dispose();_code.dispose();_text.dispose();super.dispose();}
  void _notice(Object e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}
  Future<void> _call(String action,Map<String,dynamic> data) async {
    if(_busy)return;setState(()=>_busy=true);
    try{final id=await LiveDebateService.call(action,{'roomId':_roomId,...data});if(mounted){setState((){if(id.isNotEmpty)_roomId=id;});if(action=='send')_text.clear();}}
    catch(e){_notice(e);}finally{if(mounted)setState(()=>_busy=false);}
  }
  Future<void> _end() async {
    var draft='';
    final summary=await showDialog<String>(context:context,builder:(c)=>AlertDialog(title:const Text('중재자 최종 정리'),content:TextField(onChanged:(v)=>draft=v,maxLines:5,maxLength:4000,decoration:const InputDecoration(hintText:'공통점과 차이점 및 미해결 사항을 입력하세요.')),
      actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('취소')),FilledButton(onPressed:()=>Navigator.pop(c,draft.trim()),child:const Text('정리하고 종료'))]));
    if(summary!=null)await _call('end',{'summary':summary});
  }
  @override
  Widget build(BuildContext context)=>Scaffold(
    backgroundColor:const Color(0xFF101322),
    appBar:AppBar(title:const Text('공동 문자 토론방 BETA',style:TextStyle(fontSize:17))),
    body:FirebaseAuth.instance.currentUser==null?const Center(child:Text('기존 ORQUBE 계정으로 로그인한 뒤 입장하세요.',style:TextStyle(color:Colors.white))):
      _roomId.isEmpty?_lobby():StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
        stream:FirebaseFirestore.instance.collection('live_debate_rooms').doc(_roomId).snapshots(),
        builder:(context,s){
          if(s.hasError)return Center(child:Text('토론방 읽기 권한을 확인하세요. ${s.error}',style:const TextStyle(color:Colors.white)));
          if(!s.hasData)return const Center(child:CircularProgressIndicator());
          final room=s.data!.data();if(room==null)return const Center(child:Text('토론방이 없습니다.'));
          return _room(room);
        }),
  );
  Widget _lobby()=>ListView(padding:const EdgeInsets.all(20),children:[
    const Text('여러 사람이 같은 주제로 글을 입력하는 토론입니다. AI 3자 토론과 별도입니다. 방장이 역할을 지정한 뒤 시작합니다.',style:TextStyle(color:Colors.white70)),
    const SizedBox(height:20),_input(_topic,'새 토론 주제',maxLines:3,maxLength:500),
    DropdownButtonFormField<int>(value:_minutes,decoration:const InputDecoration(labelText:'토론 시간'),items:[1,3,5,10,20,30,60,120].map((v)=>DropdownMenuItem(value:v,child:Text('$v분'))).toList(),onChanged:_busy?null:(v)=>setState(()=>_minutes=v??10)),
    FilledButton(onPressed:_busy?null:()=>_call('create',{'topic':_topic.text,'minutes':_minutes}),child:const Text('토론방 만들기')),
    const SizedBox(height:28),_input(_code,'공유받은 참가 코드'),
    FilledButton(onPressed:_busy?null:()=>_call('join',{'roomId':_code.text.trim()}),child:const Text('같은 토론방 입장')),
    if(_busy)const LinearProgressIndicator(),
  ]);
  Widget _input(TextEditingController controller,String label,{int maxLines=1,int? maxLength})=>TextField(controller:controller,maxLines:maxLines,maxLength:maxLength,style:const TextStyle(color:Colors.white),decoration:InputDecoration(labelText:label,labelStyle:const TextStyle(color:Colors.white70),border:const OutlineInputBorder()));
  Widget _room(Map<String,dynamic> r){
    final uid=FirebaseAuth.instance.currentUser!.uid;
    final members=Map<String,dynamic>.from(r['members'] as Map? ?? {});
    final mine=Map<String,dynamic>.from(members[uid] as Map? ?? {});
    final host=r['ownerUid']==uid, moderator=host||mine['role']=='moderator';
    final end=r['endAt'] as Timestamp?;
    final seconds=end==null?0:end.toDate().difference(DateTime.now()).inSeconds;
    final live=r['status']=='live'&&seconds>0;
    final eligible=['host','moderator','panel'].contains(mine['role']);
    final floor='${r['floorUid']??''}';
    final canSpeak=live&&eligible&&(floor.isEmpty||floor==uid||moderator);
    final controls=<Widget>[
      SelectableText('주제: ${r['topic']}\n참가 코드: $_roomId',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),
      Wrap(spacing:8,children:[TextButton.icon(onPressed:()=>Clipboard.setData(ClipboardData(text:_roomId)),icon:const Icon(Icons.copy),label:const Text('코드 복사')),
        TextButton(onPressed:_busy?null:()=>setState(()=>_roomId=''),child:const Text('입장 화면으로'))]),
      Text(r['status']=='waiting'?'시작 전 역할 설정':r['status']=='ended'?'토론 종료':live?'남은 시간 ${seconds~/60}:${(seconds%60).toString().padLeft(2,'0')}':'시간 종료 · 중재자 정리 대기',style:const TextStyle(color:Colors.lightGreenAccent)),
      const SizedBox(height:8),const Text('참가자와 역할',style:TextStyle(color:Colors.white)),
      ...members.entries.map((e){final m=Map<String,dynamic>.from(e.value as Map);final role='${m['role']}';return ListTile(dense:true,contentPadding:EdgeInsets.zero,title:Text('${m['name']}${e.key==uid?' (나)':''}',style:const TextStyle(color:Colors.white)),
        subtitle:Text({'host':'방장','moderator':'중재자','panel':'패널','audience':'관람자'}[role]??role,style:const TextStyle(color:Colors.white60)),
        trailing:host&&r['status']=='waiting'&&e.key!=r['ownerUid']?DropdownButton<String>(value:role,items:['panel','moderator','audience'].map((v)=>DropdownMenuItem(value:v,child:Text({'panel':'패널','moderator':'중재자','audience':'관람자'}[v]!))).toList(),onChanged:_busy?null:(v)=>_call('assign',{'targetUid':e.key,'role':v})):null);}),
      if(moderator&&r['status']=='waiting')FilledButton(onPressed:_busy?null:()=>_call('start',{}),child:const Text('함께 토론 시작')),
      if(moderator&&live)...[
        DropdownButtonFormField<String>(value:floor,decoration:const InputDecoration(labelText:'발언 차례'),items:[const DropdownMenuItem(value:'',child:Text('패널 자유 발언')),
          ...members.entries.where((e)=>['host','moderator','panel'].contains((e.value as Map)['role'])).map((e)=>DropdownMenuItem(value:e.key,child:Text('${(e.value as Map)['name']}')))],onChanged:_busy?null:(v)=>_call('floor',{'targetUid':v??''})),
      ],
      if(moderator&&r['status']!='ended')TextButton(onPressed:_busy?null:_end,child:const Text('최종 정리와 종료')),
    ];
    final chat=Column(children:[Expanded(child:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
      stream:FirebaseFirestore.instance.collection('live_debate_rooms').doc(_roomId).collection('messages').orderBy('createdAt',descending:true).limit(200).snapshots(),
      builder:(c,s){if(s.hasError)return Text('발언 조회 실패: ${s.error}',style:const TextStyle(color:Colors.redAccent));if(!s.hasData)return const Center(child:CircularProgressIndicator());
        return ListView(reverse:true,children:s.data!.docs.map((doc){final m=doc.data();return Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${m['name']} · ${m['role']}',style:const TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:5),SelectableText('${m['text']}')])));}).toList());}),),
      if('${r['summary']??''}'.isNotEmpty)SizedBox(height:130,child:SingleChildScrollView(child:SelectableText('중재자 최종 정리\n${r['summary']}',style:const TextStyle(color:Colors.lightBlueAccent)))),
      const SizedBox(height:8),_input(_text,canSpeak?'발언 입력':'패널 지정과 발언 차례를 기다려 주세요',maxLines:2,maxLength:2000),
      FilledButton(onPressed:canSpeak&&!_busy?()=>_call('send',{'text':_text.text,'messageId':DateTime.now().microsecondsSinceEpoch.toString()}):null,child:const Text('발언 등록')),
    ]);
    return LayoutBuilder(builder:(c,constraints)=>Padding(padding:const EdgeInsets.all(14),child:constraints.maxWidth>=900?
      Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:290,child:ListView(children:controls)),const SizedBox(width:14),Expanded(child:chat)]):
      ListView(children:[...controls,const SizedBox(height:18),SizedBox(height:650,child:chat)])));
  }
}
