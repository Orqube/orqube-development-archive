import '../../../services/admin_only.dart';
import '../../../services/admin_access.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/launch_chain.dart';
import '../services/launch_deep_link.dart';
import '../services/launch_policy.dart';
import '../services/launch_economy_policy.dart';
import '../services/launch_repository.dart';
import '../services/launch_status_label.dart';
import '../services/launch_wallet_repository.dart';
import '../services/browser_wallet_bridge.dart';
import '../services/token_marketing_service.dart';
import '../services/token_deployment_service.dart';
import '../services/token_drop_service.dart';
import '../services/token_liquidity_service.dart';
import '../services/token_swap_service.dart';
import '../services/token_use_progress.dart';
import '../services/token_use_service.dart';
import '../services/token_lifecycle_state.dart';
import '../services/token_creation_i18n.dart';
import '../widgets/launch_ui.dart';
import '../widgets/geometric_token_logo.dart';
import '../widgets/auto_verify_panel.dart';
import '../widgets/token_creation_progress_bar.dart';
import '../widgets/orqube_ai_assistant.dart';
import '../widgets/wallet_address_compare_panel.dart';
import 'launch_profile_edit_page.dart';
import 'launch_wallet_page.dart';
import 'ai_marketing_approval_page.dart';
import 'qr_reward_setup_page.dart';
import 'developer_center_page.dart';

class LaunchProjectPage extends StatefulWidget {
  const LaunchProjectPage({
    super.key,
    required this.projectId,
    this.ownerUid = '',
  });

  final String projectId;
  final String ownerUid;

  @override
  State<LaunchProjectPage> createState() => _LaunchProjectPageState();
}

class _LaunchProjectPageState extends State<LaunchProjectPage> {
  String get projectId => widget.projectId;
  String get ownerUid => widget.ownerUid;
  String get inviteUrl => LaunchDeepLink.inviteUrl(projectId);

  final _tokenUseKey = GlobalKey();
  final _deploymentKey = GlobalKey();
  final _verifyKey = GlobalKey();
  final _marketingKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final stream =
        FirebaseFirestore.instance
            .collection('launch_projects')
            .doc(projectId)
            .snapshots();

    return LaunchBackground(
      floatingActionButton: OrqubeAiAssistantButton(
        screen: 'TOKEN PROFILE',
        projectId: projectId,
      ),
      appBar: launchAppBar(
        'TOKEN PROFILE',
        actions: [
          IconButton(
            tooltip: '토큰 공유',
            onPressed: () => _invite(context),
            icon: const Icon(Icons.ios_share_outlined),
          ),
        ],
      ),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(
              child: Text(
                '토큰을 찾을 수 없습니다.',
                style: TextStyle(color: LaunchPalette.muted),
              ),
            );
          }

          final name = (data['name'] ?? '').toString();
          final symbol = (data['symbol'] ?? '').toString();
          final tagline = (data['tagline'] ?? '').toString();
          final description = (data['description'] ?? '').toString();
          final vision = (data['vision'] ?? '').toString();
          final utility = (data['utility'] ?? '').toString();
          final category = (data['category'] ?? '').toString();
          final status = (data['status'] ?? 'draft').toString();
          final imageUrl = (data['imageUrl'] ?? '').toString();
          final contractAddress = (data['contractAddress'] ?? '').toString();
          final deploymentTxHash = (data['txHash'] ?? '').toString().trim();
          final storedWalletAddress = (data['walletAddress'] ?? '').toString();
          final verifiedWalletAddress =
              (data['testnetVerifiedWallet'] ?? '').toString().trim();
          // TESTNET에서는 마지막으로 MetaMask에서 검증한 지갑을 화면/실행의 기준으로 사용합니다.
          // 과거 launch_wallets 값이 남아 있더라도 실제 배포 지갑과 뒤섞이지 않게 합니다.
          final walletAddress =
              verifiedWalletAddress.isNotEmpty
                  ? verifiedWalletAddress
                  : storedWalletAddress;
          final externalMarketUrl =
              (data['externalMarketUrl'] ?? '').toString();
          final totalSupply = data['totalSupply'];
          // Some project routes (deep-link / direct named route) can open this page
          // without passing ownerUid. Fall back to the currently authenticated user
          // so owner-only Token Use actions such as DROPS are not silently disabled.
          final effectiveOwnerUid =
              ownerUid.isNotEmpty
                  ? ownerUid
                  : (FirebaseAuth.instance.currentUser?.uid ?? '');
          final isOwner =
              effectiveOwnerUid.isNotEmpty &&
              effectiveOwnerUid == (data['ownerUid'] ?? '').toString();

          final socials =
              <_SocialLink>[
                _SocialLink('Website', Icons.language, data['websiteUrl']),
                _SocialLink(
                  'YouTube',
                  Icons.play_circle_outline,
                  data['youtubeUrl'],
                ),
                _SocialLink(
                  'Instagram',
                  Icons.photo_camera_outlined,
                  data['instagramUrl'],
                ),
                _SocialLink(
                  'Facebook',
                  Icons.people_outline,
                  data['facebookUrl'],
                ),
                _SocialLink('X', Icons.alternate_email, data['xUrl']),
              ].where((e) => e.url.isNotEmpty).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 52),
            children: [
              if (isOwner) ...[
                TokenCreationProgressBar(
                  projectId: projectId,
                  ownerUid: effectiveOwnerUid,
                  projectData: data,
                  onNavigate: (stage) => _navigateCreationStage(
                    context,
                    stage,
                    effectiveOwnerUid,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              _TokenHeroCard(
                name: name,
                symbol: symbol,
                tagline: tagline,
                category: category,
                status: status,
                imageUrl: imageUrl,
                logoSpec: data['logoSpec'] is Map ? data['logoSpec'] as Map : null,
                contractAddress: contractAddress,
                lifecycle: TokenLifecycleState.label(data),
                lifecycleDescription: TokenLifecycleState.description(data),
                networkMode: (data['networkMode'] ?? 'testnet').toString(),
                onShare: () => _invite(context),
                onEdit:
                    isOwner
                        ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => LaunchProfileEditPage(
                                    projectId: projectId,
                                    ownerUid: effectiveOwnerUid,
                                  ),
                            ),
                          );
                        }
                        : null,
              ),
              const SizedBox(height: 14),
              if (isOwner) ...[
                LaunchGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.developer_mode_rounded, color: LaunchPalette.cyan),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'DEVELOPER CENTER',
                              style: TextStyle(
                                color: LaunchPalette.text,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          LaunchStatusPill(
                            label: 'DEPLOY HOLD',
                            icon: Icons.lock_clock_outlined,
                            active: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'QR REWARD · 지갑 · 재수령 정책 · 중복방지 · 네트워크 · 보안 · TX LOG를 배포 전에 먼저 설정합니다.',
                        style: TextStyle(color: LaunchPalette.muted, height: 1.45),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DeveloperCenterPage(
                              projectId: projectId,
                              projectData: data,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('개발자 설정 열기'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              _MarketStrip(data: data, totalSupply: totalSupply),
              const SizedBox(height: 18),
              const LaunchSectionTitle(
                title: 'TOKEN VALUE',
                subtitle: '가격과 별개로 이 토큰이 존재하는 이유와 실제 쓰임을 보여줍니다.',
              ),
              LaunchGlassCard(
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.bolt_outlined,
                      title: 'VISION',
                      body: vision.isEmpty ? '아직 VISION이 입력되지 않았습니다.' : vision,
                    ),
                    const Divider(height: 26, color: LaunchPalette.line),
                    _InfoRow(
                      icon: Icons.hub_outlined,
                      title: 'UTILITY',
                      body:
                          utility.isEmpty ? '아직 UTILITY가 입력되지 않았습니다.' : utility,
                    ),
                    const Divider(height: 26, color: LaunchPalette.line),
                    _InfoRow(
                      icon: Icons.notes_outlined,
                      title: 'TOKEN STORY',
                      body:
                          description.isEmpty ? '토큰 설명을 입력해 주세요.' : description,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              KeyedSubtree(
                key: _tokenUseKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LaunchSectionTitle(
                      title: 'TOKEN USE CENTER',
                      subtitle: '단순 보유·가격 기대가 아니라 보상·멤버십·캠페인·유동성 준비로 실제 사용처를 설계합니다.',
                    ),
                    _TokenUseCenter(
                      data: data,
                      isOwner: isOwner,
                      onConfigure:
                          isOwner ? () => _configureTokenUse(context, data) : null,
                      onManageStage:
                          isOwner
                              ? (stage) => _manageTokenUseStage(context, data, stage)
                              : null,
                      onStartMarketStage:
                          isOwner
                              ? (stage) {
                                switch (stage) {
                                  case TokenMarketStage.drops:
                                    _runDrops(context, data);
                                  case TokenMarketStage.liquidity:
                                    _runLiquidity(context, data);
                                  case TokenMarketStage.swap:
                                    _runSwap(context, data);
                                }
                              }
                              : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              KeyedSubtree(
                key: _deploymentKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LaunchSectionTitle(
                title:
                    '${LaunchChainInfo.fromStored((data['chain'] ?? '').toString()).label} DEPLOYMENT',
                subtitle: '프로필 공개와 실제 온체인 배포를 분리해 안전하게 진행합니다.',
              ),
              LaunchGlassCard(
                child: Column(
                  children: [
                    if (isOwner) ...[
                      _NetworkModeSelector(
                        mode: (data['networkMode'] ?? 'testnet').toString(),
                        kaiaOnly: LaunchChainInfo.fromStored((data['chain'] ?? '').toString()) == LaunchChain.kaia,
                        onChanged: (mode) => _setNetworkMode(context, data, mode),
                      ),
                      const Divider(height: 26, color: LaunchPalette.line),
                    ],
                    _InfoRow(
                      icon: Icons.hub_outlined,
                      title: 'Network',
                      body: _networkSummary(data),
                    ),
                    if (isOwner &&
                        LaunchChainInfo.fromStored(
                          (data['chain'] ?? '').toString(),
                        ).isEvm) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              () => _selectAndVerifyTestnet(context, data),
                          icon: const Icon(Icons.wifi_tethering_outlined),
                          label: const Text('테스트넷 선택 · MetaMask 확인'),
                        ),
                      ),
                    ],
                    const Divider(height: 26, color: LaunchPalette.line),
                    _InfoRow(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Wallet',
                      body:
                          walletAddress.isEmpty
                              ? '미연결 · 다음 단계에서 새 지갑 만들기 / 기존 지갑 연결'
                              : walletAddress,
                      copyValue: walletAddress.isEmpty ? null : walletAddress,
                      copyMessage: '지갑 주소를 복사했습니다.',
                    ),
                    const Divider(height: 26, color: LaunchPalette.line),
                    _InfoRow(
                      icon: Icons.token_outlined,
                      title:
                          LaunchChainInfo.fromStored(
                                    (data['chain'] ?? '').toString(),
                                  ) ==
                                  LaunchChain.solana
                              ? 'Solana Mint'
                              : 'Contract',
                      body:
                          contractAddress.isEmpty
                              ? '미배포 · 사용자 최종 확인 후 TESTNET TOKEN 배포'
                              : contractAddress,
                      copyValue:
                          contractAddress.isEmpty ? null : contractAddress,
                      copyMessage: '컨트랙트 주소를 복사했습니다.',
                    ),
                    if (deploymentTxHash.isNotEmpty) ...[
                      const Divider(height: 26, color: LaunchPalette.line),
                      _InfoRow(
                        icon: Icons.receipt_long_outlined,
                        title: 'TX Hash',
                        body: deploymentTxHash,
                        copyValue: deploymentTxHash,
                        copyMessage: 'TX Hash를 복사했습니다.',
                      ),
                    ],
                    const Divider(height: 26, color: LaunchPalette.line),
                    _InfoRow(
                      icon: Icons.swap_horiz,
                      title: 'Market',
                      body:
                          externalMarketUrl.isEmpty
                              ? '외부 시장 미연결'
                              : '외부 시장 링크 연결됨',
                    ),
                    if (isOwner && contractAddress.isEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => LaunchWalletPage(
                                      ownerUid: effectiveOwnerUid,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
                          label: const Text('멀티체인 지갑 · ORBS 준비'),
                        ),
                      ),
                      const SizedBox(height: 9),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeploymentNext(context, data),
                          icon: const Icon(Icons.rocket_launch_outlined),
                          label: const Text('TESTNET Token Deploy 준비'),
                        ),
                      ),
                    ],
                  ],
                ),
                    ),
                  ],
                ),
              ),
              if (isOwner) ...[
                const SizedBox(height: 18),
                WalletAddressComparePanel(
                  projectWalletAddress: walletAddress,
                  projectId: projectId,
                  ownerUid: effectiveOwnerUid,
                ),
              ],
              const SizedBox(height: 18),
              KeyedSubtree(
                key: _verifyKey,
                child: AutoVerifyPanel(
                projectId: projectId,
                projectData: data,
                isOwner: isOwner,
                ),
              ),
              if (socials.isNotEmpty) ...[
                const SizedBox(height: 18),
                const LaunchSectionTitle(
                  title: 'TOKEN LINKS',
                  subtitle: '공식 채널은 토큰 정보 아래에서 연결합니다.',
                ),
                LaunchGlassCard(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final social in socials)
                        GestureDetector(
                          onTap: () => _showSocialLink(context, social),
                          child: LaunchStatusPill(
                            label: social.name,
                            icon: social.icon,
                            active: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              AdminOnly(child: KeyedSubtree(
                key: _marketingKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LaunchSectionTitle(
                      title: 'AI MARKETING',
                      subtitle:
                          'TOKEN_FIT_SCORE · 국가 · 언어 · 플랫폼 · 홍보문을 생성해 승인 큐로 보냅니다.',
                    ),
                    LaunchGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InfoRow(
                            icon: Icons.auto_awesome,
                            title: 'Human Approval Marketing',
                            body:
                                'AI 분석 → TOKEN_FIT_SCORE → 타깃 국가/언어/플랫폼 → 활용안/홍보문 → 승인 대기. 외부 자동게시와 유료광고는 OFF입니다.',
                          ),
                          if (isOwner) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => _startAiMarketing(context),
                                icon: const Icon(Icons.auto_awesome_rounded),
                                label: const Text('AI Marketing 시작'),
                              ),
                            ),
                            const SizedBox(height: 9),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const AiMarketingApprovalPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.fact_check_outlined),
                                label: const Text('승인 대기함 보기'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              if (isOwner) ...[
                const SizedBox(height: 18),
                LaunchGlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          status == 'published'
                              ? '현재 TOKEN PROFILE이 공개되어 있습니다.'
                              : '현재 TOKEN PROFILE은 비공개입니다. 온체인 배포와는 별도 상태입니다.',
                          style: const TextStyle(color: LaunchPalette.muted),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (status == 'published')
                        OutlinedButton(
                          onPressed:
                              () => LaunchRepository().makeDraft(projectId),
                          child: const Text('비공개'),
                        )
                      else if (status != 'archived')
                        FilledButton(
                          onPressed: () => _publish(context, data),
                          child: const Text('프로필 공개'),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _navigateCreationStage(
    BuildContext context,
    TokenCreationStage stage,
    String effectiveOwnerUid,
  ) async {
    switch (stage) {
      case TokenCreationStage.wallet:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LaunchWalletPage(ownerUid: effectiveOwnerUid),
          ),
        );
        break;
      case TokenCreationStage.create:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LaunchProfileEditPage(
              projectId: projectId,
              ownerUid: effectiveOwnerUid,
            ),
          ),
        );
        break;
      case TokenCreationStage.test:
      case TokenCreationStage.deploy:
        await _scrollTo(_deploymentKey);
        break;
      case TokenCreationStage.pay:
      case TokenCreationStage.verify:
        await _scrollTo(_verifyKey);
        break;
      case TokenCreationStage.use:
        await _scrollTo(_tokenUseKey);
        break;
      case TokenCreationStage.aiMarketing:
        await _scrollTo(_marketingKey);
        break;
    }
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      alignment: .05,
    );
  }

  Future<void> _configureTokenUse(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final progress = TokenUseProgress.fromData(data);
    final next = progress.next;

    if (next == null) {
      await showDialog<void>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('TOKEN USE 단계 완료'),
              content: const Text(
                'REWARD → MEMBERSHIP → CAMPAIGN → LIQUIDITY READY가 모두 활성화되어 있습니다. '
                '다음 확장 단계는 DROPS → LIQUIDITY → SWAP 순서로 연결할 수 있도록 준비되어 있습니다.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            ),
      );
      return;
    }

    final approved = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${next.label} 활성화'),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${progress.current.label}까지 활성화되어 있습니다.'),
                  const SizedBox(height: 12),
                  Text(
                    next.description,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '이 단계는 이전 단계를 대체하지 않습니다. 한 번 활성화하면 기존 단계와 함께 누적되어 TOKEN USE CENTER에 표시됩니다.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '투명성 원칙: 발행량·발행자 보유분·배분/락업·유동성·중요 변경사항을 우선 공개합니다.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('다음 단계 활성화'),
              ),
            ],
          ),
    );
    if (approved != true) return;

    final nextIndex = TokenUseStage.values.indexOf(next);
    await FirebaseFirestore.instance
        .collection('launch_projects')
        .doc(projectId)
        .set({
          // New cumulative progression fields.
          'utilityStageIndex': nextIndex,
          'utilityStage': next.id,
          'utilityStages': {
            for (var i = 0; i <= nextIndex; i++)
              TokenUseStage.values[i].id: true,
          },
          'utilityActivatedAt': {next.id: FieldValue.serverTimestamp()},

          // Backward compatibility with the existing first-generation UI/data.
          'utilityMode': next.id,

          // Guardrails retained for later Drops/Liquidity/Swap expansion.
          'transparencyRequired': true,
          'insiderTradingWarning': true,
          'marketExpansion': {
            'drops': false,
            'liquidity': false,
            'swap': false,
            'gate': 'liquidity_ready_required',
          },
          'utilityUpdatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> _manageTokenUseStage(
    BuildContext context,
    Map<String, dynamic> data,
    TokenUseStage stage,
  ) async {
    final progress = TokenUseProgress.fromData(data);
    if (!progress.isActive(stage)) return;

    // REWARD는 토큰 프로필 안의 실제 운영공간(QR REWARD)으로 연결합니다.
    // 기존 reward 설정 데이터는 QR Reward 화면에서 그대로 읽고 저장합니다.
    if (stage == TokenUseStage.reward) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QrRewardSetupPage(
            projectId: projectId,
            projectData: data,
          ),
        ),
      );
      return;
    }

    final root = data['tokenUseConfig'];
    final configs = root is Map ? root : const {};
    final raw = configs[stage.id];
    final current =
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    final first = TextEditingController();
    final second = TextEditingController();
    final third = TextEditingController();
    bool riskAccepted = current['riskAccepted'] == true;

    String title;
    String firstLabel;
    String secondLabel;
    String thirdLabel;
    switch (stage) {
      case TokenUseStage.reward:
        title = 'REWARD 운영 설정';
        firstLabel = '보상 이름 (예: 커뮤니티 기여 보상)';
        secondLabel = '1회 보상 수량';
        thirdLabel = '지급 조건 / 설명';
        first.text = (current['rewardName'] ?? '').toString();
        second.text = (current['rewardAmount'] ?? '').toString();
        third.text = (current['condition'] ?? '').toString();
        break;
      case TokenUseStage.membership:
        title = 'MEMBERSHIP 운영 설정';
        firstLabel = '멤버십 이름';
        secondLabel = '최소 보유 수량';
        thirdLabel = '혜택 / 참여권';
        first.text = (current['membershipName'] ?? '').toString();
        second.text = (current['minimumHolding'] ?? '').toString();
        third.text = (current['benefit'] ?? '').toString();
        break;
      case TokenUseStage.campaign:
        title = 'CAMPAIGN 운영 설정';
        firstLabel = '캠페인 이름';
        secondLabel = '참여/보상 수량';
        thirdLabel = '기간·조건·혜택';
        first.text = (current['campaignName'] ?? '').toString();
        second.text = (current['campaignAmount'] ?? '').toString();
        third.text = (current['campaignDetail'] ?? '').toString();
        break;
      case TokenUseStage.liquidityReady:
        title = 'LIQUIDITY READY 공개 설정';
        firstLabel = '초기 유동성 계획 (예: 1,000,000 KRW 상당)';
        secondLabel = '발행자 보유분 / 배분 비율';
        thirdLabel = '락업·LP·위험고지 내용';
        first.text = (current['initialLiquidityPlan'] ?? '').toString();
        second.text = (current['issuerAllocation'] ?? '').toString();
        third.text = (current['lockupAndRisk'] ?? '').toString();
        break;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setLocalState) => AlertDialog(
                  title: Text(title),
                  content: SizedBox(
                    width: 560,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: first,
                            decoration: InputDecoration(labelText: firstLabel),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: second,
                            keyboardType:
                                stage == TokenUseStage.liquidityReady
                                    ? TextInputType.text
                                    : const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                            decoration: InputDecoration(labelText: secondLabel),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: third,
                            maxLines: 3,
                            decoration: InputDecoration(labelText: thirdLabel),
                          ),
                          if (stage == TokenUseStage.liquidityReady) ...[
                            const SizedBox(height: 10),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: riskAccepted,
                              onChanged:
                                  (value) => setLocalState(
                                    () => riskAccepted = value == true,
                                  ),
                              title: const Text(
                                '유동성·가격 변동·손실 가능성에 대한 위험고지를 확인했습니다.',
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ],
                          const SizedBox(height: 8),
                          const Text(
                            '이 설정은 TOKEN USE CENTER 운영정보로 저장됩니다. 실제 온체인 전송·LP 생성·Swap은 별도 단계에서 사용자 최종 확인 후 연결됩니다.',
                            style: TextStyle(
                              fontSize: 12,
                              color: LaunchPalette.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('취소'),
                    ),
                    FilledButton(
                      onPressed:
                          stage == TokenUseStage.liquidityReady && !riskAccepted
                              ? null
                              : () => Navigator.pop(dialogContext, true),
                      child: const Text('저장'),
                    ),
                  ],
                ),
          ),
    );

    if (saved != true) return;

    Map<String, dynamic> config;
    switch (stage) {
      case TokenUseStage.reward:
        config = {
          'rewardName': first.text.trim(),
          'rewardAmount': double.tryParse(second.text.trim()) ?? 0,
          'condition': third.text.trim(),
        };
        break;
      case TokenUseStage.membership:
        config = {
          'membershipName': first.text.trim(),
          'minimumHolding': double.tryParse(second.text.trim()) ?? 0,
          'benefit': third.text.trim(),
        };
        break;
      case TokenUseStage.campaign:
        config = {
          'campaignName': first.text.trim(),
          'campaignAmount': double.tryParse(second.text.trim()) ?? 0,
          'campaignDetail': third.text.trim(),
        };
        break;
      case TokenUseStage.liquidityReady:
        config = {
          'initialLiquidityPlan': first.text.trim(),
          'issuerAllocation': second.text.trim(),
          'lockupAndRisk': third.text.trim(),
          'riskAccepted': riskAccepted,
        };
        break;
    }

    try {
      await TokenUseService().saveStageConfig(
        projectId: projectId,
        stage: stage,
        config: config,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${stage.label} 운영 설정을 저장했습니다.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('TOKEN USE 설정 저장 실패: $e')));
    } finally {
      first.dispose();
      second.dispose();
      third.dispose();
    }
  }

  String _networkSummary(Map<String, dynamic> data) {
    final chain = LaunchChainInfo.fromStored((data['chain'] ?? '').toString());
    if (!chain.isEvm) return '${chain.testnetLabel} · 현재 시장 단계는 EVM 테스트넷만 지원';
    final info = BrowserWalletBridge.networkInfo(chain.key);
    final verified = (data['testnetVerifiedChainId'] ?? '').toString();
    final expected = (info['chainId'] ?? '').toString();
    final status =
        verified.toLowerCase() == expected.toLowerCase() ? 'VERIFIED' : '확인 필요';
    return '${info['chainName']} · Chain ID $expected · $status · MAINNET 차단';
  }

  Future<void> _selectAndVerifyTestnet(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final stored = LaunchChainInfo.fromStored((data['chain'] ?? '').toString());
    LaunchChain selected = stored.isEvm ? stored : LaunchChain.kaia;
    final contract = (data['contractAddress'] ?? '').toString().trim();

    final approved = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setLocalState) => AlertDialog(
                  title: const Text('테스트넷 선택 · 지갑 확인'),
                  content: SizedBox(
                    width: 590,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DROPS · LIQUIDITY · SWAP 실제 테스트는 Mainnet이 아니라 Kaia Kairos / Polygon Amoy에서만 허용됩니다.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 14),
                        SegmentedButton<LaunchChain>(
                          segments: const [
                            ButtonSegment(
                              value: LaunchChain.kaia,
                              label: Text('KAIA · Kairos'),
                              icon: Icon(Icons.hexagon_outlined),
                            ),
                            ButtonSegment(
                              value: LaunchChain.polygon,
                              label: Text('POLYGON · Amoy'),
                              icon: Icon(Icons.change_history_outlined),
                            ),
                          ],
                          selected: {selected},
                          onSelectionChanged:
                              (value) =>
                                  setLocalState(() => selected = value.first),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '선택 네트워크: ${BrowserWalletBridge.networkInfo(selected.key)['chainName']}\n'
                          'Chain ID: ${BrowserWalletBridge.networkInfo(selected.key)['chainId']}',
                          style: const TextStyle(
                            color: LaunchPalette.muted,
                            height: 1.5,
                          ),
                        ),
                        if (contract.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            '이미 배포된 컨트랙트는 ${(data['chain'] ?? '').toString()} 체인에 고정됩니다. 다른 테스트넷을 선택하면 전송을 차단합니다.',
                            style: const TextStyle(
                              color: LaunchPalette.muted,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('취소'),
                    ),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: const Text('MetaMask 연결 · 확인'),
                    ),
                  ],
                ),
          ),
    );
    if (approved != true) return;

    try {
      final storedChain = (data['chain'] ?? '').toString();
      if (contract.isNotEmpty &&
          storedChain.isNotEmpty &&
          storedChain != selected.key) {
        throw StateError(
          '이 토큰은 $storedChain 테스트넷에 배포되어 있어 ${selected.key} 테스트넷으로 바꿀 수 없습니다.',
        );
      }
      final wallet = await BrowserWalletBridge.connectEvm(chain: selected.key);
      final savedWallet = (data['walletAddress'] ?? '').toString().trim();
      final verifiedWallet =
          (data['testnetVerifiedWallet'] ?? '').toString().trim();
      // 이미 한 번 MetaMask에서 검증된 지갑을 우선 신뢰합니다.
      // 검증값이 없는 기존 배포 건은 txHash의 실제 from 주소를 온체인에서 읽어 복구합니다.
      var expectedWallet = verifiedWallet;
      final txHash = (data['txHash'] ?? '').toString().trim();
      if (expectedWallet.isEmpty && contract.isNotEmpty && txHash.isNotEmpty) {
        expectedWallet = await BrowserWalletBridge.evmTransactionFrom(
          chain: selected.key,
          txHash: txHash,
        );
      }
      if (expectedWallet.isEmpty) expectedWallet = savedWallet;
      if (expectedWallet.isNotEmpty &&
          expectedWallet.toLowerCase() != wallet.address.toLowerCase()) {
        throw StateError('현재 MetaMask 계정이 이 프로젝트에서 검증된 지갑과 다릅니다.');
      }
      final chainId = await BrowserWalletBridge.ensureEvmTestnet(
        chain: selected.key,
      );
      final info = BrowserWalletBridge.networkInfo(selected.key);
      await FirebaseFirestore.instance
          .collection('launch_projects')
          .doc(projectId)
          .set({
            if (contract.isEmpty) 'chain': selected.key,
            // 검증된 현재 MetaMask를 canonical walletAddress로 항상 동기화합니다.
            'walletAddress': wallet.address,
            'networkMode': 'testnet',
            'testnetNetworkName': info['chainName'],
            'testnetVerifiedChainId': chainId,
            'testnetVerifiedWallet': wallet.address,
            'testnetVerifiedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      final uid =
          ownerUid.isNotEmpty
              ? ownerUid
              : (FirebaseAuth.instance.currentUser?.uid ?? '');
      if (uid.isNotEmpty) {
        await LaunchWalletRepository().connectWallet(
          ownerUid: uid,
          walletAddress: wallet.address,
          chain: selected.key,
        );
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${info['chainName']} 확인 완료 · ${_shortHash(wallet.address)}',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('테스트넷/지갑 확인 실패: $e')));
    }
  }

  Future<void> _setNetworkMode(BuildContext context, Map<String, dynamic> data, String mode) async {
    final contract = (data['contractAddress'] ?? '').toString().trim();
    final current = (data['networkMode'] ?? 'testnet').toString().toLowerCase();
    if (contract.isNotEmpty && current != mode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미 배포된 토큰은 배포 네트워크 상태를 변경할 수 없습니다.')));
      return;
    }
    if (mode == 'mainnet' && LaunchChainInfo.fromStored((data['chain'] ?? '').toString()) != LaunchChain.kaia) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('현재 MAINNET 선택은 Kaia Mainnet 기준입니다.')));
      return;
    }
    await FirebaseFirestore.instance.collection('launch_projects').doc(projectId).set({
      'networkMode': mode,
      if (mode == 'mainnet') 'deploymentNetwork': 'Kaia Mainnet',
      if (mode == 'testnet') 'deploymentNetwork': LaunchChainInfo.fromStored((data['chain'] ?? '').toString()).testnetLabel,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> _ensureMarketTestnet(
    BuildContext context,
    Map<String, dynamic> data, {
    required String action,
  }) async {
    final chain = (data['chain'] ?? '').toString();
    if (chain != 'Kaia' && chain != 'Polygon') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$action은 Kaia Kairos / Polygon Amoy 테스트넷에서만 실행할 수 있습니다.',
          ),
        ),
      );
      return false;
    }
    try {
      final wallet = await BrowserWalletBridge.connectEvm(chain: chain);
      final savedWallet = (data['walletAddress'] ?? '').toString().trim();
      final verifiedWallet =
          (data['testnetVerifiedWallet'] ?? '').toString().trim();
      var expectedWallet = verifiedWallet;
      final contract = (data['contractAddress'] ?? '').toString().trim();
      final txHash = (data['txHash'] ?? '').toString().trim();
      if (expectedWallet.isEmpty && contract.isNotEmpty && txHash.isNotEmpty) {
        expectedWallet = await BrowserWalletBridge.evmTransactionFrom(
          chain: chain,
          txHash: txHash,
        );
      }
      if (expectedWallet.isEmpty) expectedWallet = savedWallet;
      if (expectedWallet.isNotEmpty &&
          expectedWallet.toLowerCase() != wallet.address.toLowerCase()) {
        throw StateError('현재 MetaMask 계정이 이 프로젝트에서 검증된 지갑과 다릅니다.');
      }
      final chainId = await BrowserWalletBridge.ensureEvmTestnet(chain: chain);
      final info = BrowserWalletBridge.networkInfo(chain);
      await FirebaseFirestore.instance
          .collection('launch_projects')
          .doc(projectId)
          .set({
            // DROPS/LIQUIDITY/SWAP 직전에도 현재 검증된 MetaMask 주소로 자동 복구합니다.
            'walletAddress': wallet.address,
            'networkMode': 'testnet',
            'testnetNetworkName': info['chainName'],
            'testnetVerifiedChainId': chainId,
            'testnetVerifiedWallet': wallet.address,
            'testnetVerifiedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      final uid =
          ownerUid.isNotEmpty
              ? ownerUid
              : (FirebaseAuth.instance.currentUser?.uid ?? '');
      if (uid.isNotEmpty) {
        await LaunchWalletRepository().connectWallet(
          ownerUid: uid,
          walletAddress: wallet.address,
          chain: chain,
        );
      }
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$action 사전확인 완료 · ${info['chainName']} · MetaMask 연결됨',
          ),
        ),
      );
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$action 차단 · 테스트넷/지갑 확인 실패: $e')));
      return false;
    }
  }

  Future<void> _runDrops(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final core = TokenUseProgress.fromData(data);
    final market = TokenMarketProgress.fromData(data);
    if (!core.isComplete || market.next != TokenMarketStage.drops) return;

    final chain = (data['chain'] ?? '').toString();
    if (chain != 'Kaia' && chain != 'Polygon') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('현재 실제 DROPS 전송은 Kaia/Polygon EVM 테스트넷부터 지원합니다.'),
        ),
      );
      return;
    }
    if ((data['contractAddress'] ?? '').toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DROPS 실행 전에 테스트넷 토큰 배포를 완료해 주세요.')),
      );
      return;
    }
    if (!await _ensureMarketTestnet(context, data, action: 'DROPS')) return;

    final title = TextEditingController(text: 'ORQUBE TOKEN DROP');
    final recipients = TextEditingController();
    final approved = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('DROPS 실제 전송'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '연결된 MetaMask에서 배포 토큰을 대상 지갑으로 실제 전송합니다. 각 전송마다 지갑 승인창이 표시될 수 있습니다.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: '드롭 이름'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: recipients,
                      minLines: 5,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        labelText: '대상 지갑과 수량',
                        hintText: '0x1234...abcd, 100\n0xabcd...1234, 250.5',
                        helperText: '한 줄에 지갑주소, 수량 · 중복 주소 불가 · 한 번에 최대 20개',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '실행 전 현재 지갑의 ERC-20 잔액을 확인합니다. 모든 전송이 성공한 경우에만 DROPS가 ACTIVE가 되며, 중간 실패 시 성공한 Tx Hash까지 PARTIAL 기록으로 보존됩니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: LaunchPalette.muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('취소'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.send_rounded),
                label: const Text('검증 후 DROPS 실행'),
              ),
            ],
          ),
    );
    if (approved != true) {
      title.dispose();
      recipients.dispose();
      return;
    }

    try {
      final parsed = TokenDropService.parseRecipients(recipients.text);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${parsed.length}개 지갑 DROPS를 시작합니다. MetaMask 승인창을 확인해 주세요.',
          ),
        ),
      );
      final result = await TokenDropService().execute(
        projectId: projectId,
        projectData: data,
        title: title.text,
        recipients: parsed,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'DROPS 완료 · ${result.transfers.length}건 전송 · DROPS ACTIVE',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('DROPS 실행 실패/중단: $e')));
    } finally {
      title.dispose();
      recipients.dispose();
    }
  }

  Future<void> _runLiquidity(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final market = TokenMarketProgress.fromData(data);
    if (market.next != TokenMarketStage.liquidity) return;
    if (!await _ensureMarketTestnet(context, data, action: 'LIQUIDITY')) return;

    final router = TextEditingController();
    final tokenAmount = TextEditingController(text: '1000');
    final nativeAmount = TextEditingController(text: '1');
    final slippage = TextEditingController(text: '1.0');
    final approved = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('LIQUIDITY 실제 연결'),
            content: SizedBox(
              width: 640,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uniswap V2 호환 테스트넷 Router에 토큰 + Native(KAIA/POL) 초기 유동성을 실제 추가합니다.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: router,
                      decoration: const InputDecoration(
                        labelText: 'DEX Router 주소 (0x...)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tokenAmount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: '추가할 토큰 수량'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nativeAmount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            '추가할 ${(data['chain'] ?? '') == 'Kaia' ? 'KAIA' : 'POL'} 수량',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: slippage,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Slippage % (예: 1.0)',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Router 컨트랙트 코드와 WETH/Wrapped Native 응답을 먼저 검증합니다. 이후 ERC-20 approve와 addLiquidityETH가 각각 MetaMask 승인을 요청할 수 있습니다. 테스트넷에서만 진행하세요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: LaunchPalette.muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('취소'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.water_drop_outlined),
                label: const Text('검증 후 LIQUIDITY 실행'),
              ),
            ],
          ),
    );
    if (approved != true) {
      router.dispose();
      tokenAmount.dispose();
      nativeAmount.dispose();
      slippage.dispose();
      return;
    }

    try {
      final result = await TokenLiquidityService().execute(
        projectId: projectId,
        projectData: data,
        routerAddress: router.text.trim(),
        tokenAmount: tokenAmount.text.trim(),
        nativeAmount: nativeAmount.text.trim(),
        slippagePercent: double.tryParse(slippage.text.trim()) ?? 0,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'LIQUIDITY 완료 · Tx ${_shortHash(result.liquidityTxHash)} · 다음 SWAP이 열렸습니다.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('LIQUIDITY 실행 실패/중단: $e')));
    } finally {
      router.dispose();
      tokenAmount.dispose();
      nativeAmount.dispose();
      slippage.dispose();
    }
  }

  Future<void> _runSwap(BuildContext context, Map<String, dynamic> data) async {
    final market = TokenMarketProgress.fromData(data);
    if (market.next != TokenMarketStage.swap) return;
    if (!await _ensureMarketTestnet(context, data, action: 'SWAP')) return;

    bool tokenToNative = false;
    final amount = TextEditingController(text: '0.01');
    final slippage = TextEditingController(text: '1.0');
    final approved = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setLocalState) => AlertDialog(
                  title: const Text('SWAP 실제 테스트'),
                  content: SizedBox(
                    width: 620,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '방금 생성한 LIQUIDITY Router를 사용해 실제 테스트넷 Swap을 실행합니다.',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(
                                value: false,
                                label: Text(
                                  '${(data['chain'] ?? '') == 'Kaia' ? 'KAIA' : 'POL'} → TOKEN',
                                ),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text(
                                  'TOKEN → ${(data['chain'] ?? '') == 'Kaia' ? 'KAIA' : 'POL'}',
                                ),
                              ),
                            ],
                            selected: {tokenToNative},
                            onSelectionChanged:
                                (v) => setLocalState(
                                  () => tokenToNative = v.first,
                                ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: amount,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Swap 입력 수량',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: slippage,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Slippage % (예: 1.0)',
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            '실행 직전 Router getAmountsOut으로 예상 수령량을 조회하고 Slippage를 반영한 최소 수령량을 설정합니다. 성공 Tx가 확인된 경우에만 SWAP ACTIVE가 됩니다.',
                            style: TextStyle(
                              fontSize: 12,
                              color: LaunchPalette.muted,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('취소'),
                    ),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('견적 확인 후 SWAP 실행'),
                    ),
                  ],
                ),
          ),
    );
    if (approved != true) {
      amount.dispose();
      slippage.dispose();
      return;
    }

    try {
      final result = await TokenSwapService().execute(
        projectId: projectId,
        projectData: data,
        tokenToNative: tokenToNative,
        amountIn: amount.text.trim(),
        slippagePercent: double.tryParse(slippage.text.trim()) ?? 0,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SWAP 완료 · Tx ${_shortHash(result.txHash)} · SWAP ACTIVE',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('SWAP 실행 실패/중단: $e')));
    } finally {
      amount.dispose();
      slippage.dispose();
    }
  }

  String _shortHash(String value) =>
      value.length <= 14
          ? value
          : '${value.substring(0, 8)}…${value.substring(value.length - 6)}';

  Future<void> _startAiMarketing(BuildContext context) async {
    if (!await AdminAccess.allowed()) return;
    try {
      final result = await TokenMarketingService().start(projectId: projectId);
      await FirebaseFirestore.instance
          .collection('launch_projects')
          .doc(projectId)
          .set({
            'aiMarketingQueueId': result.queueId,
            'aiMarketingStartedAt': FieldValue.serverTimestamp(),
            'aiMarketingTokenFitScore': result.tokenFitScore,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'AI Marketing 승인 요청 생성 · TOKEN_FIT_SCORE ${result.tokenFitScore} · ${result.language} · ${result.platform}',
          ),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AiMarketingApprovalPage()),
      );
    } on TokenMarketingException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('AI Marketing 시작 실패: $e')));
    }
  }

  Future<void> _publish(BuildContext context, Map<String, dynamic> data) async {
    final category = LaunchPolicy.categoryFromRaw(
      (data['category'] ?? '').toString(),
    );
    final result = LaunchPolicy.evaluateTokenRequest(
      category: category,
      name: (data['name'] ?? '').toString(),
      symbol: (data['symbol'] ?? '').toString(),
      text:
          "${data['tagline'] ?? ''} ${data['description'] ?? ''} ${data['vision'] ?? ''} ${data['utility'] ?? ''}",
    );

    if (!result.allowed) {
      await showDialog<void>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('공개할 수 없습니다'),
              content: Text(result.message),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            ),
      );
      return;
    }

    await LaunchRepository().publish(projectId);
  }

  Future<int?> _confirmFinalSupply(
    BuildContext context,
    dynamic currentSupply,
  ) async {
    final initial = currentSupply is num
        ? currentSupply.toInt().toString()
        : currentSupply?.toString().replaceAll(',', '').trim() ?? '';
    final controller = TextEditingController(text: initial);
    String? errorText;

    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(TokenCreationI18n.t('finalSupplyTitle')),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TokenCreationI18n.t('finalSupplyBody')),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: TokenCreationI18n.t('supplyLabel'),
                    hintText: TokenCreationI18n.t('supplyHint'),
                    errorText: errorText,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  TokenCreationI18n.t('finalSupplyWarning'),
                  style: const TextStyle(
                    color: LaunchPalette.muted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(TokenCreationI18n.t('cancel')),
            ),
            FilledButton.icon(
              onPressed: () {
                final raw = controller.text.replaceAll(',', '').trim();
                final value = int.tryParse(raw);
                if (value == null) {
                  setDialogState(() {
                    errorText = TokenCreationI18n.t('supplyRequired');
                  });
                  return;
                }
                if (value < LaunchEconomyPolicy.minTokenSupply ||
                    value > LaunchEconomyPolicy.maxTokenSupply) {
                  setDialogState(() {
                    errorText = TokenCreationI18n.t('supplyRange');
                  });
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              icon: const Icon(Icons.fact_check_outlined),
              label: Text(TokenCreationI18n.t('confirmSupply')),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _showDeploymentNext(
    BuildContext context,
    Map<String, dynamic> projectData,
  ) async {
    final walletRepo = LaunchWalletRepository();
    final effectiveOwnerUid =
        ownerUid.isNotEmpty
            ? ownerUid
            : (FirebaseAuth.instance.currentUser?.uid ?? '');
    final account = await walletRepo.loadAccount(effectiveOwnerUid);
    final config = await walletRepo.loadDeployConfig();

    // 프로젝트에서 선택한 체인을 기준으로 하고, 실제 배포 지갑은 브라우저 지갑에서
    // 다시 읽습니다. launch_wallets의 오래된 주소가 배포 메타데이터에 섞이는 것을 방지합니다.
    final chain = LaunchChainInfo.fromStored(
      (projectData['chain'] ?? account['chain'] ?? '').toString(),
    );
    var walletAddress =
        (projectData['testnetVerifiedWallet'] ?? '').toString().trim();
    if (walletAddress.isEmpty) {
      walletAddress = (projectData['walletAddress'] ?? '').toString().trim();
    }
    if (walletAddress.isEmpty) {
      walletAddress = (account['walletAddress'] ?? '').toString().trim();
    }

    if (chain.isEvm) {
      try {
        final connected = await BrowserWalletBridge.connectEvm(
          chain: chain.key,
        );
        final verifiedWallet =
            (projectData['testnetVerifiedWallet'] ?? '').toString().trim();
        if (verifiedWallet.isNotEmpty &&
            verifiedWallet.toLowerCase() != connected.address.toLowerCase()) {
          throw StateError('현재 MetaMask 계정이 이 프로젝트에서 검증된 지갑과 다릅니다.');
        }
        await BrowserWalletBridge.ensureEvmTestnet(chain: chain.key);
        walletAddress = connected.address;
        await FirebaseFirestore.instance
            .collection('launch_projects')
            .doc(projectId)
            .set({
              'walletAddress': walletAddress,
              'testnetVerifiedWallet': walletAddress,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
        await walletRepo.connectWallet(
          ownerUid: effectiveOwnerUid,
          walletAddress: walletAddress,
          chain: chain.key,
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('배포 지갑 확인 실패: $e')));
        return;
      }
    }

    // TESTNET 배포에서는 ORBS 정책 비용을 차감하지 않습니다.
    // deployFeeOrbs 설정값은 향후 Mainnet 정책용으로 그대로 보존합니다.
    const deployFee = 0.0;
    final mainnetDeployFee = LaunchWalletRepository.numberAsDouble(
      config['deployFeeOrbs'],
    );
    final mainnetPolicyLabel =
        mainnetDeployFee > 0
            ? 'Mainnet 정책 기준: ${mainnetDeployFee.toStringAsFixed(4)} ORBS · 현재 미적용'
            : 'Mainnet 정책 기준: 관리자 설정 전 · 현재 미적용';

    final category = LaunchPolicy.categoryFromRaw(
      (projectData['category'] ?? '').toString(),
    );
    final policy = LaunchPolicy.evaluateTokenRequest(
      category: category,
      name: (projectData['name'] ?? '').toString(),
      symbol: (projectData['symbol'] ?? '').toString(),
      text:
          "${projectData['tagline'] ?? ''} ${projectData['description'] ?? ''} ${projectData['vision'] ?? ''} ${projectData['utility'] ?? ''}",
    );

    if (!context.mounted) return;
    String? blockReason;
    if (!policy.allowed) {
      blockReason = policy.message;
    } else if (walletAddress.isEmpty) {
      blockReason = '먼저 배포할 체인의 지갑을 연결해 주세요.';
    }

    if (blockReason != null) {
      await showDialog<void>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Token Deploy 준비 필요'),
              content: Text(blockReason!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
                if (walletAddress.isEmpty)
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  LaunchWalletPage(ownerUid: effectiveOwnerUid),
                        ),
                      );
                    },
                    child: const Text('지갑 · ORBS 보기'),
                  ),
              ],
            ),
      );
      return;
    }

    final finalSupply = await _confirmFinalSupply(
      context,
      projectData['totalSupply'],
    );
    if (finalSupply == null || !context.mounted) return;

    final rawFeatures = projectData['tokenFeatures'];
    final features = rawFeatures is Map
        ? Map<String, dynamic>.from(rawFeatures)
        : <String, dynamic>{};
    final mintable = features['mintable'] == true;
    final capSupply = int.tryParse(
          (features['capSupply'] ?? '').toString().replaceAll(',', ''),
        ) ??
        0;
    if (mintable && capSupply < finalSupply) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TokenCreationI18n.t('capTooSmall'))),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('launch_projects')
        .doc(projectId)
        .set({
          'totalSupply': finalSupply,
          'totalSupplyConfirmedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    projectData = Map<String, dynamic>.from(projectData)
      ..['totalSupply'] = finalSupply;

    final featureSummary = <String>[
      mintable
          ? '${TokenCreationI18n.t('mintable')} · ${TokenCreationI18n.t('capSupply')}: $capSupply'
          : TokenCreationI18n.t('fixedSupply'),
      if (features['burnable'] == true) TokenCreationI18n.t('burnable'),
      if (features['pausable'] == true) TokenCreationI18n.t('pausable'),
    ].join(' / ');

    final approved = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('TESTNET DEPLOY'),
            content: Text(
              '${chain.label} · ${chain.testnetLabel}\n'
              'Wallet: ${_TokenHeroCard._shortAddress(walletAddress)}\n'
              'Supply: ${projectData['totalSupply'] ?? '-'}\n'
              'Features: $featureSummary\n'
              'TESTNET ORBS Fee: ${deployFee.toStringAsFixed(0)} ORBS · 차감 없음\n'
              '$mainnetPolicyLabel\n\n'
              '테스트넷 실제 배포를 실행합니다. 최종 네트워크 수수료는 연결된 지갑에서 확인·승인하며 개인키는 ORQUBE로 전송되지 않습니다.\n\n'
              '※ Kaia Kairos / Polygon Amoy 등 TESTNET에서는 ORBS를 차감하지 않습니다. Mainnet 배포 기능을 열 때만 관리자 deployFeeOrbs 정책값을 적용하도록 분리합니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('지갑에서 배포 승인'),
              ),
            ],
          ),
    );
    if (approved != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${chain.label} ${chain.testnetLabel} 배포를 시작합니다. 지갑 승인창을 확인해 주세요.',
        ),
      ),
    );

    try {
      final deployData =
          Map<String, dynamic>.from(projectData)
            ..['walletAddress'] = walletAddress
            ..['chain'] = chain.key;
      final result = await TokenDeploymentService().deploy(
        projectId: projectId,
        ownerUid: effectiveOwnerUid,
        projectData: deployData,
        chain: chain,
      );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${result.chain} 테스트 배포 완료 · ${_TokenHeroCard._shortAddress(result.address)}',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('테스트 토큰 배포 실패: $e')));
    }
  }

  Future<void> _showSocialLink(BuildContext context, _SocialLink social) async {
    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(social.name),
            content: SelectableText(social.url),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: social.url));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${social.name} 주소를 복사했습니다.')),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 17),
                label: const Text('주소 복사'),
              ),
            ],
          ),
    );
  }

  Future<void> _invite(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('토큰 공유'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('이 TOKEN PROFILE의 고유 링크입니다.'),
                const SizedBox(height: 12),
                SelectableText(inviteUrl),
                const SizedBox(height: 10),
                const Text(
                  '메인 진입 파일에서 launch 파라미터를 연결하면 방문자가 이 토큰 화면으로 바로 들어오게 됩니다.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: inviteUrl));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('토큰 링크를 복사했습니다.')),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 17),
                label: const Text('링크 복사'),
              ),
            ],
          ),
    );
  }
}

class _NetworkModeSelector extends StatelessWidget {
  const _NetworkModeSelector({required this.mode, required this.kaiaOnly, required this.onChanged});
  final String mode;
  final bool kaiaOnly;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final mainnet = mode.toLowerCase() == 'mainnet';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('NETWORK MODE', style: TextStyle(color: LaunchPalette.text, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      SegmentedButton<String>(
        segments: const [ButtonSegment(value: 'testnet', label: Text('TESTNET'), icon: Icon(Icons.science_outlined)), ButtonSegment(value: 'mainnet', label: Text('MAINNET'), icon: Icon(Icons.public_outlined))],
        selected: {mainnet ? 'mainnet' : 'testnet'},
        onSelectionChanged: (v) => onChanged(v.first),
      ),
      const SizedBox(height: 7),
      Text(mainnet ? 'Kaia Mainnet 모드 · 실제 배포/결제 전 지갑과 비용을 최종 확인합니다.' : 'Testnet 모드 · Kaia Kairos / Polygon Amoy에서 먼저 시험합니다.', style: const TextStyle(color: LaunchPalette.muted, fontSize: 12)),
    ]);
  }
}

class _TokenHeroCard extends StatelessWidget {
  const _TokenHeroCard({
    required this.name,
    required this.symbol,
    required this.tagline,
    required this.category,
    required this.status,
    required this.imageUrl,
    this.logoSpec,
    required this.contractAddress,
    required this.lifecycle,
    required this.lifecycleDescription,
    required this.networkMode,
    required this.onShare,
    this.onEdit,
  });

  final String name;
  final String symbol;
  final String tagline;
  final String category;
  final String status;
  final String imageUrl;
  final Map? logoSpec;
  final String contractAddress;
  final String lifecycle;
  final String lifecycleDescription;
  final String networkMode;
  final VoidCallback onShare;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final fallback = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final categoryLabel = LaunchPolicy.categoryLabel(
      LaunchPolicy.categoryFromRaw(category),
    );

    return LaunchGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [LaunchPalette.purple, LaunchPalette.blue],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(.16),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    imageUrl.isEmpty
                        ? GeometricTokenLogo(symbol: symbol, spec: logoSpec, size: 78)
                        : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Center(
                                child: Text(
                                  fallback,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                        ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: LaunchPalette.text,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '\$$symbol',
                      style: const TextStyle(
                        color: LaunchPalette.cyan,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        const LaunchStatusPill(label: 'KAIA', active: true),
                        LaunchStatusPill(label: categoryLabel),
                        LaunchStatusPill(
                          label: launchStatusLabel(status),
                          active: launchStatusIsActive(status),
                        ),
                        LaunchStatusPill(
                          label: lifecycle,
                          icon: lifecycle == 'VERIFIED' ? Icons.verified_outlined : (lifecycle == 'DEPLOYED' ? Icons.rocket_launch_outlined : Icons.inventory_2_outlined),
                          active: lifecycle != 'INTERNAL',
                        ),
                        LaunchStatusPill(
                          label: networkMode.toLowerCase() == 'mainnet' ? 'MAINNET' : 'TESTNET',
                          icon: Icons.public_outlined,
                          active: networkMode.toLowerCase() == 'mainnet',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tagline.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              tagline,
              style: const TextStyle(
                color: LaunchPalette.text,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 15),
          Text(
            lifecycleDescription,
            style: const TextStyle(color: LaunchPalette.cyan, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Text(
            contractAddress.isEmpty
                ? 'CONTRACT · PRE-LAUNCH'
                : 'CONTRACT · ${_shortAddress(contractAddress)}',
            style: const TextStyle(
              color: LaunchPalette.muted,
              fontSize: 12,
              letterSpacing: .4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              FilledButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.ios_share_outlined),
                label: const Text('토큰 공유'),
              ),
              if (onEdit != null)
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.tune),
                  label: const Text('토큰 편집'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _shortAddress(String value) {
    if (value.length <= 14) return value;
    return '${value.substring(0, 8)}…${value.substring(value.length - 6)}';
  }
}

class _TokenUseCenter extends StatelessWidget {
  const _TokenUseCenter({
    required this.data,
    required this.isOwner,
    this.onConfigure,
    this.onManageStage,
    this.onStartMarketStage,
  });
  final Map<String, dynamic> data;
  final bool isOwner;
  final VoidCallback? onConfigure;
  final ValueChanged<TokenUseStage>? onManageStage;
  final ValueChanged<TokenMarketStage>? onStartMarketStage;

  @override
  Widget build(BuildContext context) {
    final progress = TokenUseProgress.fromData(data);
    final deployed = (data['contractAddress'] ?? '').toString().isNotEmpty;
    final market = TokenMarketProgress.fromData(data);
    final configRoot = data['tokenUseConfig'];
    final configs = configRoot is Map ? configRoot : const {};

    return LaunchGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < TokenUseStage.values.length; i++) ...[
            _TokenUseStageRow(
              stage: TokenUseStage.values[i],
              progress: progress,
              configured:
                  configs[TokenUseStage.values[i].id] is Map &&
                  configs[TokenUseStage.values[i].id]['configured'] == true,
              onManage:
                  isOwner &&
                          (progress.isActive(TokenUseStage.values[i]) ||
                              progress.isNext(TokenUseStage.values[i]))
                      ? () => onManageStage?.call(TokenUseStage.values[i])
                      : null,
            ),
            if (i != TokenUseStage.values.length - 1)
              const Divider(height: 22, color: LaunchPalette.line),
          ],
          const Divider(height: 28, color: LaunchPalette.line),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            title: 'TRANSPARENCY',
            body: '발행량 · 발행자 보유분 · 배분/락업 · 유동성 · 주요 변경사항을 공개하는 것을 기본 원칙으로 합니다.',
          ),
          const SizedBox(height: 12),
          Text(
            progress.isComplete
                ? 'CORE UTILITY COMPLETE · 다음 확장: DROPS → LIQUIDITY → SWAP'
                : 'NEXT · ${progress.next!.label}',
            style: const TextStyle(
              color: LaunchPalette.text,
              fontWeight: FontWeight.w900,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress.isComplete
                ? (market.hasStarted
                    ? '${market.current!.label}까지 확장 준비가 활성화되었습니다. 다음 단계도 기존 구조를 유지한 채 순차 연결됩니다.'
                    : 'Liquidity Ready까지 완료되었습니다. DROPS부터 기존 구조를 버리지 않고 순서대로 연결할 수 있습니다.')
                : progress.next!.description,
            style: const TextStyle(color: LaunchPalette.muted, height: 1.45),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final stage in TokenMarketStage.values)
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap:
                      isOwner &&
                              market.isNext(stage) &&
                              onStartMarketStage != null
                          ? () => onStartMarketStage!.call(stage)
                          : null,
                  child: LaunchStatusPill(
                    label:
                        '${stage.label}${market.isNext(stage) ? ' · NEXT' : ''}',
                    icon:
                        stage == TokenMarketStage.drops
                            ? Icons.card_giftcard_outlined
                            : stage == TokenMarketStage.liquidity
                            ? Icons.water_drop_outlined
                            : Icons.swap_horiz,
                    active: market.isActive(stage),
                  ),
                ),
            ],
          ),
          if (data['dropRun'] is Map) ...[
            const SizedBox(height: 12),
            _DropRunSummary(
              raw: Map<String, dynamic>.from(data['dropRun'] as Map),
            ),
          ],
          if (data['liquidityRun'] is Map) ...[
            const SizedBox(height: 10),
            _MarketRunSummary(
              icon: Icons.water_drop_rounded,
              label: 'LIQUIDITY',
              raw: Map<String, dynamic>.from(data['liquidityRun'] as Map),
            ),
          ],
          if (data['swapRun'] is Map) ...[
            const SizedBox(height: 10),
            _MarketRunSummary(
              icon: Icons.swap_horiz_rounded,
              label: 'SWAP',
              raw: Map<String, dynamic>.from(data['swapRun'] as Map),
            ),
          ],
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.route_outlined,
            title: 'ON-CHAIN CONNECTION',
            body:
                deployed
                    ? '테스트넷 배포 완료 · 활성화된 Utility 단계에 실제 전송/보상/사용 이력 모듈을 순차 연결할 수 있습니다.'
                    : '테스트넷 배포 전에도 Utility 설계는 가능하며, 실제 전송 기능은 배포 후 연결합니다.',
          ),
          if (isOwner) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onConfigure,
                icon: Icon(
                  progress.isComplete
                      ? Icons.check_circle_outline
                      : Icons.lock_open_outlined,
                ),
                label: Text(
                  progress.isComplete
                      ? 'Token Use 단계 확인'
                      : '${progress.next!.label} 활성화',
                ),
              ),
            ),
            if (progress.isComplete && market.next != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => onStartMarketStage?.call(market.next!),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    market.next == TokenMarketStage.drops
                        ? 'DROPS 실행'
                        : market.next == TokenMarketStage.liquidity
                        ? 'LIQUIDITY 실행'
                        : 'SWAP 실행',
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DropRunSummary extends StatelessWidget {
  const _DropRunSummary({required this.raw});
  final Map<String, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    final status = (raw['status'] ?? '').toString().toUpperCase();
    final completed = (raw['completedCount'] as num?)?.toInt() ?? 0;
    final total = (raw['recipientCount'] as num?)?.toInt() ?? completed;
    final transfers = raw['transfers'];
    final txCount = transfers is List ? transfers.length : completed;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: LaunchPalette.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard_rounded, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'DROPS $status · $completed/$total 전송 · Tx $txCount건 기록',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketRunSummary extends StatelessWidget {
  const _MarketRunSummary({
    required this.icon,
    required this.label,
    required this.raw,
  });
  final IconData icon;
  final String label;
  final Map<String, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    final status = (raw['status'] ?? '').toString().toUpperCase();
    final tx = (raw['liquidityTxHash'] ?? raw['txHash'] ?? '').toString();
    final router = (raw['routerAddress'] ?? '').toString();
    String short(String v) =>
        v.length <= 14
            ? v
            : '${v.substring(0, 8)}…${v.substring(v.length - 6)}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: LaunchPalette.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label $status${tx.isNotEmpty ? ' · Tx ${short(tx)}' : ''}${router.isNotEmpty ? ' · Router ${short(router)}' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenUseStageRow extends StatelessWidget {
  const _TokenUseStageRow({
    required this.stage,
    required this.progress,
    required this.configured,
    this.onManage,
  });

  final TokenUseStage stage;
  final TokenUseProgress progress;
  final bool configured;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final active = progress.isActive(stage);
    final next = progress.isNext(stage);
    final icon =
        active
            ? Icons.check_circle_rounded
            : next
            ? Icons.radio_button_checked_rounded
            : Icons.lock_outline_rounded;
    final state =
        active
            ? 'ACTIVE'
            : next
            ? 'NEXT'
            : 'LOCKED';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: active ? LaunchPalette.text : LaunchPalette.muted,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stage.label}  ·  $state',
                style: TextStyle(
                  color: active ? LaunchPalette.text : LaunchPalette.muted,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                stage.shortDescription,
                style: const TextStyle(color: LaunchPalette.muted, height: 1.4),
              ),
              if (active) ...[
                const SizedBox(height: 5),
                Text(
                  configured ? '운영 설정 저장됨' : '운영 설정 필요',
                  style: TextStyle(
                    color:
                        configured ? LaunchPalette.cyan : LaunchPalette.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (onManage != null) ...[
                  const SizedBox(height: 7),
                  OutlinedButton.icon(
                    onPressed: onManage,
                    icon: const Icon(Icons.settings_outlined, size: 16),
                    label: Text(configured ? '운영 설정 수정' : '운영 설정'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketStrip extends StatelessWidget {
  const _MarketStrip({required this.data, required this.totalSupply});

  final Map<String, dynamic> data;
  final dynamic totalSupply;

  @override
  Widget build(BuildContext context) {
    final price = data['price'];
    final change = data['priceChange24h'];
    final holders = data['holders'] ?? 0;
    final volume = data['volume24h'];
    final marketCap = data['marketCap'];
    final contract = (data['contractAddress'] ?? '').toString();

    return LaunchGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Metric(label: 'PRICE', value: _value(price)),
              _Metric(label: '24H', value: _percent(change)),
              _Metric(label: 'HOLDERS', value: '$holders'),
              _Metric(label: 'VOLUME', value: _value(volume)),
              _Metric(label: 'M.CAP', value: _value(marketCap)),
              _Metric(label: 'SUPPLY', value: _value(totalSupply)),
            ],
          ),
          if (contract.isEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              '실제 테스트넷 배포 및 시장 연결 전에는 가격·거래량 데이터가 “—”로 표시됩니다.',
              style: TextStyle(
                color: LaunchPalette.muted,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _value(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '—';
    return value.toString();
  }

  static String _percent(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '—';
    final n = num.tryParse(value.toString());
    if (n == null) return value.toString();
    return '${n >= 0 ? '+' : ''}$n%';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LaunchPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: LaunchPalette.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: LaunchPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.body,
    this.copyValue,
    this.copyMessage = '복사했습니다.',
  });

  final IconData icon;
  final String title;
  final String body;
  final String? copyValue;
  final String copyMessage;

  @override
  Widget build(BuildContext context) {
    final canCopy = (copyValue ?? '').trim().isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: LaunchPalette.purple.withOpacity(.14),
          ),
          child: Icon(icon, color: LaunchPalette.cyan, size: 21),
        ),
        const SizedBox(width: 13),
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
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SelectableText(
                      body,
                      style: const TextStyle(
                        color: LaunchPalette.muted,
                        height: 1.45,
                      ),
                    ),
                  ),
                  if (canCopy) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: '복사',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: copyValue!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(copyMessage)),
                        );
                      },
                      icon: const Icon(
                        Icons.copy_rounded,
                        size: 19,
                        color: LaunchPalette.cyan,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialLink {
  _SocialLink(this.name, this.icon, dynamic rawUrl)
    : url = (rawUrl ?? '').toString().trim();

  final String name;
  final IconData icon;
  final String url;
}
