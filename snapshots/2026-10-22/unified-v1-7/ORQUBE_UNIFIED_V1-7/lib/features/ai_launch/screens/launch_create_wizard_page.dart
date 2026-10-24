import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/launch_project.dart';
import '../models/launch_chain.dart';
import '../services/launch_ai_draft_service.dart';
import '../services/launch_ai_logo_service.dart';
import '../services/launch_policy.dart';
import '../services/launch_economy_policy.dart';
import '../services/launch_repository.dart';
import '../services/token_creation_i18n.dart';
import '../services/token_use_guide_catalog.dart';
import '../widgets/launch_ui.dart';
import '../widgets/geometric_token_logo.dart';
import '../widgets/orqube_ai_assistant.dart';
import 'launch_project_page.dart';
import 'token_use_guide_page.dart';
import '../../../pages/login_page.dart';

class LaunchCreateWizardPage extends StatefulWidget {
  const LaunchCreateWizardPage({
    super.key,
    required this.ownerUid,
    this.initialIdea = '',
  });

  final String ownerUid;
  final String initialIdea;

  @override
  State<LaunchCreateWizardPage> createState() => _LaunchCreateWizardPageState();
}

class _LaunchCreateWizardPageState extends State<LaunchCreateWizardPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _symbol = TextEditingController();
  final _description = TextEditingController();
  final _vision = TextEditingController();
  final _utility = TextEditingController();
  final _totalSupply = TextEditingController();
  final _capSupply = TextEditingController();

  LaunchCategory _category = LaunchCategory.community;
  LaunchChain _chain = LaunchChain.kaia;
  bool _saving = false;
  bool _reviewing = false;
  bool _aiGenerating = false;
  bool _logoGenerating = false;
  bool _burnable = true;
  bool _mintable = false;
  bool _pausable = false;
  Map<String, String> _logoSpec = defaultTokenLogo('ORQ');
  String _tagline = '';
  String _aiSource = '';
  String _selectedLogoUrl = '';
  String _logoMessage = '';
  String _appliedGuideRole = '';
  List<LaunchAiLogoOption> _logoOptions = const [];

  @override
  void initState() {
    super.initState();
    final idea = widget.initialIdea.trim();
    if (idea.isNotEmpty) {
      _description.text = idea;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _generateAiDraft();
      });
    }
  }

  Future<void> _generateAiDraft() async {
    final idea = widget.initialIdea.trim().isNotEmpty
        ? widget.initialIdea.trim()
        : _description.text.trim();
    if (idea.length < 3 || _aiGenerating) return;

    setState(() => _aiGenerating = true);
    try {
      final draft = await LaunchAiDraftService().generate(idea: idea);
      if (!mounted) return;
      setState(() {
        _name.text = draft.name;
        _symbol.text = draft.symbol;
        _logoSpec = defaultTokenLogo(draft.symbol);
        _description.text = draft.description;
        _vision.text = draft.vision;
        _utility.text = draft.utility;
        _tagline = draft.tagline;
        _category = draft.category;
        _aiSource = draft.usedRemoteAi ? 'remote_ai' : 'local_fallback';
        _logoOptions = const [];
        _selectedLogoUrl = '';
        _logoMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            draft.usedRemoteAi
                ? 'AI가 토큰 초안을 생성했습니다. 내용을 확인한 뒤 만들기를 눌러주세요.'
                : '토큰 초안을 자동 생성했습니다. 서버 AI 연결 전에는 ORQUBE 안전 초안 엔진이 사용됩니다.',
          ),
        ),
      );
    } on LaunchAiDraftException catch (e) {
      if (!mounted) return;
      await _showPolicyBlock(e.message);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI 초안 생성 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _aiGenerating = false);
    }
  }

  Future<void> _generateLogoOptions({LaunchAiDraft? draft}) async {
    if (_logoGenerating) return;

    final idea = widget.initialIdea.trim().isNotEmpty
        ? widget.initialIdea.trim()
        : _description.text.trim();
    final name = draft?.name ?? _name.text.trim();
    final symbol = draft?.symbol ?? _symbol.text.trim();
    final tagline = draft?.tagline ?? _tagline.trim();
    final category = (draft?.category ?? _category).name;

    if (idea.length < 3 || name.length < 2 || symbol.length < 2) {
      setState(() => _logoMessage = '토큰 이름과 심볼을 먼저 준비해 주세요.');
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      setState(() => _logoMessage = 'AI 로고는 로그인 후 생성할 수 있습니다. 첫 1개는 무료입니다.');
      return;
    }

    setState(() {
      _logoGenerating = true;
      _logoMessage = 'AI가 토큰 정체성을 바탕으로 로고 1개를 만들고 있습니다.';
    });

    try {
      final logos = await LaunchAiLogoService().generate(
        idea: idea,
        name: name,
        symbol: symbol,
        category: category,
        tagline: tagline,
      );
      if (!mounted) return;
      setState(() {
        _logoOptions = logos;
        _selectedLogoUrl = logos.isEmpty ? '' : logos.first.url;
        _logoMessage = logos.isEmpty
            ? 'AI 로고 후보를 만들지 못했습니다.'
            : 'AI 로고가 생성되었습니다. 첫 1개는 무료이며, 다음 생성부터 1개당 3 ORBS가 사용됩니다.';
      });
    } on LaunchAiLogoException catch (e) {
      if (!mounted) return;
      setState(() => _logoMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _logoMessage = 'AI 로고 생성 실패: $e');
    } finally {
      if (mounted) setState(() => _logoGenerating = false);
    }
  }

  Future<void> _generateLogoWithLogin() async {
    final uid = await _ensureOwnerUid();
    if (!mounted || uid.isEmpty) return;
    await _generateLogoOptions();
  }

  Future<String> _ensureOwnerUid() async {
    var uid = FirebaseAuth.instance.currentUser?.uid ?? widget.ownerUid.trim();
    if (uid.isNotEmpty) return uid;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onLoginSuccess: () async {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );

    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  int? _parseWholeTokenAmount(String raw) {
    final normalized = raw
        .replaceAll(',', '')
        .replaceAll('，', '')
        .replaceAll(' ', '')
        .trim();
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }

  Future<void> _save() async {
    if (_saving || _reviewing || _aiGenerating || !_formKey.currentState!.validate()) return;

    final totalSupply = _parseWholeTokenAmount(_totalSupply.text);
    if (totalSupply == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('총 발행량을 숫자로 입력해주세요. 예: 310000000'),
        ),
      );
      return;
    }

    int? capSupply;
    if (_mintable) {
      capSupply = _parseWholeTokenAmount(_capSupply.text);
      if (capSupply == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('추가 발행을 선택한 경우 최대 발행량(Cap)을 숫자로 입력해주세요.'),
          ),
        );
        return;
      }
      if (capSupply < totalSupply) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('최대 발행량(Cap)은 최초 발행량보다 작을 수 없습니다.'),
          ),
        );
        return;
      }
    }

    _reviewing = true;
    bool? reviewed;
    try {
      reviewed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('토큰 초안 검토'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        GeometricTokenLogo(symbol: _symbol.text, spec: _logoSpec),
        const SizedBox(height: 12),
        Text('${_name.text} (${_symbol.text.toUpperCase()})'),
        Text('발행량: $totalSupply · ${_chain.label}'),
        const SizedBox(height: 8),
        Text(_description.text),
        const SizedBox(height: 8),
        Text('Vision: ${_vision.text}'),
        Text('Utility: ${_utility.text}'),
        const SizedBox(height: 12),
        const Text('지금은 초안을 저장합니다. 이후 프로젝트 화면에서 테스트넷 배포와 전송 시험을 진행하세요. 결제·소스검증은 별도 확인 후 진행됩니다.'),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('돌아가서 수정')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('초안 적용·저장')),
      ],
    ));
    } finally { _reviewing = false; }
    if (reviewed != true || !mounted) return;

    final ownerUid = await _ensureOwnerUid();
    if (!mounted) return;
    if (ownerUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('토큰 초안 저장에는 로그인이 필요합니다.')),
      );
      return;
    }

    final policy = LaunchPolicy.evaluateTokenRequest(
      category: _category,
      name: _name.text,
      symbol: _symbol.text,
      text: _description.text,
    );

    if (!policy.allowed) {
      await _showPolicyBlock(policy.message);
      return;
    }

    setState(() => _saving = true);
    try {
      final id = await LaunchRepository().createDraft(
        ownerUid: ownerUid,
        name: _name.text,
        symbol: _symbol.text,
        description: _description.text,
        category: _category.name,
        assetMode: AssetMode.publicToken.name,
        imageUrl: _selectedLogoUrl.isEmpty ? null : _selectedLogoUrl,
        logoSpec: _logoSpec,
        tagline: _tagline,
        vision: _vision.text,
        utility: _utility.text,
        totalSupply: totalSupply,
        burnable: _burnable,
        mintable: _mintable,
        pausable: _pausable,
        capSupply: capSupply,
        chain: _chain.key,
        aiIdea: widget.initialIdea.trim(),
        aiGenerationSource: _aiSource,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LaunchProjectPage(
            projectId: id,
            ownerUid: ownerUid,
          ),
        ),
      );
    } on FormatException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장 실패: 발행량 또는 최대 발행량을 정수로 입력해주세요.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openTokenUseGuide() async {
    final item = await Navigator.of(context).push<TokenUseGuideItem>(
      MaterialPageRoute(
        builder: (_) => const TokenUseGuidePage(selectionMode: true),
      ),
    );
    if (!mounted || item == null) return;

    final guideText = <String>[
      '[TOKEN USE GUIDE · ${item.role}]',
      "활용: ${item.useCases.join(' / ')}",
      "Tokenomics: ${item.tokenomics.join(' / ')}",
    ].join('\n');

    setState(() {
      _appliedGuideRole = item.id == 'CUSTOM'
          ? '${item.role} (직접 입력)'
          : item.role;
      _mintable = item.featureSummary.mint;
      _burnable = item.featureSummary.burn;
      _pausable = item.featureSummary.pause;

      // Cap 수량은 정책상 임의 자동입력하지 않고 사용자가 직접 정합니다.
      _capSupply.clear();
      _utility.text = guideText.length <= 500
          ? guideText
          : guideText.substring(0, 500);

      // 기본 120개 항목의 기존 동작은 보존하고, 직접 입력한 직업만
      // Token Story / Vision을 1회 맞춤 생성합니다.
      if (item.id == 'CUSTOM') {
        _description.text = '${item.role} 토큰은 구성원·고객·참여자가 단순한 이용자를 넘어 활동과 기여에 참여하고, 그 가치를 기록하고 보상하기 위한 참여형 토큰입니다.';
        _vision.text = '${item.role}와 이용자·커뮤니티가 지속적으로 연결되고, 참여 가치가 투명한 디지털 리워드로 이어지는 생태계를 만듭니다.';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.role} 맞춤 설계를 CREATE 화면에 미리 적용했습니다. 아직 토큰은 생성되지 않았습니다. 내용을 확인한 뒤 “이대로 토큰 초안 만들기”를 눌러주세요.',
        ),
      ),
    );
  }

  Future<void> _showPolicyBlock(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 토큰은 생성할 수 없습니다'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _symbol.dispose();
    _description.dispose();
    _vision.dispose();
    _utility.dispose();
    _totalSupply.dispose();
    _capSupply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LaunchBackground(
      floatingActionButton: const OrqubeAiAssistantButton(
        screen: 'TOKEN CREATE',
      ),
      appBar: launchAppBar('새 토큰 만들기'),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 44),
          children: [
            LaunchGlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LaunchStatusPill(
                    label: 'TOKEN FIRST · KAIA',
                    icon: Icons.token_outlined,
                    active: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '내가 만들 토큰의\n정체성을 먼저 정의합니다.',
                    style: TextStyle(
                      color: LaunchPalette.text,
                      fontSize: 27,
                      height: 1.18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    '현재는 토큰 초안과 프로필을 만들고, 실제 지갑·Kaia 배포는 다음 단계에서 최종 확인 후 연결합니다.',
                    style: TextStyle(
                      color: LaunchPalette.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LaunchGlassCard(
              onTap: _openTokenUseGuide,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: LaunchPalette.purple.withOpacity(.18),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: LaunchPalette.cyan.withOpacity(.28),
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      color: LaunchPalette.cyan,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOKEN USE GUIDE · 120',
                          style: TextStyle(
                            color: LaunchPalette.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          '120개 직업·업종의 활용방법, Tokenomics, Fixed/Mint/Cap/Burn/Pause, NFT 예시를 보고 원하는 설계를 CREATE 초안에 적용합니다.',
                          style: TextStyle(
                            color: LaunchPalette.muted,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _appliedGuideRole.isEmpty
                              ? '직접 선택 → 이 설계로 적용 → CREATE에서 수정 가능'
                              : '적용됨 · $_appliedGuideRole · 눌러서 다른 설계 선택',
                          style: const TextStyle(
                            color: LaunchPalette.cyan,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: LaunchPalette.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (widget.initialIdea.trim().isNotEmpty) ...[
              LaunchGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: LaunchPalette.cyan,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'QUICK IDEA · AI DRAFT',
                                style: TextStyle(
                                  color: LaunchPalette.text,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.initialIdea.trim(),
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _aiGenerating ? null : _generateAiDraft,
                        icon: _aiGenerating
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh_rounded),
                        label: Text(
                          _aiGenerating ? 'AI가 토큰을 설계하는 중...' : 'AI 초안 다시 만들기',
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _aiSource == 'remote_ai'
                          ? '서버 AI 초안 · 이름, 심볼, 분야, 설명, Vision, Utility를 자동 제안했습니다.'
                          : '서버 AI가 아직 연결되지 않은 경우 ORQUBE 안전 초안 엔진이 자동으로 이어갑니다.',
                      style: const TextStyle(
                        color: LaunchPalette.muted,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            LaunchGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LaunchSectionTitle(
                    title: 'TOKEN IDENTITY',
                    subtitle: '이름 · 심볼 · 목적. PUBLIC TOKEN을 기본으로 준비합니다.',
                  ),
                  DropdownButtonFormField<LaunchCategory>(
                    value: _category,
                    dropdownColor: const Color(0xFF121326),
                    iconEnabledColor: LaunchPalette.cyan,
                    style: const TextStyle(
                      color: LaunchPalette.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      labelText: '토큰 분야',
                      labelStyle: TextStyle(color: Color(0xFFD7D8E8)),
                      floatingLabelStyle: TextStyle(color: LaunchPalette.cyan),
                      hintStyle: TextStyle(color: Color(0xFF8E91A8)),
                    ),
                    items: [
                      for (final category in LaunchCategory.values)
                        DropdownMenuItem<LaunchCategory>(
                          value: category,
                          enabled: !LaunchPolicy.isRestrictedCategory(category),
                          child: Text(
                            LaunchPolicy.categoryLabel(category),
                            style: TextStyle(
                              color: LaunchPolicy.isRestrictedCategory(category)
                                  ? LaunchPalette.muted
                                  : LaunchPalette.text,
                              fontWeight: LaunchPolicy.isRestrictedCategory(category)
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null ||
                          LaunchPolicy.isRestrictedCategory(value)) {
                        return;
                      }
                      setState(() => _category = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _name,
                    cursorColor: LaunchPalette.cyan,
                    style: const TextStyle(
                      color: LaunchPalette.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Token Name',
                      hintText: '예: Qubic Safety',
                      labelStyle: TextStyle(color: Color(0xFFD7D8E8)),
                      floatingLabelStyle: TextStyle(color: LaunchPalette.cyan),
                      hintStyle: TextStyle(color: Color(0xFF7F8298)),
                    ),
                    validator: (v) => v == null || v.trim().length < 2
                        ? '토큰 이름을 입력하세요.'
                        : null,
                  ),
                  TextFormField(
                    controller: _symbol,
                    textCapitalization: TextCapitalization.characters,
                    cursorColor: LaunchPalette.cyan,
                    style: const TextStyle(
                      color: LaunchPalette.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Symbol',
                      prefixText: r'$',
                      hintText: 'QSAFE',
                      labelStyle: TextStyle(color: Color(0xFFD7D8E8)),
                      floatingLabelStyle: TextStyle(color: LaunchPalette.cyan),
                      prefixStyle: TextStyle(
                        color: LaunchPalette.cyan,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                      hintStyle: TextStyle(color: Color(0xFF7F8298)),
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.length < 2 || value.length > 10) {
                        return '심볼은 2~10자로 입력하세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<LaunchChain>(
                    value: _chain,
                    dropdownColor: const Color(0xFF171A28),
                    decoration: const InputDecoration(
                      labelText: 'Blockchain · 발행 체인',
                      helperText: 'KAIA / Polygon은 EVM, Solana는 별도 배포 어댑터를 사용합니다.',
                      labelStyle: TextStyle(color: Color(0xFFD7D8E8)),
                      floatingLabelStyle: TextStyle(color: LaunchPalette.cyan),
                    ),
                    style: const TextStyle(color: LaunchPalette.text, fontWeight: FontWeight.w800),
                    items: LaunchChain.values.map((chain) => DropdownMenuItem(
                      value: chain,
                      child: Text('${chain.label} · ${chain.testnetLabel}'),
                    )).toList(),
                    onChanged: (value) => setState(() => _chain = value ?? LaunchChain.kaia),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _totalSupply,
                    keyboardType: TextInputType.number,
                    cursorColor: LaunchPalette.cyan,
                    style: const TextStyle(
                      color: LaunchPalette.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      labelText: TokenCreationI18n.t('supplyLabel'),
                      hintText: TokenCreationI18n.t('supplyHint'),
                      helperText: TokenCreationI18n.t('supplyHelper'),
                      helperMaxLines: 2,
                      labelStyle: const TextStyle(color: Color(0xFFD7D8E8)),
                      floatingLabelStyle: const TextStyle(color: LaunchPalette.cyan),
                      hintStyle: const TextStyle(color: Color(0xFF7F8298)),
                      helperStyle: const TextStyle(color: Color(0xFF8E91A8)),
                    ),
                    validator: (v) {
                      final value = _parseWholeTokenAmount(v ?? '');
                      if (value == null) return TokenCreationI18n.t('supplyRequired');
                      if (value < LaunchEconomyPolicy.minTokenSupply ||
                          value > LaunchEconomyPolicy.maxTokenSupply) {
                        return TokenCreationI18n.t('supplyRange');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0E19),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TokenCreationI18n.t('tokenFeaturesTitle'),
                          style: const TextStyle(
                            color: LaunchPalette.text,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          TokenCreationI18n.t('tokenFeaturesHelp'),
                          style: const TextStyle(
                            color: LaunchPalette.muted,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          TokenCreationI18n.t('issuanceMode'),
                          style: const TextStyle(
                            color: LaunchPalette.cyan,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        RadioListTile<bool>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: false,
                          groupValue: _mintable,
                          activeColor: LaunchPalette.cyan,
                          title: Text(
                            TokenCreationI18n.t('fixedSupply'),
                            style: const TextStyle(
                              color: LaunchPalette.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            TokenCreationI18n.t('fixedSupplyHelp'),
                            style: const TextStyle(
                              color: LaunchPalette.muted,
                              fontSize: 12,
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => _mintable = value ?? false),
                        ),
                        RadioListTile<bool>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: true,
                          groupValue: _mintable,
                          activeColor: LaunchPalette.cyan,
                          title: Text(
                            TokenCreationI18n.t('mintable'),
                            style: const TextStyle(
                              color: LaunchPalette.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            TokenCreationI18n.t('mintableHelp'),
                            style: const TextStyle(
                              color: LaunchPalette.muted,
                              fontSize: 12,
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => _mintable = value ?? false),
                        ),
                        if (_mintable) ...[
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _capSupply,
                            keyboardType: TextInputType.number,
                            cursorColor: LaunchPalette.cyan,
                            style: const TextStyle(
                              color: LaunchPalette.text,
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: InputDecoration(
                              labelText: TokenCreationI18n.t('capSupply'),
                              hintText: TokenCreationI18n.t('supplyHint'),
                              labelStyle: const TextStyle(
                                color: Color(0xFFD7D8E8),
                              ),
                              floatingLabelStyle: const TextStyle(
                                color: LaunchPalette.cyan,
                              ),
                            ),
                            validator: (v) {
                              if (!_mintable) return null;
                              final cap = _parseWholeTokenAmount(v ?? '');
                              if (cap == null) {
                                return TokenCreationI18n.t('capRequired');
                              }
                              if (cap < LaunchEconomyPolicy.minTokenSupply ||
                                  cap > LaunchEconomyPolicy.maxTokenSupply) {
                                return TokenCreationI18n.t('supplyRange');
                              }
                              final initial = _parseWholeTokenAmount(_totalSupply.text);
                              if (initial != null && cap < initial) {
                                return TokenCreationI18n.t('capTooSmall');
                              }
                              return null;
                            },
                          ),
                        ],
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: LaunchPalette.cyan,
                          value: _burnable,
                          title: Text(
                            TokenCreationI18n.t('burnable'),
                            style: const TextStyle(
                              color: LaunchPalette.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            TokenCreationI18n.t('burnableHelp'),
                            style: const TextStyle(
                              color: LaunchPalette.muted,
                              fontSize: 12,
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => _burnable = value),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: LaunchPalette.cyan,
                          value: _pausable,
                          title: Text(
                            TokenCreationI18n.t('pausable'),
                            style: const TextStyle(
                              color: LaunchPalette.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            TokenCreationI18n.t('pausableHelp'),
                            style: const TextStyle(
                              color: LaunchPalette.muted,
                              fontSize: 12,
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => _pausable = value),
                        ),
                        if (_mintable || _pausable)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              TokenCreationI18n.t('adminAuto'),
                              style: const TextStyle(
                                color: LaunchPalette.cyan,
                                fontSize: 11.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        if (!_chain.isEvm)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              TokenCreationI18n.t('evmFeatureNote'),
                              style: const TextStyle(
                                color: Color(0xFFFFC857),
                                fontSize: 11.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _description,
                    maxLines: 4,
                    maxLength: 500,
                    cursorColor: LaunchPalette.cyan,
                    style: const TextStyle(
                      color: LaunchPalette.text,
                      fontSize: 15.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      labelText: '이 토큰은 어떤 가치를 담나요?',
                      hintText: '누구를 위한 토큰인지, 어떤 활동과 가치를 연결할지 적어주세요.',
                      labelStyle: TextStyle(color: Color(0xFFD7D8E8)),
                      floatingLabelStyle: TextStyle(color: LaunchPalette.cyan),
                      hintStyle: TextStyle(color: Color(0xFF7F8298)),
                      counterStyle: TextStyle(color: Color(0xFF8E91A8)),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? '토큰의 목적을 입력하세요.'
                        : null,
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
                    title: 'AI TOKEN VALUE',
                    subtitle: 'AI가 제안한 Vision과 Utility입니다. 사용자가 직접 수정할 수 있습니다.',
                  ),
                  TextFormField(
                    controller: _vision,
                    maxLines: 3,
                    maxLength: 500,
                    cursorColor: LaunchPalette.cyan,
                    style: const TextStyle(
                      color: LaunchPalette.text,
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Vision',
                      hintText: '이 토큰이 만들고 싶은 미래를 적어주세요.',
                      labelStyle: TextStyle(color: Color(0xFFD7D8E8)),
                      floatingLabelStyle: TextStyle(color: LaunchPalette.cyan),
                      hintStyle: TextStyle(color: Color(0xFF7F8298)),
                      counterStyle: TextStyle(color: Color(0xFF8E91A8)),
                    ),
                  ),
                  TextFormField(
                    controller: _utility,
                    minLines: 3,
                    maxLines: 8,
                    maxLength: 500,
                    cursorColor: LaunchPalette.cyan,
                    style: const TextStyle(
                      color: LaunchPalette.text,
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Utility',
                      hintText: '멤버십, 참여, 이벤트 등 실제 쓰임을 적어주세요.',
                      labelStyle: TextStyle(color: Color(0xFFD7D8E8)),
                      floatingLabelStyle: TextStyle(color: LaunchPalette.cyan),
                      hintStyle: TextStyle(color: Color(0xFF7F8298)),
                      counterStyle: TextStyle(color: Color(0xFF8E91A8)),
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
                    title: 'BASIC TOKEN LOGO',
                    subtitle: '기본 도형 로고가 자동으로 준비됩니다. 모양과 색상을 수정할 수 있습니다.',
                  ),
                  GeometricTokenLogo(symbol: _symbol.text, spec: _logoSpec, size: 84),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final item in const {'circle': '원', 'hexagon': '육각형', 'diamond': '마름모'}.entries)
                      ChoiceChip(label: Text(item.value), selected: _logoSpec['shape'] == item.key,
                        onSelected: (_) => setState(() => _logoSpec = {..._logoSpec, 'shape': item.key})),
                  ]),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final item in const {'green': '녹색', 'blue': '파랑', 'purple': '보라', 'orange': '주황'}.entries)
                      ChoiceChip(label: Text(item.value), selected: _logoSpec['palette'] == item.key,
                        onSelected: (_) => setState(() => _logoSpec = {..._logoSpec, 'palette': item.key})),
                  ]),
                  const Text('로고 생성 비용 없음 · 발행량은 직접 입력 · 저장 후에도 초안 수정 가능',
                    style: TextStyle(color: LaunchPalette.muted)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const LaunchGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LaunchSectionTitle(
                    title: 'AI MARKETING',
                    subtitle: '토큰 저장 후 Human Approval 마케팅으로 바로 이어집니다.',
                  ),
                  Text(
                    'AI가 TOKEN_FIT_SCORE와 추천 국가·언어·플랫폼, 토큰 활용안과 홍보문을 만들고 승인 대기함에 보냅니다. 외부 자동게시·유료광고는 OFF입니다.',
                    style: TextStyle(color: LaunchPalette.muted, height: 1.5),
                  ),
                  SizedBox(height: 10),
                  LaunchStatusPill(
                    label: '토큰 생성 → AI Marketing 시작 → 승인 대기함',
                    icon: Icons.fact_check_outlined,
                    active: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            LaunchGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  LaunchSectionTitle(
                    title: 'ORQUBE LAUNCH POLICY',
                    subtitle: '사용자가 가입부터 토큰 Launch까지 비용과 보상을 한눈에 확인합니다.',
                  ),
                  _ModeRow(icon: Icons.person_add_alt_1_outlined, title: 'SIGN UP · +1,000 P', body: '신규 가입 시 서비스 포인트 1,000P 지급'),
                  SizedBox(height: 10),
                  _ModeRow(icon: Icons.account_balance_wallet_outlined, title: 'KAIA WALLET · +10 ORBS', body: '지갑 연결 완료 시 Starter ORBS 10개를 1회 지급'),
                  SizedBox(height: 10),
                  _ModeRow(icon: Icons.bolt_outlined, title: 'MINING · 0.2 ORBS/H', body: '24시간 세션 기준 최대 4.8 ORBS'),
                  SizedBox(height: 10),
                  _ModeRow(icon: Icons.image_outlined, title: 'LOGO · 직접 등록', body: 'ChatGPT 등 AI 도구로 제작한 로고를 사용자가 직접 등록'),
                  SizedBox(height: 10),
                  _ModeRow(icon: Icons.token_outlined, title: 'PUBLIC TOKEN · 50 ORBS', body: 'PUBLIC TOKEN 생성 비용'),
                  SizedBox(height: 10),
                  _ModeRow(icon: Icons.rocket_launch_outlined, title: 'MULTICHAIN DEPLOY', body: 'KAIA Kairos · Polygon Amoy · Solana Devnet 단계별 배포'),
                  SizedBox(height: 10),
                  _ModeRow(icon: Icons.campaign_outlined, title: 'AI MARKETING · 100 ORBS', body: 'TOKEN_FIT_SCORE + 홍보안 + Human Approval Queue'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            LaunchGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  LaunchSectionTitle(
                    title: 'DEPLOYMENT MODE',
                    subtitle: '프로필이 아니라 실제 토큰 Launch를 중심으로 진행합니다.',
                  ),
                  _ModeRow(
                    icon: Icons.public,
                    title: 'PUBLIC TOKEN',
                    body: 'KAIA · Polygon · Solana 공개 배포 후보 · 실제 배포 전 사용자 최종 확인',
                  ),
                  SizedBox(height: 12),
                  _ModeRow(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'WALLET',
                    body: '새 지갑 만들기 / 기존 지갑 연결은 다음 단계에서 연결',
                  ),
                  SizedBox(height: 12),
                  _ModeRow(
                    icon: Icons.verified_user_outlined,
                    title: 'POLICY GATE',
                    body: '정치·선거, 수익보장형 투자, 도박·베팅, 불법·규제품목, 사칭 토큰 차단',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _RestrictedPanel(),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: (_saving || _aiGenerating || _logoGenerating) ? null : _save,
              icon: const Icon(Icons.token_outlined),
              label: Text(_aiGenerating ? 'AI 초안 생성 중...' : (_logoGenerating ? 'AI 로고 생성 중...' : (_saving ? '생성 중...' : '이대로 토큰 초안 만들기'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoOptionTile extends StatelessWidget {
  const _LogoOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final LaunchAiLogoOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 126,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? LaunchPalette.purple.withOpacity(.16)
              : Colors.white.withOpacity(.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? LaunchPalette.cyan.withOpacity(.85)
                : Colors.white.withOpacity(.10),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 102,
                  height: 102,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.04),
                  ),
                  child: Image.network(
                    option.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: LaunchPalette.muted),
                    ),
                  ),
                ),
                if (selected)
                  const Positioned(
                    right: 3,
                    top: 3,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: LaunchPalette.cyan,
                      child: Icon(Icons.check, color: Colors.black, size: 16),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              option.style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? LaunchPalette.cyan : LaunchPalette.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: LaunchPalette.cyan, size: 21),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: LaunchPalette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
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
    );
  }
}

class _RestrictedPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LaunchGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LaunchSectionTitle(
            title: '발행 제한 영역',
            subtitle: '선택 단계에서 비활성화하고, 저장·공개·실제 배포 직전에 다시 검사하는 구조입니다.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in LaunchPolicy.visibleRestrictedCategories)
                LaunchStatusPill(
                  label: LaunchPolicy.categoryLabel(category),
                  icon: Icons.block,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
