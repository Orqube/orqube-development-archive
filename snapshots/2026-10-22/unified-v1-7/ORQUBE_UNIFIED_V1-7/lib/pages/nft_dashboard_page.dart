import 'package:flutter/material.dart';

/// ORQUBE NFT Dashboard V2
///
/// 저장 위치:
///   lib/pages/nft_dashboard_page.dart
///
/// 연결 예:
///   Navigator.push(
///     context,
///     MaterialPageRoute(
///       builder: (_) => const NftDashboardPage(),
///     ),
///   );
///
/// 주의:
/// - 포인트 매수/판매는 현재 화면 내부의 데모 상태입니다.
/// - 실제 운영 시 Firestore 트랜잭션, 서버 검증, 거래 로그 및 운영정책이 필요합니다.
class NftDashboardPage extends StatefulWidget {
  const NftDashboardPage({super.key});

  @override
  State<NftDashboardPage> createState() => _NftDashboardPageState();
}

class _NftDashboardPageState extends State<NftDashboardPage> {
  static const Color bg = Color(0xFF03040B);
  static const Color panel = Color(0xFF0C0D18);
  static const Color panel2 = Color(0xFF13152A);
  static const Color purple = Color(0xFF8B2CF6);
  static const Color lime = Color(0xFFD7FF35);
  static const Color border = Color(0xFF292B45);
  static const Color muted = Color(0xFF9EA3B8);

  static const String logoPath =
      'assets/images/brand/orqube_aircraft_round.jpg';

  final List<_NftItem> _items = [
    _NftItem(
      id: 'ORQ-001',
      name: 'ORQUBE Genesis Core',
      grade: NftGrade.founder,
      rarity: '0.10%',
      owner: 'Kim MyoungKeun',
      benefit: 'Founder 배지 · 특별 이벤트 · 우선 참여권',
      imagePath: 'assets/images/nft/nft_legacy_of_honor.jpg',
      pointPrice: 250000,
      owned: true,
    ),
    _NftItem(
      id: 'ORQ-014',
      name: 'Crystal Vanguard',
      grade: NftGrade.mythic,
      rarity: '0.50%',
      owner: 'Kim MyoungKeun',
      benefit: '채굴 보너스 · 프리미엄 퀘스트',
      imagePath: 'assets/images/nft/nft_butterfly_operation.jpg',
      pointPrice: 180000,
      owned: true,
    ),
    _NftItem(
      id: 'ORQ-028',
      name: 'Golden Guardian',
      grade: NftGrade.legendary,
      rarity: '1.20%',
      owner: 'Kim MyoungKeun',
      benefit: '랭킹 보너스 · 전용 프로필 프레임',
      imagePath: 'assets/images/nft/nft_golden_guardian.jpg',
      pointPrice: 180000,
      owned: true,
    ),
    _NftItem(
      id: 'ORQ-074',
      name: 'Titan Commander',
      grade: NftGrade.epic,
      rarity: '4.80%',
      owner: 'Kim MyoungKeun',
      benefit: '일일 보상 증가 · 특별 미션',
      imagePath: 'assets/images/nft/nft_titan_commander.jpg',
      pointPrice: 90000,
      owned: true,
    ),
    _NftItem(
      id: 'ORQ-155',
      name: 'Silent Sentinel',
      grade: NftGrade.rare,
      rarity: '12.00%',
      owner: 'Kim MyoungKeun',
      benefit: '커뮤니티 포인트 보너스',
      imagePath: 'assets/images/nft/nft_silent_sentinel.png',
      pointPrice: 18000,
      owned: true,
    ),
    _NftItem(
      id: 'ORQ-232',
      name: 'Legacy of Honor',
      grade: NftGrade.rare,
      rarity: '16.50%',
      owner: 'Kim MyoungKeun',
      benefit: '출석 포인트 보너스',
      imagePath: 'assets/images/nft/nft1.png',
      pointPrice: 14000,
      owned: true,
    ),
    _NftItem(
      id: 'ORQ-310',
      name: 'Butterfly Operation',
      grade: NftGrade.common,
      rarity: '45.00%',
      owner: 'Kim MyoungKeun',
      benefit: '기본 프로필 배지',
      imagePath: 'assets/images/nft/nft2.png',
      pointPrice: 120000,
      owned: true,
    ),
  ];

  NftGrade? _selectedGrade;
  bool _ownedOnly = true;
  bool _krMode = true;
  int _points = 250000;
  String _query = '';

  List<_NftItem> get _filtered {
    final keyword = _query.trim().toLowerCase();
    return _items.where((item) {
      final gradeOk =
          _selectedGrade == null || item.grade == _selectedGrade;
      final ownedOk = !_ownedOnly || item.owned;
      final searchOk = keyword.isEmpty ||
          item.name.toLowerCase().contains(keyword) ||
          item.id.toLowerCase().contains(keyword) ||
          item.owner.toLowerCase().contains(keyword);
      return gradeOk && ownedOk && searchOk;
    }).toList();
  }

  int get _ownedCount => _items.where((e) => e.owned).length;

  NftGrade get _topGrade {
    const order = [
      NftGrade.founder,
      NftGrade.mythic,
      NftGrade.legendary,
      NftGrade.epic,
      NftGrade.rare,
      NftGrade.common,
    ];
    for (final grade in order) {
      if (_items.any((item) => item.owned && item.grade == grade)) {
        return grade;
      }
    }
    return NftGrade.common;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: '채굴 화면으로 돌아가기',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 2,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ORQUBE NFT',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'MULTI-CHAIN COLLECTION',
              style: TextStyle(
                color: muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: () => _message('NFT 정보를 새로고침했습니다.'),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              sliver: SliverToBoxAdapter(child: _buildHeader()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              sliver: SliverToBoxAdapter(child: _buildChainStrip()),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverToBoxAdapter(child: _buildModePanel()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              sliver: SliverToBoxAdapter(child: _buildSearch()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              sliver: SliverToBoxAdapter(child: _buildFilters()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              sliver: SliverToBoxAdapter(child: _buildOwnedToggle()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Text(
                      'NFT GALLERY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_filtered.length} items',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _emptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width < 520
                        ? 2
                        : width < 900
                            ? 3
                            : 4;
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = _filtered[index];
                          return _NftCard(
                            item: item,
                            onTap: () => _openDetail(item),
                          );
                        },
                        childCount: _filtered.length,
                      ),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: width < 520 ? 250 : 275,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF29115A),
            Color(0xFF11132A),
            Color(0xFF080914),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: purple),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Logo(size: 62),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY NFT COLLECTION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'ORQUBE INTERNAL NFT',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: lime,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$_ownedCount OWNED',
                  style: const TextStyle(
                    color: Color(0xFF101307),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF373950)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.stars_rounded,
                  label: 'POINTS',
                  value: _formatPoints(_points),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  icon: Icons.collections_bookmark_outlined,
                  label: 'OWNED NFT',
                  value: '$_ownedCount',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  icon: Icons.workspace_premium_outlined,
                  label: 'TOP GRADE',
                  value: _topGrade.label,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChainStrip() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _ChainBadge(label: 'KAIA', color: lime, icon: Icons.hexagon_outlined),
        _ChainBadge(label: 'POLYGON', color: Color(0xFF9A5CFF), icon: Icons.link_rounded),
        _ChainBadge(label: 'SOLANA', color: Color(0xFF28E2D0), icon: Icons.view_stream_rounded),
      ],
    );
  }

  void _openModeDashboard(bool krMode) {
    setState(() => _krMode = krMode);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _NftModeDashboardPage(
          krMode: krMode,
          items: _items,
          initialPoints: _points,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  Widget _buildModePanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: 'KR MODE',
                  selected: _krMode,
                  onTap: () => _openModeDashboard(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ModeButton(
                  label: 'GLOBAL MODE',
                  selected: !_krMode,
                  onTap: () => _openModeDashboard(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _krMode
                    ? Icons.shield_outlined
                    : Icons.public_rounded,
                color: lime,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _krMode
                      ? '국내 운영: ORQUBE 플랫폼 내부에서 포인트로만 거래하는 데모입니다. 현금 환전, 외부 전송 및 투자수익 표현은 제공하지 않습니다.'
                      : '글로벌 운영: Kaia Wallet 및 외부 NFT 마켓 연동 예정입니다. 현재 버튼은 안내용이며 실제 온체인 거래는 실행하지 않습니다.',
                  style: const TextStyle(
                    color: Color(0xFFC4C7D8),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      onChanged: (value) => setState(() => _query = value),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'NFT 이름·ID·소유자 검색',
        hintStyle: const TextStyle(color: muted, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: muted),
        filled: true,
        fillColor: panel,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: purple, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 39,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChipButton(
            label: 'ALL',
            color: purple,
            selected: _selectedGrade == null,
            onTap: () => setState(() => _selectedGrade = null),
          ),
          const SizedBox(width: 7),
          ...NftGrade.values.expand(
            (grade) => [
              _FilterChipButton(
                label: grade.label,
                color: grade.color,
                selected: _selectedGrade == grade,
                onTap: () => setState(() => _selectedGrade = grade),
              ),
              const SizedBox(width: 7),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwnedToggle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 7, 7, 7),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: lime, size: 20),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              '보유 NFT만 표시',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch.adaptive(
            value: _ownedOnly,
            activeTrackColor: purple,
            activeThumbColor: lime,
            onChanged: (value) => setState(() => _ownedOnly = value),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        decoration: const BoxDecoration(
          color: Color(0xFF090A13),
          border: Border(top: BorderSide(color: border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _BottomItem(
                icon: Icons.bolt_rounded,
                label: '채굴 화면',
                onTap: () => Navigator.maybePop(context),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => _message('ORQUBE NFT COLLECTION'),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Logo(size: 42),
                    SizedBox(height: 3),
                    Text(
                      'ORQUBE',
                      style: TextStyle(
                        color: lime,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _BottomItem(
                icon: _krMode
                    ? Icons.swap_horiz_rounded
                    : Icons.account_balance_wallet_outlined,
                label: _krMode ? '포인트 거래' : 'Kaia 예정',
                onTap: () => _openModeDashboard(_krMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          '조건에 맞는 NFT가 없습니다.',
          style: TextStyle(
            color: muted,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _openDetail(_NftItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.90,
              minChildSize: 0.62,
              maxChildSize: 0.96,
              expand: false,
              builder: (context, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF090A13),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    controller: controller,
                    padding:
                        const EdgeInsets.fromLTRB(17, 10, 17, 28),
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B3D52),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: AspectRatio(
                          aspectRatio: 1.45,
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageFallback(
                              item.grade.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _SmallBadge(
                            label: item.grade.label,
                            color: item.grade.color,
                          ),
                          const Spacer(),
                          Text(
                            item.id,
                            style: const TextStyle(
                              color: muted,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _InfoPanel(
                        children: [
                          _InfoRow(label: 'ID', value: item.id),
                          _InfoRow(
                            label: '등급',
                            value: item.grade.label,
                          ),
                          _InfoRow(label: '희귀도', value: item.rarity),
                          _InfoRow(label: '소유자', value: item.owner),
                          _InfoRow(
                            label: '소유 상태',
                            value: item.owned ? '보유 중' : '판매 중',
                          ),
                          _InfoRow(
                            label: '포인트 가격',
                            value: '${_formatPoints(item.pointPrice)} P',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoPanel(
                        children: [
                          const Text(
                            '혜택',
                            style: TextStyle(
                              color: lime,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.benefit,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),
                      if (_krMode)
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: item.owned
                                    ? null
                                    : () {
                                        _buyItem(item);
                                        setSheetState(() {});
                                      },
                                icon:
                                    const Icon(Icons.shopping_cart_outlined),
                                label: const Text('포인트로 구매'),
                                style: FilledButton.styleFrom(
                                  minimumSize:
                                      const Size.fromHeight(52),
                                  backgroundColor: purple,
                                  disabledBackgroundColor:
                                      const Color(0xFF282A3C),
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: item.owned
                                    ? () {
                                        _sellItem(item);
                                        setSheetState(() {});
                                      }
                                    : null,
                                icon: const Icon(Icons.sell_outlined),
                                label: const Text('포인트로 판매'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize:
                                      const Size.fromHeight(52),
                                  foregroundColor: lime,
                                  side: const BorderSide(color: lime),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        FilledButton.icon(
                          onPressed: () => _message(
                            'Kaia Wallet 및 외부 마켓 연동은 준비 중입니다.',
                          ),
                          icon:
                              const Icon(Icons.account_balance_wallet_outlined),
                          label: const Text('Kaia Wallet · 외부 마켓 예정'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: purple,
                          ),
                        ),
                      const SizedBox(height: 10),
                      const Text(
                        '현재 거래는 데모입니다. 실제 운영 전 Firestore 트랜잭션, 서버 검증, 거래기록 및 이용약관 연결이 필요합니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _buyItem(_NftItem item) {
    if (item.owned) {
      _message('이미 보유 중인 NFT입니다.');
      return;
    }
    if (_points < item.pointPrice) {
      _message('포인트가 부족합니다.');
      return;
    }
    setState(() {
      _points -= item.pointPrice;
      item.owned = true;
      item.owner = 'Kim MyoungKeun';
    });
    _message('${item.name} 구매 완료');
  }

  void _sellItem(_NftItem item) {
    if (!item.owned) {
      _message('보유하지 않은 NFT입니다.');
      return;
    }
    final salePoints = (item.pointPrice * 0.8).round();
    setState(() {
      _points += salePoints;
      item.owned = false;
      item.owner = 'ORQUBE MARKET';
    });
    _message('${_formatPoints(salePoints)}P 판매 완료');
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _formatPoints(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  static Widget _imageFallback(Color color) {
    return Container(
      color: const Color(0xFF15172A),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: color,
        size: 58,
      ),
    );
  }
}

class _NftCard extends StatelessWidget {
  const _NftCard({
    required this.item,
    required this.onTap,
  });

  final _NftItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = item.grade.color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C0D18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(19),
                      ),
                      child: Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _NftDashboardPageState._imageFallback(color),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xE6080914),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(19),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _SmallBadge(
                        label: item.grade.label,
                        color: color,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _SmallBadge(
                        label: item.owned ? 'OWNED' : 'MARKET',
                        color: item.owned
                            ? const Color(0xFFD7FF35)
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          item.id,
                          style: const TextStyle(
                            color: Color(0xFF9EA3B8),
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '희귀도 ${item.rarity}',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFFD7FF35),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_NftDashboardPageState._formatPoints(item.pointPrice)} P',
                          style: const TextStyle(
                            color: Color(0xFFD7FF35),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.open_in_new_rounded,
                          color: Color(0xFF85899E),
                          size: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _NftDashboardPageState.lime, width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          _NftDashboardPageState.logoPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(
            color: Color(0xFF27104F),
            child: Icon(
              Icons.flight_rounded,
              color: Color(0xFFD7FF35),
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x2A000000),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF3A3C55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _NftDashboardPageState.lime, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _NftDashboardPageState.muted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0x338B2CF6)
              : const Color(0xFF13152A),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? _NftDashboardPageState.purple
                : _NftDashboardPageState.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : _NftDashboardPageState.muted,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Color.fromARGB(48, color.red, color.green, color.blue) : _NftDashboardPageState.panel,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? color : _NftDashboardPageState.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : _NftDashboardPageState.muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xD9151622),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _NftDashboardPageState.muted, size: 23),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: _NftDashboardPageState.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _NftDashboardPageState.panel2,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _NftDashboardPageState.border),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _NftDashboardPageState.muted,
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ChainBadge extends StatelessWidget {
  const _ChainBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NftModeDashboardPage extends StatefulWidget {
  const _NftModeDashboardPage({
    required this.krMode,
    required this.items,
    required this.initialPoints,
  });

  final bool krMode;
  final List<_NftItem> items;
  final int initialPoints;

  @override
  State<_NftModeDashboardPage> createState() => _NftModeDashboardPageState();
}

class _NftModeDashboardPageState extends State<_NftModeDashboardPage> {
  late int points;

  @override
  void initState() {
    super.initState();
    points = widget.initialPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03040B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF03040B),
        title: Text(widget.krMode ? '포인트 거래 (KR MODE)' : 'GLOBAL MODE DASHBOARD'),
      ),
      body: widget.krMode ? _buildKrMode() : _buildGlobalMode(),
    );
  }

  Widget _buildKrMode() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF29115A), Color(0xFF101225)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFD7FF35), size: 34),
              const SizedBox(width: 12),
              const Text('보유 포인트', style: TextStyle(color: Colors.white70)),
              const Spacer(),
              Text(
                '$points P',
                style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...widget.items.map((item) => Card(
          color: const Color(0xFF10121F),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                item.imagePath,
                width: 54,
                height: 54,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 54,
                  height: 54,
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            title: Text(item.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text('${item.grade.label} · ${item.pointPrice} P', style: TextStyle(color: item.grade.color)),
            trailing: item.owned
                ? OutlinedButton(
                    onPressed: () {
                      setState(() {
                        points += (item.pointPrice * 0.8).round();
                        item.owned = false;
                        item.owner = 'ORQUBE MARKET';
                      });
                    },
                    child: const Text('판매'),
                  )
                : FilledButton(
                    onPressed: () {
                      if (points < item.pointPrice) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('포인트가 부족합니다.')),
                        );
                        return;
                      }
                      setState(() {
                        points -= item.pointPrice;
                        item.owned = true;
                        item.owner = 'Kim MyoungKeun';
                      });
                    },
                    child: const Text('구매'),
                  ),
          ),
        )),
        const SizedBox(height: 12),
        const Text(
          '현재 포인트 거래는 화면 데모입니다. 실제 운영 전 Firestore 트랜잭션, 서버 검증, 거래기록 및 이용약관 연결이 필요합니다.',
          style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.45),
        ),
      ],
    );
  }

  Widget _buildGlobalMode() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10204B), Color(0xFF1A0E42), Color(0xFF080913)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF8B2CF6)),
          ),
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public_rounded, color: Color(0xFFD7FF35), size: 62),
              SizedBox(height: 12),
              Text(
                'ORQUBE GLOBAL ECOSYSTEM',
                style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _GlobalInfoTile(icon: Icons.account_balance_wallet_outlined, title: 'Kaia Wallet', subtitle: 'Kaia Wallet 연동 예정'),
        const _GlobalInfoTile(icon: Icons.storefront_outlined, title: '외부 NFT 마켓', subtitle: '외부 마켓 연동 예정'),
        const _GlobalInfoTile(icon: Icons.hub_outlined, title: 'Polygon · Solana', subtitle: '멀티체인 확장 예정'),
        const SizedBox(height: 12),
        const Text(
          '현재 GLOBAL MODE는 안내용 대시보드입니다. 실제 온체인 거래와 외부 전송은 실행하지 않습니다.',
          style: TextStyle(color: Colors.white54, height: 1.5),
        ),
      ],
    );
  }
}

class _GlobalInfoTile extends StatelessWidget {
  const _GlobalInfoTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF10121F),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD7FF35)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

enum NftGrade {
  founder,
  mythic,
  legendary,
  epic,
  rare,
  common,
}

extension NftGradeExtension on NftGrade {
  String get label {
    switch (this) {
      case NftGrade.founder:
        return 'FOUNDER';
      case NftGrade.mythic:
        return 'MYTHIC';
      case NftGrade.legendary:
        return 'LEGENDARY';
      case NftGrade.epic:
        return 'EPIC';
      case NftGrade.rare:
        return 'RARE';
      case NftGrade.common:
        return 'COMMON';
    }
  }

  Color get color {
    switch (this) {
      case NftGrade.founder:
        return const Color(0xFFD7FF35);
      case NftGrade.mythic:
        return const Color(0xFFFF477E);
      case NftGrade.legendary:
        return const Color(0xFFFFB02E);
      case NftGrade.epic:
        return const Color(0xFFC56BFF);
      case NftGrade.rare:
        return const Color(0xFF39A9FF);
      case NftGrade.common:
        return const Color(0xFFB5BAC8);
    }
  }
}

class _NftItem {
  _NftItem({
    required this.id,
    required this.name,
    required this.grade,
    required this.rarity,
    required this.owner,
    required this.benefit,
    required this.imagePath,
    required this.pointPrice,
    required this.owned,
  });

  final String id;
  final String name;
  final NftGrade grade;
  final String rarity;
  String owner;
  final String benefit;
  final String imagePath;
  final int pointPrice;
  bool owned;
}
