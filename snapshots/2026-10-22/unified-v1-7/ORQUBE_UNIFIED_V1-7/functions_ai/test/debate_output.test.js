'use strict';
const {test} = require('node:test');
const assert = require('node:assert/strict');
const {parseDebateOutput: parse} = require('../debate_output');
const valid = () => ({panelA: [{order: 2, stage: '시민 답변', text: 'A 답변'}], panelB: [{order: 1, stage: '시민 답변', text: 'B 답변'}], panelC: [{order: 3, stage: '시민 답변', text: 'C 답변'}], summary: '요약', checks: []});
test('citizen question returns all three numeric panels in contextual order', () => {
  const result = parse({output: [{content: [{type: 'output_text', text: JSON.stringify(valid())}]}]});
  assert.deepEqual(result.lines.map(x => x.panel), [1, 0, 2]);
});
test('missing panel is rejected, no fabricated answer', () => {
  const data = valid(); data.panelC = [];
  assert.throws(() => parse({output_text: JSON.stringify(data)}), {message: 'INVALID_AI_OUTPUT', status: 502});
});
test('incomplete, refusal, invalid JSON and summary are handled separately', () => {
  assert.throws(() => parse({status: 'incomplete'}), {message: 'AI_OUTPUT_INCOMPLETE'});
  assert.throws(() => parse({output: [{content: [{type: 'refusal'}]}]}), {message: 'AI_REFUSED'});
  assert.throws(() => parse({output_text: '{'}), {message: 'INVALID_AI_OUTPUT'});
  assert.deepEqual(parse({output_text: '{"summary":"최종요약","checks":[]}'}, true), {summary: '최종요약', checks: []});
});
test('tied order preserves answers; empty text rejected', () => {
  const data = valid(); data.panelC[0].order = 1;
  assert.equal(parse({output_text: JSON.stringify(data)}).lines.length, 3);
  data.panelC[0].order = 3; data.panelA[0].text = ' ';
  assert.throws(() => parse({output_text: JSON.stringify(data)}));
});

test('short and detailed speeches coexist without truncation', () => {
  const data = valid();
  data.panelA[0].text = '간단히 동의합니다.';
  data.panelB[0].text = '주장과 근거 및 사례를 상세히 설명합니다. '.repeat(70);
  const result = parse({output_text: JSON.stringify(data)});
  assert.equal(result.lines.find(x => x.panel === 1).text, data.panelB[0].text);
  assert.equal(result.lines.find(x => x.panel === 0).text, data.panelA[0].text);
});

test('moderator redirects between panel replies in the generated order', () => {
  const data=valid(); data.moderator=[{order:0,stage:'논점 정리',text:'핵심 질문으로 돌아가죠.'}];
  const result=parse({output_text:JSON.stringify(data)});
  assert.deepEqual(result.lines.map(x=>x.panel),[3,1,0,2]);
  data.moderator=[{order:0,stage:'논점 정리',text:''}];
  assert.throws(()=>parse({output_text:JSON.stringify(data)}),{message:'INVALID_AI_OUTPUT'});
});
