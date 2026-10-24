# ORQUBE V22-1 웹 진입 안정화 변경 내역

기준 원본: ORQUBE_V21_MOBILE_READABILITY_ENTRY_STABLE_FULL.zip

## 변경 파일

1. `lib/main.dart`
   - 웹 홈을 `V17WebHomePage`에서 실제 수정 대상인 `V16WebHomePage`로 연결.
   - 사용되지 않는 V17 및 Wallet Setup import 제거.
   - 구형 내부 HomePage 로그인 성공 경로도 Wallet Setup 대신 `OrqubeV14Entry`로 연결.

2. `lib/pages/v16_web_home_page.dart`
   - Hero 버튼을 `채굴 시작하기`, `백서 보기` 두 개로 간소화.
   - 채굴 시작 시 Firebase 로그인 상태 확인.
   - 미로그인 사용자는 로그인 화면으로, 로그인 성공 사용자는 `OrqubeV14Entry`로 직접 이동.
   - Wallet Setup 진입 제거.
   - 중복 스토리, 기능 소개, 로드맵, 반복 CTA를 첫 화면 흐름에서 제외.
   - 자체 업체 광고용 반응형 자리 1개와 Google AdSense 대체 자리 1개 추가.
   - 기존 다크 배경, 비행기 로고, 별빛 애니메이션 유지.
   - 하단 Telegram, X, YouTube, ADMIN, 저작권, 개인정보처리방침, 이용약관 유지/추가.

## 보존 확인

- `lib/pages/orqube_v14_entry.dart`
  → `lib/pages/mobile_dashboard_page-yy.txt`
  → `lib/pages/mobile_dashboard_page.dart`
  연결 구조 유지.
- 한글·영문 백서 PDF 및 Whitepaper Center 경로 변경 없음.
- `main_mobile.dart` 변경 없음.
- Wallet 자체 페이지와 서비스 파일 삭제·변경 없음.

## 검증 상태

- 파일 존재, import 대상, 괄호/중괄호 균형 및 핵심 연결을 정적 확인.
- 현재 작업 환경에는 Flutter/Dart SDK 실행 명령이 없어 `flutter analyze`와 `flutter build web`은 실행하지 못함.
- 따라서 본 ZIP은 V22-1 수정본이며, 사용자 PC에서 아래 명령으로 최종 실행 검증 필요:

```bash
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome
```
