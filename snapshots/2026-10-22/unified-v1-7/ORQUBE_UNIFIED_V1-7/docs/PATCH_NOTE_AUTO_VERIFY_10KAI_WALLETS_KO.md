# ORQUBE AUTO VERIFY · 10 KAI Mainnet Wallet Test Patch

기준 전체본: `swap-center5.zip`

## 이번 패치 목표

AUTO VERIFY 실제 Mainnet 결제/검증을 다음 순서로 시험한다.

1. 결제수단 선택: `10 KAI` 또는 `100 ORBS`
2. 지갑 선택: `MetaMask` 또는 `Kaia Wallet`
3. `CONNECT WALLET`
4. 잔액 사전 확인
5. 실제 Kaia Mainnet 전송
6. TX receipt 성공/실패 확인
7. 서버가 Kaia Mainnet RPC로 TX를 다시 검증
8. `launch_auto_verify_payments` TX 기록
9. Deployment Archive `PAYMENT_CONFIRMED`
10. 자동으로 Source Verification 호출
11. 성공 시 `VERIFIED`, 실패 시 `VERIFY_FAILED` + 재결제 없는 `RETRY VERIFY`

## 테스트 조합

- 10 KAI × MetaMask
- 10 KAI × Kaia Wallet
- 100 ORBS × MetaMask
- 100 ORBS × Kaia Wallet

보안상 선택한 결제 계정은 해당 Mainnet 프로젝트의 `walletAddress`와 같아야 한다.
두 확장지갑을 각각 시험하려면 동일한 프로젝트 배포 계정을 MetaMask / Kaia Wallet에서 선택한다.

## 테스트 금액

이번 패치 동안 KAI 결제는 코드에서 **10 KAI로 강제 고정**한다.
Firestore `launch_config/auto_verify.kaiFee` 값이 500이어도 테스트 모드에서는 클라이언트와 서버 모두 10 KAI를 사용한다.

ORBS는 기존 정책값을 그대로 사용하며 기본값은 100 ORBS다.

## 500 KAI로 최종 복귀하는 위치

테스트 4종이 정상 통과한 뒤 다음 두 곳을 모두 `false`로 변경한다.

### Flutter
`lib/features/ai_launch/services/auto_verify_service.dart`

```dart
static const bool kaiMainnetTestMode = false;
```

### Firebase Functions
`functions_ai/ai_launch_v081.js`

```js
const AUTO_VERIFY_KAI_TEST_MODE = false;
```

그리고 Firestore `launch_config/auto_verify`의 `kaiFee`를 최종 정책값 `500`으로 확인한다.

## 배포 순서

이번 패치는 프런트엔드와 서버 검증 금액이 함께 바뀌므로 **Hosting만 배포하면 안 된다.**

프로젝트 루트에서:

```bash
cd functions_ai
npm run check
cd ..
firebase deploy --only functions:ai
flutter build web
firebase deploy --only hosting
```

## 실제 테스트 전 확인

- 프로젝트가 Kaia Mainnet 배포 상태
- Deployment Archive `chainId = 8217`
- `launch_config/auto_verify.enabled = true`
- `kaiEnabled = true`
- `orbsEnabled = true`
- `treasuryAddress`가 실제 ORQUBE 운영지갑
- `orbsContractAddress`가 실제 ORBS Mainnet 컨트랙트
- `orbsDecimals`가 실제 ORBS decimals와 일치
- 선택 지갑의 현재 계정이 프로젝트 `walletAddress`와 동일
- 10 KAI 결제 시 10 KAI 외 가스비 여유 보유
- 100 ORBS 결제 시 100 ORBS + 가스비용 KAI 보유

## 변경 파일

- `lib/features/ai_launch/widgets/auto_verify_panel.dart`
- `lib/features/ai_launch/services/auto_verify_service.dart`
- `lib/features/ai_launch/services/browser_wallet_bridge_web.dart`
- `lib/features/ai_launch/services/browser_wallet_bridge_stub.dart`
- `functions_ai/ai_launch_v081.js`
- `docs/PATCH_NOTE_AUTO_VERIFY_10KAI_WALLETS_KO.md`
