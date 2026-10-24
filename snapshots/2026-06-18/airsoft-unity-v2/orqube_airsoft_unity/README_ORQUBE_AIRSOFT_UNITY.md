# ORQUBE Airsoft Survival Unity MVP

이 파일은 ORQUBE 서바이벌 에어소프트 미니게임 1단계용 Unity 코드입니다.

## 포함 기능

- 플레이어 이동
- 마우스 시점 회전
- 마우스 왼쪽 클릭 발사
- 타겟 명중
- 개인 점수
- 팀 점수
- 국가 점수
- ORBS 포인트
- TextMeshPro UI 표시

## 설치 방법

1. Unity Hub 실행
2. New Project 클릭
3. 3D Core 선택
4. 프로젝트 이름: OrqubeAirsoftGame
5. 프로젝트 생성
6. 압축 파일 안의 Assets/Scripts 폴더를 Unity 프로젝트의 Assets 폴더 안에 복사
7. Unity에서 MainScene 생성
8. Plane, Player, Main Camera, Target, Canvas, InfoText, GameManager 생성
9. 각 오브젝트에 스크립트 연결
10. Play 버튼 실행

## 필요한 오브젝트

### Player
- Empty Object
- Character Controller 추가
- PlayerController 추가
- AirsoftGun 추가
- Main Camera를 Player 안에 넣기

### Main Camera
- Position: X 0, Y 1.6, Z 0

### GameManager
- Empty Object
- AirsoftGameManager 추가
- InfoText 연결

### Target
- Cube 생성
- AirsoftTarget 추가
- targetTeam: Red 또는 Blue
- targetCountry: Korea, Japan, USA 중 하나

## 조작법

- W A S D: 이동
- 마우스: 시점 회전
- 마우스 왼쪽 클릭: 발사

## 다음 확장 단계

- Firebase 점수 저장
- Flutter ORQUBE 앱과 점수 연동
- NFT 캐릭터 적용
- 모바일 터치 조작
- 멀티플레이
- Kaia 기반 NFT/토큰 보상 연동
