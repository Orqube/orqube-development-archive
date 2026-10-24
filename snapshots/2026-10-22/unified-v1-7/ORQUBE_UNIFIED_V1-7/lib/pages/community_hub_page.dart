import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/moderation_service.dart';
import '../utils/orqube_i18n.dart';
import '../services/social_service.dart';
import 'airsoft_page.dart';
import 'chat_page.dart';
import 'notification_center_page.dart';
import 'social_hub_page.dart';

class CommunityHubPage extends StatefulWidget {
  const CommunityHubPage({super.key});

  @override
  State<CommunityHubPage> createState() => _CommunityHubPageState();
}

class _CommunityHubPageState extends State<CommunityHubPage> {
  static const _background = Color(0xFF050510);
  static const _panel = Color(0xFF10101D);
  static const _purple = Color(0xFF8B2CF6);
  static const _lime = Color(0xFFD7FF35);

  final TextEditingController _searchController = TextEditingController();
  String _category = '전체';
  String _sort = '최신순';
  String _searchText = '';

  static const _categories = <String>[
    '전체',
    '공지',
    '자유',
    'Airsoft',
    '장비',
    '중고장터',
    '팀 모집',
    '이벤트',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Query<Map<String, dynamic>> get _postQuery {
    return FirebaseFirestore.instance
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .limit(100);
  }

  Future<void> _openNewPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage(
        OrqubeI18n.currentPair(
          '게시글을 작성하려면 로그인이 필요합니다.',
          'Sign in to write a post.',
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PostEditorDialog(),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0B0B18),
        foregroundColor: Colors.white,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              OrqubeI18n.currentPair('ORQUBE 커뮤니티', 'ORQUBE COMMUNITY'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
              ),
            ),
            Text(
              OrqubeI18n.currentPair(
                '에어소프트 · 팀 · 글로벌 네트워크',
                'Airsoft · Team · Global Network',
              ),
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: OrqubeI18n.currentPair('알림', 'Notifications'),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationCenterPage(),
                  ),
                ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'community-write',
        onPressed: _openNewPost,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: const Text(
          '게시글 작성',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        color: _lime,
        backgroundColor: _panel,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              sliver: SliverToBoxAdapter(child: _buildQuickMenu()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              sliver: SliverToBoxAdapter(child: _buildBoardHeader()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              sliver: SliverToBoxAdapter(child: _buildSearch()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              sliver: SliverToBoxAdapter(child: _buildCategories()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
              sliver: SliverToBoxAdapter(child: _buildPostStream()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenu() {
    final items = <_QuickMenuItem>[
      _QuickMenuItem(
        icon: Icons.forum_rounded,
        title: OrqubeI18n.currentPair('국내 채팅', 'Korea Chat'),
        subtitle: OrqubeI18n.currentPair('한국어 실시간 채팅', 'Real-time Korean chat'),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ChatPage(
                      roomId: 'kr_general',
                      title: OrqubeI18n.currentPair('국내 채팅', 'Korea Chat'),
                    ),
              ),
            ),
      ),
      _QuickMenuItem(
        icon: Icons.public_rounded,
        title: OrqubeI18n.currentPair('글로벌 채팅', 'Global Chat'),
        subtitle: OrqubeI18n.currentPair(
          '영어 글로벌 채팅방',
          'English-only global room',
        ),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ChatPage(
                      roomId: 'global_en',
                      title: OrqubeI18n.currentPair('글로벌 채팅', 'Global Chat'),
                      englishOnly: true,
                    ),
              ),
            ),
      ),
      _QuickMenuItem(
        icon: Icons.sports_mma_rounded,
        title: OrqubeI18n.currentPair('에어소프트 팀 및 경기', 'Airsoft Team & Match'),
        subtitle: OrqubeI18n.currentPair(
          '팀 모집 · 경기 일정 · 참가 신청',
          'Team recruitment · schedules · applications',
        ),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AirsoftPage()),
            ),
      ),
      _QuickMenuItem(
        icon: Icons.people_alt_rounded,
        title: OrqubeI18n.currentPair('친구 및 활동', 'Friends & Activity'),
        subtitle: OrqubeI18n.currentPair(
          '친구 · 팔로우 · 사용자 활동',
          'Friends · follows · user activity',
        ),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SocialHubPage()),
            ),
      ),
    ];

    return Column(
      children:
          items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _HubCard(item: item),
                ),
              )
              .toList(),
    );
  }

  Widget _buildBoardHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                OrqubeI18n.currentPair('커뮤니티 게시판', 'COMMUNITY BOARD'),
                style: TextStyle(
                  color: _lime,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
              SizedBox(height: 3),
              Text(
                OrqubeI18n.currentPair(
                  '회원들과 소식과 경험을 공유하세요.',
                  'Share news and experiences with members.',
                ),
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: OrqubeI18n.currentPair('정렬', 'Sort'),
          initialValue: _sort,
          color: const Color(0xFF17172A),
          icon: const Icon(Icons.swap_vert_rounded, color: Colors.white70),
          onSelected: (value) => setState(() => _sort = value),
          itemBuilder:
              (_) => [
                PopupMenuItem(
                  value: '최신순',
                  child: Text(
                    OrqubeI18n.currentPair('최신순', 'Newest'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                PopupMenuItem(
                  value: '인기순',
                  child: Text(
                    OrqubeI18n.currentPair('인기순', 'Popular'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                PopupMenuItem(
                  value: '조회순',
                  child: Text(
                    OrqubeI18n.currentPair('조회순', 'Most viewed'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.search,
      onChanged: (value) => setState(() => _searchText = value.trim()),
      decoration: InputDecoration(
        hintText: OrqubeI18n.currentPair(
          '제목, 내용, 작성자 검색',
          'Search title, content or author',
        ),
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
        suffixIcon:
            _searchText.isEmpty
                ? null
                : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchText = '');
                  },
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                ),
        filled: true,
        fillColor: _panel,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _purple),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (_, index) {
          final category = _categories[index];
          final selected = category == _category;
          return ChoiceChip(
            selected: selected,
            onSelected: (_) => setState(() => _category = category),
            label: Text(category),
            labelStyle: TextStyle(
              color: selected ? const Color(0xFF171717) : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            selectedColor: _lime,
            backgroundColor: _panel,
            side: BorderSide(color: selected ? _lime : Colors.white12),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 6),
          );
        },
      ),
    );
  }

  Widget _buildPostStream() {
    return FutureBuilder<Set<String>>(
      future: ModerationService.instance.blockedUserIds(),
      builder: (context, blockedSnapshot) {
        final blocked = blockedSnapshot.data ?? <String>{};
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _postQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorPanel(
                message: '게시판을 불러오지 못했습니다.\n${snapshot.error}',
                onRetry: () => setState(() {}),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(50),
                child: Center(child: CircularProgressIndicator(color: _lime)),
              );
            }

            var docs =
                snapshot.data?.docs.where((doc) {
                  final data = doc.data();
                  final uid = (data['uid'] ?? '').toString();
                  final status = (data['status'] ?? 'active').toString();
                  if (blocked.contains(uid) || status != 'active') return false;

                  final category = (data['category'] ?? '자유').toString();
                  if (_category != '전체' && category != _category) {
                    return false;
                  }

                  if (_searchText.isNotEmpty) {
                    final keyword = _searchText.toLowerCase();
                    final searchable =
                        [
                          data['title'],
                          data['body'],
                          data['authorName'],
                          data['category'],
                        ].join(' ').toLowerCase();
                    if (!searchable.contains(keyword)) return false;
                  }
                  return true;
                }).toList() ??
                <QueryDocumentSnapshot<Map<String, dynamic>>>[];

            if (_sort == '인기순') {
              docs.sort((a, b) {
                final aScore =
                    _number(a.data()['likeCount']) * 3 +
                    _number(a.data()['commentCount']) * 2 +
                    _number(a.data()['viewCount']);
                final bScore =
                    _number(b.data()['likeCount']) * 3 +
                    _number(b.data()['commentCount']) * 2 +
                    _number(b.data()['viewCount']);
                return bScore.compareTo(aScore);
              });
            } else if (_sort == '조회순') {
              docs.sort(
                (a, b) => _number(
                  b.data()['viewCount'],
                ).compareTo(_number(a.data()['viewCount'])),
              );
            }

            if (docs.isEmpty) {
              return _EmptyBoard(onWrite: _openNewPost);
            }

            return Column(
              children:
                  docs
                      .map(
                        (doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PostCard(
                            postId: doc.id,
                            data: doc.data(),
                            onChanged: () => setState(() {}),
                          ),
                        ),
                      )
                      .toList(),
            );
          },
        );
      },
    );
  }

  static int _number(dynamic value) => value is num ? value.toInt() : 0;
}

class _QuickMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _HubCard extends StatelessWidget {
  final _QuickMenuItem item;

  const _HubCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111120),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0x338B2CF6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(item.icon, color: const Color(0xFFD7FF35)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  const _PostCard({
    required this.postId,
    required this.data,
    required this.onChanged,
  });

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _PostDetailPage(postId: postId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = (data['category'] ?? '자유').toString();
    final title = (data['title'] ?? '').toString();
    final body = (data['body'] ?? '').toString();
    final author = (data['authorName'] ?? 'ORQUBE User').toString();
    final uid = (data['uid'] ?? '').toString();
    final createdAt = data['createdAt'];
    final mine = FirebaseAuth.instance.currentUser?.uid == uid;

    return Material(
      color: const Color(0xFF10101D),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 14, 10, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryBadge(category: category),
                const Spacer(),
                Text(
                  _formatTimestamp(createdAt),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                PopupMenuButton<String>(
                  color: const Color(0xFF19192B),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (_) => _PostEditorDialog(
                              postId: postId,
                              initialData: data,
                            ),
                      );
                    } else if (value == 'delete') {
                      await _deletePost(context, postId);
                    } else if (value == 'report') {
                      await _reportPost(context, postId, uid);
                    } else if (value == 'block') {
                      await ModerationService.instance.blockUser(uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('해당 사용자를 차단했습니다.')),
                        );
                      }
                      onChanged();
                    }
                  },
                  itemBuilder:
                      (_) => [
                        if (mine)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              '수정',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        if (mine)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              '삭제',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        if (!mine)
                          const PopupMenuItem(
                            value: 'report',
                            child: Text(
                              '신고',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        if (!mine && uid.isNotEmpty)
                          const PopupMenuItem(
                            value: 'block',
                            child: Text(
                              '사용자 차단',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                ),
              ],
            ),
            // 제목·본문을 눌렀을 때만 상세 화면으로 이동합니다.
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openDetail(context),
              child: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.45,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openDetail(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 13,
                          backgroundColor: Color(0x338B2CF6),
                          child: Icon(
                            Icons.person_rounded,
                            size: 15,
                            color: Color(0xFFD7FF35),
                          ),
                        ),
                        const SizedBox(width: 7),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 125),
                          child: Text(
                            author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // 하트는 좋아요만 처리하며 상세 화면으로 이동하지 않습니다.
                _CardLikeButton(
                  postId: postId,
                  likeCount: _asInt(data['likeCount']),
                ),
                const SizedBox(width: 8),
                // 댓글 아이콘을 눌렀을 때만 상세/댓글 화면으로 이동합니다.
                _CommentButton(
                  count: _asInt(data['commentCount']),
                  onTap: () => _openDetail(context),
                ),
                const SizedBox(width: 8),
                _Stat(
                  icon: Icons.visibility_outlined,
                  value: _asInt(data['viewCount']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static int _asInt(dynamic value) => value is num ? value.toInt() : 0;
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final isNotice = category == '공지';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isNotice ? const Color(0x33D7FF35) : const Color(0x338B2CF6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isNotice ? const Color(0x66D7FF35) : const Color(0x668B2CF6),
        ),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: isNotice ? const Color(0xFFD7FF35) : Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CardLikeButton extends StatelessWidget {
  final String postId;
  final int likeCount;

  const _CardLikeButton({required this.postId, required this.likeCount});

  Future<void> _toggleLike(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    final postRef = FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId);
    final likeRef = postRef.collection('likes').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final likeSnapshot = await transaction.get(likeRef);
        if (likeSnapshot.exists) {
          transaction.delete(likeRef);
          final current = _asInt(postSnapshot.data()?['likeCount']);
          transaction.update(postRef, {
            'likeCount': current > 0 ? FieldValue.increment(-1) : 0,
          });
        } else {
          transaction.set(likeRef, {
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
          transaction.update(postRef, {'likeCount': FieldValue.increment(1)});
        }
      });
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 처리 실패: ${error.message ?? error.code}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final likeStream =
        user == null
            ? null
            : FirebaseFirestore.instance
                .collection('community_posts')
                .doc(postId)
                .collection('likes')
                .doc(user.uid)
                .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: likeStream,
      builder: (context, snapshot) {
        final liked = snapshot.data?.exists ?? false;
        return InkResponse(
          radius: 22,
          containedInkWell: true,
          onTap: () => _toggleLike(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 17,
                  color: liked ? const Color(0xFFD7FF35) : Colors.white54,
                ),
                const SizedBox(width: 4),
                Text(
                  '$likeCount',
                  style: TextStyle(
                    color: liked ? const Color(0xFFD7FF35) : Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static int _asInt(dynamic value) => value is num ? value.toInt() : 0;
}

class _CommentButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _CommentButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 22,
      containedInkWell: true,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 17,
              color: Colors.white54,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final int value;

  const _Stat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.white38),
        const SizedBox(width: 3),
        Text(
          '$value',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}

class _PostEditorDialog extends StatefulWidget {
  final String? postId;
  final Map<String, dynamic>? initialData;

  const _PostEditorDialog({this.postId, this.initialData});

  @override
  State<_PostEditorDialog> createState() => _PostEditorDialogState();
}

class _PostEditorDialogState extends State<_PostEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late String _category;
  bool _saving = false;

  static const _categories = <String>[
    '공지',
    '자유',
    'Airsoft',
    '장비',
    '중고장터',
    '팀 모집',
    '이벤트',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: (widget.initialData?['title'] ?? '').toString(),
    );
    _bodyController = TextEditingController(
      text: (widget.initialData?['body'] ?? '').toString(),
    );
    final initialCategory =
        (widget.initialData?['category'] ?? '자유').toString();
    _category = _categories.contains(initialCategory) ? initialCategory : '자유';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _message('로그인이 필요합니다.');
      return;
    }

    final title = ModerationService.instance.inspect(_titleController.text);
    final body = ModerationService.instance.inspect(_bodyController.text);

    if (_titleController.text.trim().length < 2) {
      _message('제목을 2자 이상 입력해 주세요.');
      return;
    }
    if (_bodyController.text.trim().length < 2) {
      _message('내용을 2자 이상 입력해 주세요.');
      return;
    }
    if (!title.allowed || !body.allowed) {
      _message(title.reason ?? body.reason ?? '등록할 수 없는 표현이 있습니다.');
      return;
    }

    setState(() => _saving = true);
    try {
      final db = FirebaseFirestore.instance;
      if (widget.postId == null) {
        final profile = await db.collection('users').doc(user.uid).get();
        final profileData = profile.data() ?? <String, dynamic>{};
        final authorName =
            (profileData['nickname'] ?? user.displayName ?? 'ORQUBE User')
                .toString();
        final authorPhotoUrl =
            (profileData['profileImageUrl'] ?? user.photoURL ?? '').toString();

        // community_posts와 ORQUBE NEWS가 같은 게시글 ID를 사용하도록
        // 문서 참조를 먼저 생성합니다. 공지인 경우 두 컬렉션에 원자적으로
        // 함께 저장되어 채굴화면 ORQUBE NEWS에서 바로 읽을 수 있습니다.
        final postRef = db.collection('community_posts').doc();
        final batch = db.batch();

        batch.set(postRef, {
          'uid': user.uid,
          'authorName': authorName,
          'authorPhotoUrl': authorPhotoUrl,
          'title': title.sanitized,
          'body': body.sanitized,
          'category': _category,
          'likeCount': 0,
          'commentCount': 0,
          'viewCount': 0,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (_category == '공지' || _category == '이벤트' || _category == 'Airsoft') {
          final newsRef = db.collection('orqube_news').doc(postRef.id);
          batch.set(newsRef, {
            'title': title.sanitized,
            'content': body.sanitized,
            'body': body.sanitized,
            'category': _category,
            'type': _category == '공지'
                ? 'notice'
                : (_category == '이벤트' ? 'event' : 'airsoft'),
            'isActive': true,
            'published': true,
            'visible': true,
            'isPinned': false,
            'status': 'active',
            'createdAt': FieldValue.serverTimestamp(),
            'publishedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'createdBy': user.uid,
            'authorUid': user.uid,
            'authorName': authorName,
            'source': 'community_posts',
            'sourcePostId': postRef.id,
          });
        }

        await batch.commit();

        await SocialService.instance.writeActivity(
          type: 'community_post',
          title: '커뮤니티 게시글 작성',
          description: title.sanitized,
          targetId: postRef.id,
          metadata: {'category': _category},
        );
      } else {
        final postRef = db.collection('community_posts').doc(widget.postId);
        final newsRef = db.collection('orqube_news').doc(widget.postId);
        final previousCategory =
            (widget.initialData?['category'] ?? '').toString();
        final authorName =
            (widget.initialData?['authorName'] ??
                    user.displayName ??
                    'ORQUBE User')
                .toString();
        final batch = db.batch();

        batch.update(postRef, {
          'title': title.sanitized,
          'body': body.sanitized,
          'category': _category,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (_category == '공지' || _category == '이벤트' || _category == 'Airsoft') {
          batch.set(
            newsRef,
            {
              'title': title.sanitized,
              'content': body.sanitized,
              'body': body.sanitized,
              'category': _category,
              'type': _category == '공지'
                  ? 'notice'
                  : (_category == '이벤트' ? 'event' : 'airsoft'),
              'isActive': true,
              'published': true,
              'visible': true,
              'isPinned': false,
              'status': 'active',
              'updatedAt': FieldValue.serverTimestamp(),
              'createdBy': user.uid,
              'authorUid': user.uid,
              'authorName': authorName,
              'source': 'community_posts',
              'sourcePostId': widget.postId,
              if (previousCategory != '공지' &&
                  previousCategory != '이벤트' &&
                  previousCategory != 'Airsoft')
                'createdAt': FieldValue.serverTimestamp(),
              if (previousCategory != '공지' &&
                  previousCategory != '이벤트' &&
                  previousCategory != 'Airsoft')
                'publishedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } else if (previousCategory == '공지' ||
            previousCategory == '이벤트' ||
            previousCategory == 'Airsoft') {
          // NEWS 대상 카테고리에서 일반 게시글로 변경하면 이 게시글이 만든 NEWS 문서만 제거합니다.
          batch.delete(newsRef);
        }

        await batch.commit();
      }

      if (mounted) Navigator.pop(context);
    } on FirebaseException catch (error) {
      _message('저장 실패: ${error.message ?? error.code}');
    } catch (error) {
      _message('저장 중 오류가 발생했습니다: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111120),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        widget.postId == null ? '새 게시글' : '게시글 수정',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _category,
                dropdownColor: const Color(0xFF19192B),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('게시판'),
                items:
                    _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                maxLength: 80,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('제목'),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _bodyController,
                minLines: 6,
                maxLines: 12,
                maxLength: 3000,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('내용'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF8B2CF6),
          ),
          onPressed: _saving ? null : _save,
          icon:
              _saving
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.save_rounded),
          label: Text(_saving ? '저장 중' : '저장'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      counterStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF090914),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF8B2CF6)),
      ),
    );
  }
}

class _PostDetailPage extends StatefulWidget {
  final String postId;

  const _PostDetailPage({required this.postId});

  @override
  State<_PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<_PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _commentSaving = false;
  bool _viewCounted = false;

  DocumentReference<Map<String, dynamic>> get _postRef => FirebaseFirestore
      .instance
      .collection('community_posts')
      .doc(widget.postId);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _increaseView() async {
    if (_viewCounted) return;
    _viewCounted = true;
    try {
      await _postRef.update({'viewCount': FieldValue.increment(1)});
    } catch (_) {
      // 조회수 실패가 게시글 열람을 막지 않도록 무시합니다.
    }
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _message('로그인이 필요합니다.');
      return;
    }

    final likeRef = _postRef.collection('likes').doc(user.uid);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final like = await transaction.get(likeRef);
        final post = await transaction.get(_postRef);
        if (!post.exists) return;
        if (like.exists) {
          transaction.delete(likeRef);
          transaction.update(_postRef, {'likeCount': FieldValue.increment(-1)});
        } else {
          transaction.set(likeRef, {
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
          transaction.update(_postRef, {'likeCount': FieldValue.increment(1)});
        }
      });
    } on FirebaseException catch (error) {
      _message('좋아요 처리 실패: ${error.message ?? error.code}');
    }
  }

  Future<void> _addComment() async {
    if (_commentSaving) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _message('로그인이 필요합니다.');
      return;
    }

    final inspected = ModerationService.instance.inspect(
      _commentController.text,
    );
    if (_commentController.text.trim().length < 1) {
      _message('댓글을 입력해 주세요.');
      return;
    }
    if (!inspected.allowed) {
      _message(inspected.reason ?? '댓글을 등록할 수 없습니다.');
      return;
    }

    setState(() => _commentSaving = true);
    try {
      final db = FirebaseFirestore.instance;
      final profile = await db.collection('users').doc(user.uid).get();
      final data = profile.data() ?? <String, dynamic>{};
      final commentRef = _postRef.collection('comments').doc();

      final batch = db.batch();
      batch.set(commentRef, {
        'uid': user.uid,
        'authorName': data['nickname'] ?? user.displayName ?? 'ORQUBE User',
        'body': inspected.sanitized,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(_postRef, {'commentCount': FieldValue.increment(1)});
      await batch.commit();
      _commentController.clear();
    } on FirebaseException catch (error) {
      _message('댓글 등록 실패: ${error.message ?? error.code}');
    } finally {
      if (mounted) setState(() => _commentSaving = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      batch.delete(_postRef.collection('comments').doc(commentId));
      batch.update(_postRef, {'commentCount': FieldValue.increment(-1)});
      await batch.commit();
    } on FirebaseException catch (error) {
      _message('댓글 삭제 실패: ${error.message ?? error.code}');
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B18),
        foregroundColor: Colors.white,
        title: const Text('게시글', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _postRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD7FF35)),
            );
          }
          if (snapshot.hasError || !(snapshot.data?.exists ?? false)) {
            return const Center(
              child: Text(
                '게시글을 찾을 수 없습니다.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) => _increaseView());
          final data = snapshot.data!.data()!;
          final uid = (data['uid'] ?? '').toString();
          final mine = FirebaseAuth.instance.currentUser?.uid == uid;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10101D),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _CategoryBadge(
                                category: (data['category'] ?? '자유').toString(),
                              ),
                              const Spacer(),
                              Text(
                                _formatTimestamp(data['createdAt']),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            (data['title'] ?? '').toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              height: 1.3,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 15,
                                backgroundColor: Color(0x338B2CF6),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFFD7FF35),
                                  size: 17,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  (data['authorName'] ?? 'ORQUBE User')
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.visibility_outlined,
                                color: Colors.white38,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_asInt(data['viewCount'])}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28, color: Colors.white10),
                          SelectableText(
                            (data['body'] ?? '').toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.65,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              StreamBuilder<
                                DocumentSnapshot<Map<String, dynamic>>
                              >(
                                stream:
                                    FirebaseAuth.instance.currentUser == null
                                        ? null
                                        : _postRef
                                            .collection('likes')
                                            .doc(
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid,
                                            )
                                            .snapshots(),
                                builder: (_, likeSnapshot) {
                                  final liked =
                                      likeSnapshot.data?.exists ?? false;
                                  return OutlinedButton.icon(
                                    onPressed: _toggleLike,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          liked
                                              ? const Color(0xFFD7FF35)
                                              : Colors.white70,
                                      side: BorderSide(
                                        color:
                                            liked
                                                ? const Color(0xFFD7FF35)
                                                : Colors.white24,
                                      ),
                                    ),
                                    icon: Icon(
                                      liked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                    ),
                                    label: Text(
                                      '좋아요 ${_asInt(data['likeCount'])}',
                                    ),
                                  );
                                },
                              ),
                              const Spacer(),
                              if (mine)
                                TextButton.icon(
                                  onPressed: () async {
                                    await showDialog<void>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (_) => _PostEditorDialog(
                                            postId: widget.postId,
                                            initialData: data,
                                          ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('수정'),
                                )
                              else
                                TextButton.icon(
                                  onPressed:
                                      () => _reportPost(
                                        context,
                                        widget.postId,
                                        uid,
                                      ),
                                  icon: const Icon(Icons.flag_outlined),
                                  label: const Text('신고'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Text(
                          '댓글',
                          style: TextStyle(
                            color: Color(0xFFD7FF35),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_asInt(data['commentCount'])}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildComments(),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B0B18),
                    border: Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          minLines: 1,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '댓글을 입력하세요',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xFF151526),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _commentSaving ? null : _addComment,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF8B2CF6),
                          foregroundColor: Colors.white,
                        ),
                        icon:
                            _commentSaving
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildComments() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          _postRef
              .collection('comments')
              .orderBy('createdAt', descending: false)
              .limit(200)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            '댓글을 불러오지 못했습니다: ${snapshot.error}',
            style: const TextStyle(color: Colors.redAccent),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFFD7FF35)),
            ),
          );
        }
        final docs =
            snapshot.data?.docs.where((doc) {
              return (doc.data()['status'] ?? 'active') == 'active';
            }).toList() ??
            [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                '첫 댓글을 남겨보세요.',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          );
        }

        return Column(
          children:
              docs.map((doc) {
                final data = doc.data();
                final mine =
                    FirebaseAuth.instance.currentUser?.uid == data['uid'];
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10101D),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 13,
                        backgroundColor: Color(0x338B2CF6),
                        child: Icon(
                          Icons.person_rounded,
                          size: 15,
                          color: Color(0xFFD7FF35),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (data['authorName'] ?? 'ORQUBE User')
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTimestamp(data['createdAt']),
                                  style: const TextStyle(
                                    color: Colors.white30,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              (data['body'] ?? '').toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                height: 1.4,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (mine)
                        IconButton(
                          tooltip: '댓글 삭제',
                          onPressed: () => _deleteComment(doc.id),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.white38,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  static int _asInt(dynamic value) => value is num ? value.toInt() : 0;
}

class _EmptyBoard extends StatelessWidget {
  final VoidCallback onWrite;

  const _EmptyBoard({required this.onWrite});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 46),
      decoration: BoxDecoration(
        color: const Color(0xFF10101D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.forum_outlined, color: Colors.white24, size: 50),
          const SizedBox(height: 13),
          Text(
            OrqubeI18n.currentPair('표시할 게시글이 없습니다.', 'No posts to display.'),
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '오른쪽 아래 게시글 작성 버튼을 눌러 첫 이야기를 작성해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF10101D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.redAccent.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

Future<void> _deletePost(BuildContext context, String postId) async {
  final confirmed =
      await showDialog<bool>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              backgroundColor: const Color(0xFF111120),
              title: const Text(
                '게시글 삭제',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                '이 게시글을 삭제하시겠습니까?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('취소'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('삭제'),
                ),
              ],
            ),
      ) ??
      false;
  if (!confirmed) return;

  try {
    await FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId)
        .delete();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다.')));
    }
  } on FirebaseException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${error.message ?? error.code}')),
      );
    }
  }
}

Future<void> _reportPost(
  BuildContext context,
  String postId,
  String targetUid,
) async {
  try {
    await ModerationService.instance.report(
      targetType: 'post',
      targetId: postId,
      targetUid: targetUid,
      reason: '사용자 신고',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
    }
  } on StateError catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  } on FirebaseException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('신고 실패: ${error.message ?? error.code}')),
      );
    }
  }
}

String _formatTimestamp(dynamic value) {
  if (value is! Timestamp) return '방금 전';
  final date = value.toDate();
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return '방금 전';
  if (difference.inHours < 1) return '${difference.inMinutes}분 전';
  if (difference.inDays < 1) return '${difference.inHours}시간 전';
  if (difference.inDays < 7) return '${difference.inDays}일 전';
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}
