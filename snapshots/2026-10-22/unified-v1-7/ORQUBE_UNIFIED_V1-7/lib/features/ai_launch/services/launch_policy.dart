import '../models/launch_project.dart';

class LaunchPolicyResult {
  const LaunchPolicyResult({
    required this.allowed,
    required this.code,
    required this.message,
  });

  final bool allowed;
  final String code;
  final String message;

  static const ok = LaunchPolicyResult(
    allowed: true,
    code: 'allowed',
    message: '토큰 생성 가능',
  );
}

class LaunchPolicy {
  const LaunchPolicy._();

  static bool isRestrictedCategory(LaunchCategory category) {
    switch (category) {
      case LaunchCategory.publicFigure:
      case LaunchCategory.politics:
      case LaunchCategory.financialInvestment:
      case LaunchCategory.gambling:
      case LaunchCategory.prohibitedCommerce:
        return true;
      default:
        return false;
    }
  }

  static String categoryLabel(LaunchCategory category) {
    switch (category) {
      case LaunchCategory.dailyLife:
        return '일상 / 라이프';
      case LaunchCategory.hobby:
        return '취미 / 팬';
      case LaunchCategory.work:
        return '업무 / 프로젝트';
      case LaunchCategory.localBusiness:
        return '로컬 비즈니스';
      case LaunchCategory.professional:
        return '전문 활동';
      case LaunchCategory.creator:
        return '크리에이터';
      case LaunchCategory.community:
        return '커뮤니티';
      case LaunchCategory.event:
        return '이벤트';
      case LaunchCategory.meme:
        return '밈 / 캐릭터';
      case LaunchCategory.publicFigure:
        return '공인 / 유명인 · 본인확인 필요';
      case LaunchCategory.politics:
        return '정치 / 선거 / 정당 · 발행 불가';
      case LaunchCategory.financialInvestment:
        return '투자 / 수익보장형 · 발행 불가';
      case LaunchCategory.gambling:
        return '도박 / 베팅 · 발행 불가';
      case LaunchCategory.prohibitedCommerce:
        return '불법·규제품목 거래 · 발행 불가';
    }
  }

  static String categoryReason(LaunchCategory category) {
    switch (category) {
      case LaunchCategory.publicFigure:
        return '타인 사칭·무단 팬토큰을 막기 위해 본인/권리 확인 전에는 공개 토큰 발행을 허용하지 않습니다.';
      case LaunchCategory.politics:
        return '정치인·정당·선거·정치후원 목적의 토큰은 ORQUBE 셀프서비스 발행 대상에서 제외합니다.';
      case LaunchCategory.financialInvestment:
        return '원금·수익 보장, 배당 약속, 투자계약형 구조는 셀프서비스 토큰 발행에서 제외합니다.';
      case LaunchCategory.gambling:
        return '도박·베팅·승패 배당 목적의 토큰은 발행할 수 없습니다.';
      case LaunchCategory.prohibitedCommerce:
        return '불법 상품·제재 대상·규제품목 거래를 목적으로 한 토큰은 발행할 수 없습니다.';
      default:
        return '허용되는 토큰 카테고리입니다.';
    }
  }

  static List<LaunchCategory> get selectableCategories => LaunchCategory.values
      .where((category) => !isRestrictedCategory(category))
      .toList(growable: false);

  static List<LaunchCategory> get visibleRestrictedCategories => const [
        LaunchCategory.publicFigure,
        LaunchCategory.politics,
        LaunchCategory.financialInvestment,
        LaunchCategory.gambling,
        LaunchCategory.prohibitedCommerce,
      ];

  static AssetMode recommendedMode(LaunchCategory category) =>
      AssetMode.publicToken;

  static List<AssetMode> allowedModes(LaunchCategory category) {
    if (isRestrictedCategory(category)) return const [];
    return const [AssetMode.publicToken];
  }

  static LaunchPolicyResult evaluateTokenRequest({
    required LaunchCategory category,
    required String name,
    required String symbol,
    required String text,
  }) {
    if (isRestrictedCategory(category)) {
      return LaunchPolicyResult(
        allowed: false,
        code: 'restricted_category',
        message: categoryReason(category),
      );
    }

    final source = '${name.trim()} ${symbol.trim()} ${text.trim()}'.toLowerCase();

    if (_containsAny(source, _politicsTerms)) {
      return const LaunchPolicyResult(
        allowed: false,
        code: 'politics',
        message: '정치·선거·정당·정치후원 목적의 토큰은 생성할 수 없습니다.',
      );
    }

    if (_containsAny(source, _guaranteedReturnTerms)) {
      return const LaunchPolicyResult(
        allowed: false,
        code: 'guaranteed_return',
        message: '원금보장·확정수익·배당보장 등 투자수익을 약속하는 토큰은 생성할 수 없습니다.',
      );
    }

    if (_containsAny(source, _gamblingTerms)) {
      return const LaunchPolicyResult(
        allowed: false,
        code: 'gambling',
        message: '도박·베팅·승패 배당 목적의 토큰은 생성할 수 없습니다.',
      );
    }

    if (_containsAny(source, _impersonationTerms)) {
      return const LaunchPolicyResult(
        allowed: false,
        code: 'impersonation',
        message: '타인·브랜드 사칭 또는 무단 공식 토큰을 표방하는 내용은 허용하지 않습니다.',
      );
    }

    if (_containsAny(source, _illegalTerms)) {
      return const LaunchPolicyResult(
        allowed: false,
        code: 'illegal',
        message: '불법 거래·범죄 수익·제재 대상 활동을 목적으로 한 토큰은 생성할 수 없습니다.',
      );
    }

    return LaunchPolicyResult.ok;
  }

  static LaunchCategory categoryFromRaw(String raw) {
    final value = raw.trim();
    for (final category in LaunchCategory.values) {
      if (category.name == value) return category;
    }
    return LaunchCategory.community;
  }

  static bool _containsAny(String source, List<String> terms) {
    for (final term in terms) {
      if (source.contains(term)) return true;
    }
    return false;
  }

  // 1차 UX 차단용 보수적 키워드입니다.
  // 실제 온체인 배포 직전에는 서버에서 별도 정책 검증을 다시 해야 합니다.
  static const _politicsTerms = <String>[
    '정치후원',
    '정당 토큰',
    '선거 토큰',
    '후보자 토큰',
    '대선 토큰',
    '총선 토큰',
    'political fundraising',
    'political token',
    'election token',
    'candidate token',
    'party token',
  ];

  static const _guaranteedReturnTerms = <String>[
    '원금보장',
    '원금 보장',
    '확정수익',
    '확정 수익',
    '수익보장',
    '수익 보장',
    '배당보장',
    'guaranteed return',
    'guaranteed profit',
    'risk-free profit',
  ];

  static const _gamblingTerms = <String>[
    '도박 토큰',
    '베팅 토큰',
    '승부 배당',
    '카지노 토큰',
    'gambling token',
    'betting token',
    'casino token',
  ];

  static const _impersonationTerms = <String>[
    '공식인 척',
    '사칭 토큰',
    '무단 공식',
    'impersonation token',
    'fake official token',
  ];

  static const _illegalTerms = <String>[
    '범죄 수익',
    '자금세탁 토큰',
    '불법 거래 토큰',
    'money laundering token',
    'illegal trade token',
  ];
}
