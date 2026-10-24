# ORQUBE 9-1 TOKEN UTILITY UPGRADE

## 이번 업그레이드의 방향
사용자가 토큰을 만든 뒤 곧바로 '가격 상승/매매'만 바라보게 하지 않고, 토큰의 실제 쓰임을 먼저 선택하도록 `TOKEN USE CENTER`를 추가했습니다.

### 4가지 사용 모델
1. **REWARD** — 커뮤니티 활동, 미션, 이벤트, 기여에 대한 토큰 보상
2. **MEMBERSHIP** — 토큰 보유자 전용 혜택, 콘텐츠, 참여권
3. **CAMPAIGN** — 브랜드·크리에이터·지역 프로젝트의 쿠폰/이벤트/프로모션 참여
4. **LIQUIDITY READY** — 바로 거래를 열기보다 공급·배분·락업·LP·위험고지를 공개한 뒤 거래 기능으로 확장하는 준비 단계

## 김남국 관련 논의에서 ORQUBE가 취할 교훈
핵심은 특정인의 거래방식을 따라 하는 것이 아니라, 대규모·복잡한 토큰 거래가 사회적으로 문제가 될 때 반복해서 제기되는 **정보 비대칭, 이해관계, 거래 투명성, 자금/토큰 이동 추적 가능성**을 제품 설계에서 선제적으로 줄이는 것입니다.

ORQUBE에서는 다음 원칙을 적용합니다.
- 발행량과 발행자 보유분 공개
- 팀/발행자 물량의 배분 및 락업 정보 공개
- LP가 만들어질 경우 초기 유동성과 변경 이력 공개
- 중요한 토큰 이동 및 정책 변경 이력 보존
- 내부정보나 가격상승 기대를 이용한 홍보를 기본 사용 모델로 삼지 않음
- 실제 사용처(REWARD/MEMBERSHIP/CAMPAIGN)를 거래 기능보다 먼저 설계

## 이번 패치에 실제 반영한 것
- TOKEN PROFILE에 `TOKEN USE CENTER` 추가
- 발행자가 4개 사용 모델 중 하나를 선택해 Firestore 프로젝트에 저장
- `transparencyRequired = true`, `insiderTradingWarning = true` 기본 저장
- 배포 전/후 다음 사용단계를 화면에 안내

## 다음 개발 권장 순서
1. **Token Distribution** — 발행자 보유/커뮤니티 보상/마케팅/유동성 물량 비율 설정
2. **Vesting & Lock** — 팀/발행자 물량 락업 일정
3. **Reward Transfer** — 테스트넷에서 실제 사용자 지갑으로 소량 보상 전송
4. **Token Activity Ledger** — 누가 어떤 사유로 얼마를 받았는지 ORQUBE 내부 사용 이력 표시
5. **Liquidity Ready** — LP 금액·초기 가격·발행량 관계를 사전에 계산/공개
6. **Swap** — 위 투명성/리스크 고지/법률 검토가 끝난 뒤 마지막 단계로 연결

즉, `Token Creator → Wallet → Testnet Deploy → Utility → Distribution/Lock → Reward Transfer → Liquidity → Swap` 순서로 확장합니다.
