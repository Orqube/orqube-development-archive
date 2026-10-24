ORQUBE DEV25 패치 (2026-10-02)

적용: 프로젝트 전체를 먼저 백업한 후, 이 ZIP의 lib 폴더·firestore.rules·pubspec.yaml·pubspec.lock을 기존 프로젝트 루트에 같은 경로로 덮어쓰세요. 새 프로젝트가 아닌 변경 파일만 담은 패치입니다.

1) flutter pub get
2) flutter analyze
3) flutter run -d chrome (localhost: UI 및 이메일/Google 등 해당 설정 범위의 점검)
4) firebase deploy --only firestore:rules
5) flutter build web --release
6) firebase deploy --only hosting

Firestore Rules는 서버에 배포해야 적용됩니다. 웹 배포만으로 규칙은 변경되지 않습니다.

문자 로그인
- 요청마다 새 reCAPTCHA verifier를 사용하고 성공·실패·창 종료 시 정리합니다.
- 발송 실패 후 입력을 유지해 재시도할 수 있습니다. 인증번호 오류는 다시 입력하고, 만료 시 다시 보내기를 누르세요.
- 실제 SMS Phone Auth를 localhost에서 성공했다고 판단하지 마세요. Firebase 공식 문서는 Phone Auth의 호스팅 도메인으로 localhost를 허용하지 않는다고 안내합니다.
- 실제 시험: https://orqubic.com 및 https://www.orqubic.com을 Authentication 승인 도메인에 각각 등록합니다. 전화번호 제공자 활성화, 대한민국 SMS 지역 정책, 결제 및 할당량을 확인합니다.
- API 키의 HTTP referrer 제한, App Check 강제 적용, 브라우저 추적 차단도 실제 콘솔 상태를 확인해야 합니다. 승인 도메인 등록은 코드 패치가 대신할 수 없습니다.
- Firebase 가상 테스트 번호는 콘솔에 등록된 번호/코드를 사용합니다. 이 패치에는 reCAPTCHA를 무조건 우회하는 설정을 넣지 않았습니다. 로컬 인증 통합 시험이 필요하면 Authentication Emulator를 별도로 연결하세요.
- 기존 이메일/Google 이용자는 먼저 기존 계정 로그인 후 전화번호를 연결해야 데이터가 유지됩니다.

광고 및 관리자 권한
- 웹 광고는 public_config/ads만 읽습니다. 관리자 설정 저장 시 광고 공개 설정을 함께 원자적으로 저장합니다.
- 패치 후 관리자 설정을 한 번 저장하여 public_config/ads를 생성하세요.
- isAdmin 판단에서 role/isAdmin 필드가 없는 문서의 평가 오류를 방지했습니다.
- 관리자 지정은 Firebase 콘솔에서 실제 로그인 UID의 users/{UID} 문서에 isAdmin: true(불리언) 또는 role: admin을 설정하세요. 이메일 주소나 계급명만으로 관리자 권한을 부여하지 않습니다. byd1009@naver.com도 해당 로그인 UID를 확인해야 합니다.
- 공개 광고 읽기 외에는 기존 권한 구조를 유지했습니다. 서버 규칙 버전·사용자 문서·실제 오류가 제공되지 않아 운영 서버 오류 원인의 전부를 확정할 수 없습니다.

화면과 문서
- 홈 하단 지정한 6개 링크, 로그인 계정 찾기 링크: 흰색.
- 홈·채굴 화면: 회사소개/이용약관/개인정보처리방침을 읽는 화면 연결.
- 모바일 링크 Wrap, 문서 폭 제한·스크롤, 문자 로그인 창 스크롤 적용.
- 정책은 개발용 초안입니다. 실제 개인정보처리자, 주소·연락처, 위탁/국외 이전, 보유기간 등은 공개 전 실제 운영과 맞춰 완성해야 합니다. 열람만으로 약관 동의가 저장되지는 않습니다.

검증 범위
- 첨부 원본과 바이트 비교해 변경 파일만 패키징했습니다. AI 토론/마케팅 구현 파일은 변경하지 않았습니다.
- Flutter SDK가 없어 analyze/build 및 PC·모바일 화면 렌더링 검증은 실행하지 못했습니다. 실제 SMS, 운영 Firestore 및 도메인 설정 변경도 수행하지 않았습니다.
- 적용 후: 틀린 인증번호→정상 입력, 발송 실패→재시도, 만료→재발송, 기존 계정 전화번호 연결, 비회원 광고 표시, 일반 사용자 관리자 저장 거부, 관리자 저장 성공을 확인하세요. 화면은 360px 모바일·PC 및 확대 글꼴에서 확인하세요.

공식 참고:
https://firebase.google.com/docs/auth/web/phone-auth
https://pub.dev/documentation/firebase_auth/latest/firebase_auth/RecaptchaVerifier-class.html

변경 파일:
lib/pages/v17_web_home_page.dart
lib/pages/admin_dashboard_page.dart
lib/pages/phone_sign_in_dialog.dart
lib/pages/login_page.dart
lib/pages/mobile_dashboard_page.dart
lib/pages/legal_information_page.dart
lib/adsense/adsense_ad_web.dart
firestore.rules
pubspec.yaml
pubspec.lock