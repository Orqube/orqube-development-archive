# ORQUBE V21 모바일 가독성 및 채굴 진입 안정화

## 기준 원본
- `orqube_app-백서탑재 최종본.zip`
- 기존 프로젝트 전체 구조와 기능을 보존한 상태에서 필요한 파일만 수정했습니다.

## 수정 파일
1. `lib/pages/v17_web_home_page.dart`
2. `lib/pages/mobile_dashboard_page-yy.txt`

## 핵심 변경

### 1. 채굴 진입 경로 안정화
웹 홈의 `ORQUBE 시작하기`, `채굴 대시보드` 버튼은 로그인 여부를 확인합니다.

- 비로그인: 로그인 화면 표시
- 로그인 성공: `OrqubeV14Entry` 진입
- 로그인 상태: `OrqubeV14Entry` 직접 진입

따라서 채굴 전에 `WalletSetupPage`를 거치지 않습니다.

유지된 핵심 경로:

`orqube_v14_entry.dart` → `mobile_dashboard_page-yy.txt` → 고품격 모바일 채굴 화면

지갑 생성 및 연결 기능은 기존 Wallet 메뉴에서 사용합니다.

### 2. 모바일 글자 크기 개선
실제 사용 중인 `mobile_dashboard_page-yy.txt`의 지나치게 작은 7.5px~11px 텍스트를 확대했습니다.

- 7.5px → 10.5px
- 8px → 11px
- 9px → 11.5px
- 10px → 12px
- 11px → 13px

아울러 기능 메뉴 영역의 높이와 폭을 확대하여 글자가 겹치거나 잘릴 가능성을 줄였습니다.

### 3. 신규 준비 기능 버튼
채굴 대시보드 기능 스트립에 다음 버튼을 추가했습니다.

- `CRYPTO` — 가상자산 시세
- `FRIENDS` — 친구 찾기

현재 클릭 시 준비 중 안내가 표시됩니다.

### 4. 푸터 가독성
모바일 푸터를 두 줄로 분리하여 작은 화면에서 긴 문장이 한 줄에 눌리지 않도록 조정했습니다.

## 로컬 검증 명령

```bash
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome
flutter run -d SM-A125N -t lib/main_mobile.dart
```

웹 배포 전:

```bash
flutter build web
firebase deploy
```

## 검증 상태
현재 작업 환경에는 Flutter/Dart SDK 실행 명령이 없어 `flutter analyze`와 실제 빌드를 직접 실행하지 못했습니다. 수정 파일의 괄호 균형, import 참조, 클래스 연결 관계는 별도로 검사했습니다.
