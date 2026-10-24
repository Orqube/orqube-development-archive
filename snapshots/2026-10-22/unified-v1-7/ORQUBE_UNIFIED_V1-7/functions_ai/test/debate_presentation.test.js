'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const {normalizeVisuals, attachVisualIds} = require('../debate_presentation');
const {parseDebateOutput} = require('../debate_output');
test('visuals exclude image bytes, reject invalid and duplicate IDs, bound user content', () => {
  const actual = normalizeVisuals([null, {id:'../bad',title:'bad'},
    {id:'token',title:'토큰',content:'a'.repeat(2000),image:'secret'},
    {id:'token',title:'duplicate'}, {id:'qr',title:'QR'}]);
  assert.equal(actual.length,2); assert.equal(actual[0].content.length,1400);
  assert.equal(actual[0].image,undefined); assert.equal(actual[1].status,'상태 확인 필요');
  assert.equal(normalizeVisuals('bad').length,0);
  assert.equal(normalizeVisuals(Array.from({length:30}, (_,i)=>({id:`id_${i}`,title:'title'}))).length,20);
});
test('AI visual IDs survive sorting and invalid IDs cannot select fabricated material', () => {
  const raw = {panelA:[{order:2,stage:'설명',text:'토큰',visualId:'token'}],
    panelB:[{order:1,stage:'반박',text:'조건',visualId:'invented'}],
    panelC:[{order:3,stage:'사례',text:'QR',visualId:'qr'}], moderator:[], summary:'요약',checks:[]};
  const parsed = parseDebateOutput({output_text:JSON.stringify(raw)});
  const result = attachVisualIds(parsed,normalizeVisuals([{id:'token',title:'Token'},{id:'qr',title:'QR'}]));
  assert.deepEqual(result.lines.map(x=>x.visualId),['','token','qr']);
  assert.deepEqual(result.lines.map(x=>x.panel),[1,0,2]);
});
test('legacy output remains unchanged without visualId and summary parsing stays compatible', () => {
  const raw = {panelA:[{order:1,stage:'s',text:'a'}],panelB:[{order:2,stage:'s',text:'b'}],
    panelC:[{order:3,stage:'s',text:'c'}],moderator:[],summary:'s',checks:[]};
  assert.deepEqual(parseDebateOutput({output_text:JSON.stringify(raw)}).lines[0],{panel:0,stage:'s',text:'a'});
  assert.deepEqual(parseDebateOutput({output_text:JSON.stringify(raw)},true),{summary:'s',checks:[]});
});
