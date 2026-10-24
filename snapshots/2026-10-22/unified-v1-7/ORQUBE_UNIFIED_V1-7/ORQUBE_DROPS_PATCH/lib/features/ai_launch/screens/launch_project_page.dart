import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/launch_chain.dart';
import '../services/launch_deep_link.dart';
import '../services/launch_policy.dart';
import '../services/launch_repository.dart';
import '../services/launch_status_label.dart';
import '../services/launch_wallet_repository.dart';
import '../services/token_marketing_service.dart';
import '../services/token_deployment_service.dart';
import '../services/token_drop_service.dart';
import '../services/token_use_progress.dart';
import '../services/token_use_service.dart';
import '../widgets/launch_ui.dart';
import 'launch_profile_edit_page.dart';
import 'launch_wallet_page.dart';
import 'ai_marketing_approval_page.dart';

class LaunchProjectPage extends StatelessWidget {
  const LaunchProjectPage({
    super.key,
    required this.projectId,
    this.ownerUid = '',
  });

  final String projectId;
  final String ownerUid;

  String get inviteUrl => LaunchDeepLink.inviteUrl(projectId);

  @override
  Widget build(BuildContext context) {
    final stream =
        FirebaseFirestore.instance
            .collection('launch_projects')
            .doc(projectId)
            .snapshots();

    return LaunchBackground(
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
          final walletAddress = (data['walletAddress'] ?? '').toString();
          final externalMarketUrl =
              (data['externalMarketUrl'] ?? '').toString();
          final totalSupply = data['totalSupply'];
          final isOwner = ownerUid.isNotEmpty && ownerUid == data['ownerUid'];

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
              _TokenHeroCard(
                name: name,
                symbol: symbol,
                tagline: tagline,
                category: category,
                status: status,
                imageUrl: imageUrl,
                contractAddress: contractAddress,
                onShare: () => _invite(context),
                onEdit:
                    isOwner
                        ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => LaunchProfileEditPage(
                                    projectId: projectId,
                                    ownerUid: ownerUid,
                                  ),
                            ),
                          );
                        }
                        : null,
              ),
              const SizedBox(height: 14),
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
              const LaunchSectionTitle(
                title: 'TOKEN USE CENTER',
                subtitle: '단순 보유·가격 기대가 아니라 보상·멤버십·캠페인·유동성 준비로 실제 사용처를 설계합니다.',
              ),
              _TokenUseCenter(
                data: data,
                isOwner: isOwner,
                onConfigure: isOwner ? () => _configureTokenUse(context, data) : null,
                onManageStage: isOwner
                    ? (stage) => _manageTokenUseStage(context, data, stage)
                    : null,
                onStartMarketStage: isOwner
                    ? (stage) => stage == TokenMarketStage.drops
                        ? _runDrops(context, data)
                        : _startMarketStage(context, data, stage)
                    : null,
              ),
              const SizedBox(height: 18),
              LaunchSectionTitle(
                title: '${LaunchChainInfo.fromStored((data['chain'] ?? '').toString()).label} DEPLOYMENT',
                subtitle: '프로필 공개와 실제 온체인 배포를 분리해 안전하게 진행합니다.',
              ),
              LaunchGlassCard(
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Wallet',
                      body:
                          walletAddress.isEmpty
                              ? '미연결 · 다음 단계에서 새 지갑 만들기 / 기존 지갑 연결'
                              : walletAddress,
                    ),
                    const Divider(height: 26, color: LaunchPalette.line),
                    _InfoRow(
                      icon: Icons.token_outlined,
                      title: LaunchChainInfo.fromStored((data['chain'] ?? '').toString()) == LaunchChain.solana ? 'Solana Mint' : 'Contract',
                      body:
                          contractAddress.isEmpty
                              ? '미배포 · 사용자 최종 확인 후 TESTNET TOKEN 배포'
                              : contractAddress,
                    ),
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
                                    (_) => LaunchWalletPage(ownerUid: ownerUid),
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
                          label: const Text('ORBS로 Token Deploy 준비'),
                        ),
                      ),
                    ],
                  ],
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
              const LaunchSectionTitle(
                title: 'AI MARKETING',
                subtitle: 'TOKEN_FIT_SCORE · 국가 · 언어 · 플랫폼 · 홍보문을 생성해 승인 큐로 보냅니다.',
              ),
              LaunchGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _InfoRow(
                      icon: Icons.auto_awesome,
                      title: 'Human Approval Marketing',
                      body: 'AI 분석 → TOKEN_FIT_SCORE → 타깃 국가/언어/플랫폼 → 활용안/홍보문 → 승인 대기. 외부 자동게시와 유료광고는 OFF입니다.',
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

  Future<void> _configureTokenUse(BuildContext context, Map<String, dynamic> data) async {
    final progress = TokenUseProgress.fromData(data);
    final next = progress.next;

    if (next == null) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('TOKEN USE 단계 완료'),
          content: const Text(
            'REWARD → MEMBERSHIP → CAMPAIGN → LIQUIDITY READY가 모두 활성화되어 있습니다. '
            '다음 확장 단계는 DROPS → LIQUIDITY → SWAP 순서로 연결할 수 있도록 준비되어 있습니다.',
          ),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
          ],
        ),
      );
      return;
    }

    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${next.label} 활성화'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${progress.current.label}까지 활성화되어 있습니다.'),
              const SizedBox(height: 12),
              Text(next.description, style: const TextStyle(fontWeight: FontWeight.w700)),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('다음 단계 활성화')),
        ],
      ),
    );
    if (approved != true) return;

    final nextIndex = TokenUseStage.values.indexOf(next);
    await FirebaseFirestore.instance.collection('launch_projects').doc(projectId).set({
      // New cumulative progression fields.
      'utilityStageIndex': nextIndex,
      'utilityStage': next.id,
      'utilityStages': {
        for (var i = 0; i <= nextIndex; i++) TokenUseStage.values[i].id: true,
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

    final root = data['tokenUseConfig'];
    final configs = root is Map ? root : const {};
    final raw = configs[stage.id];
    final current = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

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
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: first, decoration: InputDecoration(labelText: firstLabel)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: second,
                    keyboardType: stage == TokenUseStage.liquidityReady
                        ? TextInputType.text
                        : const TextInputType.numberWithOptions(decimal: true),
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
                      onChanged: (value) => setLocalState(() => riskAccepted = value == true),
                      title: const Text('유동성·가격 변동·손실 가능성에 대한 위험고지를 확인했습니다.'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    '이 설정은 TOKEN USE CENTER 운영정보로 저장됩니다. 실제 온체인 전송·LP 생성·Swap은 별도 단계에서 사용자 최종 확인 후 연결됩니다.',
                    style: TextStyle(fontSize: 12, color: LaunchPalette.muted),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('취소')),
            FilledButton(
              onPressed: stage == TokenUseStage.liquidityReady && !riskAccepted
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${stage.label} 운영 설정을 저장했습니다.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TOKEN USE 설정 저장 실패: $e')),
      );
    } finally {
      first.dispose();
      second.dispose();
      third.dispose();
    }
  }

  Future<void> _runDrops(BuildContext context, Map<String, dynamic> data) async {
    final core = TokenUseProgress.fromData(data);
    final market = TokenMarketProgress.fromData(data);
    if (!core.isComplete || market.next != TokenMarketStage.drops) return;

    final chain = (data['chain'] ?? '').toString();
    if (chain != 'Kaia' && chain != 'Polygon') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 실제 DROPS 전송은 Kaia/Polygon EVM 테스트넷부터 지원합니다.')),
      );
      return;
    }
    if ((data['contractAddress'] ?? '').toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DROPS 실행 전에 테스트넷 토큰 배포를 완료해 주세요.')),
      );
      return;
    }

    final title = TextEditingController(text: 'ORQUBE TOKEN DROP');
    final recipients = TextEditingController();
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                  style: TextStyle(fontSize: 12, color: LaunchPalette.muted, height: 1.45),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('취소')),
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
        SnackBar(content: Text('${parsed.length}개 지갑 DROPS를 시작합니다. MetaMask 승인창을 확인해 주세요.')),
      );
      final result = await TokenDropService().execute(
        projectId: projectId,
        projectData: data,
        title: title.text,
        recipients: parsed,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('DROPS 완료 · ${result.transfers.length}건 전송 · DROPS ACTIVE')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('DROPS 실행 실패/중단: $e')),
      );
    } finally {
      title.dispose();
      recipients.dispose();
    }
  }

  Future<void> _startMarketStage(
    BuildContext context,
    Map<String, dynamic> data,
    TokenMarketStage stage,
  ) async {
    final core = TokenUseProgress.fromData(data);
    final market = TokenMarketProgress.fromData(data);
    if (!core.isComplete || market.next != stage) return;

    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${stage.label} 단계 준비'),
        content: Text(
          '${stage.description}\n\n'
          '이 패치에서는 단계 상태와 확장 게이트를 연결합니다. 실제 토큰 전송, LP 생성 또는 Swap 실행은 아직 자동 수행하지 않으며 다음 구현에서 별도 최종확인과 온체인 트랜잭션을 연결합니다.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('단계 준비 시작')),
        ],
      ),
    );
    if (approved != true) return;

    try {
      await TokenUseService().startMarketStage(projectId: projectId, stage: stage);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${stage.label} 확장 단계가 활성화되었습니다.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${stage.label} 단계 시작 실패: $e')),
      );
    }
  }

  Future<void> _startAiMarketing(BuildContext context) async {
    try {
      final result = await TokenMarketingService().start(projectId: projectId);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI Marketing 시작 실패: $e')));
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

  Future<void> _showDeploymentNext(
    BuildContext context,
    Map<String, dynamic> projectData,
  ) async {
    final walletRepo = LaunchWalletRepository();
    final account = await walletRepo.loadAccount(ownerUid);
    final config = await walletRepo.loadDeployConfig();

    final walletAddress = (account['walletAddress'] ?? '').toString();
    final chain = LaunchChainInfo.fromStored((account['chain'] ?? '').toString());
    final balance = LaunchWalletRepository.numberAsDouble(account['orbsBalance']);
    final deployFee = LaunchWalletRepository.numberAsDouble(config['deployFeeOrbs']);

    final category = LaunchPolicy.categoryFromRaw(
      (projectData['category'] ?? '').toString(),
    );
    final policy = LaunchPolicy.evaluateTokenRequest(
      category: category,
      name: (projectData['name'] ?? '').toString(),
      symbol: (projectData['symbol'] ?? '').toString(),
      text: "${projectData['tagline'] ?? ''} ${projectData['description'] ?? ''} ${projectData['vision'] ?? ''} ${projectData['utility'] ?? ''}",
    );

    if (!context.mounted) return;
    String? blockReason;
    if (!policy.allowed) {
      blockReason = policy.message;
    } else if (walletAddress.isEmpty) {
      blockReason = '먼저 배포할 체인의 지갑을 연결해 주세요.';
    } else if (deployFee <= 0) {
      blockReason = '관리자가 Token Deploy ORBS 비용을 아직 설정하지 않았습니다.';
    } else if (balance < deployFee) {
      blockReason = 'ORBS 잔액이 Token Deploy 비용보다 부족합니다.';
    }

    if (blockReason != null) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Token Deploy 준비 필요'),
          content: Text(blockReason!),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
            if (walletAddress.isEmpty || balance < deployFee)
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LaunchWalletPage(ownerUid: ownerUid)),
                  );
                },
                child: const Text('지갑 · ORBS 보기'),
              ),
          ],
        ),
      );
      return;
    }

    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('TESTNET DEPLOY'),
        content: Text(
          '${chain.label} · ${chain.testnetLabel}\n'
          'Wallet: ${_TokenHeroCard._shortAddress(walletAddress)}\n'
          'Supply: ${projectData['totalSupply'] ?? '-'}\n'
          'ORBS Policy Fee: ${deployFee.toStringAsFixed(4)} ORBS\n\n'
          '테스트넷 실제 배포를 실행합니다. 최종 네트워크 수수료는 연결된 지갑에서 확인·승인하며 개인키는 ORQUBE로 전송되지 않습니다.\n\n'
          '※ 현재 패치는 테스트넷 배포를 활성화하지만 ORBS 자동 차감은 별도 서버 결제 단계로 유지합니다.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
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
    messenger.showSnackBar(SnackBar(content: Text('${chain.label} ${chain.testnetLabel} 배포를 시작합니다. 지갑 승인창을 확인해 주세요.')));

    try {
      final deployData = Map<String, dynamic>.from(projectData)
        ..['walletAddress'] = walletAddress
        ..['chain'] = chain.key;
      final result = await TokenDeploymentService().deploy(
        projectId: projectId,
        ownerUid: ownerUid,
        projectData: deployData,
        chain: chain,
      );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('${result.chain} 테스트 배포 완료 · ${_TokenHeroCard._shortAddress(result.address)}')),
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

class _TokenHeroCard extends StatelessWidget {
  const _TokenHeroCard({
    required this.name,
    required this.symbol,
    required this.tagline,
    required this.category,
    required this.status,
    required this.imageUrl,
    required this.contractAddress,
    required this.onShare,
    this.onEdit,
  });

  final String name;
  final String symbol;
  final String tagline;
  final String category;
  final String status;
  final String imageUrl;
  final String contractAddress;
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
                        ? Center(
                          child: Text(
                            fallback,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
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
              configured: configs[TokenUseStage.values[i].id] is Map &&
                  configs[TokenUseStage.values[i].id]['configured'] == true,
              onManage: isOwner && progress.isActive(TokenUseStage.values[i])
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
                LaunchStatusPill(
                  label: '${stage.label}${market.isNext(stage) ? ' · NEXT' : ''}',
                  icon: stage == TokenMarketStage.drops
                      ? Icons.card_giftcard_outlined
                      : stage == TokenMarketStage.liquidity
                          ? Icons.water_drop_outlined
                          : Icons.swap_horiz,
                  active: market.isActive(stage),
                ),
            ],
          ),
          if (data['dropRun'] is Map) ...[
            const SizedBox(height: 12),
            _DropRunSummary(raw: Map<String, dynamic>.from(data['dropRun'] as Map)),
          ],
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.route_outlined,
            title: 'ON-CHAIN CONNECTION',
            body: deployed
                ? '테스트넷 배포 완료 · 활성화된 Utility 단계에 실제 전송/보상/사용 이력 모듈을 순차 연결할 수 있습니다.'
                : '테스트넷 배포 전에도 Utility 설계는 가능하며, 실제 전송 기능은 배포 후 연결합니다.',
          ),
          if (isOwner) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onConfigure,
                icon: Icon(progress.isComplete ? Icons.check_circle_outline : Icons.lock_open_outlined),
                label: Text(progress.isComplete ? 'Token Use 단계 확인' : '${progress.next!.label} 활성화'),
              ),
            ),
            if (progress.isComplete && market.next != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => onStartMarketStage?.call(market.next!),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(market.next == TokenMarketStage.drops ? 'DROPS 실행' : '${market.next!.label} 다음 단계 준비'),
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
    final icon = active
        ? Icons.check_circle_rounded
        : next
            ? Icons.radio_button_checked_rounded
            : Icons.lock_outline_rounded;
    final state = active ? 'ACTIVE' : next ? 'NEXT' : 'LOCKED';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: active ? LaunchPalette.text : LaunchPalette.muted, size: 22),
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
                    color: configured ? LaunchPalette.cyan : LaunchPalette.muted,
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
  const _InfoRow({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
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

class _SocialLink {
  _SocialLink(this.name, this.icon, dynamic rawUrl)
    : url = (rawUrl ?? '').toString().trim();

  final String name;
  final IconData icon;
  final String url;
}
