import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/social_service.dart';

class TeamCreatePage extends StatefulWidget {
  const TeamCreatePage({super.key});

  @override
  State<TeamCreatePage> createState() => _TeamCreatePageState();
}

class _TeamCreatePageState extends State<TeamCreatePage> {
  static const _background = Color(0xFF050510);
  static const _panel = Color(0xFF111120);
  static const _purple = Color(0xFF8B2CF6);
  static const _lime = Color(0xFFD7FF35);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isSaving = false;
  bool _isRecruiting = true;
  String _playStyle = '종합';

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 후 팀을 등록할 수 있습니다.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = FirebaseFirestore.instance;
      final teamRef = db.collection('airsoft_teams').doc();
      final userRef = db.collection('users').doc(user.uid);
      final now = FieldValue.serverTimestamp();

      final batch = db.batch();
      batch.set(teamRef, {
        'name': _nameController.text.trim(),
        'region': _regionController.text.trim(),
        'location': _regionController.text.trim(),
        'description': _descriptionController.text.trim(),
        'contact': _contactController.text.trim(),
        'playStyle': _playStyle,
        'isRecruiting': _isRecruiting,
        'ownerUid': user.uid,
        'ownerEmail': user.email,
        'ownerName': user.displayName ?? 'ORQUBE User',
        'memberCount': 1,
        'status': 'active',
        'createdAt': now,
        'updatedAt': now,
      });
      batch.set(teamRef.collection('members').doc(user.uid), {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? 'ORQUBE User',
        'role': 'leader',
        'status': 'active',
        'joinedAt': now,
      });
      batch.set(userRef, {
        'airsoftTeamId': teamRef.id,
        'airsoftTeamName': _nameController.text.trim(),
        'airsoftTeamRole': 'leader',
        'updatedAt': now,
      }, SetOptions(merge: true));

      await batch.commit();
      await SocialService.instance.writeActivity(
        type: 'team_created',
        title: '${_nameController.text.trim()} 팀 창설',
        targetId: teamRef.id,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('팀 등록이 완료되었습니다.')),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('팀 등록 실패: ${error.message ?? error.code}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('팀 등록 중 오류가 발생했습니다: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label을(를) 입력해주세요.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('팀 등록'),
        backgroundColor: const Color(0xFF0B0B18),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _purple.withOpacity(0.55)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.groups_rounded, color: _lime, size: 30),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ORQUBE AIRSOFT TEAM',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      '팀명과 활동 지역을 정확히 입력하세요. 등록한 사용자가 최초 팀장이 됩니다.',
                      style: TextStyle(color: Colors.white70, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _field(
                controller: _nameController,
                label: '팀명 *',
                hint: '예: ORQUBE PIONEERS',
                icon: Icons.shield_outlined,
                validator: (value) {
                  final required = _required(value, '팀명');
                  if (required != null) return required;
                  if (value!.trim().length < 2) return '팀명은 2자 이상 입력해주세요.';
                  if (value.trim().length > 30) return '팀명은 30자 이하로 입력해주세요.';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _field(
                controller: _regionController,
                label: '주요 활동 지역 *',
                hint: '예: 서울·경기 / 대전·충청',
                icon: Icons.location_on_outlined,
                validator: (value) => _required(value, '활동 지역'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _playStyle,
                dropdownColor: _panel,
                decoration: _decoration('활동 유형', Icons.sports_mma_outlined),
                items: const [
                  DropdownMenuItem(value: '종합', child: Text('종합')),
                  DropdownMenuItem(value: '밀심', child: Text('밀심 / 전술 중심')),
                  DropdownMenuItem(value: '스피드', child: Text('스피드 게임')),
                  DropdownMenuItem(value: '입문', child: Text('입문자 친화')),
                  DropdownMenuItem(value: '수집', child: Text('장비·컬렉션')),
                ],
                onChanged: (value) => setState(() => _playStyle = value ?? '종합'),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _contactController,
                label: '연락 방법',
                hint: '오픈채팅 링크 또는 연락용 이메일',
                icon: Icons.contact_mail_outlined,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _descriptionController,
                label: '팀 소개 *',
                hint: '팀 성격, 주요 활동, 가입 조건을 소개해주세요.',
                icon: Icons.description_outlined,
                maxLines: 5,
                validator: (value) {
                  final required = _required(value, '팀 소개');
                  if (required != null) return required;
                  if (value!.trim().length < 10) return '팀 소개는 10자 이상 입력해주세요.';
                  if (value.trim().length > 500) return '팀 소개는 500자 이하로 입력해주세요.';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                value: _isRecruiting,
                onChanged: (value) => setState(() => _isRecruiting = value),
                activeTrackColor: _purple,
                title: const Text('신규 팀원 모집', style: TextStyle(color: Colors.white)),
                subtitle: const Text(
                  '켜두면 팀 목록에 참가 신청 버튼이 표시됩니다.',
                  style: TextStyle(color: Colors.white54),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _createTeam,
                  style: FilledButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_circle_outline),
                  label: Text(_isSaving ? '등록 중...' : '팀 등록 완료'),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '실제 모임과 경기 운영 시 현지 법규, 경기장 안전수칙 및 보호장비 규정을 반드시 준수하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLines > 1 ? 500 : null,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label, icon).copyWith(hintText: hint),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: _lime),
      filled: true,
      fillColor: _panel,
      counterStyle: const TextStyle(color: Colors.white38),
      hintStyle: const TextStyle(color: Colors.white30),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF29293D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _purple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
