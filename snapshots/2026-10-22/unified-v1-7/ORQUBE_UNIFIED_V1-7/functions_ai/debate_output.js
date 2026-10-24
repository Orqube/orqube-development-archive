 'use strict';
const failure = code => Object.assign(new Error(code), {status: 502});
exports.parseDebateOutput = (json, summarize = false) => {
  if (json.status === 'incomplete') throw failure('AI_OUTPUT_INCOMPLETE');
  const content = (json.output || []).flatMap(x => x.content || []);
  if (content.some(x => x.type === 'refusal')) throw failure('AI_REFUSED');
  let result;
  try { result = JSON.parse(json.output_text || content.filter(x => x.type === 'output_text').map(x => x.text).join('')); }
  catch (_) { throw failure('INVALID_AI_OUTPUT'); }
  if (!result || typeof result.summary !== 'string' || !Array.isArray(result.checks) || result.checks.some(x => typeof x !== 'string')) throw failure('INVALID_AI_OUTPUT');
  if (summarize) return {summary: result.summary, checks: result.checks};
  const groups = ['panelA', 'panelB', 'panelC'].map(k => result[k]);
  if (groups.some(g => !Array.isArray(g) || g.length < 1 || g.length > 4 || g.some(x => !x || typeof x.stage !== 'string' || typeof x.text !== 'string' || !x.text.trim()))) throw failure('INVALID_AI_OUTPUT');
  const moderator = result.moderator || [];
  if (!Array.isArray(moderator) || moderator.length > 2 || moderator.some(x => !x || typeof x.stage !== 'string' || typeof x.text !== 'string' || !x.text.trim())) throw failure('INVALID_AI_OUTPUT');
  const ordered = groups.flatMap((g, panel) => g.map(x => ({panel, ...x}))).concat(moderator.map(x => ({panel: 3, ...x})));
  if (ordered.some(x => !Number.isInteger(x.order))) throw failure('INVALID_AI_OUTPUT');
  const lines = ordered.sort((a, b) => a.order - b.order).map(({panel, stage, text, visualId}) => ({panel, stage, text,
    ...(typeof visualId === 'string' ? {visualId} : {})}));
  return {lines, summary: result.summary, checks: result.checks};
};
