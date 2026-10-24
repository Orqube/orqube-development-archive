import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

import '../widgets/launch_ui.dart';
import '../services/browser_wallet_bridge.dart';

/// ORQUBE QR REWARD - phase 1 operating skeleton.
///
/// This screen deliberately creates/configures a campaign and its QR only.
/// Actual token transfer, wallet signature, gas sponsorship and claim endpoint
/// are connected in the next phase so a printed QR can never silently move funds.
class QrRewardSetupPage extends StatefulWidget {
  const QrRewardSetupPage({
    super.key,
    required this.projectId,
    required this.projectData,
  });

  final String projectId;
  final Map<String, dynamic> projectData;

  @override
  State<QrRewardSetupPage> createState() => _QrRewardSetupPageState();
}

class _QrRewardSetupPageState extends State<QrRewardSetupPage> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _dailyLimit;
  late final TextEditingController _totalLimit;
  late final TextEditingController _days;
  late final TextEditingController _condition;
  bool _enabled = false;
  bool _saving = false;

  Map<String, dynamic> get _existing {
    final root = widget.projectData['qrReward'];
    return root is Map ? Map<String, dynamic>.from(root) : <String, dynamic>{};
  }

  String get _symbol => (widget.projectData['symbol'] ?? 'TOKEN').toString();
  String get _campaignId => 'default';
  String get _docId => '${widget.projectId}_$_campaignId';
  String get _ownerUid => FirebaseAuth.instance.currentUser?.uid ?? (widget.projectData['ownerUid'] ?? '').toString();
  static final Uri _confirmEndpoint = Uri.parse('https://asia-northeast3-orqube-576e7.cloudfunctions.net/qrRewardConfirmPaid');
  int get _chainId { final raw=(widget.projectData['chainId'] as num?)?.toInt(); if(raw!=null&&raw>0)return raw; final chain=(widget.projectData['chain']??'Kaia').toString(); final net=(widget.projectData['deploymentNetwork']??widget.projectData['network']??'').toString().toLowerCase(); if(chain=='Kaia') return net.contains('mainnet')?8217:1001; if(chain=='Polygon') return net.contains('mainnet')?137:80002; return 0; }
  // Use the site root for newly generated QR codes. Some mobile QR browsers
  // or hosting/CDN setups normalize an unknown /reward path back to '/', which
  // made the app miss the public claim route and show the normal home screen.
  // main.dart still accepts the previous /reward URL for already printed QRs.
  String get _claimUrl =>
      'https://www.orqubic.com/?qr=reward&project=${Uri.encodeComponent(widget.projectId)}&campaign=$_campaignId';

  @override
  void initState() {
    super.initState();
    final rewardRoot = widget.projectData['tokenUseConfig'];
    final reward = rewardRoot is Map && rewardRoot['reward'] is Map
        ? Map<String, dynamic>.from(rewardRoot['reward'] as Map)
        : <String, dynamic>{};
    final e = _existing;
    final developerRoot = widget.projectData['developerSettings'];
    final developer = developerRoot is Map
        ? Map<String, dynamic>.from(developerRoot)
        : <String, dynamic>{};
    final developerQrRoot = developer['qrReward'];
    final developerQr = developerQrRoot is Map
        ? Map<String, dynamic>.from(developerQrRoot)
        : <String, dynamic>{};
    _name = TextEditingController(
      text: (e['name'] ?? reward['rewardName'] ?? '방문 고객 보상').toString(),
    );
    _amount = TextEditingController(
      text: (developerQr['rewardAmount'] ?? e['amount'] ?? reward['rewardAmount'] ?? 10).toString(),
    );
    _dailyLimit = TextEditingController(
      text: (developerQr['dailyLimit'] ?? e['dailyLimit'] ?? 1).toString(),
    );
    _totalLimit = TextEditingController(
      text: (developerQr['totalLimit'] ?? e['totalLimit'] ?? 1000).toString(),
    );
    _days = TextEditingController(
      text: (developerQr['validDays'] ?? e['validDays'] ?? 30).toString(),
    );
    _condition = TextEditingController(
      text: (e['condition'] ?? reward['condition'] ?? '매장 방문 고객').toString(),
    );
    _enabled = developerQr.containsKey('enabled')
        ? developerQr['enabled'] == true
        : e['enabled'] == true;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _dailyLimit.dispose();
    _totalLimit.dispose();
    _days.dispose();
    _condition.dispose();
    super.dispose();
  }

  double? _positiveDouble(String value) {
    final n = double.tryParse(value.trim());
    return n != null && n > 0 ? n : null;
  }

  int? _positiveInt(String value) {
    final n = int.tryParse(value.trim());
    return n != null && n > 0 ? n : null;
  }

  Future<void> _save() async {
    final amount = _positiveDouble(_amount.text);
    final daily = _positiveInt(_dailyLimit.text);
    final total = _positiveDouble(_totalLimit.text);
    final days = _positiveInt(_days.text);
    if (_name.text.trim().isEmpty ||
        amount == null ||
        daily == null ||
        total == null ||
        days == null) {
      _message('보상명과 수량·횟수·기간을 올바르게 입력해 주세요.');
      return;
    }
    if (amount * daily > total) {
      _message('1일 최대 지급량이 총 지급 한도를 초과합니다.');
      return;
    }

    setState(() => _saving = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || _ownerUid.isEmpty) {
        throw StateError('QR REWARD 설정 저장에는 로그인이 필요합니다.');
      }
      final developerRoot = widget.projectData['developerSettings'];
      final developer = developerRoot is Map
          ? Map<String, dynamic>.from(developerRoot)
          : <String, dynamic>{};
      final developerQrRoot = developer['qrReward'];
      final developerQr = developerQrRoot is Map
          ? Map<String, dynamic>.from(developerQrRoot)
          : <String, dynamic>{};
      final db = FirebaseFirestore.instance;
      final projectRef = db.collection('launch_projects').doc(widget.projectId);
      final campaignRef = db.collection('qr_reward_campaigns').doc(_docId);
      final batch = db.batch();

      // Keep project configuration and the public QR campaign in one commit.
      // This avoids back-to-back web writes while Firestore snapshot listeners
      // are changing routes, which reduces b815/ca9 target-state churn.
      batch.set(
        projectRef,
        {
          'qrReward': {
            'version': 1,
            'campaignId': _campaignId,
            'name': _name.text.trim(),
            'amount': amount,
            'dailyLimit': daily,
            'totalLimit': total,
            'validDays': days,
            'condition': _condition.text.trim(),
            'enabled': _enabled,
            'requestedEnabled': _enabled,
            'claimUrl': _claimUrl,
            'status': _enabled ? 'active' : 'draft',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          'tokenUseConfig.reward': {
            'rewardName': _name.text.trim(),
            'rewardAmount': amount,
            'condition': _condition.text.trim(),
            'configured': true,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Only non-sensitive campaign metadata is public. Actual claim locking
      // and transfer remain server/wallet controlled.
      batch.set(
        campaignRef,
        {
          'projectId': widget.projectId,
          'campaignId': _campaignId,
          'ownerUid': _ownerUid,
          'name': _name.text.trim(),
          'symbol': _symbol,
          'amount': amount,
          'dailyLimit': daily,
          'totalLimit': total,
          'validDays': days,
          'condition': _condition.text.trim(),
          'repeatPolicy': (developerQr['repeatPolicy'] ?? 'daily').toString(),
          'repeatEveryDays': (developerQr['repeatEveryDays'] as num?)?.toInt() ?? 1,
          'maxClaimsPerWallet': (developerQr['maxClaimsPerWallet'] as num?)?.toInt() ?? 30,
          'cooldownHours': (developerQr['cooldownHours'] as num?)?.toInt() ?? 24,
          'duplicateWalletGuard': developerQr['duplicateWalletGuard'] ?? true,
          'duplicateDeviceGuard': developerQr['duplicateDeviceGuard'] ?? true,
          'contractAddress': widget.projectData['contractAddress'],
          'decimals': (widget.projectData['decimals'] as num?)?.toInt() ?? 18,
          'chainId': _chainId,
          'network': (widget.projectData['network'] ??
                  widget.projectData['chain'] ??
                  'Kaia')
              .toString(),
          'status': _enabled ? 'active' : 'draft',
          'claimEnabled': _enabled &&
              RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(
                (widget.projectData['contractAddress'] ?? '').toString(),
              ),
          'activatedAt': _enabled ? FieldValue.serverTimestamp() : null,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      if (!mounted) return;
      _message('QR REWARD 설정을 저장했습니다. 이제 QR 스캔 시 고객용 수령 화면이 열립니다.');
    } catch (e) {
      final text = e.toString();
      if (text.contains('b815') || text.contains('INTERNAL ASSERTION FAILED')) {
        _message('Firestore 웹 연결 상태가 초기화되지 않았습니다. 앱을 완전히 다시 실행한 뒤 다시 저장해 주세요.');
      } else {
        _message('QR REWARD 저장 실패: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _field(TextEditingController c, String label, {bool number = false, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: lines,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          floatingLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  BigInt _units(num amount, int decimals) {
    final parts = amount.toString().split('.');
    final whole = BigInt.parse(parts[0]);
    final frac = parts.length > 1 ? parts[1] : '';
    final padded = frac.padRight(decimals, '0').substring(0, decimals);
    return whole * BigInt.from(10).pow(decimals) + (padded.isEmpty ? BigInt.zero : BigInt.parse(padded));
  }

  Future<void> _fulfill(String claimId, Map<String, dynamic> data, bool kaiaWallet) async {
    final contract = (widget.projectData['contractAddress'] ?? '').toString();
    final chainId = _chainId > 0 ? _chainId : ((data['chainId'] as num?)?.toInt() ?? 0);
    final decimals = (widget.projectData['decimals'] as num?)?.toInt() ?? 18;
    final to = (data['walletAddress'] ?? '').toString();
    final amount = (data['amount'] as num?) ?? 0;
    if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(contract) || chainId <= 0) {
      _message('먼저 배포된 토큰의 Contract Address와 Chain ID를 확인해 주세요.'); return;
    }
    try {
      final tx = await BrowserWalletBridge.sendErc20TransferFromSelectedWallet(
        useKaiaWallet: kaiaWallet, contractAddress: contract, toAddress: to,
        amountUnits: _units(amount, decimals), expectedChainId: chainId,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError('TX 기록을 위해 발행자 로그인이 필요합니다.');
      }
      final token = await user.getIdToken();
      final response = await http.post(
        _confirmEndpoint,
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({'claimId': claimId, 'txHash': tx}),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 || body['ok'] != true) {
        throw StateError((body['message'] ?? 'TX 서버 기록에 실패했습니다.').toString());
      }
      _message('지급 완료 · 서버 TX LOG에 기록되었습니다.');
    } catch (e) { _message('실제 토큰 지급 실패: $e'); }
  }

  Widget _pendingClaims() {
    return LaunchGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      const Text('CUSTOMER CLAIMS · 지급 대기', style: TextStyle(color:LaunchPalette.text,fontWeight:FontWeight.w900)),
      const SizedBox(height:8),
      const Text('고객이 QR에서 보상을 요청하면 서버가 중복·기간·총한도를 먼저 잠급니다. 발행자 지갑에서 실제 전송을 승인하면 TX가 기록됩니다.', style:TextStyle(color:LaunchPalette.muted,height:1.45)),
      const SizedBox(height:12),
      StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
        stream: _ownerUid.isEmpty ? const Stream<QuerySnapshot<Map<String,dynamic>>>.empty() : FirebaseFirestore.instance.collection('qr_reward_claims').where('ownerUid',isEqualTo:_ownerUid).limit(100).snapshots(),
        builder:(context,snap){
          if (snap.hasError) return Text('지급 대기 목록: ${snap.error}',style:const TextStyle(color:Colors.orangeAccent));
          if (!snap.hasData) return const LinearProgressIndicator();
          final pending=snap.data!.docs.where((d){ final x=d.data(); return x['campaignDocId']==_docId && x['status']=='reserved'; }).take(20).toList();
          if (pending.isEmpty) return const Text('현재 지급 대기 고객이 없습니다.',style:TextStyle(color:LaunchPalette.muted));
          return Column(children:pending.map((doc){ final d=doc.data(); final w=(d['walletAddress']??'').toString(); return Padding(padding:const EdgeInsets.only(bottom:10),child:Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(border:Border.all(color:Colors.white24),borderRadius:BorderRadius.circular(12)),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Text('${d['amount']} ${d['symbol'] ?? _symbol} → ${w.length>14?'${w.substring(0,8)}…${w.substring(w.length-6)}':w}',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800)),
            const SizedBox(height:8), Row(children:[Expanded(child:OutlinedButton(onPressed:()=>_fulfill(doc.id,d,false),child:const Text('MetaMask로 지급'))),const SizedBox(width:8),Expanded(child:OutlinedButton(onPressed:()=>_fulfill(doc.id,d,true),child:const Text('Kaia Wallet로 지급')))])
          ]))); }).toList());
        },
      ),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return LaunchBackground(
      appBar: launchAppBar('QR REWARD'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 48),
        children: [
          const LaunchSectionTitle(
            title: 'QR REWARD',
            subtitle: '토큰 프로필에서 고객 보상 QR을 만들고 운영하는 기본 공간입니다.',
          ),
          LaunchGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CAMPAIGN SETTINGS', style: TextStyle(color: LaunchPalette.text, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                _field(_name, '보상 이름'),
                _field(_amount, 'QR 1회 지급 수량 ($_symbol)', number: true),
                _field(_dailyLimit, '고객 1인 하루 최대 횟수', number: true),
                _field(_totalLimit, '캠페인 총 지급 한도 ($_symbol)', number: true),
                _field(_days, '유효 기간 (일)', number: true),
                _field(_condition, '지급 조건 / 설명', lines: 2),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
                  title: const Text('실제 지급 활성화 요청', style: TextStyle(color: LaunchPalette.text)),
                  subtitle: const Text('활성화하면 고객이 QR에서 보상 요청을 할 수 있습니다. 실제 전송은 아래 지급 대기 목록에서 발행자 지갑 승인 후 완료됩니다.', style: TextStyle(color: LaunchPalette.muted)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LaunchGlassCard(
            child: Column(
              children: [
                const Text('PRINT QR PREVIEW', style: TextStyle(color: LaunchPalette.text, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  color: Colors.white,
                  child: QrImageView(data: _claimUrl, size: 210),
                ),
                const SizedBox(height: 12),
                Text('${_amount.text.isEmpty ? '0' : _amount.text} $_symbol REWARD', style: const TextStyle(color: LaunchPalette.text, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 6),
                const Text('서버 중복수령 방지 후 발행자 지갑이 실제 토큰을 전송하고 TX Hash를 기록합니다.', textAlign: TextAlign.center, style: TextStyle(color: LaunchPalette.muted, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LaunchGlassCard(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT CONNECTION', style: TextStyle(color: LaunchPalette.text, fontWeight: FontWeight.w900)),
                SizedBox(height: 10),
                Text('QR 스캔 → 모바일 웹 → 지갑 연결/생성 → 캠페인 확인 → 중복·기간·총한도 확인 → 사용자 승인 → 토큰 지급 → TX Hash 기록', style: TextStyle(color: LaunchPalette.muted, height: 1.55)),
                SizedBox(height: 10),
                Text('중요: 개인키나 발행자 지갑 서명정보는 QR에 넣지 않습니다.', style: TextStyle(color: LaunchPalette.text, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _pendingClaims(),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
            label: Text(_saving ? '저장 중...' : 'QR REWARD 설정 저장'),
          ),
        ],
      ),
    );
  }
}
