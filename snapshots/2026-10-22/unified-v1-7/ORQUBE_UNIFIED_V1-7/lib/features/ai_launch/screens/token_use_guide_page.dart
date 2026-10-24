import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/token_use_guide_catalog.dart';
import '../widgets/launch_ui.dart';

class TokenUseGuidePage extends StatefulWidget {
  const TokenUseGuidePage({super.key, this.selectionMode = false});

  final bool selectionMode;

  @override
  State<TokenUseGuidePage> createState() => _TokenUseGuidePageState();
}

class _TokenUseGuidePageState extends State<TokenUseGuidePage> {
  final _search = TextEditingController();
  String _category = '전체';
  bool _customRoleUsed = false;
  TokenUseGuideItem? _customPreview;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<TokenUseGuideItem> get _filtered {
    final keyword = _search.text.trim().toLowerCase();
    return TokenUseGuideCatalog.items.where((item) {
      final categoryMatches = _category == '전체' || item.category == _category;
      final keywordMatches = keyword.isEmpty || item.searchableText.contains(keyword);
      return categoryMatches && keywordMatches;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return LaunchBackground(
      appBar: launchAppBar('TOKEN USE GUIDE · 120'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 44),
        children: [
          LaunchGlassCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LaunchStatusPill(
                  label: '120 OCCUPATIONS · USE CASE LIBRARY',
                  icon: Icons.menu_book_outlined,
                  active: true,
                ),
                const SizedBox(height: 15),
                const Text(
                  '직업·업종별 토큰 활용 설계 예시',
                  style: TextStyle(
                    color: LaunchPalette.text,
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '기본 120개 직업·업종을 검색하고 활용방법 · Tokenomics · Fixed/Mint/Cap/Burn/Pause · NFT 연계 예시를 확인합니다. 목록에 없는 정당한 직업·업종도 직접 입력해 맞춤 설계를 만들 수 있으며, ORQUBE 직업 생태계는 120개를 상한으로 두지 않습니다.',
                  style: TextStyle(
                    color: LaunchPalette.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: LaunchPalette.text),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: LaunchPalette.cyan),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close, color: LaunchPalette.muted),
                          ),
                    labelText: '직업·업종 검색',
                    hintText: '예: 자영업자, 변호사, 작가, 카페, 노동조합',
                    labelStyle: const TextStyle(color: LaunchPalette.muted),
                    floatingLabelStyle: const TextStyle(color: LaunchPalette.cyan),
                    hintStyle: const TextStyle(color: Color(0xFF7F8298)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LaunchGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LaunchSectionTitle(
                  title: 'CATEGORY',
                  subtitle: '분야를 선택하면 해당 직업만 빠르게 볼 수 있습니다.',
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CategoryChip(
                      label: '전체',
                      selected: _category == '전체',
                      onTap: () => setState(() => _category = '전체'),
                    ),
                    for (final category in TokenUseGuideCatalog.categories)
                      _CategoryChip(
                        label: category,
                        selected: _category == category,
                        onTap: () => setState(() => _category = category),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '표시 ${items.length} / ${TokenUseGuideCatalog.items.length}',
                  style: const TextStyle(
                    color: LaunchPalette.cyan,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            LaunchGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '입력하신 직업·업종은 ORQUBE 기본 120개 직업군에 없습니다.',
                    style: TextStyle(
                      color: LaunchPalette.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '내 직업이 목록에 없어도 괜찮습니다. 정당한 직업·업종이면 직접 입력해 맞춤 토큰 설계를 진행할 수 있습니다. 새롭게 입력된 직업은 즉시 공식 목록에 등재되지 않으며, 이용 현황과 검토를 거쳐 향후 ORQUBE 공통 직업 생태계로 확장될 수 있습니다.',
                    style: TextStyle(color: LaunchPalette.muted, height: 1.5),
                  ),
                  if (widget.selectionMode) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _customRoleUsed || _search.text.trim().isEmpty
                            ? null
                            : () {
                                final role = _search.text.trim();
                                if (TokenUseGuideCatalog.isRestrictedCustomRole(role)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(TokenUseGuideCatalog.restrictedCustomRoleMessage),
                                    ),
                                  );
                                  return;
                                }
                                try {
                                  final custom = TokenUseGuideCatalog.buildCustom(role);
                                  setState(() {
                                    _customRoleUsed = true;
                                    _customPreview = custom;
                                  });
                                } on ArgumentError catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.message?.toString() ?? e.toString())),
                                  );
                                }
                              },
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: Text(
                          _customRoleUsed
                              ? '맞춤 설계 미리보기 생성 완료'
                              : '“${_search.text.trim()}”으로 맞춤 설계',
                        ),
                      ),
                    ),
                    if (_customPreview != null) ...[
                      const SizedBox(height: 14),
                      const Text(
                        '맞춤 설계 미리보기 · 아직 CREATE에 적용되지 않았습니다.',
                        style: TextStyle(
                          color: LaunchPalette.cyan,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _GuideCard(item: _customPreview!, selectionMode: true),
                    ],
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('직업군 선택 없이 계속'),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            for (final item in items) ...[
              _GuideCard(item: item, selectionMode: widget.selectionMode),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 4),
          const LaunchGlassCard(
            child: Text(
              '120+ OPEN OCCUPATION · ORQUBE의 기본 목록은 120개이지만 상한은 아닙니다. 목록에 없는 정당한 직업·업종도 직접 입력할 수 있습니다. 신규 입력 직업은 즉시 공식 등재되지 않으며 이용 현황과 검토를 거쳐 공통 직업군 후보로 확장될 수 있습니다.\n\nGUIDE NOTE · Tokenomics와 기능 조합은 설계 예시입니다. 사용자가 ‘이 설계로 적용’을 눌러도 최초 발행량과 Cap 수량은 자동 입력하지 않으며 직접 확인·입력합니다. 모든 항목은 적용 후 CREATE 화면에서 다시 수정할 수 있습니다.',
              style: TextStyle(
                color: LaunchPalette.muted,
                height: 1.5,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: LaunchPalette.purple.withOpacity(.30),
      backgroundColor: Colors.white.withOpacity(.05),
      side: BorderSide(
        color: selected ? LaunchPalette.cyan.withOpacity(.55) : Colors.white12,
      ),
      labelStyle: TextStyle(
        color: selected ? LaunchPalette.text : LaunchPalette.muted,
        fontWeight: FontWeight.w700,
      ),
      checkmarkColor: LaunchPalette.cyan,
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.item, required this.selectionMode});

  final TokenUseGuideItem item;
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    return LaunchGlassCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: LaunchPalette.cyan.withOpacity(.05),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          iconColor: LaunchPalette.cyan,
          collapsedIconColor: LaunchPalette.muted,
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.restricted
                      ? const Color(0x33FFC857)
                      : LaunchPalette.purple.withOpacity(.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.id,
                  style: TextStyle(
                    color: item.restricted
                        ? const Color(0xFFFFC857)
                        : LaunchPalette.cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.role,
                      style: const TextStyle(
                        color: LaunchPalette.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.category,
                      style: const TextStyle(
                        color: LaunchPalette.muted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _FeatureMiniChip(
                  label: item.featureSummary.fixed ? 'Fixed ✓' : 'Fixed —',
                  active: item.featureSummary.fixed,
                ),
                _FeatureMiniChip(
                  label: item.featureSummary.mint ? 'Mint ✓' : 'Mint —',
                  active: item.featureSummary.mint,
                ),
                _FeatureMiniChip(
                  label: item.featureSummary.cap ? 'Cap ✓' : 'Cap —',
                  active: item.featureSummary.cap,
                ),
                _FeatureMiniChip(
                  label: item.featureSummary.burn ? 'Burn ✓' : 'Burn —',
                  active: item.featureSummary.burn,
                ),
                _FeatureMiniChip(
                  label: item.featureSummary.pause ? 'Pause ✓' : 'Pause —',
                  active: item.featureSummary.pause,
                ),
              ],
            ),
          ),
          children: [
            if (item.policyNote.isNotEmpty) ...[
              _InfoBox(
                icon: Icons.policy_outlined,
                title: 'POLICY NOTE',
                body: item.policyNote,
                warning: true,
              ),
              const SizedBox(height: 12),
            ],
            _DetailSection(
              icon: Icons.token_outlined,
              title: 'TOKEN 활용방법',
              children: [for (final line in item.useCases) _Bullet(line)],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              icon: Icons.pie_chart_outline,
              title: 'TOKENOMICS 예시',
              children: [for (final line in item.tokenomics) _Bullet(line)],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              icon: Icons.tune,
              title: '기능 설계 예시 · Fixed / Mint / Cap / Burn / Pause',
              children: [
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _FeatureLargeChip(name: 'Fixed', enabled: item.featureSummary.fixed),
                    _FeatureLargeChip(name: 'Mint', enabled: item.featureSummary.mint),
                    _FeatureLargeChip(name: 'Cap', enabled: item.featureSummary.cap),
                    _FeatureLargeChip(name: 'Burn', enabled: item.featureSummary.burn),
                    _FeatureLargeChip(name: 'Pause', enabled: item.featureSummary.pause),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  item.featureSummary.reason,
                  style: const TextStyle(
                    color: LaunchPalette.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              icon: Icons.image_outlined,
              title: 'NFT 연계 가능성',
              children: [
                Text(
                  item.nftLink,
                  style: const TextStyle(
                    color: LaunchPalette.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            if (selectionMode) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: item.restricted
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.info_outline),
                        label: const Text('참고 전용 · CREATE 적용 불가'),
                      )
                    : FilledButton.icon(
                        onPressed: () async {
                          if (item.id == 'CUSTOM') {
                            final prefs = await SharedPreferences.getInstance();
                            final key = 'orqube_custom_occupation_${item.role.trim().toLowerCase()}';
                            await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
                          }
                          if (context.mounted) Navigator.of(context).pop(item);
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('이 설계로 내 토큰에 적용'),
                      ),
              ),
              const SizedBox(height: 5),
              Text(
                item.restricted
                    ? '정치·선거 관련 항목은 현재 ORQUBE 셀프서비스 CREATE에 자동 적용하지 않습니다.'
                    : '기능 조합과 활용·Tokenomics 예시가 CREATE 초안에 반영됩니다. 발행량과 Cap 수량은 사용자가 직접 입력합니다.',
                style: const TextStyle(
                  color: LaunchPalette.muted,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeatureMiniChip extends StatelessWidget {
  const _FeatureMiniChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? LaunchPalette.cyan.withOpacity(.10)
            : Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? LaunchPalette.cyan.withOpacity(.35) : Colors.white10,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? LaunchPalette.cyan : LaunchPalette.muted,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FeatureLargeChip extends StatelessWidget {
  const _FeatureLargeChip({required this.name, required this.enabled});

  final String name;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: enabled
            ? LaunchPalette.purple.withOpacity(.18)
            : Colors.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? LaunchPalette.cyan.withOpacity(.45) : Colors.white10,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.remove_circle_outline,
            size: 15,
            color: enabled ? LaunchPalette.cyan : LaunchPalette.muted,
          ),
          const SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              color: enabled ? LaunchPalette.text : LaunchPalette.muted,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: LaunchPalette.cyan, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: LaunchPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 5, color: LaunchPalette.cyan),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: LaunchPalette.muted,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.body,
    this.warning = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final accent = warning ? const Color(0xFFFFC857) : LaunchPalette.cyan;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: LaunchPalette.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
