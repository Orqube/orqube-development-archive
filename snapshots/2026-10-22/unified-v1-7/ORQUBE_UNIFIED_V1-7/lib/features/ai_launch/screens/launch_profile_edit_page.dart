import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/launch_project.dart';
import '../services/launch_policy.dart';
import '../services/launch_repository.dart';
import '../widgets/launch_ui.dart';
import '../widgets/orqube_ai_assistant.dart';

class LaunchProfileEditPage extends StatefulWidget {
  const LaunchProfileEditPage({
    super.key,
    required this.projectId,
    required this.ownerUid,
  });

  final String projectId;
  final String ownerUid;

  @override
  State<LaunchProfileEditPage> createState() => _LaunchProfileEditPageState();
}

class _LaunchProfileEditPageState extends State<LaunchProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _symbol = TextEditingController();
  final _tagline = TextEditingController();
  final _description = TextEditingController();
  final _vision = TextEditingController();
  final _utility = TextEditingController();
  final _imageUrl = TextEditingController();
  final _coverImageUrl = TextEditingController();
  final _websiteUrl = TextEditingController();
  final _youtubeUrl = TextEditingController();
  final _instagramUrl = TextEditingController();
  final _facebookUrl = TextEditingController();
  final _xUrl = TextEditingController();

  bool _loaded = false;
  bool _saving = false;
  LaunchCategory _category = LaunchCategory.community;

  @override
  void dispose() {
    for (final c in [
      _name,
      _symbol,
      _tagline,
      _description,
      _vision,
      _utility,
      _imageUrl,
      _coverImageUrl,
      _websiteUrl,
      _youtubeUrl,
      _instagramUrl,
      _facebookUrl,
      _xUrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(Map<String, dynamic> data) {
    if (_loaded) return;
    _loaded = true;
    _category = LaunchPolicy.categoryFromRaw((data['category'] ?? '').toString());
    _name.text = (data['name'] ?? '').toString();
    _symbol.text = (data['symbol'] ?? '').toString();
    _tagline.text = (data['tagline'] ?? '').toString();
    _description.text = (data['description'] ?? '').toString();
    _vision.text = (data['vision'] ?? '').toString();
    _utility.text = (data['utility'] ?? '').toString();
    _imageUrl.text = (data['imageUrl'] ?? '').toString();
    _coverImageUrl.text = (data['coverImageUrl'] ?? '').toString();
    _websiteUrl.text = (data['websiteUrl'] ?? '').toString();
    _youtubeUrl.text = (data['youtubeUrl'] ?? '').toString();
    _instagramUrl.text = (data['instagramUrl'] ?? '').toString();
    _facebookUrl.text = (data['facebookUrl'] ?? '').toString();
    _xUrl.text = (data['xUrl'] ?? '').toString();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final policy = LaunchPolicy.evaluateTokenRequest(
      category: _category,
      name: _name.text,
      symbol: _symbol.text,
      text: '${_tagline.text} ${_description.text} ${_vision.text} ${_utility.text}',
    );
    if (!policy.allowed) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('저장할 수 없는 토큰 내용입니다'),
          content: Text(policy.message),
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

    setState(() => _saving = true);
    try {
      await LaunchRepository().updateProfile(
        projectId: widget.projectId,
        name: _name.text,
        symbol: _symbol.text,
        tagline: _tagline.text,
        description: _description.text,
        vision: _vision.text,
        utility: _utility.text,
        imageUrl: _imageUrl.text,
        coverImageUrl: _coverImageUrl.text,
        websiteUrl: _websiteUrl.text,
        youtubeUrl: _youtubeUrl.text,
        instagramUrl: _instagramUrl.text,
        facebookUrl: _facebookUrl.text,
        xUrl: _xUrl.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('launch_projects')
        .doc(widget.projectId)
        .snapshots();

    return LaunchBackground(
      floatingActionButton: OrqubeAiAssistantButton(
        screen: 'TOKEN PROFILE EDIT',
        projectId: widget.projectId,
      ),
      appBar: launchAppBar('토큰 프로필 편집'),
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

          _fill(data);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 44),
              children: [
                const LaunchSectionTitle(
                  title: 'TOKEN IDENTITY',
                  subtitle: '토큰의 이름·심볼·한 줄 가치와 로고를 정리합니다.',
                ),
                LaunchGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Token Name',
                          hintText: '예: Qubic Safety',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? '토큰 이름을 입력하세요.'
                            : null,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _symbol,
                        decoration: const InputDecoration(
                          labelText: 'Symbol',
                          prefixText: r'$',
                          hintText: 'QSAFE',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? '심볼을 입력하세요.'
                            : null,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _tagline,
                        maxLength: 80,
                        decoration: const InputDecoration(
                          labelText: '한 줄 가치',
                          hintText: '이 토큰이 무엇을 상징하는지 한 문장으로',
                        ),
                      ),
                      TextFormField(
                        controller: _description,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Token Story',
                          hintText: '왜 이 토큰을 만들었는지 설명하세요.',
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _imageUrl,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: '토큰 로고 이미지 URL',
                          hintText: 'https://...',
                          prefixIcon: Icon(Icons.token_outlined),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _coverImageUrl,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: '배경 이미지 URL (선택)',
                          hintText: 'https://...',
                          prefixIcon: Icon(Icons.landscape_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const LaunchSectionTitle(
                  title: 'TOKEN VALUE',
                  subtitle: '가격을 AI가 정하는 것이 아니라, 토큰이 담는 가치와 쓰임을 명확히 합니다.',
                ),
                LaunchGlassCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _vision,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: const InputDecoration(
                          labelText: 'VISION',
                          hintText: '이 토큰이 장기적으로 만들고 싶은 변화',
                        ),
                      ),
                      TextFormField(
                        controller: _utility,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'UTILITY',
                          hintText: '참여, 멤버십, 보상, 이벤트 등 실제 사용처',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const LaunchSectionTitle(
                  title: 'TOKEN LINKS',
                  subtitle: '공식 채널은 토큰 정보 아래의 보조 링크로 배치합니다.',
                ),
                LaunchGlassCard(
                  child: Column(
                    children: [
                      _socialField(
                        controller: _websiteUrl,
                        label: 'Website',
                        icon: Icons.language,
                      ),
                      _socialField(
                        controller: _youtubeUrl,
                        label: 'YouTube',
                        icon: Icons.play_circle_outline,
                      ),
                      _socialField(
                        controller: _instagramUrl,
                        label: 'Instagram',
                        icon: Icons.photo_camera_outlined,
                      ),
                      _socialField(
                        controller: _facebookUrl,
                        label: 'Facebook',
                        icon: Icons.people_outline,
                      ),
                      _socialField(
                        controller: _xUrl,
                        label: 'X',
                        icon: Icons.alternate_email,
                        bottomPadding: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const LaunchGlassCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome, color: LaunchPalette.cyan),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '다음 AI 단계에서는 “이런 토큰 만들어줘” 한 문장으로 이름·심볼·로고·VISION·UTILITY·소개문을 제안하도록 연결합니다.',
                          style: TextStyle(
                            color: LaunchPalette.muted,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_saving ? '저장 중...' : '토큰 프로필 저장'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _socialField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    double bottomPadding = 8,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'https://...',
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
