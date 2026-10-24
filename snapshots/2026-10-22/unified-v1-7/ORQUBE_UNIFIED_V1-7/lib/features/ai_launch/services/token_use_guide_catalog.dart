class TokenUseGuideItem {
  const TokenUseGuideItem({
    required this.id,
    required this.role,
    required this.category,
    required this.useCases,
    required this.tokenomics,
    required this.featureSummary,
    required this.nftLink,
    this.policyNote = '',
    this.restricted = false,
  });

  final String id;
  final String role;
  final String category;
  final List<String> useCases;
  final List<String> tokenomics;
  final TokenUseFeatureSummary featureSummary;
  final String nftLink;
  final String policyNote;
  final bool restricted;

  String get searchableText => [
        role,
        category,
        ...useCases,
        ...tokenomics,
        nftLink,
        policyNote,
      ].join(' ').toLowerCase();
}

class TokenUseFeatureSummary {
  const TokenUseFeatureSummary({
    required this.fixed,
    required this.mint,
    required this.cap,
    required this.burn,
    required this.pause,
    required this.reason,
  });

  final bool fixed;
  final bool mint;
  final bool cap;
  final bool burn;
  final bool pause;
  final String reason;
}

class TokenUseGuideCatalog {
  const TokenUseGuideCatalog._();

  static const categories = <String>[
    '상점 · 생활서비스',
    '전문직 · 기술',
    '방송 · 콘텐츠 · 창작',
    '교육 · 연구',
    '의료 · 웰니스',
    '기업 · 프로젝트',
    '단체 · 공공 · 커뮤니티',
  ];

  static final List<TokenUseGuideItem> items = _buildItems();

  static List<TokenUseGuideItem> _buildItems() {
    final rows = <_GuideSeed>[
      _GuideSeed('자영업자', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('전문직업인', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('방송인(아나운서·쇼호스트)', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('작가', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('교수', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('교사', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('유치원·어린이집 교사', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('배우', '방송 · 콘텐츠 · 창작', _GuideProfile.fan),
      _GuideSeed('모델', '방송 · 콘텐츠 · 창작', _GuideProfile.fan),
      _GuideSeed('가수', '방송 · 콘텐츠 · 창작', _GuideProfile.fan),
      _GuideSeed('변호사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('법무사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('변리사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('공인회계사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('세무사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('노무사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('감정평가사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('관세사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('행정사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('공인중개사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('건축사', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('건축·설계사무소', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('기술사·엔지니어', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('소프트웨어 개발자', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('앱 개발자', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('웹 개발자', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('AI 개발자', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('데이터 분석가', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('정보보안 전문가', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('CAD·3D 설계 전문가', '전문직 · 기술', _GuideProfile.professional),
      _GuideSeed('디자이너', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('그래픽 디자이너', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('제품 디자이너', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('인테리어 디자이너', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('사진작가', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('영상제작자', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('영상편집자', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('콘텐츠 크리에이터', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('유튜버·스트리머', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('번역가·통역사', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('출판사·편집자', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('기자·언론인', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('방송제작자·PD', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('성우', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('음악 작곡가·작사가', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('공연기획자', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('예술가·화가', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('공예가', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('웹툰·일러스트 작가', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('문화기획자', '방송 · 콘텐츠 · 창작', _GuideProfile.creator),
      _GuideSeed('의사', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('치과의사', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('한의사', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('약사', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('간호사', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('물리치료사', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('작업치료사', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('임상병리사', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('방사선사', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('상담·코칭 전문가', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('동물병원·수의사', '의료 · 웰니스', _GuideProfile.health),
      _GuideSeed('반려동물 미용·돌봄', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('학원 운영자', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('강사·교육콘텐츠 제작자', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('독서실·스터디카페', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('직업훈련기관', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('온라인 교육사업자', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('연구원', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('연구기관·연구소', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('교육 컨설턴트', '교육 · 연구', _GuideProfile.education),
      _GuideSeed('음식점', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('카페', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('베이커리·제과점', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('편의점·소매점', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('의류·패션 매장', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('화장품 매장', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('꽃집', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('문구·생활용품점', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('전자기기·컴퓨터 매장', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('온라인 쇼핑몰', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('전자상거래 판매자', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('도매·유통업', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('식품 제조·판매업', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('농업·농장', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('축산업', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('수산업', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('전통시장 상인', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('프랜차이즈 가맹점', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('배달·테이크아웃 전문점', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('무인매장 운영자', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('미용실·헤어디자이너', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('네일·뷰티숍', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('피부관리숍', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('세탁소', '상점 · 생활서비스', _GuideProfile.commerce),
      _GuideSeed('청소·시설관리업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('인테리어·리모델링업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('전기·설비업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('자동차 정비업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('렌터카·차량서비스업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('이사·운송업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('택배·물류업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('숙박업·펜션', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('여행사·여행기획자', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('관광·체험사업자', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('웨딩·행사기획업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('장례서비스업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('부동산 임대·관리업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('공유오피스·코워킹스페이스', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('창업자·스타트업', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('중소기업·법인사업자', '기업 · 프로젝트', _GuideProfile.business),
      _GuideSeed('비영리단체·협회', '단체 · 공공 · 커뮤니티', _GuideProfile.organization),
      _GuideSeed('사회적기업·협동조합', '단체 · 공공 · 커뮤니티', _GuideProfile.organization),
      _GuideSeed('종교·지역공동체 운영단체', '단체 · 공공 · 커뮤니티', _GuideProfile.organization),
      _GuideSeed('정치인', '단체 · 공공 · 커뮤니티', _GuideProfile.publicActivity, restricted: true, policyNote: '정치·선거·정치후원 목적의 토큰은 ORQUBE 현재 셀프서비스 발행 정책에서 적용 대상이 아닙니다. 이 항목은 비금전성 공개 참여·교육·기록 구조를 검토하기 위한 참고 예시이며, 실제 발행 전 관련 법규와 플랫폼 정책 확인이 필요합니다.'),
      _GuideSeed('정치·정책 연구단체', '단체 · 공공 · 커뮤니티', _GuideProfile.publicActivity, restricted: true, policyNote: '정치·선거·정치후원 목적의 토큰은 ORQUBE 현재 셀프서비스 발행 정책에서 적용 대상이 아닙니다. 이 항목은 비금전성 공개 참여·교육·기록 구조를 검토하기 위한 참고 예시이며, 실제 발행 전 관련 법규와 플랫폼 정책 확인이 필요합니다.'),
      _GuideSeed('선거사무소·정치후원 조직', '단체 · 공공 · 커뮤니티', _GuideProfile.publicActivity, restricted: true, policyNote: '정치·선거·정치후원 목적의 토큰은 ORQUBE 현재 셀프서비스 발행 정책에서 적용 대상이 아닙니다. 이 항목은 비금전성 공개 참여·교육·기록 구조를 검토하기 위한 참고 예시이며, 실제 발행 전 관련 법규와 플랫폼 정책 확인이 필요합니다.'),
      _GuideSeed('노동조합', '단체 · 공공 · 커뮤니티', _GuideProfile.organization),
      _GuideSeed('직능단체·전문협회', '단체 · 공공 · 커뮤니티', _GuideProfile.organization),
      _GuideSeed('주민자치·지역단체', '단체 · 공공 · 커뮤니티', _GuideProfile.organization),
      _GuideSeed('동문회·친목단체', '단체 · 공공 · 커뮤니티', _GuideProfile.organization),
    ];

    assert(rows.length == 120, 'TOKEN USE GUIDE must contain exactly 120 items.');

    return List<TokenUseGuideItem>.unmodifiable(
      List.generate(rows.length, (index) => _buildItem(index + 1, rows[index])),
    );
  }

  static TokenUseGuideItem _buildItem(int number, _GuideSeed seed) {
    final role = seed.role;
    late final List<String> useCases;
    late final List<String> tokenomics;
    late final TokenUseFeatureSummary features;
    late final String nft;

    switch (seed.profile) {
      case _GuideProfile.fan:
        useCases = [
          '$role 팬·멤버십 참여 리워드',
          '공연·팬미팅·라이브·이벤트 참여권 또는 우선권',
          '공식 콘텐츠·굿즈·커뮤니티 활동과 연결되는 유틸리티',
        ];
        tokenomics = [
          '40% 팬·커뮤니티 리워드',
          '20% 이벤트·콘텐츠 운영',
          '15% 협업·파트너 캠페인',
          '15% $role 운영·성장 풀',
          '10% 장기 예비 풀',
        ];
        features = _mintCapBurnPause('지속적인 팬 활동과 시즌 운영을 고려해 Mint + Cap으로 상한을 두고 Burn·Pause를 함께 두는 설계 예시입니다.');
        nft = '$role 멤버십 카드, 디지털 포토·포스터, 공연 티켓, 시즌 배지, 한정 컬렉터블 NFT와 연결할 수 있습니다.';
        break;
      case _GuideProfile.creator:
        useCases = [
          '$role 콘텐츠 열람·선공개·멤버십 리워드',
          '작품·프로젝트 제작 과정 참여와 커뮤니티 기여 보상',
          '디지털 상품·라이선스·행사·팬 커뮤니티와 연결되는 유틸리티',
        ];
        tokenomics = [
          '35% 독자·시청자·팬 리워드',
          '25% 콘텐츠·프로젝트 운영',
          '15% 콜라보·이벤트',
          '15% $role 크리에이터 풀',
          '10% 장기 예비 풀',
        ];
        features = _mintCapBurnPause('콘텐츠와 프로젝트가 계속 추가될 수 있어 Mint + Cap을 기본 예시로 두고, 종료형 프로젝트는 Fixed로 전환할 수 있습니다.');
        nft = '$role 작품 에디션, 원본 인증, 멤버십 패스, 행사 티켓, 기념 배지 형태의 NFT 연계가 가능합니다.';
        break;
      case _GuideProfile.education:
        useCases = [
          '$role 수업·학습 참여 리워드와 출석·과제 배지',
          '교육 콘텐츠 접근권, 커뮤니티 활동, 행사 참여',
          '학습 성취를 금전 가치와 분리해 기록하는 참여형 유틸리티',
        ];
        tokenomics = [
          '45% 학습·참여 리워드',
          '20% 교육콘텐츠 운영',
          '15% 행사·프로젝트',
          '10% 교육자·운영 풀',
          '10% 장기 예비 풀',
        ];
        features = _mintCapPause('학기·기수별 참여자가 늘 수 있어 Mint + Cap이 유연하며, 교육 운영 중 오류 대응을 위해 Pause를 두는 예시입니다.');
        nft = '$role 수료증, 출석 배지, 프로젝트 인증서, 학습 포트폴리오 NFT와 연결할 수 있습니다. 아동·학생 개인정보는 온체인에 직접 저장하지 않는 구조가 적합합니다.';
        break;
      case _GuideProfile.professional:
        useCases = [
          '$role 회원·고객 커뮤니티 참여 리워드',
          '세미나·교육자료·전문 콘텐츠 접근권',
          '전문 프로젝트 참여·추천·기여·교육 활동 기록',
        ];
        tokenomics = [
          '35% 회원·고객 참여 리워드',
          '20% 전문 콘텐츠·교육',
          '20% 커뮤니티·프로젝트',
          '15% $role 운영 풀',
          '10% 장기 예비 풀',
        ];
        features = _fixedBurnPause('전문서비스는 발행량과 권한을 단순하게 유지하기 위해 Fixed를 우선 예시로 두고, 필요 시 Burn·Pause를 적용합니다.');
        nft = '$role 회원증, 교육 이수증, 행사 참가증, 프로젝트 기여 배지 NFT와 연결할 수 있습니다. 법정 자격증 자체를 대체하거나 민감한 고객정보를 온체인에 넣는 용도는 피합니다.';
        break;
      case _GuideProfile.health:
        useCases = [
          '$role 건강교육·웰니스 프로그램 참여 리워드',
          '일반적인 예약·교육·커뮤니티 프로그램 멤버십 혜택',
          '개인 의료정보와 분리된 비민감 참여 기록',
        ];
        tokenomics = [
          '35% 참여·웰니스 리워드',
          '25% 교육 콘텐츠',
          '15% 멤버십 프로그램',
          '15% 행사·커뮤니티',
          '10% 장기 예비 풀',
        ];
        features = _fixedPause('의료·웰니스 분야는 공급과 권한을 단순하게 유지하는 Fixed + Pause 예시를 우선하며, 진료·처방·민감 건강정보와 토큰을 직접 결합하지 않는 구조가 적합합니다.');
        nft = '$role 일반 교육 수료증, 웰니스 챌린지 배지, 행사 참가증 NFT는 가능하지만 진료기록·검사결과 같은 민감한 건강정보를 NFT에 넣지 않는 것이 적합합니다.';
        break;
      case _GuideProfile.commerce:
        useCases = [
          '$role 구매·방문·리뷰·추천에 대한 로열티 리워드',
          '멤버십 등급, 쿠폰·이벤트·재방문 혜택',
          '제휴 상점·지역 커뮤니티와 연결되는 사용처 확장',
        ];
        tokenomics = [
          '45% 고객 로열티 리워드',
          '20% 멤버십·쿠폰 프로그램',
          '15% 시즌 이벤트',
          '10% 제휴·파트너',
          '10% 장기 예비 풀',
        ];
        features = _mintCapBurnPause('반복 구매·신규 고객 유입에 맞춰 Mint + Cap을 두고, 프로모션 소각과 긴급 Pause를 활용하는 예시입니다.');
        nft = '$role VIP 멤버십, 디지털 스탬프 완주 배지, 한정 쿠폰·기념품·이벤트 티켓 NFT와 연결할 수 있습니다.';
        break;
      case _GuideProfile.business:
        useCases = [
          '$role 고객·파트너·프로젝트 참여 리워드',
          '프로젝트 마일스톤, 교육·안전·품질 활동 참여 기록',
          '협력사·직원·고객 커뮤니티의 비금전성 인센티브',
        ];
        tokenomics = [
          '35% 고객·프로젝트 참여 리워드',
          '20% 파트너·협력 프로그램',
          '20% 내부 프로젝트·교육',
          '15% 캠페인·이벤트',
          '10% 장기 예비 풀',
        ];
        features = _mintCapPause('프로젝트 규모 변화에 대응할 수 있도록 Mint + Cap을 두고, 운영상 사고 대응을 위해 Pause를 포함하는 예시입니다.');
        nft = '$role 프로젝트 완료 인증, 교육·안전 이수 배지, 파트너 인증, 행사 패스 NFT와 연결할 수 있습니다.';
        break;
      case _GuideProfile.organization:
        useCases = [
          '$role 회원 참여·봉사·행사 기여 리워드',
          '멤버십 등급, 교육·회의·캠페인 참여 확인',
          '조직 내부 커뮤니티와 제휴 프로그램의 비금전성 유틸리티',
        ];
        tokenomics = [
          '45% 회원·참여 리워드',
          '20% 행사·교육 운영',
          '15% 멤버십 프로그램',
          '10% 협력 프로젝트',
          '10% 장기 예비 풀',
        ];
        features = _mintCapPause('회원 수와 활동량 변화에 대응하도록 Mint + Cap을 두고, 조직 운영 리스크 대응을 위해 Pause를 포함하는 예시입니다.');
        nft = '$role 회원증, 활동 인증, 봉사·공로 배지, 행사 패스 NFT와 연결할 수 있습니다. 법적 의결권·노동권 등은 별도 제도와 규정을 따라야 합니다.';
        break;
      case _GuideProfile.publicActivity:
        useCases = [
          '$role 공개 행사·교육·자원봉사 참여 기록',
          '공공 프로젝트 참여 포인트와 디지털 배지',
          '비금전성 커뮤니티 참여 이력과 콘텐츠 접근',
        ];
        tokenomics = [
          '50% 참여·봉사 리워드',
          '20% 공개 콘텐츠·교육',
          '15% 행사·프로젝트 운영',
          '10% 협력기관 프로그램',
          '5% 예비 풀',
        ];
        features = _fixedPause('공공성 영역은 공급과 권한 구조를 단순하게 유지하는 Fixed + Pause 참고 예시입니다. 정치·선거 관련 항목은 실제 발행에 적용하지 않고 정책·법규 확인이 우선입니다.');
        nft = '$role 행사 참가증, 공개교육 수료증, 봉사·프로젝트 배지 같은 비금전성 NFT 구조를 검토할 수 있습니다.';
        break;
    }

    return TokenUseGuideItem(
      id: number.toString().padLeft(3, '0'),
      role: role,
      category: seed.category,
      useCases: useCases,
      tokenomics: tokenomics,
      featureSummary: features,
      nftLink: nft,
      policyNote: seed.policyNote,
      restricted: seed.restricted,
    );
  }

  /// 직접 입력 직업·업종의 유해/불법 목적 여부를 로컬에서 1차 차단합니다.
  /// 합법적인 일반 업종을 과도하게 차단하지 않도록 명백한 표현 위주로 검사합니다.
  static bool isRestrictedCustomRole(String rawRole) {
    final normalized = rawRole
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-./·]+'), '');

    const blockedTerms = <String>[
      // 성매매·성적 서비스/알선
      '성매매', '매춘', '조건만남', '성매매알선', '성적서비스',
      'escortservice', 'prostitution', 'sexwork',
      // 불법 도박·사설 베팅
      '불법도박', '사설도박', '사설토토', '불법토토', '카지노총판',
      '도박사이트', '베팅사이트', 'illegalgambling', 'sportsbookagent',
      // 불법 약물·마약 유통
      '마약판매', '마약유통', '불법약물', 'drugdealer', 'narcoticsdealer',
      // 불법 무기 거래
      '불법무기', '무기밀매', '총기밀매', 'weapontrafficking', 'gunrunning',
      // 사기·피싱 등 범죄 목적
      '보이스피싱', '피싱업자', '사기업자', '불법대출', '대포통장',
      'phishing', 'scammer', 'moneylaundering',
    ];

    return blockedTerms.any(normalized.contains);
  }

  static const String restrictedCustomRoleMessage =
      '이 직업·업종은 ORQUBE 맞춤 토큰 설계 지원 대상이 아닙니다. '
      '다른 직업·업종을 입력하거나 기본 직업군을 선택해주세요.';

  /// 기본 120개 목록에 없는 정당한 직업·업종을 동적으로 설계할 때 사용합니다.
  /// 120은 기본 라이브러리이며 상한이 아닙니다. 신규 입력은 공식 목록과 분리해 후보로 다룹니다.
  static TokenUseGuideItem buildCustom(String rawRole) {
    final role = rawRole.trim();
    if (role.isEmpty) {
      throw ArgumentError('직업·업종을 입력해주세요.');
    }
    if (isRestrictedCustomRole(role)) {
      throw ArgumentError(restrictedCustomRoleMessage);
    }

    final lower = role.toLowerCase();
    _GuideProfile profile = _GuideProfile.professional;
    String category = '전문직 · 기술';

    if (lower.contains('헬스') || lower.contains('트레이너') ||
        lower.contains('피트니스') || lower.contains('운동') ||
        lower.contains('웰니스') || lower.contains('요가') ||
        lower.contains('필라테스')) {
      profile = _GuideProfile.health;
      category = '의료 · 웰니스';
    } else if (lower.contains('가수') || lower.contains('배우') ||
        lower.contains('팬') || lower.contains('아이돌')) {
      profile = _GuideProfile.fan;
      category = '방송 · 콘텐츠 · 창작';
    } else if (lower.contains('작가') || lower.contains('크리에이터') ||
        lower.contains('영상') || lower.contains('디자인') ||
        lower.contains('방송') || lower.contains('음악')) {
      profile = _GuideProfile.creator;
      category = '방송 · 콘텐츠 · 창작';
    } else if (lower.contains('교사') || lower.contains('강사') ||
        lower.contains('교육') || lower.contains('학원') ||
        lower.contains('연구')) {
      profile = _GuideProfile.education;
      category = '교육 · 연구';
    } else if (lower.contains('상점') || lower.contains('매장') ||
        lower.contains('카페') || lower.contains('식당') ||
        lower.contains('판매') || lower.contains('쇼핑')) {
      profile = _GuideProfile.commerce;
      category = '상점 · 생활서비스';
    } else if (lower.contains('회사') || lower.contains('기업') ||
        lower.contains('사업') || lower.contains('프로젝트') ||
        lower.contains('스타트업')) {
      profile = _GuideProfile.business;
      category = '기업 · 프로젝트';
    } else if (lower.contains('모임') || lower.contains('협회') ||
        lower.contains('단체') || lower.contains('동호회') ||
        lower.contains('커뮤니티')) {
      profile = _GuideProfile.organization;
      category = '단체 · 공공 · 커뮤니티';
    }

    final seed = _GuideSeed(role, category, profile);
    final base = _buildItem(0, seed);
    return TokenUseGuideItem(
      id: 'CUSTOM',
      role: base.role,
      category: base.category,
      useCases: base.useCases,
      tokenomics: base.tokenomics,
      featureSummary: base.featureSummary,
      nftLink: base.nftLink,
      policyNote: '사용자가 직접 입력한 직업·업종을 기준으로 만든 맞춤 설계입니다. 신규 직업은 즉시 공식 등재되지 않으며 이용 현황과 검토를 거쳐 공통 직업군 후보가 될 수 있습니다.',
    );
  }

  static TokenUseFeatureSummary _mintCapBurnPause(String reason) =>
      TokenUseFeatureSummary(
        fixed: false,
        mint: true,
        cap: true,
        burn: true,
        pause: true,
        reason: reason,
      );

  static TokenUseFeatureSummary _mintCapPause(String reason) =>
      TokenUseFeatureSummary(
        fixed: false,
        mint: true,
        cap: true,
        burn: false,
        pause: true,
        reason: reason,
      );

  static TokenUseFeatureSummary _fixedBurnPause(String reason) =>
      TokenUseFeatureSummary(
        fixed: true,
        mint: false,
        cap: false,
        burn: true,
        pause: true,
        reason: reason,
      );

  static TokenUseFeatureSummary _fixedPause(String reason) =>
      TokenUseFeatureSummary(
        fixed: true,
        mint: false,
        cap: false,
        burn: false,
        pause: true,
        reason: reason,
      );
}

class _GuideSeed {
  const _GuideSeed(
    this.role,
    this.category,
    this.profile, {
    this.restricted = false,
    this.policyNote = '',
  });

  final String role;
  final String category;
  final _GuideProfile profile;
  final bool restricted;
  final String policyNote;
}

enum _GuideProfile {
  fan,
  creator,
  education,
  professional,
  health,
  commerce,
  business,
  organization,
  publicActivity,
}
