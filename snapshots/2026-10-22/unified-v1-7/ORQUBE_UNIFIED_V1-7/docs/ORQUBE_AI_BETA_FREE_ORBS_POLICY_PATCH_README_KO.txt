ORQUBE AI ASSISTANT BETA FREE / ORBS POLICY PATCH
Date: 2026-09-15
Base: swap-center6 + ORQUBE_AI_CHAT_FIRESTORE_WALLET_INTEGRATED_PATCH_2026-09-15

[이번 패치의 목적]
ORQUBE AI Assistant를 처음부터 전면 유료화하지 않고 BETA 단계에서 충분히 사용/검증할 수 있도록 합니다.
동시에 향후 ORBS 유료 고급분석으로 자연스럽게 확장할 수 있는 정책 표시와 서버 사용량 제한을 넣었습니다.

[현재 BETA 정책]
1) 기본 안내 / 가이드라인: 무료
2) OpenAI 기반 AI 심층분석: 사용자별 하루 10회 무료
3) 향후 고급 프로젝트 분석: ORBS 선택 결제 예정
4) 현재 BETA에서는 ORBS를 자동 차감하지 않음
5) OpenAI 호출이 실패한 경우(예: API credit 부족) 무료 10회 횟수에 포함하지 않음

[화면 변경]
- ORQUBE AI ASSISTANT 상단에 BETA · FREE 표시
- AI 이용 정책 카드 추가
- 빠른 질문 버튼의 흰색/글자 미표시 문제 수정
- 성공한 AI 답변에 "오늘 무료 n/10회 남음" 표시
- 하루 10회 소진 시 ORBS 자동 차감 없이 기본 안내 모드 유지

[PROJECT WALLET 보완]
TOKEN PROFILE의 WALLET ADDRESS CHECK에서 프로젝트 주소가 비어 있을 때 아래 순서로 자동 확인합니다.
1. launch_projects.testnetVerifiedWallet / walletAddress
2. launch_deployment_archives.walletAddress
3. launch_wallets.walletAddress (참고값)

ACCOUNT WALLET을 참고값으로 사용하는 경우 실제 배포/결제 전 재확인 안내를 표시합니다.

[Flutter ListTile 경고 보완]
AI 이용 가이드라인의 ExpansionTile을 Material 위에 렌더링하도록 수정하여
"ListTile background color or ink splashes may be invisible" 경고 원인을 제거했습니다.

[서버 사용량 기록]
Firestore ai_launch_usage/{uid} 문서에 assistantBetaCount를 사용합니다.
기존 chatCount와 분리했으므로 이전 테스트/실패 기록이 새 BETA 10회에 영향을 주지 않습니다.
날짜가 바뀌면 새 일일 카운트로 동작합니다(서버 UTC 날짜 기준).

[적용]
프로젝트 최상위 폴더에 ZIP 내부 파일을 경로 그대로 덮어씁니다.

1. Flutter 확인
   flutter pub get
   flutter run -d chrome

2. AI Functions 재배포 (backend 파일이 변경되었으므로 필요)
   PowerShell:
   $env:FUNCTIONS_DISCOVERY_TIMEOUT="60"
   firebase deploy --only functions:ai

3. 테스트
   - AI 도움 열기
   - BETA · FREE 및 이용 정책 표시 확인
   - 빠른 질문 버튼 글씨 확인
   - 실제 AI 성공 시 "오늘 무료 9/10회 남음" 형태 표시 확인
   - TOKEN PROFILE > WALLET ADDRESS CHECK에서 PROJECT WALLET 자동 표시 확인

[중요]
- OPENAI_API_KEY의 API credit이 없으면 서버 AI는 계속 ORQUBE 안내 모드로 동작합니다.
- API credit 부족/서버 오류는 assistantBetaCount를 소비하지 않도록 했습니다.
- 이번 패치는 실제 ORBS 결제를 시작하지 않습니다. 고급 분석 유료 결제는 가격/환불/사용량 정책을 확정한 뒤 별도 단계로 연결하는 것이 안전합니다.
- 비밀키, 시드 문구, 12단어 복구문구, 비밀번호, 인증번호는 AI에 입력하지 마세요.
