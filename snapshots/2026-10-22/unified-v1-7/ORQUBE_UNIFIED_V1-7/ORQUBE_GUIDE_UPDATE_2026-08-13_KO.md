# ORQUBE GUIDE 통합본 — 2026-08-13

## 적용 내용
- 안심귀가 · 안전산행 · AIRSOFT HUB 사용법을 `ORQUBE GUIDE` 한 화면에 통합
- 한국어 / 영어 / 일본어 / 중국어 / 프랑스어 / 포르투갈어 6개국어 제공
- GUIDE 화면 자체에서 언어 즉시 변경 가능
- 안전산행 설명문은 앱 코드에 포함되어 인터넷 단절 상태에서도 열람 가능
- 안전산행 핵심 흐름을 상단에 고정 안내
  - 산행 전 현재 지도 저장
  - 인터넷 단절
  - 저장 지도 + 현재 GPS + 청록색 이동경로 + 출발점 확인
  - 통신 복구 후 보호자 공유/서버 기능 재개
  - 안전하산 종료
- 모바일 채굴 대시보드 Drawer에 `ORQUBE GUIDE` 진입 항목 추가
- 웹 첫 화면의 기존 도움말 진입 버튼은 동일 라우팅을 유지한 채 `ORQUBE GUIDE` 명칭으로 표시

## 변경 파일
- `lib/pages/public_help_center_page.dart`
- `lib/pages/mobile_dashboard_page.dart`
- `lib/pages/v17_web_home_page.dart`

## 변경하지 않은 부분
- 안심귀가 기존 기능
- 안전산행 기존 기능 및 오프라인 지도 저장 로직
- AIRSOFT HUB 기존 기능
- 기존 로그인 흐름
- 기존 페이지 클래스/라우팅 구조
- 기존 지도 및 채굴 화면 디자인

## 참고
이 작업 환경에는 Flutter/Dart 실행기가 없어 `flutter analyze` 또는 실제 빌드 테스트는 수행하지 못했습니다. 소스 삽입 위치와 기본 괄호 구조는 점검했습니다. 로컬 개발 PC에서 기존 방식대로 `flutter run -d chrome` 또는 모바일 빌드로 최종 확인해 주세요.
