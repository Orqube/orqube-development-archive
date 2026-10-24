'use strict';
const clean=(v,n=500)=>String(v||'').trim().slice(0,n);
const fail=(message,status=400)=>Object.assign(new Error(message),{status});
function profiles(raw){
 if(!Array.isArray(raw)||raw.length!==4)throw fail('진행자와 패널 3명을 설정하세요.');
 return raw.map((p,i)=>{
  const type=p.type==='human'?'human':'ai';
  const image=String(p.imageBase64||'');
  if(image.length>200000||image.length%4!==0)throw fail('프로필 사진은 압축된 150KB 이하 JPG로 저장하세요.');
  if(image&&(!/^[A-Za-z0-9+/]+={0,2}$/.test(image)||!Buffer.from(image,'base64').subarray(0,3).equals(Buffer.from([255,216,255]))))throw fail('프로필 사진 형식 오류');
  return {name:clean(p.name,40)|| (i===3?'진행자':`패널 ${i+1}`),type,
   uid:type==='human'?clean(p.uid,128):'',gender:p.gender==='female'?'female':'male',
   appearance:clean(p.appearance,1000),personality:clean(p.personality,600),
   speakingStyle:clean(p.speakingStyle,600),ideology:clean(p.ideology,600),
   imageMode:p.imageMode==='generate'?'generate':'upload',imageBase64:image};
 });
}
function member(room,uid){if(!room.memberUids.includes(uid))throw fail('토론방 입장이 필요합니다.',403);}
function host(room,uid){member(room,uid);if(room.ownerUid!==uid)throw fail('방장만 관리할 수 있습니다.',403);}
function live(room){if(room.status!=='live'||Date.now()>=room.endAt.toMillis())throw fail('진행 시간이 종료되었습니다.',409);}
function aiProfiles(room){return room.profiles.map((p,panel)=>({panel,name:p.name,type:p.type,personality:p.personality,speakingStyle:p.speakingStyle,ideology:p.ideology}));}
module.exports={clean,fail,profiles,member,host,live,aiProfiles};
