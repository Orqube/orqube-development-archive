import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/launch_repository.dart';
import '../services/launch_status_label.dart';
import '../widgets/launch_ui.dart';
import '../widgets/geometric_token_logo.dart';
import '../widgets/studio_shortcuts.dart';
import '../widgets/orqube_ai_assistant.dart';
import 'launch_create_wizard_page.dart';
import 'launch_project_page.dart';
import 'my_launch_page.dart';
import 'launch_wallet_page.dart';

class AiLaunchHomePage extends StatelessWidget {
  const AiLaunchHomePage({super.key, required this.ownerUid});

  final String ownerUid;

  @override
  Widget build(BuildContext context) {
    return LaunchBackground(
      floatingActionButton: const OrqubeAiAssistantButton(
        screen: 'TOKEN LAUNCH HOME',
      ),
      appBar: launchAppBar('ORQUBE TOKEN LAUNCH'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 44),
        children: [
          StudioShortcuts(ownerUid: ownerUid),
          const SizedBox(height: 14),
          LaunchGlassCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LaunchStatusPill(
                  label: 'CREATE · DEPLOY · LIVE',
                  icon: Icons.blur_on,
                  active: true,
                ),
                const SizedBox(height: 18),
                const Text(
                  '나의 가치를\n하나의 토큰으로',
                  style: TextStyle(
                    color: LaunchPalette.text,
                    fontSize: 30,
                    height: 1.16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '토큰의 이름·심볼·가치·유틸리티를 만들고, 지갑 확인 후 Kaia 공개 배포로 이어지는 TOKEN FIRST 구조입니다.',
                  style: TextStyle(
                    color: LaunchPalette.muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                LaunchCreateWizardPage(ownerUid: ownerUid),
                          ),
                        );
                      },
                      icon: const Icon(Icons.token_outlined),
                      label: const Text('새 토큰 만들기'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MyLaunchPage(ownerUid: ownerUid),
                          ),
                        );
                      },
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: const Text('내 토큰 관리'),
                    ),
                    OutlinedButton.icon(
                      onPressed: ownerUid.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LaunchWalletPage(ownerUid: ownerUid),
                                ),
                              );
                            },
                      icon: const Icon(Icons.blur_circular),
                      label: const Text('Kaia 지갑 · ORBS'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const LaunchSectionTitle(
            title: 'START · EARN · CREATE',
            subtitle: '처음 사용하는 분도 ORQUBE 흐름을 한눈에 이해할 수 있습니다.',
          ),
          const LaunchGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PolicyLine('① 신규 가입', '+1,000 P'),
                _PolicyLine('② Kaia 지갑 연결', '+10 Starter ORBS · 1회'),
                _PolicyLine('③ ORBS 채굴', '0.2 ORBS/시간 · 하루 최대 4.8'),
                _PolicyLine('④ AI 토큰 기획', '무료'),
                _PolicyLine('⑤ 기본 도형 로고', '무료 자동 생성 · 수정 가능'),
                _PolicyLine('⑥ PUBLIC TOKEN 생성', '50 ORBS'),
                _PolicyLine('⑦ Kairos Testnet 배포', '3 ORBS'),
                _PolicyLine('⑧ AI Marketing 기본', '100 ORBS · Human Approval'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const LaunchSectionTitle(
            title: 'LIVE TOKEN STREAM',
            subtitle: '사용자들이 만든 공개 토큰을 한눈에 보고 좌우로 넘겨보세요.',
          ),
          _PublishedTokenFeed(ownerUid: ownerUid),
          const SizedBox(height: 22),
          const LaunchSectionTitle(
            title: 'TOKEN FLOW',
            subtitle: '프로필이 목적이 아니라 토큰 Launch가 중심입니다.',
          ),
          const LaunchGlassCard(
            child: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                LaunchStatusPill(label: '1 · TOKEN IDEA', active: true),
                LaunchStatusPill(label: '2 · AI BUILD'),
                LaunchStatusPill(label: '3 · TOKEN PROFILE'),
                LaunchStatusPill(label: '4 · WALLET'),
                LaunchStatusPill(label: '5 · KAIA DEPLOY'),
                LaunchStatusPill(label: '6 · LIVE'),
                LaunchStatusPill(label: '7 · AI MARKETING'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const LaunchSectionTitle(
            title: 'TOKEN POLICY',
            subtitle: '셀프서비스 토큰 발행에서 제외되는 영역을 처음부터 명확하게 표시합니다.',
          ),
          const LaunchGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PolicyLine('정치 · 선거 · 정당 · 정치후원', '발행 불가'),
                _PolicyLine('공인/유명인 무단 토큰', '본인·권리 확인 전 발행 불가'),
                _PolicyLine('원금·수익·배당 보장형 투자 토큰', '발행 불가'),
                _PolicyLine('도박 · 베팅 · 승패 배당', '발행 불가'),
                _PolicyLine('불법 · 제재 대상 · 규제품목 거래', '발행 불가'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishedTokenFeed extends StatelessWidget {
  const _PublishedTokenFeed({required this.ownerUid});

  final String ownerUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: LaunchRepository().watchPublishedTokens(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const LaunchGlassCard(
            child: Text(
              '공개 토큰 목록 조회에 실패했습니다. 네트워크와 Firestore 읽기 권한을 확인해주세요.',
              style: TextStyle(color: LaunchPalette.muted),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const LaunchGlassCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const LaunchGlassCard(
            child: Text(
              '아직 공개된 토큰이 없습니다. 첫 토큰을 만들어 공개해 보세요.',
              style: TextStyle(color: LaunchPalette.muted),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = width >= 1180
                ? (width - 36) / 4
                : width >= 780
                    ? (width - 24) / 3
                    : width >= 520
                        ? (width - 12) / 2
                        : width * .82;

            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return SizedBox(
                    width: cardWidth,
                    child: _TokenCard(
                      id: doc.id,
                      data: doc.data(),
                      ownerUid: ownerUid,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({
    required this.id,
    required this.data,
    required this.ownerUid,
  });

  final String id;
  final Map<String, dynamic> data;
  final String ownerUid;

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? '').toString();
    final symbol = (data['symbol'] ?? '').toString();
    final status = (data['status'] ?? 'draft').toString();
    final contract = (data['contractAddress'] ?? '').toString();
    final holders = data['holders'] ?? 0;
    final price = data['price'];
    final change24h = data['priceChange24h'];
    final imageUrl = (data['imageUrl'] ?? '').toString();

    return LaunchGlassCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LaunchProjectPage(
              projectId: id,
              ownerUid: ownerUid,
            ),
          ),
        );
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              imageUrl.isEmpty
                  ? GeometricTokenLogo(symbol: symbol, spec: data['logoSpec'] is Map ? data['logoSpec'] as Map : null, size: 52)
                  : _TokenAvatar(name: name, imageUrl: imageUrl),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'UNTITLED TOKEN' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LaunchPalette.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      symbol.isEmpty ? 'KAIA TOKEN' : '\$$symbol · KAIA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LaunchPalette.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            price == null ? 'PRICE —' : 'PRICE $price',
            style: const TextStyle(
              color: LaunchPalette.text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            change24h == null ? '24H —' : '24H $change24h',
            style: const TextStyle(
              color: LaunchPalette.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'HOLDERS',
                  value: holders.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'CHAIN',
                  value: contract.isEmpty ? 'PRE-LAUNCH' : 'ON-CHAIN',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            launchStatusLabel(status),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: LaunchPalette.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: LaunchPalette.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: LaunchPalette.text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenAvatar extends StatelessWidget {
  const _TokenAvatar({required this.name, required this.imageUrl});

  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [LaunchPalette.purple, LaunchPalette.blue],
        ),
        border: Border.all(color: Colors.white.withOpacity(.14)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? Center(
              child: Text(
                fallback,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  fallback,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
    );
  }
}

class _PolicyLine extends StatelessWidget {
  const _PolicyLine(this.title, this.state);

  final String title;
  final String state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          const Icon(Icons.block, color: LaunchPalette.muted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: LaunchPalette.text),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            state,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: LaunchPalette.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
