# ORQUBE DROPS 실제 동작 패치

- 기존 REWARD → MEMBERSHIP → CAMPAIGN → LIQUIDITY READY 누적 활성화 구조 유지
- DROPS 버튼을 단순 단계 활성화에서 실제 EVM ERC-20 전송 흐름으로 변경
- 지원: Kaia Kairos / Polygon Amoy + MetaMask 웹
- 실행 전 프로젝트 소유자, 배포 컨트랙트, 연결 지갑, ERC-20 잔액 검증
- 입력: `지갑주소, 수량` 형식, 한 번 최대 20개, 중복 주소 차단
- 각 transfer Tx의 receipt 성공(0x1)을 확인한 뒤 Tx Hash 저장
- 전체 대상 성공 시에만 `DROPS ACTIVE` 및 `marketStageIndex=0` 기록
- 중간 실패 시 `PARTIAL`, 확인 시간 초과 시 `VERIFICATION_REQUIRED`로 기록하여 중복 재전송 위험 차단
- Solana DROPS는 현재 전송 브리지가 없어 실행 차단. 이후 SPL transfer 브리지로 확장 가능
- LIQUIDITY / SWAP은 기존 순차 게이트 구조를 유지하며 DROPS 완료 후 다음 단계로 열림

테스트 권장 순서:
1. Kaia Kairos 또는 Polygon Amoy 테스트 토큰 배포 완료
2. TOKEN USE CENTER에서 LIQUIDITY READY까지 ACTIVE 확인
3. MetaMask에 배포 지갑 선택 및 해당 테스트넷 가스 토큰 확보
4. DROPS 실행 → 테스트 수신 지갑 1~2개와 소량 입력
5. MetaMask 승인 → Tx receipt 성공 확인
6. 화면에 `DROPS COMPLETED`, Tx 기록, `DROPS ACTIVE`, 다음 `LIQUIDITY` 표시 확인
