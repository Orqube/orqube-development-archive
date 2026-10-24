# ORQUBE AUTO VERIFY / Developer Center 통합 패치

## 정책
- 기존 ORQUBE 자동 소스검증 서비스 결제정책 유지
- 초기 이용료: 500 KAI 또는 100 ORBS 중 하나 선택
- 시장가격 보장이 아니라 ORQUBE 내부 서비스 구매력 정책
- 가격은 `launch_config/auto_verify`에서 관리자 변경

## 관리자 정책 문서 예시
Firestore: `launch_config/auto_verify`

```json
{
  "enabled": true,
  "kaiFee": 500,
  "orbsFee": 100,
  "kaiEnabled": true,
  "orbsEnabled": true,
  "treasuryAddress": "0x...ORQUBE 운영지갑...",
  "orbsContractAddress": "0x...ORBS 컨트랙트...",
  "orbsDecimals": 18
}
```

운영지갑 또는 ORBS 컨트랙트가 비어 있으면 실제 결제 버튼은 활성화되지 않는다.

## Deployment Archive v2
기존 source/ABI/compiler/optimizer 외에 다음 정보를 추가 저장한다.
- creationBytecode / deployedBytecode
- constructorArguments
- Standard JSON Input / Output
- dependencyVersion
- chainId / walletAddress
- paymentStatus / verificationStatus

## 결제 상태
`NOT_PAID -> PAYMENT_CONFIRMED`

서버가 Kaia Mainnet RPC에서 TX를 다시 읽고 아래를 확인한다.
- TX 성공 여부
- 보내는 지갑
- ORQUBE 운영지갑
- KAI value 또는 ORBS ERC-20 transfer calldata
- 정책에 저장된 금액
- Chain ID 8217 배포 Archive

## 검증 상태
`NOT_VERIFIED -> PAYMENT_CONFIRMED -> VERIFY_QUEUED -> VERIFYING -> VERIFIED`
실패: `VERIFY_FAILED`

`PAYMENT_CONFIRMED`가 남아 있으므로 검증 실패 후 RETRY 시 재결제하지 않는다.

## KaiaScan
Kaia 공식 문서의 Hardhat-compatible verify endpoint를 기준으로 서버 어댑터를 추가했다.
- Mainnet: `https://mainnet-api.kaiascan.io/hardhat-verify`
- Mainnet Chain ID: 8217

현재 기존 ORQUBE Token Creator는 Kairos Testnet 배포가 중심이므로 유료 AUTO VERIFY 버튼은 Mainnet 배포 Archive(chainId 8217)가 만들어진 이후 활성화된다. 이 패치는 기존 Testnet 흐름을 변경하지 않는다.

## 배포 전 관리자 필수 작업
1. `launch_config/auto_verify` 생성
2. 실제 ORQUBE 운영지갑 주소 입력
3. ORBS 실제 컨트랙트 주소와 decimals 확인
4. `functions_ai` 배포
5. `firestore.rules` 배포
6. Mainnet Token Deploy 단계 연결 후 소액 정책값으로 실제 결제/검증 테스트
