ORQUBE Flutter 분리형 프로젝트 적용 방법

1) 압축을 풀면 lib 폴더가 있습니다.
2) 기존 Flutter 프로젝트 폴더를 엽니다.
3) 기존 lib 폴더는 안전하게 백업합니다.
   예: lib_backup_날짜
4) 압축 안의 lib 폴더를 기존 프로젝트의 lib 폴더 자리에 복사합니다.
5) 기존 firebase_options.dart 파일이 있다면 새 lib 폴더 안에 그대로 넣어야 합니다.
   이 압축에는 firebase_options.dart가 포함되어 있지 않습니다.
   사용자의 Firebase 프로젝트마다 내용이 다르기 때문입니다.
6) assets/images 폴더에 아래 이미지 파일들이 있어야 합니다.
   - orqube_logo.png
   - orqube_logo2.png
   - orqube_logo3.png
   - nft5.png
7) pubspec.yaml에 assets 등록이 되어 있어야 합니다.

예시:
flutter:
  assets:
    - assets/images/

8) 터미널에서 실행합니다.
   flutter pub get
   flutter run -d chrome

9) 안드로이드 실행은 다음 명령입니다.
   flutter run

주의:
- 이 버전은 채굴 화면 UI와 기본 로직을 먼저 구현한 1단계 버전입니다.
- 실제 Kaia Wallet 연결, OpenSea NFT 조회, AdMob 광고, 관리자 기능은 다음 단계에서 services 폴더에 추가하면 됩니다.
