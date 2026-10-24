# ORQUBE AI MARKETING — FUSION V1

## 이번 개발 범위

- AI MARKETING 첫 화면을 두 개의 명확한 작업공간으로 분리
  - 관리자 전용 `ORQUBE 공식 홍보`
  - 토큰 소유자 전용 `내 토큰 홍보`
- 하나의 메시지 핵에서 채널별 콘텐츠를 생성하는 핵융합식 캠페인 엔진 추가
- ORQUBE 홈, Facebook, X, YouTube, 네이버 카페, Telegram, Discord, QR/오프라인 채널 선택
- 캠페인 핵, 슬로건, 대상 인사이트, 콘텐츠 기둥, 채널별 문안, 7일 확산 순서, 위험 점검 생성
- 모든 생성 결과는 `DRAFT / PENDING`으로 저장하며 자동 게시 금지
- 관리자 역할과 토큰 소유권을 Cloud Functions에서 재검증

## 핵융합식 생성 흐름

`목표 → 메시지 핵 → 채널별 증식 → 사람 검토·승인 → 성과 재활용`

ORQUBE 공식 홍보와 개발자 토큰 홍보는 같은 생성 엔진을 사용하지만 발신자와 데이터가 섞이지 않습니다. 공식 홍보는 관리자만 생성할 수 있고, 토큰 홍보는 본인이 소유한 `launch_projects` 문서만 사용할 수 있습니다.

## 배포 전 확인

1. `OPENAI_API_KEY` Firebase Secret 유지 여부 확인
2. AI Functions 배포: `firebase deploy --only functions:ai`
3. 웹 빌드 및 Hosting 배포
4. 관리자 계정에서 공식 홍보 카드 진입 확인
5. 일반 토큰 소유자 계정에서 내 토큰 선택 및 캠페인 생성 확인
6. Firestore `marketing_campaigns`에 `campaignEngine: FUSION_V1`, `status: draft`, `approvalStatus: PENDING` 저장 확인

## 안전 원칙

- 투자수익, 가격상승, 상장 보장 문구 생성 금지
- 선거 설득, 도박, 성인·불법 업종, 사칭·기만 홍보 제한
- AI는 초안만 만들며 외부 게시·메시지·광고 집행은 사람 승인 후 별도 단계에서 수행
