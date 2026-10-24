// ORQUBE AI-only Firebase Functions codebase.
// Kept separate so AI deployment never asks for NAVER_CLIENT_ID/SECRET.
Object.assign(exports, require('./ai_launch_v081'));
Object.assign(exports, require('./ai_token_marketing'));
Object.assign(exports, require('./ai_debate'));

Object.assign(exports, require('./mixed_debate_rooms'));

Object.assign(exports, require('./auto_marketing'));
