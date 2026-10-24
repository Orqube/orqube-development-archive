import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ORQUBE Wallet V1
///
/// 현재 단계에서 제공하는 기능
/// - Firebase Authentication 사용자 확인
/// - Firestore users/{uid} 지갑 데이터 실시간 표시
/// - ORBS 사용 가능 잔액 / 채굴 중 잔액 분리 표시
/// - Kaia 지갑 주소 저장 및 복사
/// - 받기 화면
/// - 테스트 보내기 기능(Firestore 내부 기록, 실제 블록체인 송금 아님)
/// - 최근 거래내역 표시
/// - NFT 보유 수량 표시
/// - 한국어/영어/프랑스어/일본어/중국어/포르투갈어 UI
///
/// 필요한 패키지
///   cloud_firestore
///   firebase_auth
///
/// 주의
/// - [Send]는 현재 테스트 단계입니다. 실제 KAIA/ORBS 온체인 전송이 아닙니다.
/// - 실제 송금은 추후 Kaia Wallet/스마트컨트랙트 연동 단계에서 구현합니다.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key, this.languageCode = 'ko'});

  final String languageCode;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  static const Color _background = Color(0xFF03040B);
  static const Color _panel = Color(0xFF0A0D18);
  static const Color _panel2 = Color(0xFF12162A);
  static const Color _navy = Color(0xFF07101F);
  static const Color _cyan = Color(0xFF53D8FF);
  static const Color _purple = Color(0xFF8B2CF6);
  static const Color _violet = Color(0xFFB85CFF);
  static const Color _lime = Color(0xFFD7FF35);
  static const Color _green = Color(0xFF5CFF8A);
  static const Color _muted = Color(0xFFA5A9BD);

  bool _busy = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final user = _user;
    if (user == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  CollectionReference<Map<String, dynamic>>? get _transactions {
    final doc = _userDoc;
    if (doc == null) return null;
    return doc.collection('walletTransactions');
  }

  String get _lang {
    const supported = {'ko', 'en', 'fr', 'ja', 'zh', 'pt'};
    return supported.contains(widget.languageCode) ? widget.languageCode : 'ko';
  }

  String tr(
    String ko,
    String en, {
    String? fr,
    String? ja,
    String? zh,
    String? pt,
  }) {
    switch (_lang) {
      case 'en':
        return en;
      case 'fr':
        return fr ?? en;
      case 'ja':
        return ja ?? en;
      case 'zh':
        return zh ?? en;
      case 'pt':
        return pt ?? en;
      default:
        return ko;
    }
  }

  double _asDouble(dynamic value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int _asInt(dynamic value, [int fallback = 0]) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _shortAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }

  String _formatDate(dynamic value) {
    DateTime? date;
    if (value is Timestamp) date = value.toDate();
    if (value is DateTime) date = value;
    if (date == null) return '-';
    final local = date.toLocal();
    final y = local.year.toString();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y.$m.$d  $h:$min';
  }

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: error ? Colors.red.shade700 : _panel2,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _ensureWalletFields() async {
    final doc = _userDoc;
    if (doc == null) return;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      final data = snapshot.data() ?? <String, dynamic>{};
      final updates = <String, dynamic>{
        'walletUpdatedAt': FieldValue.serverTimestamp(),
      };

      if (!data.containsKey('walletType')) {
        updates['walletType'] = 'ORQUBE_TEST';
      }
      if (!data.containsKey('availableOrbs')) {
        updates['availableOrbs'] = _asDouble(data['orbs'], 0);
      }
      if (!data.containsKey('miningOrbs')) {
        updates['miningOrbs'] = 0.0;
      }

      transaction.set(doc, updates, SetOptions(merge: true));
    });
  }

  Future<void> _saveWalletAddress(String address) async {
    final doc = _userDoc;
    if (doc == null) {
      _message(tr('로그인이 필요합니다.', 'Please sign in first.'), error: true);
      return;
    }

    final normalized = address.trim();
    if (!normalized.startsWith('0x') || normalized.length < 20) {
      _message(
        tr('올바른 Kaia 지갑 주소를 입력해주세요.', 'Enter a valid Kaia wallet address.'),
        error: true,
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await doc.set(<String, dynamic>{
        'walletAddress': normalized,
        'walletType': 'KAIA_EXTERNAL',
        'walletConnectedAt': FieldValue.serverTimestamp(),
        'walletUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _message(tr('지갑 주소가 저장되었습니다.', 'Wallet address saved.'));
    } catch (e) {
      _message(tr('지갑 저장 실패: $e', 'Failed to save wallet: $e'), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showConnectWalletDialog() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _panel,
          title: Text(
            tr('Kaia 지갑 주소 연결', 'Connect Kaia Wallet'),
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: tr('지갑 주소', 'Wallet address'),
              hintText: '0x...',
              labelStyle: const TextStyle(color: _muted),
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white24),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _purple, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('취소', 'Cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final value = controller.text;
                Navigator.pop(dialogContext);
                await _saveWalletAddress(value);
              },
              style: FilledButton.styleFrom(backgroundColor: _purple),
              child: Text(tr('연결', 'Connect')),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  Future<void> _showReceiveDialog(String address) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(sheetContext).viewPadding.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0x228B2CF6),
                child: Icon(Icons.qr_code_2_rounded, color: _violet, size: 34),
              ),
              const SizedBox(height: 14),
              Text(
                tr('ORBS 받기', 'Receive ORBS'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr(
                  '아래 주소를 보내는 사람에게 전달하세요.',
                  'Share this address with the sender.',
                  fr: 'Partagez cette adresse avec l’expéditeur.',
                  ja: 'このアドレスを送信者に共有してください。',
                  zh: '请将此地址提供给发送方。',
                  pt: 'Compartilhe este endereço com o remetente.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, height: 1.4),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _panel2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: SelectableText(
                  address.isEmpty
                      ? tr('연결된 지갑이 없습니다.', 'No wallet connected.')
                      : address,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed:
                      address.isEmpty
                          ? null
                          : () async {
                            await Clipboard.setData(
                              ClipboardData(text: address),
                            );
                            if (sheetContext.mounted)
                              Navigator.pop(sheetContext);
                            _message(
                              tr('지갑 주소를 복사했습니다.', 'Wallet address copied.'),
                            );
                          },
                  style: FilledButton.styleFrom(backgroundColor: _purple),
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(tr('주소 복사', 'Copy address')),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr(
                  '주의: 현재는 테스트 지갑 화면입니다. 실제 전송 전 네트워크를 확인하세요.',
                  'Test wallet screen. Verify the network before any real transfer.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSendDialog({
    required double availableOrbs,
    required String senderAddress,
  }) async {
    final addressController = TextEditingController();
    final amountController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool submitting = false;

            Future<void> submit() async {
              final recipient = addressController.text.trim();
              final amount = double.tryParse(amountController.text.trim()) ?? 0;

              if (!recipient.startsWith('0x') || recipient.length < 20) {
                _message(
                  tr('받는 지갑 주소를 확인해주세요.', 'Check the recipient address.'),
                  error: true,
                );
                return;
              }
              if (amount <= 0) {
                _message(
                  tr('보낼 수량을 입력해주세요.', 'Enter an amount to send.'),
                  error: true,
                );
                return;
              }
              if (amount > availableOrbs) {
                _message(
                  tr('사용 가능한 ORBS가 부족합니다.', 'Insufficient available ORBS.'),
                  error: true,
                );
                return;
              }

              setDialogState(() => submitting = true);
              final success = await _recordTestSend(
                recipient: recipient,
                amount: amount,
                senderAddress: senderAddress,
              );
              if (dialogContext.mounted) {
                if (success) Navigator.pop(dialogContext);
                if (!success) setDialogState(() => submitting = false);
              }
            }

            return AlertDialog(
              backgroundColor: _panel,
              title: Text(
                tr('ORBS 보내기', 'Send ORBS'),
                style: const TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tr('사용 가능', 'Available')}: ${availableOrbs.toStringAsFixed(4)} ORBS',
                      style: const TextStyle(
                        color: _lime,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _dialogField(
                      controller: addressController,
                      label: tr('받는 지갑 주소', 'Recipient address'),
                      hint: '0x...',
                    ),
                    const SizedBox(height: 12),
                    _dialogField(
                      controller: amountController,
                      label: tr('수량', 'Amount'),
                      hint: '0.0000',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0x18D7FF35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x44D7FF35)),
                      ),
                      child: Text(
                        tr(
                          '현재 단계에서는 실제 블록체인 송금이 아니라 Firestore 테스트 거래로 기록됩니다.',
                          'This records a Firestore test transaction; it is not an on-chain transfer.',
                        ),
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      submitting ? null : () => Navigator.pop(dialogContext),
                  child: Text(tr('취소', 'Cancel')),
                ),
                FilledButton.icon(
                  onPressed: submitting ? null : submit,
                  style: FilledButton.styleFrom(backgroundColor: _purple),
                  icon:
                      submitting
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.send_rounded),
                  label: Text(tr('테스트 전송', 'Test send')),
                ),
              ],
            );
          },
        );
      },
    );

    addressController.dispose();
    amountController.dispose();
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: _muted),
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: _panel2,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
      ),
    );
  }

  Future<bool> _recordTestSend({
    required String recipient,
    required double amount,
    required String senderAddress,
  }) async {
    final doc = _userDoc;
    final transactions = _transactions;
    if (doc == null || transactions == null) {
      _message(tr('로그인이 필요합니다.', 'Please sign in first.'), error: true);
      return false;
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(doc);
        final data = snapshot.data() ?? <String, dynamic>{};
        final current = _asDouble(
          data['availableOrbs'],
          _asDouble(data['orbs'], 0),
        );

        if (current < amount) {
          throw StateError('INSUFFICIENT_BALANCE');
        }

        transaction.set(doc, <String, dynamic>{
          'availableOrbs': current - amount,
          'orbs': current - amount,
          'walletUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final txDoc = transactions.doc();
        transaction.set(txDoc, <String, dynamic>{
          'type': 'send_test',
          'title': 'Send',
          'amount': -amount,
          'symbol': 'ORBS',
          'from': senderAddress,
          'to': recipient,
          'status': 'test_completed',
          'isTest': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      _message(tr('테스트 전송이 기록되었습니다.', 'Test transfer recorded.'));
      return true;
    } on StateError catch (e) {
      if (e.message == 'INSUFFICIENT_BALANCE') {
        _message(
          tr('사용 가능한 ORBS가 부족합니다.', 'Insufficient available ORBS.'),
          error: true,
        );
      } else {
        _message(tr('전송 실패: $e', 'Transfer failed: $e'), error: true);
      }
      return false;
    } catch (e) {
      _message(tr('전송 실패: $e', 'Transfer failed: $e'), error: true);
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _ensureWalletFields();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final doc = _userDoc;

    return Scaffold(
      backgroundColor: _background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_purple, Color(0xFF44208A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white54),
                boxShadow: const [
                  BoxShadow(color: Color(0x668B2CF6), blurRadius: 16),
                ],
              ),
              child: const Icon(
                Icons.flight_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('ORQUBE 지갑', 'ORQUBE WALLET'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  tr('KAIA MAINNET · WALLET V1', 'KAIA MAINNET · WALLET V1'),
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: IconButton(
              tooltip: tr('새로고침', 'Refresh'),
              onPressed: _busy ? null : _ensureWalletFields,
              icon: const Icon(Icons.refresh_rounded, size: 20),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _WalletBackdrop()),
          SafeArea(
            child:
                user == null || doc == null
                    ? _signedOutView()
                    : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: doc.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _errorView(snapshot.error.toString());
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(color: _purple),
                          );
                        }

                        final data =
                            snapshot.data!.data() ?? <String, dynamic>{};
                        final available = _asDouble(
                          data['availableOrbs'],
                          _asDouble(data['orbs'], 0),
                        );
                        final mining = _asDouble(data['miningOrbs'], 0);
                        final points = _asInt(data['points'], 0);
                        final nftCount = _asInt(data['nftCount'], 0);
                        final walletAddress =
                            data['walletAddress']?.toString().trim() ?? '';
                        final walletType =
                            data['walletType']?.toString() ?? 'NOT_CONNECTED';

                        return RefreshIndicator(
                          color: _purple,
                          backgroundColor: _panel,
                          onRefresh: _ensureWalletFields,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                            children: [
                              _networkBanner(walletAddress),
                              const SizedBox(height: 12),
                              _balanceCard(
                                available: available,
                                mining: mining,
                                points: points,
                                address: walletAddress,
                                walletType: walletType,
                              ),
                              const SizedBox(height: 14),
                              _actionRow(
                                available: available,
                                address: walletAddress,
                              ),
                              const SizedBox(height: 22),
                              _sectionTitle(tr('내 자산', 'MY ASSETS')),
                              const SizedBox(height: 11),
                              _assetsGrid(
                                available: available,
                                mining: mining,
                                points: points,
                                nftCount: nftCount,
                              ),
                              const SizedBox(height: 22),
                              _nftPreview(nftCount),
                              const SizedBox(height: 22),
                              _sectionTitle(tr('최근 거래', 'RECENT TRANSACTIONS')),
                              const SizedBox(height: 11),
                              _transactionList(),
                              const SizedBox(height: 18),
                              _securityNotice(),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _networkBanner(String address) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: address.isEmpty ? Colors.orangeAccent : _green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (address.isEmpty ? Colors.orangeAccent : _green)
                      .withOpacity(0.7),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Text(
            address.isEmpty
                ? tr('KAIA 지갑 미연결', 'KAIA WALLET NOT CONNECTED')
                : tr('KAIA MAINNET 연결됨', 'KAIA MAINNET CONNECTED'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.25,
            ),
          ),
          const Spacer(),
          Text(
            tr('보안 연결', 'SECURE'),
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.shield_outlined, color: _cyan, size: 15),
        ],
      ),
    );
  }

  Widget _signedOutView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 64, color: _violet),
            const SizedBox(height: 16),
            Text(
              tr('로그인이 필요합니다.', 'Sign-in required.'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                '대시보드에서 로그인한 뒤 지갑을 열어주세요.',
                'Sign in from the dashboard, then open the wallet.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            Text(
              tr('지갑 정보를 불러오지 못했습니다.', 'Could not load wallet data.'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard({
    required double available,
    required double mining,
    required int points,
    required String address,
    required String walletType,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF32115A), Color(0xFF14152B), Color(0xFF07111C)],
          stops: [0.0, 0.54, 1.0],
        ),
        border: Border.all(color: const Color(0x808B2CF6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x448B2CF6),
            blurRadius: 34,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x2253D8FF),
            blurRadius: 36,
            offset: Offset(16, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -34,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x338B2CF6), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(
                      Icons.diamond_outlined,
                      color: _violet,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('사용 가능한 ORBS', 'AVAILABLE ORBS'),
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'ORQUBE DIGITAL ASSET',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 8,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          address.isEmpty
                              ? Colors.white.withOpacity(0.05)
                              : const Color(0x225CFF8A),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color:
                            address.isEmpty
                                ? Colors.white12
                                : const Color(0x665CFF8A),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          address.isEmpty
                              ? Icons.link_off_rounded
                              : Icons.verified_rounded,
                          size: 13,
                          color: address.isEmpty ? _muted : _green,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          address.isEmpty
                              ? tr('미연결', 'OFFLINE')
                              : tr('연결됨', 'ONLINE'),
                          style: TextStyle(
                            color: address.isEmpty ? _muted : _green,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: available.toStringAsFixed(4),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.7,
                        ),
                      ),
                      const TextSpan(
                        text: ' ORBS',
                        style: TextStyle(
                          color: _lime,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tr(
                  '채굴 보상과 이벤트 보상이 합산된 사용 가능 잔액',
                  'Spendable balance from mining and event rewards',
                ),
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _miniStat(
                      icon: Icons.bolt_rounded,
                      label: tr('채굴 중', 'MINING'),
                      value: '${mining.toStringAsFixed(4)} ORBS',
                      accent: _violet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _miniStat(
                      icon: Icons.stars_rounded,
                      label: tr('포인트', 'POINTS'),
                      value: '$points P',
                      accent: _lime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x228B2CF6),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: _violet,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            walletType.replaceAll('_', ' '),
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            address.isEmpty
                                ? tr(
                                  'Kaia 지갑을 연결해주세요.',
                                  'Connect your Kaia wallet.',
                                )
                                : _shortAddress(address),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (address.isNotEmpty)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: tr('복사', 'Copy'),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: address));
                          _message(
                            tr('지갑 주소를 복사했습니다.', 'Wallet address copied.'),
                          );
                        },
                        icon: const Icon(
                          Icons.copy_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow({required double available, required String address}) {
    final actions = <_WalletAction>[
      _WalletAction(
        icon: Icons.link_rounded,
        label: address.isEmpty ? tr('지갑 연결', 'CONNECT') : tr('주소 변경', 'CHANGE'),
        onTap: _showConnectWalletDialog,
      ),
      _WalletAction(
        icon: Icons.south_west_rounded,
        label: tr('받기', 'RECEIVE'),
        onTap: () => _showReceiveDialog(address),
      ),
      _WalletAction(
        icon: Icons.north_east_rounded,
        label: tr('보내기', 'SEND'),
        onTap:
            () => _showSendDialog(
              availableOrbs: available,
              senderAddress: address,
            ),
      ),
      _WalletAction(
        icon: Icons.history_rounded,
        label: tr('내역', 'HISTORY'),
        onTap:
            () => _message(
              tr(
                '아래 최근 거래에서 확인할 수 있습니다.',
                'See the recent transactions below.',
              ),
            ),
      ),
    ];
    const accents = [_purple, _green, Color(0xFFFFB547), _cyan];

    return Row(
      children: List.generate(actions.length, (index) {
        final action = actions[index];
        final accent = accents[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == actions.length - 1 ? 0 : 8,
            ),
            child: InkWell(
              onTap: _busy ? null : action.onTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withOpacity(0.18),
                      _panel.withOpacity(0.96),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withOpacity(0.30)),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.14),
                        border: Border.all(color: accent.withOpacity(0.34)),
                      ),
                      child: Icon(action.icon, color: accent, size: 21),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _assetsGrid({
    required double available,
    required double mining,
    required int points,
    required int nftCount,
  }) {
    final assets = <_AssetData>[
      _AssetData(
        'ORBS',
        available.toStringAsFixed(4),
        Icons.blur_circular_rounded,
        _lime,
      ),
      _AssetData(
        tr('채굴 중', 'MINING'),
        mining.toStringAsFixed(4),
        Icons.bolt_rounded,
        _violet,
      ),
      _AssetData(
        tr('포인트', 'POINTS'),
        '$points',
        Icons.stars_rounded,
        const Color(0xFFFFC857),
      ),
      _AssetData(
        'NFT',
        '$nftCount',
        Icons.image_rounded,
        const Color(0xFF56D6FF),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              assets.map((asset) {
                return SizedBox(
                  width: width,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF11172A), Color(0xFF090C16)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: asset.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(asset.icon, color: asset.color, size: 22),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset.name,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                asset.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _nftPreview(int nftCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17112A), Color(0xFF0A0E1A)],
        ),
        border: Border.all(color: const Color(0x448B2CF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [_purple, Color(0xFF5120A8)],
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x448B2CF6), blurRadius: 18),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('내 NFT 컬렉션', 'MY NFT COLLECTION'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  nftCount > 0
                      ? tr('보유 NFT $nftCount개', '$nftCount NFT owned')
                      : tr('아직 등록된 NFT가 없습니다.', 'No NFT registered yet.'),
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
                const SizedBox(height: 7),
                Text(
                  tr(
                    'NFT 기능은 다음 개발 단계에서 연결됩니다.',
                    'NFT features will be connected in the next phase.',
                  ),
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
        ],
      ),
    );
  }

  Widget _transactionList() {
    final transactions = _transactions;
    if (transactions == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          transactions
              .orderBy('createdAt', descending: true)
              .limit(10)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _emptyTransaction(
            tr(
              '거래내역을 불러오지 못했습니다. Firestore 색인 또는 보안 규칙을 확인해주세요.',
              'Could not load transactions. Check Firestore rules or indexes.',
            ),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 90,
            child: Center(
              child: CircularProgressIndicator(color: _purple, strokeWidth: 2),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _emptyTransaction(
            tr('아직 거래내역이 없습니다.', 'No transactions yet.'),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: List.generate(docs.length, (index) {
              final data = docs[index].data();
              final amount = _asDouble(data['amount']);
              final positive = amount >= 0;
              final type = data['type']?.toString() ?? '';
              final title = _transactionTitle(type, data['title']?.toString());
              final address =
                  positive
                      ? (data['from']?.toString() ?? '')
                      : (data['to']?.toString() ?? '');

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            positive
                                ? const Color(0x1F5CFF8A)
                                : const Color(0x1FFF6B7A),
                      ),
                      child: Icon(
                        positive
                            ? Icons.south_west_rounded
                            : Icons.north_east_rounded,
                        color: positive ? _green : const Color(0xFFFF6B7A),
                        size: 21,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${_formatDate(data['createdAt'])}${address.isEmpty ? '' : ' · ${_shortAddress(address)}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 10),
                    ),
                    trailing: Text(
                      '${positive ? '+' : ''}${amount.toStringAsFixed(4)}\nORBS',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: positive ? _green : const Color(0xFFFF6B7A),
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (index != docs.length - 1)
                    const Divider(
                      height: 1,
                      indent: 68,
                      endIndent: 14,
                      color: Colors.white10,
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  String _transactionTitle(String type, String? fallback) {
    switch (type) {
      case 'send_test':
        return tr('테스트 전송', 'Test send');
      case 'receive':
        return tr('받기', 'Receive');
      case 'mining_reward':
        return tr('채굴 보상', 'Mining reward');
      case 'daily_reward':
        return tr('일일 보상', 'Daily reward');
      case 'event_reward':
        return tr('이벤트 보상', 'Event reward');
      default:
        return fallback?.trim().isNotEmpty == true
            ? fallback!
            : tr('거래', 'Transaction');
    }
  }

  Widget _emptyTransaction(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white30,
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _securityNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x12D7FF35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33D7FF35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: _lime, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('보안 안내', 'SECURITY NOTICE'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tr(
                    '개인키와 복구 문구는 누구에게도 알려주지 마세요. 이 V1 화면은 주소 및 앱 내부 잔액을 관리하는 테스트 단계입니다.',
                    'Never share your private key or recovery phrase. Wallet V1 manages test addresses and in-app balances only.',
                    fr:
                        'Ne partagez jamais votre clé privée ou phrase de récupération. Wallet V1 gère uniquement des données de test.',
                    ja: '秘密鍵や復元フレーズを他人に共有しないでください。V1はテスト用です。',
                    zh: '切勿泄露私钥或助记词。V1目前仅用于测试。',
                    pt:
                        'Nunca compartilhe sua chave privada ou frase de recuperação. A V1 é apenas para testes.',
                  ),
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBackdrop extends StatelessWidget {
  const _WalletBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF050716), Color(0xFF03040B), Color(0xFF020309)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _GlowOrb(size: 280, color: Color(0x338B2CF6)),
          ),
          Positioned(
            top: 300,
            left: -120,
            child: _GlowOrb(size: 250, color: Color(0x2253D8FF)),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _GlowOrb(size: 240, color: Color(0x225CFF8A)),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _WalletAction {
  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _AssetData {
  const _AssetData(this.name, this.value, this.icon, this.color);

  final String name;
  final String value;
  final IconData icon;
  final Color color;
}
