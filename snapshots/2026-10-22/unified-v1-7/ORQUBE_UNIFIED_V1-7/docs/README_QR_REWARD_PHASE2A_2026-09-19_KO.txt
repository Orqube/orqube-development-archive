ORQUBE QR REWARD PHASE 2A PATCH

적용 위치: ORQUBE_SAFE_HIKING 프로젝트 루트에 동일 경로로 덮어쓰기

포함:
1) QR REWARD 입력 글씨/라벨을 화이트 계열로 수정
2) QR 설정 저장 시 공개용(민감정보 제외) qr_reward_campaigns 문서 생성
3) https://www.orqubic.com/reward?project=...&campaign=default 로 접속하면 고객용 모바일 수령 화면 표시
4) MetaMask / Kaia Wallet 주소 연결
5) 지갑 주소 직접 입력 지원
6) 지갑이 없는 고객에게 안전한 지갑 생성 안내
7) 실제 토큰 지급은 아직 비활성 - 다음 단계에서 중복/기간/총한도 검증 + TX Hash 기록 후 활성화

중요:
- 개인키/복구문구/발행자 서명정보는 QR 또는 Firestore 공개 문서에 저장하지 않습니다.
- firestore.rules가 포함되어 있으므로 테스트 후 firebase deploy --only firestore:rules 가 필요합니다.
- 웹 빌드/Hosting 배포 후 스마트폰 카메라로 실제 QR 링크를 테스트하세요.
