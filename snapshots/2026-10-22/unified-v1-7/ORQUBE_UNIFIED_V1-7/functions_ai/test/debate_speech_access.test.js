'use strict';
const {test} = require('node:test'), assert = require('node:assert/strict');
const {canSpeak} = require('../debate_speech_access');
test('only owner can read stored citizen, moderator, panel and summary text', () => {
  const session = {ownerUid: 'u', summary: '요약', lines: [{panel: 0, text: '반론'}, {panel: 3, text: '쟁점'}, {panel: 4, text: '시민패널입니다. 질문'}]};
  for (const line of session.lines) {
    assert(canSpeak(session, 'u', line.panel, line.text));
    assert(!canSpeak(session, 'other', line.panel, line.text));
    assert(!canSpeak(session, 'u', line.panel, '임의의 텍스트'));
  }
  assert(canSpeak(session, 'u', 3, '요약'));
  assert(!canSpeak(session, 'u', 4, '요약'));
  assert(!canSpeak(null, 'u', 3, '요약'));
});
