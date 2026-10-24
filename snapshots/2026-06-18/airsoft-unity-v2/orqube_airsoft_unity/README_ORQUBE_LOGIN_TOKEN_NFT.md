# ORQUBE Airsoft v2 - 로그인/토큰/NFT 게임 실행 알고리즘

이 패키지는 실제 메인넷 연결 전 개발용 MVP입니다.
압축을 풀면 자동 설치되는 형태는 운영체제 보안상 제한이 있으므로, Unity 프로젝트의 Assets 폴더에 복사해서 사용합니다.

## 핵심 알고리즘

1. 게임 실행 시 OrqubeLocalAuthManager가 자동 로그인합니다.
2. 로컬에 기존 유저가 없으면 개발용 Guest 계정을 자동 생성합니다.
3. 사용자의 appPoint, ORBS 보유량, NFT 보유량을 확인합니다.
4. ORBS 1개 이상 또는 NFT 1개 이상이면 게임 시작 가능 상태가 됩니다.
5. 보유 조건이 없으면 “토큰 전환 신청 또는 NFT 보유 필요” 문구를 표시합니다.
6. 전환 버튼을 누르면 appPoint 100점을 ORBS 1개로 전환하는 개발용 시뮬레이션이 실행됩니다.
7. 게임 중 타겟을 맞추면 개인 점수, 팀 점수, 국가 점수, 게임 포인트, Pending ORBS 포인트가 증가합니다.

## Unity 적용 순서

### 1. 기존 Unity 프로젝트 열기
Unity Hub에서 OrqubeAirsoftGame 프로젝트를 엽니다.

### 2. Scripts 복사
이 ZIP 안의 Assets/Scripts 폴더 내용을 프로젝트의 Assets/Scripts 폴더에 복사합니다.

### 3. 시작 메뉴 씬 만들기
Assets/Scenes 폴더에서 새 Scene을 만들고 이름을 MenuScene으로 저장합니다.

### 4. MenuScene에 오브젝트 만들기
Hierarchy에서 Create Empty를 만들고 이름을 OrqubeSystem으로 바꿉니다.
다음 컴포넌트를 붙입니다.

- OrqubeLocalAuthManager
- OrqubeAccessManager
- OrqubeRewardManager
- OrqubeMainMenuUI

### 5. UI 만들기
Canvas를 만들고 TextMeshPro Text 2개, Button 4개를 만듭니다.

Text 이름:
- UserInfoText
- GuideText

Button 이름:
- StartGameButton
- ConvertTokenButton
- AddTestNftButton
- ResetUserButton

### 6. 연결
OrqubeMainMenuUI의 User Info Text에 UserInfoText 연결
OrqubeMainMenuUI의 Guide Text에 GuideText 연결
OrqubeAccessManager의 Start Button에 StartGameButton 연결
OrqubeAccessManager의 Access Message Text에 GuideText 연결

### 7. 버튼 함수 연결
StartGameButton → OrqubeMainMenuUI.OnClickStartGame
ConvertTokenButton → OrqubeMainMenuUI.OnClickConvertToken
AddTestNftButton → OrqubeMainMenuUI.OnClickAddTestNft
ResetUserButton → OrqubeMainMenuUI.OnClickResetUser

### 8. Build Settings
File → Build Settings → Scenes In Build에 MenuScene과 MainScene을 넣습니다.
MenuScene을 0번, MainScene을 1번으로 둡니다.

## 실제 서비스 버전에서 바꿀 부분

현재는 PlayerPrefs 로컬 저장 방식입니다.
실제 서비스에서는 아래로 교체합니다.

- Firebase Auth: 실제 이메일/구글/전화번호 로그인
- Firestore: 포인트, 랭킹 저장
- Kaia Wallet: 지갑 연결
- Kaia RPC 또는 API: ORBS 토큰 보유 확인
- NFT API: ORQUBE NFT 보유 확인
- 서버 검증: 토큰 전환 신청 승인/거절

## 주의

토큰 전환, NFT 보유, 포인트 보상은 실제 돈/가치와 연결될 수 있으므로 정식 서비스 전에는 법률·세무·게임물 등급·전자금융 관련 검토가 필요합니다.
