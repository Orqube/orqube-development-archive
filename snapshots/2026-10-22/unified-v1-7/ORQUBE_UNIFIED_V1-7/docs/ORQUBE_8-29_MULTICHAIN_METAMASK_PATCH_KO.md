# ORQUBE AI Token Creator 8-29 멀티체인 패치

- 기존 안전산행/안심귀가/에어소프트/AI Marketing 구조를 유지하고 `features/ai_launch` 중심으로 확장.
- Token Creator에 KAIA / Polygon / Solana 체인 선택과 총 발행량 저장을 결합.
- KAIA Kairos(Chain ID 1001)와 Polygon Amoy(80002)는 브라우저 MetaMask의 EIP-1193 요청으로 계정 연결 + 테스트넷 전환/추가.
- Solana는 데이터/배포 어댑터를 분리하고 Solana 주소 검증 및 프로젝트 저장을 지원. 실제 MetaMask Solana 서명은 MetaMask Connect SDK 연동 단계에서 활성화.
- 개인키/복구문구는 Firestore에 저장하지 않음.
- AI Logo `Failed to fetch` 점검: AI 함수는 `functions_ai` 코드베이스. 앱 기본 endpoint는 `generateLaunchLogoOptions`; 서버는 1회 클릭당 이미지 1개만 생성하도록 변경.
- AI 코드베이스 배포 예: `firebase deploy --only functions:ai`
- OPENAI_API_KEY Secret이 AI 코드베이스에 연결되어 있어야 함.
- Firestore rules의 chain 제약을 Kaia/Polygon/Solana로 확장.

## 다음 배포 단계
실제 토큰 컨트랙트 배포는 사용자 지갑 서명 -> txHash/contractAddress 검증 -> Deployment Archive 저장 순서로 연결한다. 메인넷은 테스트넷 검증 후 별도 활성화한다.
