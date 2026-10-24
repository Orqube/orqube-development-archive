# ORQUBE V14 통합 구현 상태

## 현재 통합된 기능
- Firebase 로그인 상태 기반 모바일 진입
- 기존 채굴·출석·프로필·Wallet·NFT·News 화면 유지
- AdMob 보상형 광고 기존 구현 유지
- Firestore 커뮤니티 게시판
- 국내 채팅 및 Global English Chat
- 클라이언트 금칙어 필터, 신고, 사용자 차단
- Airsoft Team/Match 조회 구조와 일반 회원 참여 등록
- Firestore ORBS 랭킹
- 웹·앱 공통 MobileDashboardPage 진입 구조 유지

## 운영 전 필수 작업
- Firebase Console에서 firestore.rules 배포
- 복합 색인이 요구될 경우 콘솔 안내에 따라 생성
- 금칙어 목록과 관리자 검토 시스템 보강
- 실제 AdMob 광고 단위 ID 교체 및 동의/개인정보 화면 추가
- 팀·경기 등록은 관리자 화면 또는 Cloud Functions로 확장

## 향후 로드맵
- 서버 측 콘텐츠 검수 및 반복 위반 제재
- 푸시 알림, 이미지 업로드, 댓글, 좋아요
- 관리자 신고 처리 화면
- 실제 온체인 Wallet/NFT 연동은 별도 보안 검토 후 진행
