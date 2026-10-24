# ORQUBE AI MARKETING — FIELD 9: AI TOKEN LAUNCH / TOKEN CREATOR

## 적용 범위

이번 패치는 기존 8개 마케팅 분야와 `marketing_approval_queue` 구조를 보존하면서 9번째 분야 `AI_TOKEN_LAUNCH`를 추가한다.

현재 전달된 2026-08-27 최신 전체 ZIP에는 V4.1의 공개 웹 탐색 엔진 자체 소스는 포함되어 있지 않다. 따라서 이 패치는 V4.1 탐색기가 발견한 공개 타깃을 받아 AI 적합도 분석 → 토큰 활용안/홍보문 생성 → Firestore Approval Queue 저장 → 휴대폰 Human Approval까지 연결하는 실행 경계를 추가한다. 실제 V4.1 탐색 엔진 원본을 다시 합치면 `ai_marketing/field_09_ai_token_launch.json`의 분야 정의와 `analyzeAiTokenMarketingCandidate` 엔드포인트를 사용하면 된다.

## FIELD 9 흐름

`V4.1 공개웹 타깃 탐색` → `발견 후보(단체/크리에이터/커뮤니티/자영업/전문직/이벤트 등)` → `analyzeAiTokenMarketingCandidate` → `TOKEN_FIT_SCORE 0~100` → `토큰 활용안 1~5개` → `홍보 헤드라인/홍보문/접근 제안` → `marketing_approval_queue` PENDING → `휴대폰 승인/보류/제외`

승인을 눌러도 외부 실행은 자동 시작되지 않는다. `execution_enabled=NO`, `email_send=OFF`, `external_posting=OFF`, `paid_ads=OFF`를 계속 강제한다.

## TOKEN_FIT_SCORE

- 식별 가능한 고객·팬·회원 커뮤니티: 25
- 반복 참여/관계: 20
- 투자 목적이 아닌 실제 토큰 활용 가능성: 25
- 디지털/커뮤니티 도달성: 15
- 공식 접촉 가능성과 실제성: 15

추천 우선순위는 80점 이상 TOP PRIORITY, 65~79 REVIEW, 50~64 HOLD 후보로 사용한다. 가격 상승, 투자수익, 거래소 상장 기대는 점수 근거로 사용하지 않는다.

## 생성되는 활용안 예

멤버십/등급, 행사 참여·입장, 충성고객 리워드, 팬 참여, 기여도 인증, 커뮤니티 배지, 특정 서비스 접근권 등 실사용 중심으로 생성한다. 정치·선거, 수익보장형 투자, 도박·베팅, 불법·규제품목, 사칭성 유명인 토큰 등은 제외한다.

## Firebase Approval Queue 주요 필드

`field=AI_TOKEN_LAUNCH`, `verified_field=AI_TOKEN_LAUNCH`, `marketing_field_number=9`, `token_fit_score`, `verified_fit_score`, `token_fit_reason`, `token_use_cases[]`, `promo_headline`, `promo_copy`, `outreach_angle`, `approval_status=PENDING`.

## 서버 통합

기존 `functions/index.js`의 NAVER Cafe 동기화 기능은 그대로 두고, `functions/ai_launch_v081.js`와 `functions/ai_token_marketing.js`를 모듈로 추가해 export한다. 이로써 기존 V0.8.1 AI 토큰 텍스트/로고 서버 코드와 FIELD 9 분석 서버가 같은 Firebase Functions 배포 경로에 들어간다.

OpenAI API 키 Secret은 기존 AI Launch와 동일하게 `OPENAI_API_KEY`를 사용한다. 실제 배포 전 Firebase Functions 환경에 Secret이 설정되어 있어야 한다.

## 휴대폰 승인 화면

기존 전체 승인 대기열을 유지하고, Marketing Center에 `9 · AI TOKEN LAUNCH 승인` 버튼을 추가했다. TOKEN #9 카드에서는 TOKEN_FIT_SCORE, 적합 근거, 토큰 활용안, 홍보문, 접근 제안을 함께 확인할 수 있다.

## 변경 파일

- `functions/index.js` — AI Launch V0.8.1 + FIELD 9 모듈 export 추가
- `functions/ai_launch_v081.js` — 기존 V0.8.1 서버 코드를 실제 functions 배포 폴더로 이동한 복사본
- `functions/ai_token_marketing.js` — FIELD 9 AI 적합도/활용안/홍보문 생성 및 Approval Queue 저장
- `lib/admin/marketing_approval_page.dart` — TOKEN #9 상세 승인 카드 확장
- `lib/features/ai_launch/screens/ai_marketing_approval_page.dart` — FIELD 9 전용 승인 대기열
- `lib/pages/ai_marketing_center_page.dart` — FIELD 9 승인 버튼 연결
- `ai_marketing/field_09_ai_token_launch.json` — V4.1 탐색 엔진 합류용 분야/점수/큐 매핑 정의

## 배포 전 검증

이 작업 환경에는 Flutter SDK가 설치되어 있지 않아 `flutter analyze`/`flutter build`는 실행하지 못했다. Node 서버 파일은 `node --check`로 구문 검사를 통과했다. 사용자 PC에서는 패치 적용 후 `flutter analyze`, `flutter build web`, Firebase Functions/Firestore/Hosting 배포 순으로 확인한다.
