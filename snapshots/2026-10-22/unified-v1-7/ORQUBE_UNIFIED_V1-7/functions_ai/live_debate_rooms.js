'use strict';
const {onRequest} = require('firebase-functions/v2/https');
const {getAuth} = require('firebase-admin/auth');
const {getFirestore, Timestamp} = require('firebase-admin/firestore');
const fail=(message,status=400)=>Object.assign(new Error(message),{status});
const text=(v,n)=>String(v || '').trim().slice(0,n);
exports.manageLiveDebateRoom=onRequest({region:'asia-northeast3',cors:true,invoker:'public',timeoutSeconds:30},async(req,res)=>{
 res.set('Cache-Control','no-store');
 if(req.method==='OPTIONS')return res.status(204).send('');
 if(req.method!=='POST')return res.status(405).json({error:'POST 요청만 지원합니다.'});
 try{
  const token=(req.get('authorization')||'').match(/^Bearer\s+(.+)$/i);
  if(!token)throw fail('로그인이 필요합니다.',401);
  const user=await getAuth().verifyIdToken(token[1],true);
  if(!user.email_verified)throw fail('이메일 인증 후 이용해 주세요.',403);
  const db=getFirestore(), b=req.body||{}, action=b.action;
  const guard=db.collection('live_debate_usage').doc(user.uid);
  await db.runTransaction(async tx=>{
   const g=(await tx.get(guard)).data()||{}, day=new Date().toISOString().slice(0,10);
   const count=g.day===day?Number(g.count||0):0;
   if(count>=1000 || (g.lastAt && Date.now()-g.lastAt.toMillis()<400))throw fail('요청이 너무 많습니다. 잠시 후 다시 시도하세요.',429);
   const creates=g.day===day?Number(g.creates||0):0;
   if(action==='create'&&creates>=10)throw fail('하루 토론방 생성 한도에 도달했습니다.',429);
   tx.set(guard,{day,count:count+1,creates:creates+(action==='create'?1:0),lastAt:Timestamp.now()});
  });
  if(action==='create'){
   const topic=text(b.topic,500), minutes=Number(b.minutes);
   if(topic.length<2 || !Number.isInteger(minutes)||minutes<1||minutes>120)throw fail('주제와 1~120분 토론 시간을 입력하세요.');
   const ref=db.collection('live_debate_rooms').doc();
   await ref.set({topic,minutes,ownerUid:user.uid,status:'waiting',memberUids:[user.uid],
    members:{[user.uid]:{name:text(user.name||'방장',50),role:'host',lastMessageAt:0}},
    floorUid:'',createdAt:Timestamp.now(),endAt:null,summary:'',updatedAt:Timestamp.now()});
   return res.json({roomId:ref.id});
  }
  const roomId=text(b.roomId,128);
  if(!/^[A-Za-z0-9_-]{1,128}$/.test(roomId))throw fail('올바른 참가 코드를 입력하세요.');
  const ref=db.collection('live_debate_rooms').doc(roomId);
  const result=await db.runTransaction(async tx=>{
   const room=(await tx.get(ref)).data();
   if(!room)throw fail('토론방을 찾을 수 없습니다.',404);
   const now=Date.now(),expired=room.endAt && now>=room.endAt.toMillis();
   const members={...room.members}, current=members[user.uid];
   if(action==='join'){
    if(current)return {roomId};
    if(room.status==='ended'||expired)throw fail('종료된 토론방입니다.',409);
    if(room.memberUids.length>=30)throw fail('토론방 정원 30명에 도달했습니다.',409);
    members[user.uid]={name:text(user.name||'참가자',50),role:'audience',lastMessageAt:0};
    tx.update(ref,{members,memberUids:[...room.memberUids,user.uid],updatedAt:Timestamp.now()});
    return {roomId};
   }
   if(!current)throw fail('먼저 참가 코드로 입장해 주세요.',403);
   const host=user.uid===room.ownerUid, moderator=host||current.role==='moderator';
   if(action==='assign'){
    if(!host)throw fail('역할은 방장만 지정할 수 있습니다.',403);
    if(room.status!=='waiting')throw fail('역할 설정은 토론 시작 전에 가능합니다.',409);
    const target=text(b.targetUid,128), role=b.role;
    if(target===room.ownerUid || !members[target] || !['panel','moderator','audience'].includes(role))throw fail('역할 지정 대상이 올바르지 않습니다.');
    members[target]={...members[target],role};tx.update(ref,{members,updatedAt:Timestamp.now()});
   }else if(action==='start'){
    if(!moderator)throw fail('방장 또는 중재자만 시작할 수 있습니다.',403);
    if(room.status!=='waiting')throw fail('이미 시작되거나 종료된 토론방입니다.',409);
    tx.update(ref,{status:'live',startedAt:Timestamp.now(),endAt:Timestamp.fromMillis(now+room.minutes*60000),updatedAt:Timestamp.now()});
   }else if(action==='floor'){
    if(!moderator)throw fail('중재 권한이 없습니다.',403);
    if(room.status!=='live'||expired)throw fail('진행 중인 토론이 아닙니다.',409);
    const target=text(b.targetUid,128);
    if(target && (!members[target]||!['panel','host','moderator'].includes(members[target].role)))throw fail('발언할 패널을 선택하세요.');
    tx.update(ref,{floorUid:target,updatedAt:Timestamp.now()});
   }else if(action==='end'){
    if(!moderator)throw fail('중재 권한이 없습니다.',403);
    if(room.status==='ended')return {roomId};
    const summary=text(b.summary,4000);
    tx.update(ref,{status:'ended',summary,endedAt:Timestamp.now(),floorUid:'',updatedAt:Timestamp.now()});
   }else if(action==='send'){
    if(room.status!=='live'||expired)throw fail('토론 시간이 종료되었습니다.',409);
    if(!['host','moderator','panel'].includes(current.role))throw fail('방장이 패널로 지정한 후 발언할 수 있습니다.',403);
    if(room.floorUid && room.floorUid!==user.uid && !moderator)throw fail('중재자가 지정한 발언 차례를 기다려 주세요.',403);
    const content=text(b.text,2000), id=text(b.messageId,128);
    if(!content||!/^[A-Za-z0-9_-]{1,128}$/.test(id))throw fail('발언 내용을 입력하세요.');
    const msg=ref.collection('messages').doc(user.uid+'_'+id);
    const existing=await tx.get(msg);
    if(existing.exists)return {roomId};
    if(now-Number(current.lastMessageAt||0)<2000)throw fail('발언은 2초 간격으로 등록해 주세요.',429);
    members[user.uid]={...current,lastMessageAt:now};
    tx.create(msg,{uid:user.uid,name:current.name,role:current.role,text:content,createdAt:Timestamp.now()});
    tx.update(ref,{members,updatedAt:Timestamp.now()});
   }else throw fail('지원하지 않는 동작입니다.');
   return {roomId};
  });
  return res.json(result);
 }catch(e){console.error('manageLiveDebateRoom',e.code||e.status||'');return res.status(e.status||(String(e.code||'').startsWith('auth/')?401:500)).json({error:e.status?e.message:'서버 인증 또는 토론방 처리에 실패했습니다.'});}
});
