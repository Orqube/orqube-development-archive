# ORQUBE V16 WEB FINAL 적용 안내

## 적용 완료
- 새 다크 웹 메인: `lib/pages/v16_web_home_page.dart`
- 군인 + 나비 + 달 배경: `assets/images/background/orqube_v16_butterfly_soldier.jpg`
- 40페이지 공식 백서: `assets/docs/ORQUBE_Official_Whitepaper_KR_2026.pdf`
- Wallet / Mining / Airsoft Hub / NFT 로그인 보호
- 로그인 성공 후 선택 서비스 연결
- Dashboard 및 Mining은 기존 `OrqubeV14Entry`로 연결
- Telegram / X / YouTube 외부 연결
- 웹 광고 배너 자리 적용

## 보존된 핵심 연결
`orqube_v14_entry.dart` → `mobile_dashboard_page-yy.txt` → `mobile_dashboard_page.dart`

기존 파일은 교체하거나 우회하지 않았습니다.

## 실행
```bash
flutter pub get
flutter run -d chrome -t lib/main.dart
```

## 웹 빌드와 배포
```bash
flutter build web -t lib/main.dart
firebase deploy --only hosting
```

## 참고
- Flutter Web에서는 AdMob이 표시되지 않습니다. 현재 웹 메인에는 웹 광고 삽입용 배너 자리를 구성했습니다.
- 실제 웹 광고는 AdSense/Google Ad Manager 승인 후 해당 스크립트를 `web/index.html` 또는 HTML 플랫폼 뷰에 연결해야 합니다.
- 백서 버튼은 Flutter Web 빌드의 로컬 PDF 자산을 새 탭으로 엽니다.
