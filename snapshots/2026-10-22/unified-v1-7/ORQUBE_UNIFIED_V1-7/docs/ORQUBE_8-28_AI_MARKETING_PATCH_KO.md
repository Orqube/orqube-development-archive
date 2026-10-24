# ORQUBE 8-28 AI Marketing / Logo Patch

이 패치는 8-28 INTEGRATED 전체본 위에 덮어씁니다.

## 반영 내용
- 새 토큰 만들기 화면에 AI MARKETING 진행 흐름 표시
- 토큰 프로필에 `AI Marketing 시작` 버튼 추가
- `TOKEN_FIT_SCORE`, 추천 국가/언어/플랫폼, 활용안, 홍보문 생성 후 `marketing_approval_queue`에 PENDING 저장
- `승인 대기함 보기` 버튼으로 Field #9 Human Approval 화면 연결
- 외부 자동게시 / 이메일 자동발송 / 유료광고는 계속 OFF
- AI 로고 `Failed to fetch` 발생 시 실제 호출 endpoint와 Firebase Functions 배포 확인 메시지 표시

## 중요: Functions 재배포
코드만 덮어쓴 뒤에는 새 서버 함수가 인터넷에 아직 존재하지 않습니다. 프로젝트 루트에서 아래 명령을 실행해야 합니다.

```bash
firebase deploy --only functions:generateLaunchLogoOptions,functions:startTokenLaunchMarketing
```

AI 초안 함수까지 함께 맞추려면:

```bash
firebase deploy --only functions:generateLaunchAiDraft,functions:generateLaunchLogoOptions,functions:startTokenLaunchMarketing
```

배포 후 Flutter 웹을 다시 빌드/배포합니다.

```bash
flutter build web
firebase deploy --only hosting
```

## 확인 순서
1. 로그인
2. 새 토큰 만들기에서 토큰 저장
3. TOKEN PROFILE의 AI MARKETING 영역에서 `AI Marketing 시작`
4. 분석 완료 후 `승인 대기함 보기`
5. TOKEN_FIT_SCORE / 국가 / 언어 / 플랫폼 / 활용안 / 홍보문 확인
6. 휴대폰에서 승인 / 보류 / 제외
7. AI 로고 3안 버튼 재시험
