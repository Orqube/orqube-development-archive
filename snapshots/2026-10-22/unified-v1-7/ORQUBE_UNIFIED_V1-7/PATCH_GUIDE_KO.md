# DEV28-1 시민 질문 / 프로필 사진 패치

압축 내부의 파일을 기존 개발용 프로젝트 루트(pubspec.yaml 위치)에 덮어쓰세요.
기존 전체본은 백업하세요. 이 ZIP은 변경 파일만 포함합니다.

## 변경 내용
- AI 응답에 A/B/C 답변 그룹을 필수화하고 기존 숫자 panel/lines 형식으로 변환합니다.
- 발언 order로 반박 흐름을 유지합니다. 시민 질문에도 세 패널 답변을 필수로 받습니다.
- 불완전 응답/거절/잘못된 JSON을 구별하며 답변을 꾸며서 보충하지 않습니다.
- 직접 사진 선택 → 위치/확대 조절 → 정사각 자르기 → 512×512 JPEG 압축(최대 300KB) → 즉시 저장.
- 원본은 최대 15MB, JPG/PNG/WebP만 선택합니다. HEIC는 JPG로 변환해주세요.
- 새 파일과 프로필 저장 성공 후 이전 직접 업로드 사진을 삭제합니다.
- 본인 UID 경로만 업로드/교체/삭제 가능하며 관리자의 다른 회원 프로필 필드 수정도 차단합니다.
- NFT 프로필과 기존 URL 입력 기능을 유지합니다. 직접 업로드 시 일반 사진 모드로 바뀝니다.
- 기존 사용자 문서 읽기 권한은 유지합니다. 사진은 다른 회원에게 표시할 수 있으며 비공개 사진 보관함이 아닙니다.

## 적용 및 배포
프로젝트 루트 터미널에서:
```powershell
flutter pub get
flutter analyze lib/pages/profile_page.dart lib/pages/profile_photo_crop_page.dart lib/services/debate_api_service.dart
flutter build web
firebase deploy --only functions:ai:generateThreeWayDebate,firestore:rules,storage --project orqube-576e7
```
위 Firebase 명령은 Hosting을 배포하지 않습니다. build/web 확인 후 개발용 Hosting의 기존 배포 방식으로 배포하세요.
공개용과 같은 Firebase 프로젝트라면 함수·규칙 변경은 공유됩니다.
Firebase Console에서 Storage가 미설정이면 먼저 시작하기로 버킷을 생성하고 요금제 요구사항을 확인하세요.
기존 Storage 규칙이 콘솔에 별도로 있다면 이 파일로 덮기 전에 다른 서비스의 규칙과 병합하세요.
새 패키지 lockfile은 flutter pub get으로 생성합니다.

## 검증
서버 문법 검사 및 서버 단위 테스트 통과. Flutter SDK가 없어 앱 컴파일/실기기 및 배포된 Firebase 권한 검증은 미실행.
배포 후 시민 질문 A/B/C 답변, 최종요약, JPG/PNG 선택·자르기·취소·교체, 로그아웃/계정 전환,
다른 UID 사진 경로 쓰기 거부를 테스트하세요. 사진 교체 실패 시 기존 프로필 사진이 유지돼야 합니다.
