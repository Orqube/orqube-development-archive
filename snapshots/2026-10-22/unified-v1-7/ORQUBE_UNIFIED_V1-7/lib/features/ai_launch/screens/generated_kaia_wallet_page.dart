import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/generated_kaia_wallet_service.dart';
import '../services/launch_wallet_repository.dart';

class GeneratedKaiaWalletPage extends StatefulWidget {
  const GeneratedKaiaWalletPage({super.key, required this.ownerUid});
  final String ownerUid;
  @override
  State<GeneratedKaiaWalletPage> createState() => _GeneratedKaiaWalletPageState();
}

class _GeneratedKaiaWalletPageState extends State<GeneratedKaiaWalletPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _address = '';
  String _encrypted = '';
  bool _busy = false;
  bool _exported = false;
  bool _verified = false;
  String _message = '';

  @override
  void dispose() {
    _password.clear(); _confirm.clear();
    _password.dispose(); _confirm.dispose();
    _encrypted = '';
    super.dispose();
  }

  bool get _signedIn => FirebaseAuth.instance.currentUser?.uid == widget.ownerUid && widget.ownerUid.isNotEmpty;

  Future<void> _generate() async {
    if (_busy || !_signedIn) return;
    if (_password.text.length < 12 || _password.text != _confirm.text) {
      setState(() => _message = '12자 이상 비밀번호를 입력하고 동일하게 한 번 더 적어주세요.'); return;
    }
    setState(() { _busy = true; _message = '기기에서 지갑과 암호화 백업 파일을 생성하고 있습니다.'; });
    try {
      final data = await compute(generateEncryptedKaiaWallet, _password.text);
      if (!mounted) return;
      setState(() { _address = data['address']!; _encrypted = data['json']!; _exported = false; _verified = false; _message = '생성 완료. 백업 파일을 저장한 뒤 다시 선택해 복구를 확인하세요.'; });
    } catch (_) {
      if (mounted) setState(() => _message = '지갑을 생성하지 못했습니다. 이 기기에서 보안 난수·암호화를 사용할 수 있는지 확인해주세요.');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _export() async {
    if (_encrypted.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final path = await FilePicker.platform.saveFile(dialogTitle: '암호화 지갑 백업 저장', fileName: 'ORQUBE_KAIA_$_address.json', type: FileType.custom, allowedExtensions: ['json'], bytes: Uint8List.fromList(utf8.encode(_encrypted)));
      if (mounted && (path != null || kIsWeb)) setState(() { _exported = true; _message = '백업 저장을 요청했습니다. 실제 다운로드된 JSON 파일을 다시 선택해 복구를 확인하세요.'; });
    } catch (_) {
      if (mounted) setState(() => _message = '백업 저장을 완료하지 못했습니다. 다시 시도해주세요.');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _verifyAndRegister() async {
    if (_busy || !_exported || !_signedIn) return;
    setState(() => _busy = true);
    try {
      final files = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json'], withData: true);
      if (files == null || !mounted) return;
      final file = files.files.single;
      if (file.size > 1000000 || file.bytes == null) throw StateError('invalid backup');
      final backupJson = utf8.decode(file.bytes!);
      if (backupJson != _encrypted) throw StateError('not the generated backup');
      final restoredAddress = await compute(recoverGeneratedKaiaWalletAddress, {'json': backupJson, 'password': _password.text});
      if (restoredAddress.toLowerCase() != _address.toLowerCase()) throw StateError('wrong wallet');
      if (!_signedIn) throw StateError('auth changed');
      final repository = LaunchWalletRepository();
      final previous = await repository.loadAccount(widget.ownerUid);
      if (!mounted) return;
      final oldAddress = (previous['walletAddress'] ?? '').toString();
      if (oldAddress.isNotEmpty && oldAddress.toLowerCase() != _address.toLowerCase()) {
        final replace = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: const Text('등록된 지갑주소 변경'),
          content: Text('기존 주소: $oldAddress\n새 주소: $_address\n\n기존 지갑의 자산은 자동으로 이동하지 않습니다. 새 주소를 계정에 등록할까요?'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('새 주소 등록'))],
        ));
        if (replace != true || !mounted) return;
      }
      if (!_signedIn) throw StateError('auth changed');
      await repository.connectWallet(ownerUid: widget.ownerUid, walletAddress: _address, chain: 'Kaia');
      if (mounted) setState(() { _verified = true; _message = '백업 복구 확인·공개 주소 등록 완료. 서명에는 이 백업을 지원하는 지갑으로 가져온 후 기존 지갑 연결을 이용하세요.'; _password.clear(); _confirm.clear(); _encrypted = ''; });
    } catch (_) {
      if (mounted) setState(() => _message = '백업 확인 또는 주소 등록을 완료하지 못했습니다. 생성한 JSON·비밀번호·로그인 상태를 확인해주세요.');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => PopScope(canPop: _address.isEmpty || _verified,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop) return;
      final leave = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('지갑 백업 확인 전입니다'), content: const Text('이 화면을 나가면 생성한 지갑은 앱에서 복구할 수 없습니다. 저장한 암호화 JSON과 비밀번호를 보관했는지 확인하세요.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('계속 백업')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('나가기'))]));
      if (leave == true && mounted) { setState(() => _verified = true); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) Navigator.pop(context); }); }
    },
    child: Scaffold(appBar: AppBar(title: const Text('KAIA 지갑주소 생성')), body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('기기에서 실제 EVM 지갑주소를 만듭니다. 개인키·비밀번호·암호화 백업을 서버에 전송하지 않습니다. 로그인 계정에는 공개 주소만 등록됩니다.'),
      const SizedBox(height: 12),
      const Text('암호화 JSON과 비밀번호를 모두 보관하세요. 분실하면 운영자도 복구할 수 없습니다. 이 화면은 주소 생성용이며, 배포·전송 서명은 호환 지갑 연결에서 진행합니다.'),
      const SizedBox(height: 16),
      if (_address.isEmpty) ...[
        TextField(controller: _password, obscureText: true, enableSuggestions: false, autocorrect: false, decoration: const InputDecoration(labelText: '백업 비밀번호 · 12자 이상')),
        TextField(controller: _confirm, obscureText: true, enableSuggestions: false, autocorrect: false, decoration: const InputDecoration(labelText: '비밀번호 확인')),
        const SizedBox(height: 12),
        FilledButton(onPressed: _busy || !_signedIn ? null : _generate, child: const Text('KAIA 지갑주소 생성')),
      ],
      if (_address.isNotEmpty) ...[
        SelectableText(_address),
        TextButton.icon(onPressed: () => Clipboard.setData(ClipboardData(text: _address)), icon: const Icon(Icons.copy), label: const Text('공개 주소 복사')),
        if (!_verified) ...[
          FilledButton(onPressed: _busy ? null : _export, child: const Text('1. 암호화 JSON 저장')),
          OutlinedButton(onPressed: _busy || !_exported ? null : _verifyAndRegister, child: const Text('2. 저장한 파일로 복구 확인·주소 등록')),
        ],
      ],
      if (_busy) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      const SizedBox(height: 12),
      Text(_message),
    ])),
  );
}
