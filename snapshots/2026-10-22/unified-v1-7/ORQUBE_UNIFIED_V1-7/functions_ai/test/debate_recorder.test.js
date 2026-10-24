'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const vm = require('node:vm');
const fs = require('node:fs');
function browser(surface) {
  let options, stopped=0;
  const video={getSettings:()=>({displaySurface:surface}),stop:()=>stopped++};
  const audio={stop:()=>stopped++};
  const stream={getVideoTracks:()=>[video],getAudioTracks:()=>[audio],getTracks:()=>[video,audio]};
  class Recorder {static isTypeSupported(){return true;} start(){this.state='recording';}}
  const window={MediaRecorder:Recorder};
  const navigator={mediaDevices:{getDisplayMedia:async x=>{options=x;return stream;},getUserMedia:()=>{throw Error('Microphone must never be requested');}}};
  vm.runInNewContext(fs.readFileSync(require.resolve('../../web/orqube_debate_recorder.js'),'utf8'),{window,navigator,MediaRecorder:Recorder,Date});
  return {recorder:window.orqubeRecorder,options:()=>options,stopped:()=>stopped};
}
test('recording requests tab audio and excludes system audio without microphone', async()=>{
  const b=browser('browser');
  await b.recorder.start();
  assert.equal(b.recorder.recording,true);
  assert.equal(b.options().systemAudio,'exclude');
  assert.equal(b.options().video.displaySurface,'browser');
});
test('monitor and window sharing are rejected and all tracks released',async()=>{
  for(const surface of ['monitor','window']) {
    const b=browser(surface);
    await assert.rejects(b.recorder.start(),/브라우저 탭/);
    assert.equal(b.stopped(),2);
    assert.equal(b.recorder.recording,false);
  }
});
