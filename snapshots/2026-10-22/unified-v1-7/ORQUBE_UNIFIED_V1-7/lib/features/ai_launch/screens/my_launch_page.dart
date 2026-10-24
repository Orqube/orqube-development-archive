import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/launch_policy.dart';
import '../services/launch_repository.dart';
import '../services/launch_status_label.dart';
import '../services/token_lifecycle_state.dart';
import '../widgets/launch_ui.dart';
import '../widgets/orqube_ai_assistant.dart';
import 'launch_profile_edit_page.dart';
import 'launch_project_page.dart';

class MyLaunchPage extends StatelessWidget {
  const MyLaunchPage({super.key, required this.ownerUid});

  final String ownerUid;

  @override
  Widget build(BuildContext context) {
    return LaunchBackground(
      floatingActionButton: const OrqubeAiAssistantButton(
        screen: 'MY TOKENS',
      ),
      appBar: launchAppBar('내 토큰 관리'),
      child: ownerUid.isEmpty
          ? const Center(
              child: Text(
                '로그인 후 내가 만든 토큰을 관리할 수 있습니다.',
                style: TextStyle(color: LaunchPalette.muted),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: LaunchRepository().watchMine(ownerUid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '불러오기 실패: ${snapshot.error}',
                      style: const TextStyle(color: LaunchPalette.muted),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = [...snapshot.data!.docs];
                docs.sort((a, b) {
                  final at = a.data()['updatedAt'];
                  final bt = b.data()['updatedAt'];
                  final am = at is Timestamp ? at.millisecondsSinceEpoch : 0;
                  final bm = bt is Timestamp ? bt.millisecondsSinceEpoch : 0;
                  return bm.compareTo(am);
                });

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      '아직 만든 토큰이 없습니다.',
                      style: TextStyle(color: LaunchPalette.muted),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 44),
                  children: [
                    const LaunchSectionTitle(
                      title: 'MY TOKENS',
                      subtitle: '토큰 편집 · 프로필 공개/비공개 · 보관 · Kaia 배포 상태를 한곳에서 관리합니다.',
                    ),
                    for (final doc in docs) ...[
                      _ProjectTile(
                        id: doc.id,
                        ownerUid: ownerUid,
                        data: doc.data(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
    required this.id,
    required this.ownerUid,
    required this.data,
  });

  final String id;
  final String ownerUid;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? '').toString();
    final symbol = (data['symbol'] ?? '').toString();
    final status = (data['status'] ?? 'draft').toString();
    final imageUrl = (data['imageUrl'] ?? '').toString();
    final contract = (data['contractAddress'] ?? '').toString();
    final lifecycle = TokenLifecycleState.label(data);

    return LaunchGlassCard(
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(name: name, imageUrl: imageUrl),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: LaunchPalette.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '\$$symbol · KAIA · $lifecycle',
                      style: const TextStyle(color: LaunchPalette.cyan),
                    ),
                  ],
                ),
              ),
              LaunchStatusPill(
                label: launchStatusLabel(status),
                active: launchStatusIsActive(status),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LaunchProjectPage(
                        projectId: id,
                        ownerUid: ownerUid,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new, size: 17),
                label: const Text('토큰 열기'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LaunchProfileEditPage(
                        projectId: id,
                        ownerUid: ownerUid,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('편집'),
              ),
              if (status == 'published')
                OutlinedButton.icon(
                  onPressed: () => LaunchRepository().makeDraft(id),
                  icon: const Icon(Icons.visibility_off_outlined, size: 17),
                  label: const Text('비공개'),
                )
              else if (status != 'archived')
                FilledButton.tonalIcon(
                  onPressed: () => _publish(context),
                  icon: const Icon(Icons.public, size: 17),
                  label: const Text('프로필 공개'),
                ),
              if (status == 'archived')
                OutlinedButton.icon(
                  onPressed: () => LaunchRepository().restore(id),
                  icon: const Icon(Icons.restore, size: 17),
                  label: const Text('복원'),
                )
              else
                OutlinedButton.icon(
                  onPressed: () => _archive(context),
                  icon: const Icon(Icons.archive_outlined, size: 17),
                  label: const Text('보관'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _publish(BuildContext context) async {
    final category = LaunchPolicy.categoryFromRaw((data['category'] ?? '').toString());
    final result = LaunchPolicy.evaluateTokenRequest(
      category: category,
      name: (data['name'] ?? '').toString(),
      symbol: (data['symbol'] ?? '').toString(),
      text: "${data['tagline'] ?? ''} ${data['description'] ?? ''} ${data['vision'] ?? ''} ${data['utility'] ?? ''}",
    );

    if (!result.allowed) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
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

    await LaunchRepository().publish(id);
  }

  Future<void> _archive(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('토큰 보관'),
        content: const Text(
          '즉시 영구삭제하지 않고 보관 상태로 전환합니다. 나중에 다시 복원할 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('보관'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await LaunchRepository().archive(id);
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.imageUrl});

  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [LaunchPalette.purple, LaunchPalette.blue],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? Center(
              child: Text(
                fallback,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
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
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
    );
  }
}
