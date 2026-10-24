# ORQUBE 8-31 MULTIWALLET TESTNET PATCH

## 적용 내용
- 체인 선택: KAIA / Polygon / Solana
- KAIA: MetaMask 실제 연결 + Kairos Testnet 자동 전환 (Chain ID 1001 / 0x3E9)
- Polygon: MetaMask 실제 연결 + Amoy Testnet 자동 전환 (Chain ID 80002 / 0x13882, POL)
- Solana: Phantom 등 `window.solana` 호환 브라우저 지갑 연결 + Devnet
- EVM 테스트 토큰: Solidity 소스 서버 컴파일 -> bytecode 반환 -> 사용자의 MetaMask가 직접 배포 서명
- Solana 테스트 토큰: SPL Token Mint 생성 + 초기 발행량 mint, 사용자의 Solana 지갑이 직접 서명
- Deployment Archive: EVM source/ABI/compiler/optimizer, chain/network, txHash, contract/mint address 보존
- 개인키/복구문구는 ORQUBE 서버/Firestore에 저장하지 않음

## 중요
1. 실제 테스트넷 트랜잭션을 보내기 전에 해당 지갑에 테스트 가스 토큰이 필요합니다.
   - KAIA: Kairos test KAIA
   - Polygon: Amoy test POL
   - Solana: Devnet SOL
2. Solana의 이번 단계는 표준 SPL Mint + 초기 공급량까지입니다. 이름/심볼은 ORQUBE 프로젝트 프로필에 유지되며, 온체인 Token Metadata 등록은 다음 확장 단계입니다.
3. ORBS Deploy Fee는 현재 정책/잔액 검증 UI를 유지하지만, 이번 패치는 ORBS 실제 자동 차감 로직을 새로 만들지 않습니다.
4. EVM 컴파일용 `solc` 의존성이 추가되므로 새 배포 배치파일은 functions_ai/package-lock.json을 재생성합니다.

## 적용/배포
패치 ZIP을 현재 ORQUBE 프로젝트 루트에 덮어쓴 다음 아래 파일을 실행합니다.

`DEPLOY_8-31_MULTIWALLET_TESTNET.bat`

## 테스트 순서
1. 웹 로그인 -> AI Token Creator -> Multichain Wallet
2. KAIA 선택 -> MetaMask 연결 -> Kairos 자동 추가/전환 확인
3. Polygon 선택 -> MetaMask 연결 -> Amoy 자동 추가/전환 확인
4. Solana 선택 -> Solana Devnet 지갑 연결 확인
5. 각 테스트넷 가스 토큰 확보
6. Token Profile -> `ORBS로 Token Deploy 준비` -> 최종 확인 -> 지갑 승인
7. 완료 후 프로젝트에 contract/mint address와 txHash가 표시/저장되는지 확인

## 보안 원칙
- 배포 트랜잭션 서명은 사용자 지갑에서만 수행합니다.
- 서버는 EVM 컴파일과 배포 결과 기록만 담당합니다.
- 테스트넷 전용 단계입니다. 메인넷 자동 배포는 포함하지 않았습니다.
