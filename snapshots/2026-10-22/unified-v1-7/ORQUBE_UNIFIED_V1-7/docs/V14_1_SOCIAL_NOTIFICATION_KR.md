# ORQUBE V14.1 커뮤니티·소셜·알림 통합

## 이번 버전에 실제 추가된 기능

- 대시보드 알림 아이콘 → Notification Center 연결
- 사용자별 Firestore 실시간 알림 목록
- 알림 읽음/모두 읽음/길게 눌러 삭제
- 사용자 활동 피드
- 회원 검색 목록 기반 팔로우
- 친구 요청, 수락, 거절
- 커뮤니티 게시글 작성 시 활동 피드 기록
- Airsoft 일반 회원 등록 시 활동 기록
- Airsoft 팀 참가 신청
- 팀 참가 신청 시 팀 운영자 알림 생성
- 새로운 Firestore 보안 규칙

## 새 파일

- `lib/services/social_service.dart`
- `lib/pages/notification_center_page.dart`
- `lib/pages/social_hub_page.dart`

## 수정 파일

- `lib/pages/mobile_dashboard_page.dart`
- `lib/pages/community_hub_page.dart`
- `lib/pages/airsoft_page.dart`
- `firestore.rules`

## Firestore 컬렉션

- `activities`
- `friend_requests`
- `users/{uid}/notifications`
- `users/{uid}/friends`
- `users/{uid}/following`
- `users/{uid}/followers`
- `airsoft_teams/{teamId}/applications`

## 적용 명령

```bash
flutter clean
flutter pub get
firebase deploy --only firestore:rules
flutter run -t lib/main_mobile.dart
```

## 다음 버전 예정

- 팀 운영자 참가 승인/거절 화면
- 경기 참가 신청 및 경기 캘린더
- 댓글·좋아요·댓글 알림
- QR 출석 및 이벤트
- GPS 경기장 지도
- NFT 배지
- AI 운영 도우미
- 관리자 통계 대시보드
