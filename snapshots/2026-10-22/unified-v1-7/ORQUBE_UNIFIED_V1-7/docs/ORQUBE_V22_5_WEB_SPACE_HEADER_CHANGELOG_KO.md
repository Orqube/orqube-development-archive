# ORQUBE V22.5 Web Space & Header Login

## 기준
`ORQUBE_V22_4_SPACE_BACKGROUND_WHITEPAPER_EXECUTABLE_FULL.zip`

## 변경 파일
- `lib/pages/v16_web_home_page.dart`

## 변경 내용
- 정적 좌표 캐시 기반 별빛 반짝임
- 저속 보라색·청록색 성운 이동
- 소수 입자 드리프트
- 간헐적 유성 효과
- `RepaintBoundary`와 `IgnorePointer`로 배경 레이어 격리
- 언어 선택 옆 Firebase Auth 로그인 UI
- 로그인 사용자 이름 및 Profile / Settings / Logout 메뉴
- 기존 `ProfilePage`, `SettingsPage`, Firebase Auth 로그아웃 연결

## 변경하지 않은 영역
Wallet, Mining, Community, Whitepaper Center, Admin, 광고, Firestore, Firebase 설정, 모바일 진입점 및 기존 데이터 구조.
