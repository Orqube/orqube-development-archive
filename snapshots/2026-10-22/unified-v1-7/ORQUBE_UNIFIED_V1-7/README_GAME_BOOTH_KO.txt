ORQUBE 통합본 V1-5 · 게임 부스 (2026-10-20)

변경 내용
1. 첫 화면: 기존 토큰 생성 첫 화면 유지. 바로 아래에 게임 부스 안내 배너 추가.
2. 대시보드: 게임 부스 배너와 GAMES 메뉴 추가.
3. 게임 부스: AI 오목 시작 버튼, 기존 Firebase 오르큐브 계정 로그인 연계.
   이미 로그인했으면 재로그인하지 않습니다. 비로그인 상태면 기존 로그인 화면을 엽니다.
4. 오목: 15×15, 흑돌 사용자 / 백돌 AI, 쉬움·보통·어려움.
   교차점 선택 → 초록 원으로 위치 확인 → 돌 놓기 버튼.
   5개 이상 연결하면 승리하는 자유 오목입니다. 금수 없음.
   되돌리기, 새 판 확인창, 승리 줄 표시, 시간 제한 없음.
5. 웹과 모바일 Flutter 화면으로 직접 실행. 외부 오목 사이트·울림을 열지 않습니다.
6. 이번 버전은 연습용: ORBS 적립·전송·예산 차감 없음.
   진행은 현재 게임 화면에서만 유지됩니다. 보상 연동은 별도 작업입니다.

실행 방법 (압축을 풀고 pubspec.yaml이 있는 폴더에서 PowerShell 실행)
flutter pub get
flutter run -d chrome -t lib/main.dart

모바일 구성을 Chrome에서 확인
flutter run -d chrome -t lib/main_mobile.dart

웹 배포 (로컬 실행 확인 후)
flutter build web --release -t lib/main.dart
firebase deploy --only hosting --project orqube-576e7

이번 변경은 화면/게임 코드입니다. Functions·Firestore Rules·컨트랙트 배포는 필요 없습니다.
배포 대상은 기존 www.orqubic.com의 Firebase Hosting 프로젝트입니다.
제공한 ZIP이 자동으로 기존 사이트를 바꾸지는 않습니다.

검증
- 새 Dart 파일 구문 검사/포맷 완료.
- 순수 Dart 오목 엔진 정적 분석: 오류 없음.
- 선후공·차례·범위·중복 칸·가로/세로/대각선 승리·종료 후 수 금지·되돌리기 검사 통과.
- AI 즉시 승리/방어 검사 및 8판 자동 시뮬레이션 통과.
- 이 제작 환경에는 Flutter SDK가 없어 전체 Flutter analyze/웹 빌드/APK 실기기 검증은 미실행.
  설치된 Flutter 환경에서 위 실행 명령으로 확인해 주세요.

추가 파일
lib/games/gomoku_engine.dart
lib/games/game_text.dart
lib/pages/game_booth_page.dart
lib/pages/gomoku_page.dart
test/gomoku_engine_test.dart

변경 파일
lib/pages/v17_web_home_page.dart
lib/pages/mobile_dashboard_page.dart

게임 부스 제목과 첫 화면 안내는 6개 언어를 지원하며,
오목 상세 조작 안내는 한국어/영어(그 외 언어는 영어)로 제공됩니다.
