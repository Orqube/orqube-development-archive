# ORQUBE V22-2 통합 지도 변경 기록

## 기준 원본
- ORQUBE_V22_1_WEB_ENTRY_STABLE_CANDIDATE_FULL.zip
- 기존 프로젝트 구조, Firebase 설정, 백서 자산, 채굴 연결 구조를 보존했습니다.

## 변경 파일
1. `lib/pages/airsoft_map_page.dart`
   - 기존 지도 화면을 공통 통합 지도 화면으로 확장
   - 상단 모드 추가: 에어소프트 경기 / 안심귀가 / 안전산행
   - 기존 네 기능 보존: 내 위치 / 장소 등록 / 30분 위치 공유 / 긴급 SOS
   - 에어소프트 모드에서는 기존 경기장 마커, 경기장 등록, 길찾기 보존
   - 안심귀가·안전산행 모드는 위치 기능을 사용자가 직접 시작해야 작동
   - 위치 공유 문서에 `shareMode`를 기록해 모드 구분 가능
   - SOS 문서에 `serviceMode`를 추가해 발생 모드 구분 가능
   - 위치 공유 종료 또는 30분 만료 시 기존 `airsoft_live_locations/{uid}` 문서 삭제

2. `lib/pages/airsoft_hub_page.dart`
   - 기존 지도 진입 버튼 명칭을 `에어소프트 경기 · 안심귀가 · 안전산행`으로 확장
   - 기존 Airsoft Hub의 경기, 팀, 채팅, 장소, 마켓, 프로필 기능은 변경하지 않음

## Firestore 규칙 점검
기존 규칙이 다음 컬렉션을 이미 보호하고 있어 신규 공개 규칙을 추가하지 않았습니다.
- `airsoft_live_locations/{uid}`: 소유자와 관리자만 읽기, 소유자만 생성·수정, 소유자/관리자 삭제
- `airsoft_sos/{id}`: 본인만 생성, 본인과 관리자만 읽기, 관리자만 수정·삭제
- `airsoft_places/{id}`: 로그인 사용자 읽기, 소유자 생성·수정·삭제, 관리자 관리

`shareMode`와 `serviceMode`는 기존 허용 필드 검증과 충돌하지 않으며 위치·SOS 공개 범위를 넓히지 않습니다.

## 보존 확인
- `orqube_v14_entry.dart`
- `mobile_dashboard_page-yy.txt`
- `mobile_dashboard_page.dart`
- 기존 Wallet, 채굴, 보상, 출석, NFT, 이벤트, 광고, Firestore 구조
- 한글·영문 백서 PDF 및 자산

## 현재 단계의 범위
안심귀가와 안전산행은 통합 화면, 모드 구분, 현재 위치, 30분 안전 공유, 공유 종료, SOS까지 연결된 2단계 기본 구조입니다.
목적지, 지정 친구 공유, 이동 경로 기록, ETA, 경로 이탈 및 장시간 정지 자동 감지는 다음 확장 단계에서 추가할 수 있습니다.

## 로컬 검증 명령
```bash
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome
flutter run -d android
```
