# ORQUBE V17.1 지도·안전 위치 기능 설치 안내

## 반영 내용

- 기존 V17 화면·별빛·버튼·채굴 연결 구조 보존
- 모바일 폭 600px 미만에서만 주요 큰 제목 약 14% 축소
- `ORQUBE 플랫폼 안내` 바로 아래 `AIRSOFT 지도 서비스 안내` 카드 추가
- 개인정보 및 위치정보 보호 기준 펼침 안내 추가
- Airsoft Hub 홈에 `경기 지도` 카드 추가
- OpenStreetMap 경기 지도, 현재 위치, 경기장 마커, 외부 길찾기
- 로그인 사용자의 명시적 동의 기반 30분 안전 위치 공유
- 긴급 SOS 위치 전송
- Firestore 위치·SOS 보안 규칙 추가

## 설치

프로젝트 폴더에서 실행합니다.

```bash
flutter clean
flutter pub get
flutter analyze
```

웹 실행:

```bash
flutter run -d chrome -t lib/main.dart
```

Android 실행:

```bash
flutter run -d SM-A125N -t lib/main_mobile.dart
```

## 중요: Firestore 규칙 배포

수정된 `firestore.rules`를 확인한 후 다음 명령으로 배포합니다.

```bash
firebase deploy --only firestore:rules
```

현재 규칙에서는 실시간 위치를 본인과 관리자만 읽을 수 있습니다. 향후 경기별 안전담당자에게 보여주려면 경기 참가자·운영자 권한 구조를 추가한 뒤 규칙을 확장해야 합니다.

## 경기장 마커 데이터

`airsoft_places` 문서에 아래 중 하나가 있어야 지도에 표시됩니다.

```text
latitude: 36.1234
longitude: 127.1234
```

또는

```text
location: GeoPoint(...)
```

기존 주소만 있는 장소는 좌표가 추가되기 전까지 지도 마커가 나타나지 않습니다.

## 개인정보 원칙

- 위치 공유 기본값은 꺼짐
- 사용자 동의 후 30분 동안만 공유
- 상대 팀 추적 용도 사용 금지
- SOS 위치는 안전 대응 목적으로만 사용
- 공유 종료 또는 만료 데이터는 서버 정리 작업으로 삭제 권장
- 정확한 위치는 일반 사용자 전체에게 공개하지 않음
