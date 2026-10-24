import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/browser_wallet_bridge.dart';
import '../widgets/launch_ui.dart';

/// Public mobile QR claim page.
/// The server reserves a claim atomically before any transfer can be made.
class QrRewardClaimPage extends StatefulWidget {
  const QrRewardClaimPage({super.key, required this.projectId, required this.campaignId});
  final String projectId;
  final String campaignId;

  @override
  State<QrRewardClaimPage> createState() => _QrRewardClaimPageState();
}

class _QrRewardClaimPageState extends State<QrRewardClaimPage> {
  bool _connecting = false;
  bool _claiming = false;
  String _wallet = '';
  String _claimId = '';
  String _claimStatus = '';
  String _message = '';
  final _manual = TextEditingController();

  String get _docId => '${widget.projectId}_${widget.campaignId}';
  static final Uri _claimEndpoint = Uri.parse('https://asia-northeast3-orqube-576e7.cloudfunctions.net/qrRewardClaim');

  @override
  void dispose() { _manual.dispose(); super.dispose(); }

  void _applyWalletAddress(String address) {
    final value = address.trim();
    _manual.text = value;
    setState(() {
      _wallet = value;
      _claimId = '';
      _claimStatus = '';
      _message = '';
    });
  }

  Future<void> _connect(bool kaia) async {
    setState(() => _connecting = true);
    try {
      final result = await BrowserWalletBridge.connectAddressOnly(useKaiaWallet: kaia);
      if (!mounted) return;
      _applyWalletAddress(result.address);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('지갑 연결 실패: $e')));
    } finally { if (mounted) setState(() => _connecting = false); }
  }

  void _useManual() {
    final value = _manual.text.trim();
    if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(value)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('올바른 EVM 지갑 주소를 입력해 주세요.'))); return;
    }
    _applyWalletAddress(value);
  }

  Future<void> _claim() async {
    if (_wallet.isEmpty || _claiming) return;
    setState(() { _claiming = true; _message = ''; });
    try {
      final response = await http.post(_claimEndpoint, headers: {'content-type':'application/json'}, body: jsonEncode({
        'projectId': widget.projectId, 'campaignId': widget.campaignId, 'walletAddress': _wallet,
      }));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 || body['ok'] != true) throw StateError((body['message'] ?? '보상 요청에 실패했습니다.').toString());
      if (!mounted) return;
      setState(() {
        _claimId = (body['claimId'] ?? '').toString();
        _claimStatus = (body['status'] ?? 'reserved').toString();
        _message = (body['message'] ?? '보상 요청이 접수되었습니다.').toString();
      });
    } catch (e) {
      if (mounted) setState(() => _message = e.toString().replaceFirst('Bad state: ', ''));
    } finally { if (mounted) setState(() => _claiming = false); }
  }

  String _short(String v) => v.length < 14 ? v : '${v.substring(0, 8)}…${v.substring(v.length - 6)}';

  @override
  Widget build(BuildContext context) {
    return LaunchBackground(
      appBar: launchAppBar('ORQUBE QR REWARD'),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('qr_reward_campaigns').doc(_docId).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || !snap.data!.exists) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('이 QR 보상 캠페인을 찾을 수 없습니다.\n발행자가 QR REWARD 설정을 먼저 저장해야 합니다.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 17, height: 1.5))));
          final d = snap.data!.data()!;
          final name = (d['name'] ?? 'QR REWARD').toString();
          final symbol = (d['symbol'] ?? 'TOKEN').toString();
          final amount = d['amount'] ?? 0;
          final condition = (d['condition'] ?? '').toString();
          final days = d['validDays'] ?? 0;
          final enabled = d['claimEnabled'] == true && d['status'] == 'active';
          return ListView(padding: const EdgeInsets.fromLTRB(18,18,18,48), children: [
            const LaunchSectionTitle(title:'보상 받기', subtitle:'QR에서 고객 지갑을 확인하고 안전하게 보상을 요청합니다.'),
            LaunchGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Text(name, style: const TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.w900)), const SizedBox(height:8),
              Text('$amount $symbol', style: const TextStyle(color:Color(0xFF67E8F9),fontSize:30,fontWeight:FontWeight.w900)), const SizedBox(height:12),
              Text(condition.isEmpty?'발행자가 지정한 고객 보상입니다.':condition, style: const TextStyle(color:Colors.white,fontSize:16,height:1.45)), const SizedBox(height:8),
              Text('유효기간: 설정 저장일로부터 $days일 · 서버가 지갑별 중복수령·일일 제한·총 지급한도를 확인합니다.', style: const TextStyle(color:Color(0xFFD1D5DB),height:1.45)),
              if (!enabled) ...[const SizedBox(height:10), const Text('현재 발행자가 실제 지급을 활성화하지 않았습니다.', style: TextStyle(color:Color(0xFFFBBF24),fontWeight:FontWeight.w800))],
            ])), const SizedBox(height:16),
            LaunchGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children:[
              const Text('받을 지갑 선택', style:TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)), const SizedBox(height:8),
              const Text('개인키·복구문구는 ORQUBE에 입력하지 않습니다.', style:TextStyle(color:Color(0xFFD1D5DB))), const SizedBox(height:16),
              FilledButton.icon(onPressed:_connecting?null:()=>_connect(false),icon:const Icon(Icons.account_balance_wallet_outlined),label:const Text('MetaMask 연결')), const SizedBox(height:10),
              OutlinedButton.icon(onPressed:_connecting?null:()=>_connect(true),icon:const Icon(Icons.wallet_outlined),label:const Text('Kaia Wallet 연결')), const SizedBox(height:10),
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(context: context, builder: (_) => AlertDialog(
                  title: const Text('ORQUBE 자동 지갑'),
                  content: const Text('지갑이 없는 고객을 위한 자동 생성 경로입니다. 고객 개인키를 브라우저·Firestore에 평문 저장하지 않도록 보안 지갑 제공자(MPC/Embedded Wallet) 연결 후 실제 생성·자동지급을 활성화합니다. 현재 패치에서는 위험한 임시 개인키 저장을 하지 않습니다.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
                )),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('지갑 없음 · ORQUBE 자동 지갑 준비 중'),
              ), const SizedBox(height:18),
              const Text('MetaMask/Kaia Wallet 연결 시 주소가 아래 칸에 자동 입력됩니다. 지갑 앱이 다른 기기에 있으면 주소를 직접 입력할 수도 있습니다.', style:TextStyle(color:Colors.white70)), const SizedBox(height:8),
              TextField(controller:_manual,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'0x 지갑 주소',labelStyle:TextStyle(color:Colors.white70),enabledBorder:OutlineInputBorder(borderSide:BorderSide(color:Colors.white54)),focusedBorder:OutlineInputBorder(borderSide:BorderSide(color:Colors.white)))), const SizedBox(height:8),
              OutlinedButton(onPressed:_useManual,child:const Text('이 주소로 받기')),
            ])),
            if (_wallet.isNotEmpty) ...[const SizedBox(height:16), LaunchGlassCard(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
              const Icon(Icons.check_circle,color:Color(0xFF86EFAC),size:42), const SizedBox(height:8),
              const Text('받을 지갑 확인 완료',textAlign:TextAlign.center,style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w900)), const SizedBox(height:6),
              SelectableText(_short(_wallet),textAlign:TextAlign.center,style:const TextStyle(color:Colors.white70)), const SizedBox(height:14),
              FilledButton.icon(onPressed:enabled&&!_claiming&&_claimId.isEmpty?_claim:null,icon:_claiming?const SizedBox.square(dimension:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.redeem),label:Text(_claimId.isEmpty?'$amount $symbol 보상 받기':'보상 요청 완료')),
              if (_message.isNotEmpty) ...[const SizedBox(height:12),Text(_message,textAlign:TextAlign.center,style:TextStyle(color:_claimId.isNotEmpty?const Color(0xFF86EFAC):const Color(0xFFFBBF24),height:1.45))],
              if (_claimId.isNotEmpty) ...[const SizedBox(height:8),Text('CLAIM ID: ${_short(_claimId)} · 상태: $_claimStatus',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white54,fontSize:12)), const SizedBox(height:8), const Text('발행자 지갑에서 전송이 승인되면 TX Hash가 기록되고 지급완료로 변경됩니다.',textAlign:TextAlign.center,style:TextStyle(color:Color(0xFFD1D5DB),height:1.45))],
            ]))],
          ]);
        },
      ),
    );
  }
}
