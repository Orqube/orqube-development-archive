V2.1 최신: V2_1_원스톱시작_먼저읽기.txt를 먼저 확인하세요. 산행/귀가 시작 버튼에서 6단계 준비 화면을 엽니다. 보안 규칙은 V2.0과 같습니다.

V2.0 최신: V2_0_내사람_공유설정_먼저읽기.txt를 우선 확인하세요. 이번에는 Firestore companion 규칙 교체가 필요합니다.

V1.9.1 최신: V1_9_1_설명서_6개국어_먼저읽기.txt를 먼저 확인하세요.

V1.9 업데이트: V1_9_수색보완_먼저읽기.txt를 우선 확인하세요. SEARCH_RULES_V19.txt 추가 적용이 필요합니다. 실제 Flutter/실기기 검증은 미실행입니다.

ORQUBE 안전산행 수정본 — 실행 및 설치 안내

1. Windows에서 ZIP을 새 폴더에 압축 해제하세요. ORQUBE_SAFE_HIKING 폴더( pubspec.yaml이 보이는 폴더 )를 열고 탐색기 주소창에 powershell을 입력해 Enter를 누르세요.

2. PC 브라우저 실행
flutter doctor
flutter clean
flutter pub get
flutter run -d chrome

웹 App Check를 설정한 경우:
flutter run -d chrome --dart-define=ORQUBE_RECAPTCHA_V3_SITE_KEY=본인의사이트키

3. Android 휴대전화에서 USB 설치 (Android SDK 및 USB 디버깅 필요)
flutter devices
flutter run -d 기기ID

4. APK 만들기 및 USB 설치
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk

USB 없이 설치: 위 app-debug.apk를 휴대전화로 복사한 뒤 열어 설치하세요. 사용한 파일 관리 앱에 한해 '이 출처 허용'을 켜고 설치 후 다시 끄세요. 이 ZIP은 수정한 소스 전체이며 새 APK를 동봉하지 않았습니다. 이전 빌드 산출물은 제거했습니다.

5. 배포용 APK
현재 원본의 release 설정은 debug 서명을 사용합니다. 정식 배포 전 자신의 release keystore와 signingConfig를 구성해야 합니다.
flutter build apk --release
산출물: build/app/outputs/flutter-apk/app-release.apk

6. Firebase 운영 설정
원본 Firebase 프로젝트는 orqube-576e7입니다. Authentication에서 이메일/비밀번호 로그인 활성화와 웹 승인 도메인 설정이 필요합니다. Android 패키지는 com.orqube.orqube_safe_hiking이며 Firebase Android 앱 등록과 firebase_options.dart의 appId가 해당 패키지와 일치하는지 운영자가 확인해야 합니다. 필요하면 flutterfire configure로 다시 생성하세요. Play Integrity/App Check는 등록·서명 설정 및 실제 토큰 발급 점검이 필요합니다.

7. Firestore 규칙
firestore.rules.example은 본인만 위치·기록을 접근하는 안전산행용 예시입니다. 원본 예시에서 누락된 보호자 설정 쓰기와 삭제 권한을 보완했습니다.
이 프로젝트는 다른 ORQUBE 앱과 공용이므로 아래 명령으로 전체 규칙을 바로 덮어쓰면 다른 앱 기능을 막을 수 있습니다. 기존 운영 규칙에 해당 match 블록을 병합하고 더 넓은 allow 규칙이 없는지 확인한 후 기존 배포 설정으로 배포하세요.
독립 테스트 프로젝트에서만:
firebase deploy --only firestore:rules --config firebase.hiking.example.json --project 본인의테스트프로젝트ID
실제 테스트 프로젝트에서는 flutterfire configure로 앱 연결도 변경하세요.

8. 확인 범위
이 작업 환경에는 Flutter/Dart 및 Android SDK가 없습니다. analyze·test·APK 빌드·실기기 로그인 및 위치 시험은 실행하지 못했습니다. 소스 구조·설정·압축 무결성 점검을 수행했으며 보안 인증/백신 통과를 주장하지 않습니다.
PC에서 다음을 반드시 실행하세요:
flutter analyze
flutter test

9. 필수 실사용 확인
회원가입 → 이메일 인증 → 새로고침 → 로그인 → 앱 재시작 시 유지.
위치 권한 거부/허용 → 산행 시작 → 지도 저장 → 통신 차단 시 GPS 화면 → 종료.
보호자 직접 공유의 수신자 선택 및 실제 수신 확인.
기록 삭제 후 서버 문서 확인 → 비밀번호 재인증 후 탈퇴.
다른 계정으로 서버 위치 문서를 읽을 때 거부되는지 Firestore Emulator 또는 Rules Playground에서 확인.
