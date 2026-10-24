const {test}=require('node:test'),assert=require('node:assert/strict');
const fs=require('node:fs'),vm=require('node:vm');
test('capture excludes microphone/system audio; muted monitor retains speech recording; restart and download',async()=>{
 let clicks=0, captureOptions, recorded, source, monitor, destination, requests=0;
 const video={kind:'video',stop(){this.stopped=true;}};
 const audio={kind:'audio',stop(){this.stopped=true;}};
 class Stream{constructor(tracks){this.tracks=tracks;} getTracks(){return this.tracks;} getVideoTracks(){return this.tracks.filter(t=>t.kind==='video');}getAudioTracks(){return this.tracks.filter(t=>t.kind==='audio');}}
 class AudioContext{
  constructor(){this.destination={type:'speakers'};}
  resume(){return Promise.resolve();}
  createMediaStreamDestination(){destination={stream:new Stream([audio])};return destination;}
  createGain(){monitor={gain:{value:1},connect(x){this.target=x;}};return monitor;}
  createMediaElementSource(){source={targets:[],connect(x){this.targets.push(x);},disconnect(){this.targets=[];}};return source;}
 }
 class Recorder{static isTypeSupported(t){return t==='video/webm';}constructor(stream){recorded=stream;this.state='inactive';}start(){this.state='recording';}stop(){this.state='inactive';this.ondataavailable({data:new Blob(['video'])});this.onstop();}}
 const window={MediaRecorder:Recorder,AudioContext};
 vm.runInNewContext(fs.readFileSync(__dirname+'/../web/orqube_debate_recorder.js','utf8'),{window,MediaRecorder:Recorder,MediaStream:Stream,navigator:{mediaDevices:{getDisplayMedia:async options=>{requests++;captureOptions=options;return new Stream([video]);},getUserMedia:()=>{throw Error('microphone must never be accessed');}}},Blob,Date,URL:{createObjectURL:()=> 'blob:test',revokeObjectURL(){}},document:{createElement:()=>({click(){clicks++;},remove(){}}),body:{appendChild(){}}},setTimeout:f=>f()});
 const events={};window.orqubeDebateAudio.attach({addEventListener:(k,f)=>events[k]=f},0);
 assert.equal(monitor.gain.value,0);assert.deepEqual(source.targets,[destination,monitor]);
 for(let i=0;i<2;i++){
  const notice=await window.orqubeRecorder.start();assert(window.orqubeRecorder.recording);assert(notice.includes('주변 소음'));
  assert.equal(captureOptions.audio,false);assert.equal(captureOptions.video,true);
  assert.equal(recorded.getAudioTracks().length,1);assert.equal(recorded.getAudioTracks()[0],audio);
  const filename=await window.orqubeRecorder.stop();assert(filename.endsWith('.webm'));assert(!window.orqubeRecorder.recording);
  assert(!audio.stopped);
 }
 assert.equal(clicks,2);assert.equal(requests,2);events.pause();assert.equal(source.targets.length,0);
});
