V1-4 통합본
기존 3자대화와 자료형 토론: 관리자 전용. 일반 토론 메뉴: 사람·AI 혼합 토론.
홈 배경은 V1-3 원본 우주·군인 이미지 유지. 토큰 스트림과 AI 상담 유지.
관리자: 이메일 인증된 byd1009@naver.com 또는 기존 관리자 계정.

PowerShell (압축을 풀고 pubspec.yaml이 있는 폴더에서):
flutter pub get
flutter build web --release
firebase deploy --only "functions:ai:generateThreeWayDebate,hosting"

서버 제한 적용에는 위 Functions 배포가 필요합니다.
Flutter SDK가 없는 제작 환경이므로 Flutter 빌드 및 실제 로그인/AI 응답은 미검증입니다.
