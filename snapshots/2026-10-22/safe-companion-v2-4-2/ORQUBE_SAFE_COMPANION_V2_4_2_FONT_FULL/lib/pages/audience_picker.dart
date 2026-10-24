import '../utils/audience_selection.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/people_service.dart';
import '../utils/app_language.dart';
import 'guardian_page.dart';

class AudienceSelection {
  final Set<String> live, search;
  final String names;
  const AudienceSelection(this.live,this.search,this.names);
}
Future<AudienceSelection?> chooseAudience(BuildContext context, {required bool hiking, bool apply = true}) async {
  var people = (await PeopleService.load()).where((p) => p.status == 'accepted').toList();
  if (!context.mounted) return null;
  if (people.isEmpty) {
    await showDialog<void>(context:context,builder:(ctx)=>AlertDialog(title:AppText('연결된 사람이 없습니다.'),content:AppText('내 사람·모임에서 가족·친구를 추가하고 상대가 초대를 수락한 뒤 공유할 수 있습니다.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:AppText('닫기')),FilledButton(onPressed:(){Navigator.pop(ctx);Navigator.push(context,MaterialPageRoute(builder:(_)=>GuardianPage()));},child:AppText('내 사람·모임'))]));
    return null;
  }
  final saved = await PeopleService.db.collection('safety_shares').doc(PeopleService.uid).get(const GetOptions(source:Source.server));
  final groupRows = await PeopleService.groups.get(const GetOptions(source:Source.server));
  if (!context.mounted) return null;
  final valid = people.map((p)=>p.uid).toSet();
  final live = ((saved.data()?['viewerUids'] as List?)??[]).cast<String>().toSet().intersection(valid);
  final search = hiking ? ((saved.data()?['searchViewerUids'] as List?)??[]).cast<String>().toSet().intersection(live) : <String>{};
  final agreed = await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,refresh)=>AlertDialog(
    title:AppText('공유 대상 선택'),
    content:SizedBox(width:560,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      AppText('연결만으로 위치가 공개되지 않습니다. 이번 이동에 공유할 사람을 선택하세요.'),
      if (hiking) AppText('수색자료 조회는 사람마다 별도로 선택합니다. 서버 수신 후 최대 24시간 마지막 기록을 볼 수 있습니다.'),
      Wrap(spacing:6,children:groupRows.docs.map((group)=>ActionChip(label:Text(group.data()['name'] as String),onPressed:()=>refresh(()=>live.addAll(eligibleGroupMembers((group.data()['memberUids'] as List).cast<String>(),valid))))).toList()),
      for(final person in people) Card(child:Padding(padding:const EdgeInsets.all(8),child:Column(children:[
        CheckboxListTile(contentPadding:EdgeInsets.zero,title:Text(person.name),subtitle:AppText(PeopleService.relations[person.relation]??'가족'),value:live.contains(person.uid),onChanged:(yes)=>refresh((){if(yes==true){live.add(person.uid);}else{live.remove(person.uid);search.remove(person.uid);}})),
        if(hiking && live.contains(person.uid)) CheckboxListTile(contentPadding:EdgeInsets.zero,title:AppText('마지막 산행 기록 조회 허용'),value:search.contains(person.uid),onChanged:(yes)=>refresh((){if(yes==true){search.add(person.uid);}else{search.remove(person.uid);}})),
      ]))),
    ]))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:AppText('취소')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:AppText('선택 적용'))])));
  if(agreed!=true)return null;
  if (apply) await PeopleService.setAudience(live,search);
  return AudienceSelection(live,search,people.where((p)=>live.contains(p.uid)).map((p)=>p.name).join(', '));
}
