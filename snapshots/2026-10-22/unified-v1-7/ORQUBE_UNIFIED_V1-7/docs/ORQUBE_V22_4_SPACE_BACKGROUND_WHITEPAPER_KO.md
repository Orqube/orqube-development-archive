# ORQUBE V22.4 우주 배경·별빛·백서 연결 적용

## 기준 원본
- ORQUBE_V22_3_PREMIUM_HOME_SAFETY_MAP_STABLE_CANDIDATE_FULL.zip

## 적용 내용
1. 웹 시작 화면(`lib/main.dart`)의 기존 V16 진입 구조를 유지했습니다.
2. 웹 Hero 배경에 다음 이미지를 적용했습니다.
   - `assets/images/background/orqube_space_soldier_earth_web.png`
3. 기존 `_SpacePainter` 별빛 애니메이션과 28초 반복 애니메이션을 그대로 유지했습니다.
4. 글자 가독성을 위해 배경 위에 좌우 명암 그라데이션을 적용했습니다.
5. 기존 Whitepaper Center와 한국어·영어 PDF 연결을 유지했습니다.
6. 지도 관련 세 기능, Firestore 규칙, 화면별 사용법 및 기존 경로는 수정하지 않았습니다.
7. 채굴 화면 연결 구조와 기존 Wallet, Airsoft Hub, Community, Admin 기능을 수정하지 않았습니다.

## 웹 실행
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## 웹 배포
```bash
flutter build web
firebase deploy --only hosting
```

## 모바일 실행
웹 전용 변경이므로 모바일 구조에는 영향이 없습니다.
```bash
flutter run -d SM-A125N -t lib/main_mobile.dart
```

## 확인 항목
- 웹 첫 화면에 우주·군인·지구 배경 표시
- 별빛이 천천히 움직이고 반짝이는지 확인
- Whitepaper 버튼에서 한국어·영어 PDF 열림 확인
- 지도 세 기능과 각 화면의 사용법 안내 유지 확인
