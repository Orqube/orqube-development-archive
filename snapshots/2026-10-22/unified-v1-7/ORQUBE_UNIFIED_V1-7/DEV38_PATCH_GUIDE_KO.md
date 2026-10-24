# ORQUBE DEV38 토론 메뉴 · 영상 게시 관리 패치

## 적용
ORQUBE_DEV38.zip을 푼 실제 Flutter 프로젝트 폴더(pubspec.yaml, lib, firebase.json이 있는 폴더)에 이 ZIP 내용을 덮어쓰세요. 원본 ZIP 내부 폴더 이름은 ORQUBE_DEV37입니다. 프로젝트 루트에 lib 폴더가 합쳐져야 합니다.

변경 파일: lib/pages/v17_web_home_page.dart, lib/pages/admin_dashboard_page.dart, lib/pages/admin_video_posts_panel.dart(신규), lib/widgets/public_video_board.dart, firestore.rules.

## 토론 진입
- 첫 홈페이지 → 전체 서비스 영역의 「토론 대시보드」
- 관리자 ADMIN → 「토론 대시보드」 → 「토론 3종 열기」
- 기존 모바일 전체 서비스의 DEBATE 메뉴도 유지합니다.
- 대시보드: AI 3자 토론 / 사람·AI 선택형 토론 / 자료 동반형 토론.
- 자료형은 기존 토론 엔진의 presentation 모드로 연결되며 기존 2종은 그대로 유지됩니다.

## 영상 게시
1. 영상을 먼저 YouTube에 업로드하고 영상 링크를 복사합니다. 이 기능은 영상 파일을 YouTube에 직접 업로드하는 기능이 아닙니다.
2. 관리자 계정으로 로그인 → 홈페이지 하단 ADMIN → 「영상 게시 관리」.
3. 제목, YouTube 링크, 설명을 입력하고 「공개」를 선택한 뒤 「등록」.
4. 첫 홈페이지 하단 영상 게시판에 공개 게시물이 표시됩니다. 클릭하면 YouTube에서 재생됩니다.
5. 「수정」을 누르면 위 입력란으로 불러옵니다. 공개를 끄고 「수정 저장」하면 홈페이지에서 숨겨집니다.
6. 「삭제」는 확인 후 게시물만 삭제하며 YouTube 영상은 유지합니다.

https://youtu.be/영상ID, YouTube watch/shorts/live/embed 링크를 지원합니다. 채널 주소는 영상 링크로 등록할 수 없습니다.
게시물은 video_posts 컬렉션에 저장합니다. 관리자 권한은 기존 users/{uid} 문서의 isAdmin:true 또는 role:admin 기준을 그대로 사용합니다.
기존 코드의 고정 영상 2개는 새 게시물로 자동 이전하지 않습니다. 원하는 영상을 관리자 화면에서 등록하세요. 비공개 설정과 관계없이 고정 영상이 계속 노출되지 않도록 새 게시판은 공개 게시물만 표시합니다.

## PowerShell에서 적용 · 확인
먼저 실제 프로젝트 폴더로 이동한 뒤 실행하세요.

```powershell
flutter pub get
flutter analyze
firebase deploy --only firestore:rules
flutter run -d chrome
```
Firestore 규칙은 현재 선택된 Firebase 프로젝트에 적용됩니다. 공개용과 개발용이 동일한 Firebase 프로젝트라면 새 video_posts 규칙도 공유됩니다. 기존 컬렉션 규칙은 변경하지 않았습니다.
위 명령에는 Hosting 배포가 없으므로 공개 홈페이지 화면을 바꾸지 않습니다. 이 패치는 새 Functions 코드를 포함하지 않으므로 이 변경만을 위해 Functions를 재배포할 필요는 없습니다.

개발용에 수정 화면을 배포하려면 먼저 .firebaserc의 프로젝트와 firebase.json의 Hosting 대상을 확인하세요. 공개용과 동일 Hosting 대상으로 배포하면 공개 화면이 바뀌므로, 개발용 대상이 분리된 경우에만 다음을 실행하세요.

```powershell
flutter build web --release
firebase deploy --only hosting
```

## 점검 기록과 실제 확인 항목
코드 점검: 3종 화면 연결, 변경 파일 상대 import, 공개 게시물 조회 조건, 등록/수정/삭제 연결, 기존 Firestore 규칙 보존 확인 완료.
이 작업 환경에는 Flutter/Dart SDK와 Firebase 로그인 세션이 없어서 Flutter 컴파일, 브라우저 실행, 실제 서버 권한 테스트는 수행하지 못했습니다.
실행 후 확인: 관리자 비공개 등록 → 방문자 화면에 미표시 → 공개 수정 → 방문자 화면 표시 → 제목/설명 수정 → YouTube 열기 → 삭제 확인. 모바일에서도 홈페이지 토론 메뉴에서 3종 각각 진입해 확인하세요.
