'use strict';
const test = require('node:test'), assert = require('node:assert/strict');
const vm = require('node:vm'), fs = require('node:fs'), path = require('node:path');
function setup() {
  const instances = [], window = {};
  class Audio {
    constructor(url) { this.url = String(url); instances.push(this); }
    play() { return Promise.resolve(); }
    pause() { this.paused = true; }
  }
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, '../../web/orqube_debate_effects.js'),'utf8'),
    {window, Audio, URL, document:{baseURI:'https://example.test/app/'}, setTimeout, clearTimeout});
  return {bus:window.orqubeEffects, instances};
}
test('reaction selection, volume and waiting for playback end', async () => {
  const {bus,instances} = setup();
  bus.setVolume(.4);
  const pending = bus.play('웃음');
  assert.match(instances[0].url, /app\/debate_sfx\/laugh.wav$/);
  assert.equal(instances[0].volume, .4);
  instances[0].onended(); await pending;
  await bus.play('반박');
  assert.equal(instances.length,1);
  bus.setVolume(0); await bus.play('박수');
  assert.equal(instances.length,1);
});
test('stop releases pending reaction and pauses sound', async () => {
  const {bus,instances} = setup();
  const pending = bus.play('반전');
  bus.stop(); await pending;
  assert.equal(instances[0].paused,true);
  assert.equal(instances[0].src,'');
});
test('gesture unlock resumes Web Audio and reactions use decoded buffers', async () => {
  const events = [], window = {};
  class Context {
    constructor() { this.destination = {}; }
    async resume() { events.push('resume'); }
    async decodeAudioData() { events.push('decode'); return {}; }
    createGain() { return {gain:{value:0},connect(){}}; }
    createBufferSource() { return {connect(){},start(){events.push('start');queueMicrotask(()=>this.onended());},stop(){}}; }
  }
  window.AudioContext = Context;
  vm.runInNewContext(fs.readFileSync(path.join(__dirname,'../../web/orqube_debate_effects.js'),'utf8'),
    {window, URL, document:{baseURI:'https://example.test/'}, fetch:async()=>({ok:true,arrayBuffer:async()=>new ArrayBuffer(4)}),queueMicrotask, console});
  await window.orqubeEffects.unlock();
  await window.orqubeEffects.play('웃음');
  await window.orqubeEffects.play('웃음');
  assert.equal(events.filter(x=>x==='decode').length,1);
  assert.equal(events.filter(x=>x==='start').length,2);
  assert.equal(events[0],'resume');
});
