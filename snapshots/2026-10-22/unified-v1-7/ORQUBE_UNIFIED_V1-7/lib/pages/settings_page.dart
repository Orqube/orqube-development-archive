import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'phone_sign_in_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color _bg = Color(0xFF03040B);
  static const Color _panel = Color(0xFF0A0B18);
  static const Color _panel2 = Color(0xFF111225);
  static const Color _purple = Color(0xFF8B2CF6);
  static const Color _lime = Color(0xFFD7FF35);

  bool _loading = true;
  bool _saving = false;

  bool _notificationsEnabled = true;
  bool _miningNotifications = true;
  bool _attendanceNotifications = true;
  bool _eventNotifications = true;
  bool _newsNotifications = true;
  bool _communityNotifications = true;

  bool _useNftProfile = true;
  bool _showWalletAddress = false;
  bool _showActivity = true;
  bool _showNftCollection = true;
  bool _allowFriendRequests = true;

  String _language = 'ko';
  String _themeMode = 'dark';
  String _profileVisibility = 'public';

  final _profileImageUrl = TextEditingController();

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _profileImageUrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = _user;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = snapshot.data() ?? <String, dynamic>{};

      _notificationsEnabled =
          _readBool(data['notificationsEnabled'], true);
      _miningNotifications =
          _readBool(data['miningNotifications'], true);
      _attendanceNotifications =
          _readBool(data['attendanceNotifications'], true);
      _eventNotifications = _readBool(data['eventNotifications'], true);
      _newsNotifications = _readBool(data['newsNotifications'], true);
      _communityNotifications =
          _readBool(data['communityNotifications'], true);

      _useNftProfile = _readBool(data['useNftProfile'], true);
      _showWalletAddress = _readBool(data['showWalletAddress'], false);
      _showActivity = _readBool(data['showActivity'], true);
      _showNftCollection = _readBool(data['showNftCollection'], true);
      _allowFriendRequests = _readBool(data['allowFriendRequests'], true);

      _language = _valid(
        data['language']?.toString(),
        const ['ko', 'en', 'ja', 'zh', 'fr', 'pt'],
        'ko',
      );
      _themeMode = _valid(
        data['themeMode']?.toString(),
        const ['dark', 'system'],
        'dark',
      );
      _profileVisibility = _valid(
        data['profileVisibility']?.toString(),
        const ['public', 'members', 'private'],
        'public',
      );
      _profileImageUrl.text =
          (data['profileImageUrl'] ?? data['photoUrl'] ?? user.photoURL ?? '')
              .toString();

      if (mounted) setState(() {});
    } catch (error) {
      _message('설정을 불러오지 못했습니다: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _readBool(dynamic value, bool fallback) {
    return value is bool ? value : fallback;
  }

  String _valid(String? value, List<String> allowed, String fallback) {
    return allowed.contains(value) ? value! : fallback;
  }

  Future<void> _save() async {
    if (_saving) return;
    final user = _user;

    if (user == null) {
      _message('로그인 정보를 확인할 수 없습니다.');
      return;
    }

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'notificationsEnabled': _notificationsEnabled,
        'miningNotifications': _miningNotifications,
        'attendanceNotifications': _attendanceNotifications,
        'eventNotifications': _eventNotifications,
        'newsNotifications': _newsNotifications,
        'communityNotifications': _communityNotifications,
        'useNftProfile': _useNftProfile,
        'profileImageUrl': _profileImageUrl.text.trim(),
        'showWalletAddress': _showWalletAddress,
        'showActivity': _showActivity,
        'showNftCollection': _showNftCollection,
        'allowFriendRequests': _allowFriendRequests,
        'language': _language,
        'themeMode': _themeMode,
        'profileVisibility': _profileVisibility,
        'settingsUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _message('설정이 저장되었습니다.');
    } catch (error) {
      _message('설정 저장에 실패했습니다: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await _confirm(
      title: '로그아웃',
      message: '현재 계정에서 로그아웃하시겠습니까?',
      confirmText: '로그아웃',
    );
    if (!confirmed) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      _message('로그아웃에 실패했습니다: $error');
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await _confirm(
      title: '설정 초기화',
      message: '알림과 공개 범위 설정을 기본값으로 되돌리시겠습니까?',
      confirmText: '초기화',
    );
    if (!confirmed) return;

    setState(() {
      _notificationsEnabled = true;
      _miningNotifications = true;
      _attendanceNotifications = true;
      _eventNotifications = true;
      _newsNotifications = true;
      _communityNotifications = true;
      _useNftProfile = true;
      _showWalletAddress = false;
      _showActivity = true;
      _showNftCollection = true;
      _allowFriendRequests = true;
      _language = 'ko';
      _themeMode = 'dark';
      _profileVisibility = 'public';
    });
    await _save();
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _panel2,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _purple),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _panel2,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _lime,
                    ),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      color: _lime,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _lime))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
              children: [
                _accountHeader(),
                const SizedBox(height: 14),
                _notificationSection(),
                const SizedBox(height: 14),
                _profileSection(),
                const SizedBox(height: 14),
                _languageSection(),
                const SizedBox(height: 14),
                _privacySection(),
                const SizedBox(height: 14),
                _accountSection(),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: Text(_saving ? '저장 중...' : '설정 저장'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _accountHeader() {
    final user = _user;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _box(highlight: true),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: _purple,
            backgroundImage:
                user?.photoURL == null ? null : NetworkImage(user!.photoURL!),
            child: user?.photoURL == null
                ? const Icon(Icons.person_rounded, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'ORQUBE USER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '로그인 정보 없음',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: _lime),
        ],
      ),
    );
  }

  Widget _notificationSection() {
    return _section(
      title: '알림 설정',
      icon: Icons.notifications_active_rounded,
      children: [
        _switch(
          title: '전체 알림',
          subtitle: 'ORQUBE의 모든 알림을 받습니다.',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
          },
        ),
        _divider(),
        _switch(
          title: '채굴 알림',
          subtitle: '24시간 채굴 종료와 재시작 알림',
          value: _miningNotifications,
          enabled: _notificationsEnabled,
          onChanged: (value) => setState(() => _miningNotifications = value),
        ),
        _switch(
          title: '출석 알림',
          subtitle: '매일 출석 및 연속 출석 보너스',
          value: _attendanceNotifications,
          enabled: _notificationsEnabled,
          onChanged: (value) =>
              setState(() => _attendanceNotifications = value),
        ),
        _switch(
          title: '이벤트 알림',
          subtitle: '일일·주간·군번줄 이벤트',
          value: _eventNotifications,
          enabled: _notificationsEnabled,
          onChanged: (value) => setState(() => _eventNotifications = value),
        ),
        _switch(
          title: '뉴스 알림',
          subtitle: '새로운 ORQUBE 뉴스와 보상 소식',
          value: _newsNotifications,
          enabled: _notificationsEnabled,
          onChanged: (value) => setState(() => _newsNotifications = value),
        ),
        _switch(
          title: '커뮤니티 알림',
          subtitle: '댓글, 좋아요, 친구 요청 알림',
          value: _communityNotifications,
          enabled: _notificationsEnabled,
          onChanged: (value) =>
              setState(() => _communityNotifications = value),
        ),
      ],
    );
  }

  Widget _profileSection() {
    return _section(
      title: '프로필 설정',
      icon: Icons.account_circle_rounded,
      children: [
        _switch(
          title: '대표 NFT 프로필',
          subtitle: '선택한 NFT를 프로필 이미지로 표시합니다.',
          value: _useNftProfile,
          onChanged: (value) => setState(() => _useNftProfile = value),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _profileImageUrl,
          style: const TextStyle(color: Colors.white),
          cursorColor: _lime,
          keyboardType: TextInputType.url,
          decoration: _input(
            '일반 프로필 이미지 URL',
            helper: 'NFT 프로필을 사용하지 않을 때 표시됩니다.',
          ),
        ),
      ],
    );
  }

  Widget _languageSection() {
    return _section(
      title: '언어 및 화면',
      icon: Icons.language_rounded,
      children: [
        _dropdown(
          label: '언어',
          value: _language,
          items: const {
            'ko': '한국어',
            'en': 'English',
            'ja': '日本語',
            'zh': '中文',
            'fr': 'Français',
            'pt': 'Português',
          },
          onChanged: (value) => setState(() => _language = value),
        ),
        const SizedBox(height: 12),
        _dropdown(
          label: '화면 테마',
          value: _themeMode,
          items: const {
            'dark': 'ORQUBE 다크',
            'system': '기기 설정 따르기',
          },
          onChanged: (value) => setState(() => _themeMode = value),
        ),
        const SizedBox(height: 8),
        const Text(
          '테마 값은 저장됩니다. 앱 전체 실시간 테마 전환은 '
          'MaterialApp의 ThemeMode 연결 단계에서 적용됩니다.',
          style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
        ),
      ],
    );
  }

  Widget _privacySection() {
    return _section(
      title: '개인정보 및 공개 범위',
      icon: Icons.privacy_tip_rounded,
      children: [
        _dropdown(
          label: '프로필 공개 범위',
          value: _profileVisibility,
          items: const {
            'public': '전체 공개',
            'members': 'ORQUBE 회원만',
            'private': '비공개',
          },
          onChanged: (value) =>
              setState(() => _profileVisibility = value),
        ),
        const SizedBox(height: 10),
        _switch(
          title: '지갑 주소 공개',
          subtitle: '프로필에서 Kaia 지갑 주소를 표시합니다.',
          value: _showWalletAddress,
          onChanged: (value) => setState(() => _showWalletAddress = value),
        ),
        _switch(
          title: '활동 내역 공개',
          subtitle: '출석, 채굴, 이벤트 활동 상태를 표시합니다.',
          value: _showActivity,
          onChanged: (value) => setState(() => _showActivity = value),
        ),
        _switch(
          title: 'NFT 컬렉션 공개',
          subtitle: '보유 NFT와 대표 NFT 정보를 표시합니다.',
          value: _showNftCollection,
          onChanged: (value) => setState(() => _showNftCollection = value),
        ),
        _switch(
          title: '친구 요청 허용',
          subtitle: '다른 회원의 친구 요청을 받을 수 있습니다.',
          value: _allowFriendRequests,
          onChanged: (value) =>
              setState(() => _allowFriendRequests = value),
        ),
      ],
    );
  }

  Future<void> _linkPhone() async {
    final current = _user;
    if (current == null || current.isAnonymous || !current.providerData.any(
        (provider) => provider.providerId == 'password' || provider.providerId == 'google.com')) {
      _message('기존 이메일 또는 Google 계정으로 먼저 로그인해 주세요.');
      return;
    }
    if (current.phoneNumber != null && current.phoneNumber!.isNotEmpty) {
      _message('이미 휴대폰 번호가 연결되어 있습니다.');
      return;
    }
    final uid = current.uid;
    final result = await showDialog<UserCredential>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PhoneSignInDialog(linkToCurrentUser: true),
    );
    if (!mounted || result == null) return;
    if (result.user?.uid == uid && FirebaseAuth.instance.currentUser?.uid == uid) {
      setState(() {});
      _message('휴대폰 번호가 기존 계정에 연결되었습니다. 이제 문자로 로그인할 수 있습니다.');
    } else {
      _message('계정 연결을 확인할 수 없습니다. 다시 로그인해 주세요.');
    }
  }

  Widget _accountSection() {
    return _section(
      title: '계정 관리',
      icon: Icons.admin_panel_settings_rounded,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.phone_android_rounded, color: _lime),
          title: const Text('휴대폰 번호 연결', style: TextStyle(color: Colors.white)),
          subtitle: Text(
            _user?.phoneNumber?.isNotEmpty == true
              ? '연결됨: ${_user!.phoneNumber}'
              : '기존 계정으로 로그인한 상태에서 문자 인증 후 연결',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          onTap: _linkPhone,
        ),
        _divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.restore_rounded, color: Colors.orangeAccent),
          title: const Text(
            '설정 초기화',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            '알림과 공개 범위를 기본값으로 되돌립니다.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          trailing:
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          onTap: _resetSettings,
        ),
        _divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.block_rounded, color: Colors.white54),
          title: const Text(
            '차단 사용자 관리',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            '차단 목록 화면은 커뮤니티 신고·차단 기능과 연결 예정입니다.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          trailing:
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          onTap: () => _message('차단 사용자 목록 기능을 준비 중입니다.'),
        ),
        _divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          title: const Text(
            '로그아웃',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w900,
            ),
          ),
          trailing:
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          onTap: _logout,
        ),
        _divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.person_remove_rounded,
            color: Colors.redAccent,
          ),
          title: const Text(
            '회원 탈퇴 안내',
            style: TextStyle(color: Colors.white70),
          ),
          subtitle: const Text(
            '실수 방지를 위해 현재는 계정을 자동 삭제하지 않습니다.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          trailing:
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          onTap: () => _message(
            '회원 탈퇴는 관리자 확인과 자산·보상 정산 절차를 거쳐야 합니다.',
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _lime, size: 20),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _switch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      activeColor: _lime,
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.white38,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled ? Colors.white54 : Colors.white24,
          fontSize: 11,
        ),
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: _panel2,
      iconEnabledColor: _lime,
      style: const TextStyle(color: Colors.white),
      decoration: _input(label),
      items: items.entries
          .map(
            (entry) => DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }

  InputDecoration _input(String label, {String? helper}) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      helperStyle: const TextStyle(color: Colors.white38, fontSize: 11),
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _purple, width: 1.4),
      ),
    );
  }

  Widget _divider() {
    return const Divider(color: Colors.white10, height: 8);
  }

  BoxDecoration _box({bool highlight = false}) {
    return BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: highlight ? _purple.withOpacity(.55) : Colors.white12,
      ),
      boxShadow: highlight
          ? [
              BoxShadow(
                color: _purple.withOpacity(.12),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ]
          : null,
    );
  }
}
