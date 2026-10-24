# ORQUBE 개발용25 로그인·3자 토론 패치 (2026-10-02)

## 적용
기준: ORQUBE_DEV25-10-02-546.zip. 전체본이 아닌 변경 파일 패치입니다.
프로젝트를 백업하고 ZIP 안의 lib/, functions_ai/, docs/와 firebase.json을 기존 프로젝트 루트에 덮어쓰세요.
루트는 pubspec.yaml이 있는 폴더입니다. 새 Flutter 프로젝트를 만들지 않습니다.
기존 채굴·QR·AI 마케팅·토론 화면/음성 기능은 유지합니다.
공개용에 이 개발용 전체 앱을 덮어 배포하지 마세요. 아래 Hosting 명령은 개발용을 올릴 대상으로 확인한 경우에 사용합니다.

## 변경 파일
- lib/pages/login_page.dart: 찾기 버튼 흰색 유지, 처리 중에는 흰색 계열 표시; Android/iOS Google 기존 세션 정리 후 계정 선택.
- lib/main.dart: 다른 Google 로그인 진입점에도 웹 select_account 팝업/모바일 세션 정리 적용.
- lib/pages/phone_sign_in_dialog.dart: DOM 컨테이너 없는 reCAPTCHA를 invisible 설정으로 통일, 매 전송마다 새 verifier 사용, 정리 오류로 버튼이 잠기지 않도록 처리, 90초 응답 제한, 만료된 인증 초기화, 다시 보내기 즉시 실행. 네이티브에서는 인증 콜백이 끝날 때 버튼 잠금 해제, 지난 요청/닫힌 화면 콜백 무시.
- lib/services/debate_api_service.dart: HTTPS 웹은 같은 도메인 /api/three-way-debate 사용. localhost/네이티브는 Firebase 함수 직접 호출. HTTP·비JSON·연결·시간초과·비활성·인증 오류 구분. DEBATE_API_URL 빌드 옵션으로 별도 서버 지정 가능.
- firebase.json: SPA rewrite 앞에 토론 API rewrite 추가. 함수 리전 asia-northeast3 유지.
- functions_ai/ai_debate.js: 브라우저 호출 가능한 invoker, 기존 CORS 유지, 무과금 GET 상태 확인, 토큰/시간초과 구분. AI 요청 제한을 45초로 조정해 Hosting의 60초 제한에 여유 확보.
- functions_ai/test/dev25.test.js: 기존 회귀 테스트 유지, 연결·상태·만료·시간초과 테스트 추가.
- 이 안내서.

## 1. 코드 검증
프로젝트 루트에서:

```shell
flutter pub get
flutter analyze lib/pages/login_page.dart lib/pages/phone_sign_in_dialog.dart lib/services/debate_api_service.dart lib/main.dart
flutter build web --release
```

서버 코드 검증:

```shell
npm --prefix functions_ai ci
npm --prefix functions_ai run check
npm --prefix functions_ai test
```

이 패치 제작 환경에서 Node 문법 검사와 서버 테스트 12개는 통과했습니다.
Flutter SDK가 없어 Dart 분석·웹 빌드·화면 검증은 수행하지 못했습니다.
실제 Firebase 배포 설정·SMS 수신·Google 계정 선택·OpenAI 호출도 이 환경에서 확인하지 못했습니다.
서버 테스트는 Firebase/OpenAI를 모의 처리하며 실제 외부 서비스 정상 동작을 보장하지 않습니다.

## 2. localhost: 화면·Google 로그인·토론 연결 확인

```shell
flutter run -d chrome --web-port=5000
```

- 아이디 찾기·비밀번호 찾기가 흰색인지, 클릭 시 안내/비밀번호 재설정 창이 열리는지 확인합니다.
- Google 로그인을 눌러 브라우저의 현재 Google 계정 목록과 다른 계정 사용 선택지가 표시되는지 확인합니다. 계정 전환 후 다시 시도합니다.
- Google 로그인 테스트에 필요하면 Firebase Authentication > Settings > Authorized domains에 localhost를 추가합니다. 팝업 차단을 해제합니다.
- localhost의 실제 SMS 전송은 이 패치에서 차단하고 안내를 표시합니다. UI 테스트용입니다. 실문자 성공 여부를 localhost에서 판정하지 않습니다.
- 토론은 로컬 화면이어도 배포된 asia-northeast3 함수에 연결합니다. 이메일 인증 완료 계정으로 로그인한 뒤 주제 입력 → 시작 → 시민 질문 → 최종 요약을 확인합니다. 실제 API 크레딧을 사용합니다.
- 네트워크를 끈 상태의 오류 안내 후 다시 연결하여 재시도합니다. 자동 재요청은 하지 않습니다(중복 과금/문자 방지).
- 임의의 HTTPS 정적 서버는 firebase.json rewrite를 처리하지 않습니다. 그런 환경에서는 다음과 같이 직접 함수 주소를 지정합니다.

```shell
flutter run -d chrome --dart-define=DEBATE_API_URL=https://asia-northeast3-orqube-576e7.cloudfunctions.net/generateThreeWayDebate
```

## 3. 토론 서버 설정과 배포 (Hosting만 배포해서는 부족)
ZIP의 .firebaserc 기본 프로젝트는 orqube-576e7입니다. 먼저 본인 개발용 대상인지 확인하세요.
AI Functions는 functions_ai 코드베이스(ai)에 있습니다. functions/ 기본 코드베이스와 혼동하지 마세요.
Blaze 결제와 Firebase CLI 로그인/배포 권한이 필요합니다.

functions_ai/.env.orqube-576e7 파일에 아래 줄을 추가하거나 기존 값을 변경하세요.
기존 다른 환경변수는 지우지 마세요. 실제 프로젝트 ID가 다르면 파일명도 맞춰야 합니다.

```dotenv
DEBATE_ENABLED=true
```

기본값은 false이므로 설정 없이 배포하면 DEV_DEBATE_DISABLED가 표시됩니다.
기존 OPENAI_API_KEY Secret이 유효하면 그대로 사용합니다. 미등록/교체가 필요한 경우에만:

```shell
firebase functions:secrets:set OPENAI_API_KEY --project orqube-576e7
```

키는 프롬프트에 입력합니다. Dart/HTML/.env에 키를 넣지 마세요.
프로젝트 루트에서 AI 코드베이스를 배포합니다(기존 마케팅·Launch도 같은 코드베이스에 포함).

```shell
firebase deploy --only functions:ai --project orqube-576e7
```

배포 완료 뒤 브라우저에서 확인:
https://asia-northeast3-orqube-576e7.cloudfunctions.net/generateThreeWayDebate

기대 응답: {"service":"three-way-debate","enabled":true}
이 GET은 AI 생성·문자 발송·크레딧 소비를 하지 않습니다. OpenAI 키의 유효성까지 확인하는 검사는 아닙니다.
- 404: 함수명/리전/프로젝트/배포 성공 여부 확인.
- 403 또는 CORS에 가려진 Failed to fetch: Gen2 Cloud Run 호출 IAM 및 배포 로그 확인. invoker 설정 적용 권한이 필요합니다. 함수 내부 Firebase ID 토큰·이메일 인증 검사는 계속 유지됩니다.
- enabled:false: 해당 프로젝트 환경파일 값을 true로 설정하고 함수를 재배포.

개발용 Hosting 대상임을 확인한 뒤 웹을 빌드·배포합니다:

```shell
flutter build web --release
firebase deploy --only hosting --project orqube-576e7
```

기본 Hosting이 현재 공개용을 서비스한다면 위 Hosting 명령을 실행하지 말고 별도 개발용 Hosting 사이트/프로젝트를 사용하세요.
별도 대상에는 토론 rewrite가 가리킬 함수도 같은 프로젝트에 있어야 합니다. 다른 프로젝트의 토론 서버를 사용할 경우 DEBATE_API_URL로 함수 주소를 명시하여 빌드합니다.
새 API rewrite 적용 후 https://개발용도메인/api/three-way-debate 에서 같은 JSON인지 확인합니다.
홈 HTML이 나오면 예전 Hosting 설정/다른 배포 대상입니다. 수정 firebase.json을 적용한 대상을 확인하세요.

## 4. 실제 HTTPS 도메인: SMS 최종 테스트
Firebase Authentication에서:
- Sign-in method의 Phone 활성화.
- SMS 지역 정책에서 대한민국 허용.
- 승인 도메인에 orqubic.com, www.orqubic.com 및 실제 개발용 Hosting 호스트를 각각 추가(https://, 경로 제외).
- 결제·문자 할당량을 확인. 별도 API 키 제한/App Check/Identity Platform 정책을 설정했다면 관련 로그와 일치 여부 확인.
- Google 로그인에도 실제 호스트 승인 및 해당 프로젝트 OAuth 설정 필요.

먼저 테스트용 전화번호/고정 6자리 코드를 Firebase 콘솔에 등록하여 HTTPS 도메인에서 확인할 수 있습니다. 이 번호에는 문자가 발송되지 않습니다.
다음 실제 번호로 테스트:
1. 문자 받기 → 필요 시 reCAPTCHA 완료 → 받은 6자리 입력 → 로그인.
2. 잘못된 코드 입력 → 오류 표시 후 올바른 코드로 재시도.
3. 다시 보내기 → 새 문자/새 인증 세션 → 최신 코드 입력.
4. 인증 만료 → 문자 받기로 복귀하여 재발송.
5. 네트워크 오류/발송 실패 후 버튼이 다시 활성화되는지 확인.
6. 기존 이메일/Google 데이터가 있는 회원은 기존 계정으로 로그인 후 번호 연결 기능 사용. 별도 문자 가입으로 자동 데이터 병합하지 않습니다.

광고 차단·브라우저 네트워크 제한이 reCAPTCHA를 막는 경우 일반 Chrome에서도 비교합니다.
성공한 로컬 UI 테스트가 실제 SMS 서비스 설정 완료를 뜻하지 않습니다.

## 5. 실제 토론 확인
이메일 인증 완료 계정으로 로그인 → 주제 입력 → A/B/C 발언 → 시민 질문 → 세 패널 응답 → 최종 요약 확인.
SMS 전용 계정은 기존 정책대로 이메일 인증이 없으면 AI 토론을 사용할 수 없습니다.
AI_PROVIDER_ERROR: Firebase Secret의 키, OpenAI API 크레딧, 서버 모델 접근 가능 여부 확인.
RATE_LIMIT: 10초 이상 대기. UTC 일자 기준 사용자당 30회 제한 유지(요약 요청도 포함).
실패 시 함수 로그:

```shell
firebase functions:log --only generateThreeWayDebate --project orqube-576e7
```

## 근거 문서
https://firebase.google.com/docs/auth/web/phone-auth
https://firebase.google.com/docs/auth/flutter/phone-auth
https://firebase.google.com/docs/hosting/functions
https://firebase.google.com/docs/functions/http-events
