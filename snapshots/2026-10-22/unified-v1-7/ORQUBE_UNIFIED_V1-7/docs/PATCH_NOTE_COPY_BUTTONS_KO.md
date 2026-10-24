# ORQUBE Wallet / Contract / TX Hash 복사 버튼 PATCH

기준: `swap-center5.zip` + `ORQUBE_AUTO_VERIFY_10KAI_DUAL_WALLET_PATCH_2026-09-15.zip` 적용 상태

## 변경 내용

- TOKEN PROFILE > KAIA DEPLOYMENT
  - Wallet 주소 옆 복사 아이콘 추가
  - Contract 주소 옆 복사 아이콘 추가
  - 배포 `TX Hash` 행 추가 및 복사 아이콘 추가
  - 주소/해시는 마우스로 직접 선택할 수도 있도록 `SelectableText` 적용
- ORQUBE AUTO VERIFY
  - 결제 완료 후 표시되는 `Payment TX` 옆 복사 아이콘 추가
  - 화면에는 짧게 표시되어도 복사되는 값은 전체 TX Hash

## 적용

프로젝트 루트(`pubspec.yaml`이 있는 폴더)에 ZIP 내용을 그대로 덮어씁니다.

그 다음 웹 실행 중이라면 Hot Restart 또는 재실행합니다.

배포 시:

```text
flutter build web
firebase deploy --only hosting
```

이번 패치는 서버 Functions 변경이 없습니다.
