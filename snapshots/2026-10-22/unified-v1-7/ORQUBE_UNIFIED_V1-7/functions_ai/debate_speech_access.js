'use strict';
exports.canSpeak = (session, uid, panel, text) => !!session && session.ownerUid === uid &&
  ((panel === 3 && session.summary === text) ||
    (Array.isArray(session.lines) && session.lines.some(x => x.panel === panel && x.text === text)));
