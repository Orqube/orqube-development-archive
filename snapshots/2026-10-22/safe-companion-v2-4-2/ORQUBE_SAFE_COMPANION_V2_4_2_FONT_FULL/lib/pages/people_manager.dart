import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/people_service.dart';
import '../utils/app_language.dart';
import 'connection_invite_page.dart';

class PeopleManager extends StatefulWidget {
  final void Function(String uid) onWatch;
  const PeopleManager({super.key,required this.onWatch});
  @override State<PeopleManager> createState()=>_PeopleManagerState();
}
class _PeopleManagerState extends State<PeopleManager> with LanguageAware<PeopleManager> {
  List<PersonConnection> people=[];
  List<Map<String,dynamic>> groups=[];
  Set<String> audience={};
  bool loading=true,busy=false,fetching=false;
  String error=''; Timer? timer;
  @override void initState(){super.initState();refresh();timer=Timer.periodic(const Duration(seconds:15),(_){if(!busy)refresh();});}
  @override void dispose(){timer?.cancel();super.dispose();}
  Future<void> refresh() async {
    if(fetching)return;fetching=true;
    try{
      final rows=await PeopleService.load();
      final groupRows=await PeopleService.groups.get();
      final share=await PeopleService.db.collection('safety_shares').doc(PeopleService.uid).get();
      if(mounted)setState((){people=rows;groups=groupRows.docs.map((r)=>{'id':r.id,...r.data()}).toList();audience=((share.data()?['viewerUids'] as List?)??[]).cast<String>().toSet();error='';loading=false;});
    }catch(_){if(mounted)setState((){error='목록을 읽지 못했습니다. 인터넷·로그인·새 보안 규칙을 확인하고 다시 시도하세요.';loading=false;});}
    finally{fetching=false;}
  }
  Future<void> run(Future<void> Function() action) async {
    if(busy)return;setState((){busy=true;error='';});
    try{await action();await refresh();}
    catch(_){if(mounted)setState(()=>error='변경하지 못했습니다. 연결 상태와 권한을 확인한 뒤 다시 시도하세요.');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<bool> confirm(String title,String body) async => await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:AppText(title),content:AppText(body),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:AppText('취소')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:AppText('확인'))]))??false;
  Future<void> edit({PersonConnection? person,bool accept=false}) async {
    final name=TextEditingController(text:person?.name??'');
    final id=TextEditingController(text:person?.uid??'');
    var relation=person?.relation??'family';
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,update)=>AlertDialog(
      title:AppText(accept?'초대 수락':person==null?'사람 추가':'이름·관계 변경'),
      content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        AppText('이름과 관계는 내 목록에만 표시됩니다. 연결 ID를 본인에게 확인하세요.'),
        TextField(controller:name,maxLength:80,decoration:InputDecoration(labelText:AppLanguage.t('표시 이름'))),
        if(person==null)TextField(controller:id,maxLength:128,decoration:InputDecoration(labelText:AppLanguage.t('상대방 연결 ID')))else SelectableText(person.uid),
        DropdownButtonFormField<String>(value:relation,items:PeopleService.relations.entries.map((e)=>DropdownMenuItem(value:e.key,child:AppText(e.value))).toList(),onChanged:(value)=>update(()=>relation=value??'family')),
      ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:AppText('취소')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:AppText(accept?'수락':person==null?'초대 보내기':'저장'))])));
    final label=name.text.trim(),peer=id.text.trim();name.dispose();id.dispose();
    if(ok!=true||!mounted)return;
    await run(()async{
      if(accept){await PeopleService.accept(person!,label,relation);}
      else if(person==null){await PeopleService.invite(peer,label,relation);}
      else{await PeopleService.saveMetadata(person.uid,person.connectionId,label,relation);}
    });
  }
  Future<void> editGroup([Map<String,dynamic>? group]) async {
    final name=TextEditingController(text:group?['name'] as String? ?? '');
    final members=((group?['memberUids'] as List?)??[]).cast<String>().toSet();
    final accepted=people.where((p)=>p.status=='accepted').toList();
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,update)=>AlertDialog(title:AppText('내 산행 모임'),content:SizedBox(width:500,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      AppText('내가 공유 대상을 고르기 위한 묶음입니다. 모임에 넣어도 위치가 자동 공개되지 않습니다.'),
      TextField(controller:name,maxLength:80,decoration:InputDecoration(labelText:AppLanguage.t('모임 이름'))),
      for(final person in accepted)CheckboxListTile(title:Text(person.name),value:members.contains(person.uid),onChanged:(yes)=>update((){if(yes==true){members.add(person.uid);}else{members.remove(person.uid);}})),
    ]))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:AppText('취소')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:AppText('저장'))])));
    final label=name.text.trim();name.dispose();
    if(ok!=true||label.isEmpty||!mounted)return;
    members.retainAll(accepted.map((p)=>p.uid));
    await run(()=>PeopleService.saveGroup(group?['id'] as String?,label,members));
  }
  @override Widget build(BuildContext context){
    final incoming=people.where((p)=>p.status=='pending'&&p.incoming).toList();
    final accepted=people.where((p)=>p.status=='accepted').toList();
    final pending=people.where((p)=>p.status=='pending'&&!p.incoming).toList();
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      AppText('내 사람·모임',style:const TextStyle(fontSize:26,fontWeight:FontWeight.bold)),
      AppText('가족·친구를 한 번 연결한 뒤 산행·귀가·위치 공유에서 대상을 선택하세요.'),
      Wrap(spacing:8,runSpacing:8,children:[FilledButton.icon(onPressed:busy?null:()async{await Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>const ConnectionInvitePage()));if(mounted)await refresh();},icon:const Icon(Icons.person_add_alt_1),label:AppText('사람 추가')),OutlinedButton.icon(onPressed:busy?null:()=>editGroup(),icon:const Icon(Icons.groups_outlined),label:AppText('모임 만들기')),TextButton.icon(onPressed:busy?null:refresh,icon:const Icon(Icons.refresh),label:AppText('새로고침'))]),
      ExpansionTile(title:AppText('연결 ID 직접 입력'),children:[TextButton.icon(onPressed:busy?null:()=>edit(),icon:const Icon(Icons.keyboard),label:AppText('연결 ID 직접 입력')),TextButton.icon(onPressed:()=>Clipboard.setData(ClipboardData(text:PeopleService.uid)),icon:const Icon(Icons.copy),label:AppText('내 연결 ID 복사')),SelectableText(PeopleService.uid)]),
      if(loading||busy)const LinearProgressIndicator(),
      if(error.isNotEmpty)Card(child:Padding(padding:const EdgeInsets.all(16),child:AppText(error))),
      AppText('받은 초대',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      if(!loading&&incoming.isEmpty)AppText('받은 초대가 없습니다.'),
      for(final person in incoming)Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(person.name),SelectableText(person.uid),Wrap(spacing:8,children:[FilledButton(onPressed:busy?null:()=>edit(person:person,accept:true),child:AppText('수락')),TextButton(onPressed:busy?null:()=>run(()=>PeopleService.disconnect(person)),child:AppText('거절'))])]))),
      AppText('연결된 사람',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      if(!loading&&accepted.isEmpty)AppText('연결된 사람이 없습니다. 사람 추가를 눌러 초대를 보내세요.'),
      for(final person in accepted)Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(person.name,style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold)),
        AppText(PeopleService.relations[person.relation]??'가족'),
        AppText(audience.contains(person.uid)?'이번 위치 공유에 선택됨':'현재 내 위치 공유 대상 아님'),
        Wrap(spacing:8,runSpacing:4,children:[
          TextButton.icon(onPressed:busy?null:()=>widget.onWatch(person.uid),icon:const Icon(Icons.map_outlined),label:AppText('상대 위치 보기')),
          TextButton(onPressed:busy?null:()=>edit(person:person),child:AppText('이름·관계 변경')),
          if(audience.contains(person.uid))TextButton(onPressed:busy?null:()async{if(await confirm('이 사람에게 공유 중지','연결은 유지하고 현재 위치와 수색자료 조회 대상에서만 제외합니다.'))await run(()=>PeopleService.removeFromCurrentShare(person.uid));},child:AppText('공유 중지')),
          TextButton(onPressed:busy?null:()async{if(await confirm('연결 해제','양쪽 위치·수색자료 접근 연결을 해제합니다. 다시 연결하려면 새 초대와 수락이 필요합니다. 오프라인에서는 서버 반영이 지연될 수 있습니다.'))await run(()=>PeopleService.disconnect(person));},child:AppText('연결 해제',style:const TextStyle(color:Colors.red))),
        ]),
      ]))),
      if(pending.isNotEmpty)AppText('보낸 초대 · 수락 대기',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      for(final person in pending)Card(child:ListTile(title:Text(person.name),subtitle:SelectableText(person.uid),trailing:TextButton(onPressed:busy?null:()=>run(()=>PeopleService.disconnect(person)),child:AppText('초대 취소')))),
      AppText('내 산행 모임',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      if(!loading&&groups.isEmpty)AppText('모임이 없습니다. 연결된 사람을 묶어 공유 대상을 쉽게 고를 수 있습니다.'),
      for(final group in groups)Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(group['name'] as String),Wrap(spacing:8,children:[TextButton(onPressed:busy?null:()=>editGroup(group),child:AppText('모임 변경')),TextButton(onPressed:busy?null:()async{if(await confirm('모임 삭제','내 모임 묶음만 삭제합니다. 사람 연결과 진행 중 공유는 유지됩니다.'))await run(()=>PeopleService.groups.doc(group['id'] as String).delete());},child:AppText('모임 삭제'))])]))),
    ]);
  }
}
