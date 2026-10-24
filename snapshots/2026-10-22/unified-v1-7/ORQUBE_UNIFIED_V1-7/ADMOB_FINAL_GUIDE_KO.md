# ORQUBE AdMob 보상형 광고 마무리 안내

## 현재 적용 상태
- Android/iOS 앱에서 Mobile Ads SDK를 앱 시작 시 1회 초기화
- 채굴 시작 버튼 클릭 → 보상형 광고 완주 확인 → 24시간 채굴 시작
- 광고 보상 버튼 클릭 → 광고 완주 확인 → 포인트/ORBS 지급
- 광고 로드 실패 또는 중도 종료 시 보상 미지급
- Chrome 웹에서는 AdMob 미지원
- 기본 설정은 Google 공식 테스트 광고

## 1. 테스트 실행
```bash
flutter clean
flutter pub get
flutter run -d <ANDROID_DEVICE_ID> -t lib/main_mobile.dart
```

채굴 시작 버튼을 눌러 화면에 `Test Ad` 표시가 있는 보상형 광고가 나오는지 확인합니다.

## 2. 실제 수익 광고로 전환
AdMob에서 Android 앱을 등록하고 아래 2개 값을 발급받습니다.

1. Android App ID: `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy`
2. Rewarded Ad Unit ID: `ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz`

### App ID 입력
`android/gradle.properties` 파일:
```properties
ADMOB_APP_ID=ca-app-pub-본인값~본인값
```

### 보상형 광고 단위 ID 입력 및 출시 빌드
```bash
flutter build appbundle -t lib/main_mobile.dart \
  --release \
  --dart-define=ADMOB_TEST_MODE=false \
  --dart-define=ADMOB_ANDROID_REWARDED_ID=ca-app-pub-본인값/본인값
```

## 매우 중요
- 개발 중에는 반드시 테스트 광고만 사용합니다.
- 본인 실제 광고를 반복 클릭하면 무효 트래픽으로 계정이 제한될 수 있습니다.
- 현재 Android applicationId는 `com.example.orqube_app`입니다. Play Store 정식 출시 전 고유 패키지명으로 변경하고, AdMob에도 동일한 패키지로 앱을 등록해야 합니다.
- 실제 출시 전 개인정보 처리방침과 사용자 동의(UMP) 적용이 필요합니다.
