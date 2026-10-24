# ORQUBE 팀 등록 기능 적용 안내

## 포함된 변경 사항
- `lib/pages/team_create_page.dart` 신규 추가
- `lib/pages/airsoft_page.dart` 팀 등록 버튼 연결
- `firestore.rules` 팀원 및 가입 신청 권한 보완

## 실행 순서
1. 이 ZIP의 `orqube_app` 폴더를 VS Code로 엽니다.
2. 터미널에서 아래 명령을 실행합니다.

```bash
flutter clean
flutter pub get
flutter run -t lib/main_mobile.dart
```

웹에서 확인할 때는 다음 명령을 사용할 수 있습니다.

```bash
flutter run -d chrome -t lib/main_mobile.dart
```

## 팀 등록 화면 열기
1. 로그인합니다.
2. Airsoft 페이지로 이동합니다.
3. 오른쪽 위 `사람+` 아이콘을 누릅니다.
4. 팀명, 활동 지역, 팀 소개를 입력합니다.
5. `팀 등록 완료`를 누릅니다.

## Firestore Rules 배포
팀 등록 및 팀원 하위 컬렉션 권한을 적용하려면 프로젝트 루트에서 실행합니다.

```bash
firebase deploy --only firestore:rules
```

Firebase CLI 로그인이 필요하면 먼저 실행합니다.

```bash
firebase login
```
