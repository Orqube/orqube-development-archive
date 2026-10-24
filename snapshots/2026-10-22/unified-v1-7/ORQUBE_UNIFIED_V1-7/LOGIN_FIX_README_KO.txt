DEV25 로그인/채굴 이름 수정 전체본 (2026-10-01)

1. OrqubeV14Entry를 mobile_dashboard_page.dart로 연결했습니다.
2. 예전 .txt 구현은 동일 파일을 export하는 호환 파일로 교체했습니다.
3. 로그아웃/계정 변경 시 이름, 지갑, 잔액 표시, 출석, 보상 상태를 초기화합니다.
4. 늦게 완료된 이전 계정 조회/저장은 계정 UID 및 변경 세대로 차단합니다.
5. 기본값으로 저장된 김명근(프로필 저장 기록 및 인증 이름 확인 없음)은 인증 이름 또는 ORQUBE USER로 표시합니다. 서버 닉네임/잔액을 일괄 수정하지 않습니다.
6. 본인 이름이 ORQUBE USER로 보이면 프로필에서 정확한 닉네임을 저장하세요.

적용: 기존 폴더를 백업하고 이 전체본을 새 폴더에 풉니다.
flutter pub get
flutter test test/account_display_name_test.dart
flutter run -d chrome
웹 배포 시 flutter build web 후 기존 Firebase 배포 방법을 사용하세요.

검증: 파일 연결, 계정 초기화, UID/세대 검사, ZIP 원본 보존 비교를 수행했습니다.
현재 작업 환경에 Flutter/Dart SDK가 없어 Flutter 테스트/빌드 및 실제 Firebase 로그인은 실행하지 못했습니다.
확인: A 로그인 -> 채굴 -> 로그아웃 -> 로그인 필요/0 표시 -> B 로그인 -> B 이름/서버 잔액 표시.
