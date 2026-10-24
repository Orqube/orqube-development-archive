import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/marketing_approval_service.dart';

class MarketingApprovalPage extends StatelessWidget {
  MarketingApprovalPage({
    super.key,
    this.onlyTokenLaunch = false,
    this.title = 'AI Marketing Approval',
  });

  final bool onlyTokenLaunch;
  final String title;
  final service = MarketingApprovalService();

  bool _isTokenLaunch(Map<String, dynamic> x) {
    final field = (x['verified_field'] ?? x['field'] ?? '').toString();
    return field == 'AI_TOKEN_LAUNCH' ||
        (x['marketing_field_number'] ?? 0) == 9;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.pending(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = onlyTokenLaunch
              ? snap.data!.docs.where((d) => _isTokenLaunch(d.data())).toList()
              : snap.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Text(
                onlyTokenLaunch
                    ? 'AI TOKEN LAUNCH 승인 대기 항목이 없습니다.'
                    : '승인 대기 항목이 없습니다.',
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 6, bottom: 24),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              final x = d.data();
              final tokenLaunch = _isTokenLaunch(x);
              final score = tokenLaunch
                  ? (x['token_fit_score'] ?? x['verified_fit_score'] ?? '-')
                  : (x['verified_fit_score'] ?? x['fit_score'] ?? '-');
              final useCases = (x['token_use_cases'] is List)
                  ? List<String>.from(
                      (x['token_use_cases'] as List).map((e) => e.toString()),
                    )
                  : const <String>[];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              x['organization_name'] ?? d.id,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (tokenLaunch)
                            const Chip(label: Text('TOKEN #9')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${x['verified_field'] ?? x['field']} · ${x['country'] ?? ''} · ${x['language'] ?? ''}',
                      ),
                      Text(
                        tokenLaunch
                            ? 'TOKEN_FIT_SCORE $score · ${x['platform'] ?? ''}'
                            : '검증점수 $score · ${x['platform'] ?? ''}',
                      ),
                      if ((x['token_fit_reason'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '적합 근거: ${x['token_fit_reason']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                      if (useCases.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          '추천 토큰 활용안',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        ...useCases.map((v) => Text('• $v')),
                      ],
                      if ((x['promo_headline'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          x['promo_headline'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                      if ((x['promo_copy'] ?? '').toString().isNotEmpty)
                        Text(x['promo_copy'].toString()),
                      if ((x['outreach_angle'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('접근 제안: ${x['outreach_angle']}'),
                      ],
                      if ((x['review_note'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(x['review_note']),
                      ],
                      const SizedBox(height: 10),
                      const Text(
                        'Human Approval · 자동게시 OFF · 유료광고 OFF',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton(
                            onPressed: () => service.decide(d.id, 'APPROVED'),
                            child: const Text('승인'),
                          ),
                          OutlinedButton(
                            onPressed: () => service.decide(d.id, 'HOLD'),
                            child: const Text('보류'),
                          ),
                          TextButton(
                            onPressed: () => service.decide(d.id, 'REJECTED'),
                            child: const Text('제외'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
