import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'profile_photo_crop_page.dart';
import '../services/account_display_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'attendance_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _bg = Color(0xFF03040B);
  static const Color _panel = Color(0xFF0A0B18);
  static const Color _panel2 = Color(0xFF111225);
  static const Color _purple = Color(0xFF8B2CF6);
  static const Color _lime = Color(0xFFD7FF35);

  final _formKey = GlobalKey<FormState>();
  final _nickname = TextEditingController();
  final _bio = TextEditingController();
  final _country = TextEditingController(text: '대한민국');
  final _profileImageUrl = TextEditingController();

  String? _loadedUid;
  bool _photoBusy = false;
  bool _loading = true;
  bool _saving = false;
  bool _useNftProfile = true;
  Map<String, dynamic> _data = <String, dynamic>{};

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nickname.dispose();
    _bio.dispose();
    _country.dispose();
    _profileImageUrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _user;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = snapshot.data() ?? <String, dynamic>{};

      if (!mounted || _user?.uid != user.uid) return;
      _loadedUid = user.uid;
      _nickname.text = accountDisplayName(user, data);
      _bio.text = _text(data['bio']);
      _country.text = _text(data['country'], fallback: '대한민국');
      _profileImageUrl.text = _text(
        data['profileImageUrl'] ?? data['photoUrl'],
        fallback: user.photoURL ?? '',
      );
      _useNftProfile = _bool(data['useNftProfile'], fallback: true);

      if (mounted) setState(() => _data = data);
    } catch (error) {
      _message('프로필을 불러오지 못했습니다: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;

    final user = _user;
    if (user == null || user.uid != _loadedUid || _photoBusy) {
      _message('로그인 정보를 확인할 수 없습니다.');
      return;
    }

    setState(() => _saving = true);

    final values = <String, dynamic>{
      'nickname': _nickname.text.trim(),
      'bio': _bio.text.trim(),
      'country': _country.text.trim(),
      'email': user.email,
      'photoUrl': user.photoURL,
      'profileImageUrl': _profileImageUrl.text.trim(),
      'useNftProfile': _useNftProfile,
      'profileUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(values, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _data = <String, dynamic>{..._data, ...values};
        });
      }
      _message('프로필이 저장되었습니다.');
    } catch (error) {
      _message('프로필 저장에 실패했습니다: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _uploadPhoto() async {
    final user = _user;
    if (_saving || _photoBusy || user == null || user.uid != _loadedUid) return;
    setState(() => _photoBusy = true);
    Reference? uploaded;
    bool committed = false;
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true, allowMultiple: false,
      );
      if (picked == null) return;
      final file = picked.files.single;
      if (file.size > 15 * 1024 * 1024 || file.bytes == null) {
        throw StateError('15MB 이하 JPG/PNG/WebP 사진을 선택해주세요.');
      }
      if (!mounted || _user?.uid != user.uid) return;
      final bytes = await Navigator.of(context).push<Uint8List>(MaterialPageRoute(
        builder: (_) => ProfilePhotoCropPage(bytes: file.bytes!),
      ));
      if (bytes == null || !mounted || _user?.uid != user.uid) return;
      final path = 'profile_photos/${user.uid}/${DateTime.now().microsecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref(path);
      uploaded = ref;
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg', cacheControl: 'public,max-age=3600'));
      final url = await ref.getDownloadURL();
      if (_user?.uid != user.uid) throw StateError('계정이 변경되었습니다. 다시 로그인해주세요.');
      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final oldPath = await FirebaseFirestore.instance.runTransaction<String>((tx) async {
        final old = (await tx.get(doc)).data() ?? <String, dynamic>{};
        tx.set(doc, {
          'profileImageUrl': url, 'profilePhotoPath': path, 'useNftProfile': false,
          'profileUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return old['profilePhotoPath']?.toString() ?? '';
      });
      committed = true;
      if (mounted && _user?.uid == user.uid) {
        setState(() {
          _profileImageUrl.text = url;
          _useNftProfile = false;
          _data = {..._data, 'profileImageUrl': url, 'profilePhotoPath': path};
        });
        _message('사진이 저장되었습니다 (${(bytes.length / 1024).round()}KB).');
      }
      if (oldPath.startsWith('profile_photos/${user.uid}/') && oldPath != path) {
        try { await FirebaseStorage.instance.ref(oldPath).delete(); } catch (_) {
          _message('새 사진은 저장됐지만 이전 사진 정리에 실패했습니다.');
        }
      }
    } catch (error) {
      _message('사진 업로드에 실패했습니다: $error');
    } finally {
      if (!committed && uploaded != null) {
        try { await uploaded.delete(); } catch (_) {}
      }
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
    if (!mounted) return;
    setState(() => _loading = true);
    await _loadProfile();
  }

  void _openAttendance() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AttendancePage()));
  }

  void _copyWallet() {
    final wallet = _text(_data['walletAddress']);
    if (wallet.isEmpty) {
      _message('등록된 지갑 주소가 없습니다.');
      return;
    }
    Clipboard.setData(ClipboardData(text: wallet));
    _message('지갑 주소를 복사했습니다.');
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

  String _text(dynamic value, {String fallback = ''}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  bool _bool(dynamic value, {required bool fallback}) {
    return value is bool ? value : fallback;
  }

  String _number(String key, {int digits = 0}) {
    final value = _data[key];
    if (value is num) {
      return digits == 0
          ? value.toInt().toString()
          : value.toDouble().toStringAsFixed(digits);
    }
    return digits == 0 ? '0' : 0.0.toStringAsFixed(digits);
  }

  String _date(dynamic value) {
    DateTime? date;
    if (value is Timestamp) date = value.toDate();
    if (value is DateTime) date = value;
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String get _nftImageUrl => _text(
    _data['representativeNftImageUrl'] ??
        _data['selectedNftImageUrl'] ??
        _data['nftProfileImageUrl'],
  );

  String get _normalProfileUrl {
    if (_profileImageUrl.text.trim().isNotEmpty) {
      return _profileImageUrl.text.trim();
    }
    return _user?.photoURL ?? '';
  }

  String get _activeProfileUrl {
    if (_useNftProfile && _nftImageUrl.isNotEmpty) return _nftImageUrl;
    return _normalProfileUrl;
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
          'PROFILE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            tooltip: '설정',
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_rounded),
          ),
          IconButton(
            tooltip: '새로고침',
            onPressed:
                _loading
                    ? null
                    : () async {
                      setState(() => _loading = true);
                      await _loadProfile();
                    },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(color: _lime))
              : RefreshIndicator(
                color: _purple,
                backgroundColor: _panel,
                onRefresh: _loadProfile,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    _profileHeader(),
                    const SizedBox(height: 14),
                    _stats(),
                    const SizedBox(height: 14),
                    _quickActions(),
                    const SizedBox(height: 14),
                    _walletCard(),
                    const SizedBox(height: 14),
                    _nftCard(),
                    const SizedBox(height: 14),
                    _activityCard(),
                    const SizedBox(height: 14),
                    _editCard(),
                    const SizedBox(height: 14),
                    _settingsShortcut(),
                  ],
                ),
              ),
    );
  }

  Widget _profileHeader() {
    final rank = _text(_data['rank'], fallback: 'PIONEER');
    final level = _text(_data['level'], fallback: 'LV.1');
    final imageUrl = _activeProfileUrl;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(highlight: true),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [_purple, _lime]),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: _panel2,
                  backgroundImage:
                      imageUrl.isEmpty ? null : NetworkImage(imageUrl),
                  onBackgroundImageError: imageUrl.isEmpty ? null : (_, __) {},
                  child:
                      imageUrl.isEmpty
                          ? Text(
                            (_nickname.text.isEmpty ? 'O' : _nickname.text[0])
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                          : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _useNftProfile ? _lime : _purple,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bg, width: 3),
                ),
                child: Icon(
                  _useNftProfile
                      ? Icons.auto_awesome_rounded
                      : Icons.person_rounded,
                  size: 16,
                  color: _useNftProfile ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _nickname.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _user?.email ?? '로그인 정보 없음',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge(level, _purple),
              _badge(rank, _lime, darkText: true),
              _badge('JOIN ${_date(_data['createdAt'])}', Colors.white12),
            ],
          ),
          if (_bio.text.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              _bio.text.trim(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.75,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _stat('ORBS BALANCE', _number('orbs', digits: 4), Icons.bolt_rounded),
        _stat('POINT', _number('points'), Icons.stars_rounded),
        _stat('NFT', _number('nftCount'), Icons.image_rounded),
        _stat('REFERRAL', _number('referralCount'), Icons.group_add_rounded),
        _stat(
          'ATTENDANCE',
          _number('attendance'),
          Icons.event_available_rounded,
        ),
        _stat('DOG TAG', _number('dogTagCount'), Icons.military_tech_rounded),
      ],
    );
  }

  Widget _quickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.event_available_rounded,
            title: '출석·보상센터',
            subtitle: '일일·주간 이벤트',
            color: _lime,
            onTap: _openAttendance,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
            icon: Icons.settings_rounded,
            title: '설정',
            subtitle: '알림·언어·보안',
            color: _purple,
            onTap: _openSettings,
          ),
        ),
      ],
    );
  }

  Widget _walletCard() {
    final wallet = _text(_data['walletAddress']);
    final connected = wallet.isNotEmpty;
    return _section(
      title: 'KAIA WALLET',
      icon: Icons.account_balance_wallet_rounded,
      child: Column(
        children: [
          _infoRow(
            '연결 상태',
            connected ? 'CONNECTED' : 'NOT CONNECTED',
            valueColor: connected ? _lime : Colors.orangeAccent,
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  connected ? wallet : '등록된 지갑 주소가 없습니다.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              IconButton(
                tooltip: '지갑 주소 복사',
                onPressed: connected ? _copyWallet : null,
                icon: const Icon(Icons.copy_rounded),
                color: _lime,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nftCard() {
    final grade = _text(
      _data['highestNftGrade'] ?? _data['representativeNftGrade'],
      fallback: 'NONE',
    );
    final nftName = _text(
      _data['representativeNftName'],
      fallback: '대표 NFT가 선택되지 않았습니다.',
    );

    return _section(
      title: 'NFT PROFILE',
      icon: Icons.auto_awesome_rounded,
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeColor: _lime,
            title: const Text(
              '대표 NFT를 프로필 이미지로 사용',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              _nftImageUrl.isEmpty ? '대표 NFT가 없으면 일반 프로필 사진이 표시됩니다.' : nftName,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            value: _useNftProfile,
            onChanged: (value) => setState(() => _useNftProfile = value),
          ),
          const Divider(color: Colors.white10),
          _infoRow('보유 NFT', '${_number('nftCount')}개'),
          const SizedBox(height: 10),
          _infoRow('최고 등급', grade, valueColor: _lime),
        ],
      ),
    );
  }

  Widget _activityCard() {
    final miningActive = _bool(_data['miningActive'], fallback: false);
    return _section(
      title: 'EVENT & ACTIVITY',
      icon: Icons.celebration_rounded,
      child: Column(
        children: [
          _eventRow(
            Icons.bolt_rounded,
            '24시간 채굴',
            miningActive ? '진행 중' : '대기',
            miningActive ? _lime : Colors.white54,
          ),
          InkWell(
            onTap: _openAttendance,
            child: _eventRow(
              Icons.event_available_rounded,
              '출석·이벤트 센터',
              '${_number('attendance')}일',
              _purple,
            ),
          ),
          _eventRow(
            Icons.newspaper_rounded,
            '뉴스 이벤트',
            _bool(_data['newsEventCompleted'], fallback: false)
                ? '완료'
                : '참여 가능',
            Colors.lightBlueAccent,
          ),
          _eventRow(
            Icons.military_tech_rounded,
            '군번줄 이벤트',
            '${_number('dogTagCount')}개',
            Colors.orangeAccent,
            bottom: false,
          ),
        ],
      ),
    );
  }

  Widget _editCard() {
    return _section(
      title: 'EDIT PROFILE',
      icon: Icons.edit_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(
              _nickname,
              '닉네임',
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return '닉네임은 2자 이상 입력하세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(_country, '국가'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _photoBusy || _saving || _user?.uid != _loadedUid || _user == null ? null : _uploadPhoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(_photoBusy ? '사진 처리 중…' : '사진 직접 업로드 · 교체'),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text(
              '자르기 후 512×512 JPEG · 최대 300KB로 압축됩니다. 사진은 즉시 저장됩니다.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            )),
            _field(
              _profileImageUrl,
              '일반 프로필 이미지 URL',
              keyboardType: TextInputType.url,
              helperText: '비워두면 Google 계정 사진을 사용합니다.',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _field(_bio, '자기소개', maxLines: 4, maxLength: 160),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving || _photoBusy || _user == null || _user?.uid != _loadedUid ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon:
                    _saving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save_rounded),
                label: Text(_saving ? '저장 중...' : '프로필 저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsShortcut() {
    return _section(
      title: 'SETTINGS',
      icon: Icons.settings_rounded,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: _openSettings,
            leading: const Icon(Icons.tune_rounded, color: _lime),
            title: const Text(
              '전체 설정 열기',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: const Text(
              '알림, 언어, 공개 범위, 프로필 이미지, 보안 설정',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _panel,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(.35)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _purple.withOpacity(.18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _lime, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _lime,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventRow(
    IconData icon,
    String title,
    String status,
    Color color, {
    bool bottom = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border:
            bottom
                ? const Border(bottom: BorderSide(color: Colors.white10))
                : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color, {bool darkText = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
        border:
            color == Colors.white12 ? Border.all(color: Colors.white12) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: darkText ? Colors.black : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? helperText,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      cursorColor: _lime,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperStyle: const TextStyle(color: Colors.white38),
        labelStyle: const TextStyle(color: Colors.white54),
        counterStyle: const TextStyle(color: Colors.white38),
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
      ),
    );
  }

  BoxDecoration _box({bool highlight = false}) {
    return BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: highlight ? _purple.withOpacity(.55) : Colors.white12,
      ),
      boxShadow:
          highlight
              ? [
                BoxShadow(
                  color: _purple.withOpacity(.12),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ]
              : null,
    );
  }
}
