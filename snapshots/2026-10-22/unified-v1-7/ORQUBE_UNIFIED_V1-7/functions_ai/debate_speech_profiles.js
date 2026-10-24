 'use strict';
const SPEECH_VERSION = 'dev33-fast-male-v1';
const profiles = [
  {voice: 'onyx', speed: 1.18, instructions: 'Natural Korean live debate. Original adult male baritone, firm energetic rebuttals, quick conversational pace. Stress the disputed words and deliver questions sharply. Brief breaths only, no slow narration, no theatrical shouting. Do not imitate any real person.'},
  {voice: 'echo', speed: 1.20, instructions: 'Natural Korean live debate, original bright adult male voice, fast incisive counterarguments and animated questions. Varied emphasis, brief breaths. Never slowly read a report; never imitate a real person.'},
  {voice: 'ash', speed: 1.12, instructions: 'Natural Korean live debate, original male lower-mid voice. Speak promptly and clearly, with firm counterquestions and concise reasoning. Slow slightly only to clarify evidence; do not drone or imitate a real person.'},
  // Fixed Onyx timbre for BOTH moderator lines and final summary.
  // Legacy TTS does not accept instructions; do not send them with this model.
  {model: 'tts-1-hd', voice: 'onyx', speed: 1.12},
  {voice: 'coral', speed: 1.10, instructions: 'Natural Korean citizen question, clear conversational delivery, brief introduction and short breaths, no slow recital, no real-person imitation.'},
];
function speechProfile(panel) {
  if (!Number.isInteger(panel) || panel < 0 || panel >= profiles.length) throw new RangeError('INVALID_PANEL');
  return {model: 'gpt-4o-mini-tts', ...profiles[panel]};
}
module.exports = {speechProfile, SPEECH_VERSION};
