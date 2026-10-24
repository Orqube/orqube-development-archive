# ORQUBE_V14_COMMUNITY_AIRSOFT_CHAT_INTEGRATED_FINAL

첨부된 최신 `orqube_app`을 기반으로 기존 대시보드 UI와 기능을 유지하며 커뮤니티·채팅·에어소프트·랭킹을 연결한 통합본입니다.

## 실행
```bash
flutter clean
flutter pub get
flutter run -t lib/main_mobile.dart
```

## Firebase 규칙 배포
```bash
firebase deploy --only firestore:rules
```

본 제작 환경에는 Flutter SDK가 없어 `flutter analyze`와 실제 빌드 검증은 실행하지 못했습니다. 로컬 VS Code에서 위 명령으로 점검해야 합니다.
