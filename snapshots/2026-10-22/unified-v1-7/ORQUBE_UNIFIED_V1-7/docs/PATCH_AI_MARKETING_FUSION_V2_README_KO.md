# ORQUBE AI MARKETING FUSION V2 패치

## 적용 방법

1. 현재 ORQUBE 프로젝트 폴더를 백업합니다.
2. 이 패치 ZIP을 프로젝트 최상위 폴더에 풀고, 같은 경로의 파일을 덮어씁니다.
3. `firebase deploy --only functions:ai,firestore:rules`로 AI Functions와 보안 규칙을 배포합니다.
4. `flutter clean`, `flutter pub get`, `flutter build web`을 순서대로 실행합니다.
5. 필요하면 `firebase deploy --only hosting`으로 웹을 배포합니다.

## 이번 패치 내용

- 관리자용 ORQUBE 공식 홍보와 개발자용 내 토큰 홍보 분리 유지
- 핵융합식 채널별 콘텐츠 생성 유지
- 캠페인 초안 승인 요청
- 관리자의 핵융합 캠페인 승인·보류·반려
- 승인된 캠페인의 채널·게시물 URL·메모 배포 기록
- 캠페인별 배포 이력 조회
- 외부 SNS 자동 게시는 안전을 위해 계속 OFF

## 포함 파일

- `lib/pages/ai_marketing_center_page.dart`
- `lib/admin/fusion_marketing_approval_page.dart`
- `lib/services/fusion_marketing_service.dart`
- `functions_ai/ai_token_marketing.js`
- `firestore.rules`

Node.js 문법 검사는 완료했습니다. 현재 작업 환경에 Flutter SDK가 없어 Flutter 실행 빌드는 로컬 PC에서 확인해야 합니다.
