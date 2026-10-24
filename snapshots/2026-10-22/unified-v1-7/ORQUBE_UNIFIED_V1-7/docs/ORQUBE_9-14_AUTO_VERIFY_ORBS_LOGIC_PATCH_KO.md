# ORQUBE AUTO VERIFY · 100 ORBS 결제 로직 검증/수정 패치

기준 전체본: `swap-center5.zip`
작업일: 2026-09-14

## 검증 결론

기존 AUTO VERIFY는 ORBS ERC-20 `transfer()` 호출과 서버 TX 확인 구조가 이미 있었지만, 실제 운영 결제 기준으로 아래 보완이 필요했습니다.

1. 결제 전 ORBS 잔액 명시 검증이 없었음
2. 현재 MetaMask 계정이 배포 지갑과 달라도 먼저 전송될 수 있었고, 이후 서버가 거절할 수 있었음
3. 서버가 성공한 calldata/receipt만 확인하고 실제 ERC-20 `Transfer` 이벤트까지 확인하지 않았음
4. 온체인 전송 완료 후 서버 확인이 실패하면 사용자가 다시 결제하여 이중 결제할 위험이 있었음
5. `launch_deployment_archives` Firestore 읽기 규칙이 없어 AUTO VERIFY 상태 스트림이 차단될 가능성이 있었음

## 수정된 결제 흐름

`Kaia Mainnet 확인`
→ `배포 지갑과 현재 MetaMask 계정 일치 확인`
→ `ORBS balanceOf 조회`
→ `100 ORBS 이상인지 확인`
→ `ORBS transfer 실행`
→ `receipt 성공 확인`
→ `서버가 TX 재조회`
→ `from / ORBS contract / treasury / amount 검증`
→ `ERC-20 Transfer 이벤트 검증`
→ `TX + block + onchain from/to 기록`
→ `PAYMENT_CONFIRMED`
→ `VERIFY NOW 활성화`
→ `requestAutoVerify`
→ `KaiaScan Source Verification`
→ `VERIFIED 또는 VERIFY_FAILED`

## 이중 결제 방지

온체인 TX는 생성되었지만 서버 확인이 일시적으로 실패한 경우 새 결제 버튼 대신
`TX 재확인 · 재결제 없음` 흐름을 사용합니다.

같은 TX hash로 `confirmAutoVerifyPayment`를 다시 호출하므로 100 ORBS를 다시 전송하지 않습니다.

## Firestore

추가된 읽기 규칙:
- `launch_deployment_archives/{projectId}`: 프로젝트 소유자/관리자 읽기
- `launch_auto_verify_payments/{paymentId}`: 결제 소유자/관리자 읽기

두 컬렉션의 create/update/delete는 클라이언트에서 금지하고 Cloud Functions(Admin SDK)만 처리하도록 유지합니다.

## 서버 기록 강화

`launch_auto_verify_payments`에 기존 TX hash 외에 다음 온체인 감사 필드를 추가합니다.
- `onchainFrom`
- `onchainTo`
- `blockNumber`

## Source Verification 연결

결제 성공 후 Archive의 `paymentStatus`가 `PAYMENT_CONFIRMED`가 되면 기존 AUTO VERIFY UI에서 `VERIFY NOW`가 활성화됩니다.
`requestAutoVerify`는 결제 상태를 다시 확인한 뒤 KaiaScan 검증을 실행합니다.
검증 실패 시 결제 상태는 유지되므로 `RETRY VERIFY · 재결제 없음`으로 재시도합니다.

## 검증 범위

- `functions_ai` JavaScript 문법 검사 통과 (`npm --prefix functions_ai run check`)
- 수정 파일 괄호/중괄호 구조 확인 완료
- 실제 Mainnet ORBS 전송은 운영지갑/ORBS 컨트랙트/실제 Mainnet 배포 Archive와 서명 지갑이 필요한 단계이므로 이 작업 환경에서는 실거래를 실행하지 않았습니다.

## 배포 시 필수

패치 적용 후 아래 항목이 실제 운영 Firebase에 반영되어야 합니다.
- `functions_ai/ai_launch_v081.js`
- `firestore.rules`
- Flutter Web 재빌드/Hosting 배포

또한 Firestore `launch_config/auto_verify`에 실제 운영값이 있어야 합니다.
- `enabled: true`
- `orbsEnabled: true`
- `orbsFee: 100`
- 실제 `treasuryAddress`
- 실제 `orbsContractAddress`
- 정확한 `orbsDecimals`
