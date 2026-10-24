# ORQUBE 8-28 무료 로고 + AI Functions 분리 패치

## 변경 정책
- 첫 AI 로고 1개: 사용자당 1회 무료
- 추가 AI 로고: 1개당 3 ORBS
- 추가 생성 시 `launch_wallets/{uid}.orbsBalance`를 서버 트랜잭션으로 확인/차감
- 생성 실패 시 예약 차감분은 서버에서 환불
- 가격은 `launch_config/economy.logoAdditionalCostOrbs` 값으로 변경 가능하며, 미설정 시 3 ORBS

## NAVER Secret 입력 문제 해결
AI Functions를 `functions_ai` codebase로 분리했습니다. 기존 `functions` codebase에는 NAVER 카페 동기화만 남기므로 AI 배포 시 NAVER_CLIENT_ID/SECRET을 묻지 않습니다.

## 적용 후 명령
프로젝트 루트에서:

```powershell
npm --prefix functions_ai install
firebase deploy --only functions:ai
```

처음 배포 시 `OPENAI_API_KEY`만 Secret으로 요청할 수 있습니다. 값을 모르면 임의 입력하지 마세요.

## 테스트 순서
1. 로그인 후 새 토큰 만들기
2. 첫 AI 로고 생성 → 1개 생성, ORBS 차감 없음
3. 다시 만들기 → 3 ORBS 차감
4. ORBS가 3 미만이면 부족 안내
5. AI Marketing 시작 → approval queue 생성 확인
