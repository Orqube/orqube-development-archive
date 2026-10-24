ORQUBE AI ROBOT CHAT + FIRESTORE BALANCE STABILITY + WALLET ADDRESS CHECK PATCH
2026-09-15

[이번 패치 목적]
기존 토큰 생성/배포 기능은 최대한 그대로 유지하면서 아래 3가지를 통합했습니다.

1) Firestore ORBS 잔액 읽기 안정화
2) PROJECT WALLET / MetaMask / Kaia Wallet 전체 주소 비교
3) ORQUBE AI ASSISTANT (AI 로봇챗 + 이용 가이드라인)

※ 토큰 생성 화면의 6개국어 전체 번역은 이번 작업에서 추가하지 않았습니다.

==================================================
1. FIRESTORE ORBS 잔액 읽기 안정화
==================================================
기존 화면은 launch_wallets / launch_starter_requests / launch_config 중
한 곳의 읽기만 실패해도 전체 Future.wait가 실패하면서 AVAILABLE ORBS가
실제 잔액과 관계없이 0처럼 보일 수 있었습니다.

수정 내용
- launch_wallets(잔액/지갑)를 가장 먼저 읽습니다.
- Starter 지급기록과 Deploy 설정을 각각 별도로 읽습니다.
- 한 문서가 실패해도 이미 정상적으로 읽은 잔액은 유지합니다.
- Firestore 서버 직접 읽기(Source.server)를 먼저 시도합니다.
- 실패 시 SDK 기본 읽기를 한 번 더 재시도합니다.
- 읽기 실패는 실제 0 ORBS와 구분하여 "확인 필요"로 표시합니다.
- 잔액/Starter 확인 전에는 중복 지급 방지를 위해 Starter 버튼을 잠급니다.
- 로그인 UID와 ownerUid 불일치도 화면에서 구분해 안내합니다.

따라서 Firestore에 10 ORBS가 정상 저장되어 있는데 브라우저 읽기만 실패한 경우,
더 이상 0 ORBS라고 오해하지 않도록 설계했습니다.

==================================================
2. WALLET ADDRESS CHECK
==================================================
TOKEN PROFILE의 DEPLOYMENT 아래에 "WALLET ADDRESS CHECK"가 표시됩니다.

- PROJECT WALLET: 프로젝트에 저장된 기준 주소
- METAMASK: 현재 MetaMask에서 선택된 계정
- KAIA WALLET: 현재 Kaia Wallet에서 선택된 계정

지원 기능
- 전체 0x... 주소 표시
- 주소 복사
- PROJECT WALLET과 일치/불일치 표시
- 주소 확인만 수행하며 전송/서명/네트워크 강제변경 없음

브라우저에 여러 EVM 지갑 확장이 함께 설치된 경우에도 MetaMask provider를
가능한 한 구분해서 찾도록 보완했습니다.

중요:
비밀키, 시드 문구, 12단어 복구문구, 비밀번호, 인증번호는 입력하지 마십시오.

==================================================
3. ORQUBE AI ASSISTANT
==================================================
토큰 생성 관련 화면 우측 하단에 "AI 도움" 버튼이 표시됩니다.

적용 화면
- ORQUBE TOKEN LAUNCH 홈
- 새 토큰 만들기
- TOKEN PROFILE
- 토큰 프로필 편집
- MULTICHAIN WALLET · ORBS
- 내 토큰 관리

AI가 설명하는 내용
- 현재 화면과 단계
- 다음 작업
- 지갑주소 차이
- Firestore ORBS/Starter 상태(화면이 정상 읽은 범위)
- 테스트넷/배포 전 확인사항
- AUTO VERIFY
- 오류 문구

ORQUBE 기본 흐름
DESCRIBE → BUILD → TEST → DEPLOY → VERIFY → USE

[Human + AI 가이드라인]
- 사람이 아이디어와 방향을 정하고 AI가 설명·검토·개발을 돕습니다.
- 배포·결제·지갑 서명·프로필 공개는 사용자가 직접 확인하고 승인합니다.
- AI는 비밀키/시드문구/복구문구/비밀번호/인증번호를 요청하거나 저장하지 않습니다.
- 확인되지 않은 TX, 주소, 잔액, 검증 성공을 사실처럼 말하지 않습니다.
- 가격 상승, 수익, 거래소 상장 등을 보장하지 않습니다.
- 외부 자동게시·유료광고·온체인 전송을 임의로 실행하지 않습니다.

AI Function이 아직 배포되지 않았거나 연결이 실패하면
ORQUBE 로컬 안내 모드가 동작하므로 UI부터 시험할 수 있습니다.

==================================================
4. 설치
==================================================
이 ZIP을 ORQUBE 프로젝트 루트에 그대로 덮어씁니다.

이 패치는 swap-center6 계열에 적용할 수 있도록
진행바/발행량 관련 필수 파일도 함께 포함했습니다.
이미 해당 파일이 있으면 같은 최신 파일로 덮어씁니다.

==================================================
5. 먼저 로컬 실행
==================================================
프로젝트 루트에서:

flutter pub get
flutter run -d chrome

우선 확인 순서
1) MULTICHAIN WALLET · ORBS 진입
2) AVAILABLE ORBS가 Firestore 값으로 표시되는지 확인
3) STARTER CREDITED가 표시되는지 확인
4) TOKEN PROFILE → WALLET ADDRESS CHECK 확인
5) MetaMask 주소 확인 / Kaia Wallet 주소 확인
6) 우측 하단 AI 도움 → AI 이용 가이드라인 확인
7) 빠른 질문으로 기본 안내 동작 확인

MetaMask가 뜨지 않는 경우:
ORQUBE를 실행한 바로 그 브라우저에 MetaMask 확장이 설치/활성화되어 있어야 합니다.
Chrome에 설치하고 Edge에서 ORQUBE를 열면 인식되지 않습니다.

==================================================
6. 실제 서버 AI 연결
==================================================
기존 OPENAI_API_KEY Firebase Secret이 설정되어 있다면 다시 입력할 필요 없습니다.

프로젝트 루트에서:

firebase deploy --only functions:ai

배포 후 로그인 사용자는 orqubeAiAssistant Function을 통해 서버 AI 답변을 받습니다.
기본 대화 제한은 사용자당 하루 80회입니다.

==================================================
7. 웹 배포
==================================================
로컬 확인 후:

flutter build web
firebase deploy --only hosting

==================================================
8. 이번에 추가로 하지 않은 작업
==================================================
- 토큰 생성 전체 6개국어 번역 확대
- 기존 AUTO VERIFY 결제 정책 변경
- 기존 DROPS / LIQUIDITY / SWAP 구조 변경
- Firestore 저장 데이터 수동 수정

기존 저장 데이터는 수정하지 않고 읽기/표시 안정화 중심으로 작업했습니다.
