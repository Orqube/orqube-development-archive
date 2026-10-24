# ORQUBE DEV40 수정 전체본

## 적용 내용
- 개발용 AI 3자 토론, 사람·AI 선택형, 자료 동반형 3종 유지.
- 토론 및 스테이킹 버튼·칩에 밝은 글자색과 대비되는 배경 적용.
- 박수 WAV 피크 6,757 → 약 30,000으로 증폭(약 4.44배), 재생 음량 55% 감쇠 제거.
- 미리듣기는 풍자 스위치와 관계없이 실행하며 클릭 시 브라우저 오디오 활성화.
- 개발용 토론은 유효한 Firebase 로그인으로 이용. 별도 이메일 주소 인증은 요구하지 않음.
- 서버 ID 토큰 서명·만료·취소 검사, 사용자별 제한, 토론방 권한·음성 기록 검사는 유지.
- 관리자 이메일 인증은 유지.

## 실행 (Windows PowerShell)
새 폴더에 전체 ZIP을 풀고, pubspec.yaml과 firebase.json이 있는 ORQUBE_DEV40_FIXED 폴더로 이동하세요.
기존 파일에 덮어쓰기보다는 새 폴더 실행을 권장합니다. 기존 설정 파일은 포함되어 있습니다.

```powershell
cd "C:\원하는경로\ORQUBE_DEV40_FIXED"
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome
```

## 배포 (같은 PowerShell 폴더)
로그인 수정은 서버도 배포해야 적용됩니다. 프로젝트는 orqube-576e7입니다.

```powershell
firebase login
firebase use orqube-576e7
firebase deploy --only "functions:ai:generateThreeWayDebate,functions:ai:generateDebateSpeech,functions:ai:manageMixedDebateRoom,functions:ai:generateMixedDebate"
flutter build web --release
firebase deploy --only hosting
```
기존 DEBATE_ENABLED=true 및 OPENAI_API_KEY 서버 설정을 유지하세요.
혼합 토론 AI 프로필 이미지 생성 서버를 처음 설치하는 경우:
```powershell
firebase deploy --only "functions:ai:generateMixedDebatePortrait"
```
이 수정에는 Firestore/Storage Rules 변경이 없습니다.

## 적용 확인
1. 기존 이메일 계정으로 로그인한 뒤 토론 대시보드의 3종 메뉴 확인.
2. AI 3자·자료 동반형 토론 생성 및 발언 음성 확인.
3. 사람·AI 선택형 방 생성·시작·발언 확인.
4. 음량 100%에서 박수 미리듣기, 풍자 OFF에서도 미리듣기 확인.
5. 토론·스테이킹의 버튼 및 선택된 기간 글자 확인.
6. 배포 후 브라우저 강력 새로고침(Ctrl+F5). 음량 0%에서는 효과음도 음소거됩니다.

## 검증 및 제한
Node 서버 구문 검사 및 자동 테스트 통과. Flutter SDK가 없는 제작 환경에서 Flutter 빌드·브라우저 실음량 검증은 수행하지 못했습니다.
효과음은 기존 웹 구현 대상입니다. Android 네이티브 효과음은 원본의 stub 구현 상태입니다.
스테이킹은 원본의 모의 테스트 화면을 유지하며 이번 수정으로 실제 온체인 예치를 연결하지 않았습니다.
