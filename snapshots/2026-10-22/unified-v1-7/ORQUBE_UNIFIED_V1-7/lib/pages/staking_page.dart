import '../widgets/dark_control_theme.dart';
import 'package:flutter/material.dart';

/// Development-only staking flow. No wallet transactions or real balances.
class StakingPage extends StatefulWidget {
  const StakingPage({super.key});
  @override
  State<StakingPage> createState() => _StakingPageState();
}

class _DemoDeposit {
  final double amount;
  final double annualRate;
  final DateTime started;
  final DateTime unlocks;
  bool withdrawn = false;
  _DemoDeposit(this.amount, this.annualRate, this.started, this.unlocks);
  double get reward => amount * annualRate / 100 *
      unlocks.difference(started).inSeconds / (365 * 24 * 60 * 60);
}

class _StakingPageState extends State<StakingPage> {
  final _amount = TextEditingController();
  static const _rates = <int, double>{3: 4, 6: 6, 9: 7, 12: 8};
  double get _annualRate => _rates[_months]!;
  final _deposits = <_DemoDeposit>[];
  int _months = 3;
  bool _advanceToMaturity = false;
  String? _error;
  bool _busy = false;
  String _status = '예치 대기';
  double _balance = 1000; // Explicit demo funds; never a wallet balance.

  String _date(DateTime value) {
    final d = value.toLocal();
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }

  Widget _summary(String label, String value, IconData icon) => Container(
    width: MediaQuery.of(context).size.width < 260
        ? MediaQuery.of(context).size.width - 40 : 205,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xff15243d),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xff2c4160))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xff74dfca)),
      const SizedBox(height: 14),
      Text(label, style: const TextStyle(color: Color(0xffb9c9de))),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      const Text('모의 ORBS', style: TextStyle(color: Color(0xffb9c9de))),
    ]),
  );

  DateTime _maturity(DateTime start) {
    final first = DateTime.utc(start.year, start.month + _months, 1);
    final lastDay = DateTime.utc(first.year, first.month + 1, 0).day;
    return DateTime.utc(first.year, first.month,
        start.day > lastDay ? lastDay : start.day,
        start.hour, start.minute, start.second, start.millisecond);
  }

  double? _number(TextEditingController c) {
    final n = double.tryParse(c.text.trim());
    return n != null && n.isFinite ? n : null;
  }

  Future<void> _deposit() async {
    if (_busy) return;
    final amount = _number(_amount);
    final rate = _annualRate;
    if (amount == null || amount <= 0 || rate < 0 || rate > 100) {
      setState(() => _error = '예치량은 0보다 큰 숫자를 입력하세요.');
      return;
    }
    if (amount > _balance) {
      setState(() => _error = '모의 사용 가능 잔액을 초과했습니다.');
      return;
    }
    setState(() { _busy = true; _status = '예치 승인 대기'; });
    final started = DateTime.now().toUtc();
    final unlocks = _maturity(started);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모의 예치 확인'),
        content: Text('$amount 모의 ORBS · $_months개월\n연 보상률 $rate%\n'
            '실제 토큰은 이동하지 않습니다. 기록은 화면을 닫으면 사라집니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('모의 예치')),
        ],
      ),
    );
    if (!mounted) return;
    if (accepted != true) {
      setState(() { _busy = false; _status = '예치 취소 · 다시 시작할 수 있습니다'; });
      return;
    }
    setState(() => _status = '승인 완료 · 모의 예치 진행 중');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _balance -= amount;
      _busy = false;
      _status = '모의 예치 완료';
      _deposits.add(_DemoDeposit(amount, rate, started, unlocks));
      _advanceToMaturity = false;
      _error = null;
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: darkControlTheme(),
    child: Builder(builder: _buildContent),
  );

  Widget _buildContent(BuildContext context) {
    final amount = _number(_amount);
    final rate = _annualRate;
    final start = DateTime.now().toUtc();
    final days = _maturity(start).difference(start).inDays;
    final valid = amount != null && amount > 0 && rate >= 0 && rate <= 100;
    final reward = valid ? amount * rate / 100 * _maturity(start).difference(start).inSeconds / (365 * 24 * 60 * 60) : null;
    return Scaffold(
      backgroundColor: const Color(0xff0b1425),
      appBar: AppBar(backgroundColor: const Color(0xff0b1425), foregroundColor: Colors.white, title: const Text('ORQUBE STAKING')),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Theme(
          data: darkControlTheme().copyWith(
            colorScheme: const ColorScheme.dark(primary: Color(0xff74dfca), surface: Color(0xff15243d)),
          ),
          child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('자산을 계획하고, 만기를 확인하세요',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('3 · 6 · 9 · 12개월 스테이킹 시뮬레이션'),
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _summary('사용 가능 잔액', _balance.toStringAsFixed(4), Icons.account_balance_wallet_outlined),
            _summary('현재 예치금', _deposits.where((d) => !d.withdrawn).fold<double>(0, (sum, d) => sum + d.amount).toStringAsFixed(4), Icons.lock_outline),
            _summary('예상 만기 보상', _deposits.where((d) => !d.withdrawn).fold<double>(0, (sum, d) => sum + d.reward).toStringAsFixed(4), Icons.auto_graph),
          ]),
          const SizedBox(height: 20),
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text(
            '모의 테스트 전용 · 초기 체험 잔액 1,000 ORBS\n실제 ORBS 예치·보상 지급은 아직 연결되지 않았습니다. '
            '연 보상률 4·6·7·8%는 승인된 개발 설정이며 실제 서비스는 배포 후 시작됩니다. '
            '이 화면은 지갑이나 채굴 잔액을 변경하지 않습니다.'))),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 8, children: [3, 6, 9, 12].map((months) => ChoiceChip(
            label: Text('$months개월 · 연 ${_rates[months]!.toStringAsFixed(0)}%'), selected: _months == months,
            onSelected: _busy ? null : (_) => setState(() => _months = months),
          )).toList()),
          const SizedBox(height: 16),
          TextField(controller: _amount, enabled: !_busy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: '모의 예치량 (ORBS)', border: OutlineInputBorder()),
            onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.percent),
            title: Text('$_months개월 · 연 ${rate.toStringAsFixed(0)}% (단리)'),
            subtitle: const Text('예치 시 조건 고정 · 만기에 원금과 보상 출금')),
          const SizedBox(height: 16),
          Text('예상 만기일: ${_date(_maturity(start))}\n예상 잠금 기간: $days일\n예상 만기 보상: ${reward?.toStringAsFixed(4) ?? "—"} 모의 ORBS\n'
              '단리 계산: 예치량 × 연 보상률 × 실제 잠금일수 ÷ 365\n잠금 중에는 모의 출금도 제한됩니다.'),
          if (_error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          const SizedBox(height: 16),
          Card(child: ListTile(
            leading: _busy ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.verified_outlined),
            title: Text(_status),
            subtitle: const Text('모의 승인 → 진행 → 완료 · 실제 지갑 승인이 아닙니다'),
          )),
          FilledButton(onPressed: _busy ? null : _deposit, child: const Text('모의 예치 시작')),
          const SizedBox(height: 24),
          Text('모의 예치 기록', style: Theme.of(context).textTheme.titleLarge),
          const Text('기록은 현재 화면에서만 유지됩니다. 실제 거래 내역이 아닙니다.'),
          SwitchListTile(contentPadding: EdgeInsets.zero,
            title: const Text('테스트: 모든 예치의 만기 도달 가정'),
            value: _advanceToMaturity,
            onChanged: _busy ? null : (value) => setState(() => _advanceToMaturity = value)),
          if (_deposits.isEmpty) const Text('모의 예치 내역이 없습니다.'),
          ..._deposits.map((d) {
            final unlocked = _advanceToMaturity || !DateTime.now().toUtc().isBefore(d.unlocks);
            return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${d.amount} 모의 ORBS · 연 ${d.annualRate}%'),
                Text('예치일: ${_date(d.started)} · 만기: ${_date(d.unlocks)}\n'
                    '만기 보상: ${d.reward.toStringAsFixed(4)} 모의 ORBS'),
                Text(d.withdrawn ? '모의 출금 완료' : unlocked ? '모의 출금 가능' : '잠금 중'),
                TextButton(onPressed: !d.withdrawn && unlocked ? () => setState(() { d.withdrawn = true; _balance += d.amount + d.reward; _status = '원금 + 보상 모의 출금 완료'; }) : null,
                  child: const Text('원금 + 보상 모의 출금')),
              ])));
          }),
        ])),
      )),
    );
  }
}
