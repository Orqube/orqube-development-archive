import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RewardCenterPage extends StatefulWidget {
  const RewardCenterPage({super.key});

  @override
  State<RewardCenterPage> createState() => _RewardCenterPageState();
}

class _RewardCenterPageState extends State<RewardCenterPage> {
  static const Color bg = Color(0xFF03040B);
  static const Color panel = Color(0xFF0B0D1B);
  static const Color lime = Color(0xFFD7FF35);
  static const Color purple = Color(0xFF8B2CF6);
  static const Color muted = Color(0xFFAAB0C5);

  bool _busy = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>>? get _userRef {
    final currentUser = _user;
    if (currentUser == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
  }

  String _dayKey(DateTime value) {
    final date = value.toLocal();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  double _readOrbs(Map<String, dynamic> data) {
    final orbs = data['orbs'];
    if (orbs is num) return orbs.toDouble();

    final storedOrbs = data['storedOrbs'];
    if (storedOrbs is num) return storedOrbs.toDouble();

    return 0;
  }

  Future<void> _claimDaily() async {
    if (_busy) return;

    final currentUser = _user;
    final userRef = _userRef;

    if (currentUser == null || userRef == null) {
      _showMessage('로그인이 필요합니다.');
      return;
    }

    setState(() => _busy = true);

    final dayKey = _dayKey(DateTime.now());
    final claimRef = userRef.collection('rewardClaims').doc('daily_$dayKey');
    final historyRef = userRef.collection('rewardHistory').doc('daily_$dayKey');

    try {
      final claimed = await FirebaseFirestore.instance.runTransaction<bool>((
        tx,
      ) async {
        final claimSnapshot = await tx.get(claimRef);

        // 웹에서 Transaction 내부 throw가 변환 Future 예외로 노출되는 문제 방지
        if (claimSnapshot.exists) return false;

        final userSnapshot = await tx.get(userRef);
        final data = userSnapshot.data() ?? <String, dynamic>{};

        final currentPoints = (data['points'] as num?)?.toInt() ?? 0;
        final currentOrbs = _readOrbs(data);
        final nextOrbs = currentOrbs + 0.02;

        tx.set(userRef, <String, dynamic>{
          'uid': currentUser.uid,
          'email': currentUser.email,
          'points': currentPoints + 20,
          'orbs': nextOrbs,
          'storedOrbs': nextOrbs,
          'lastDailyRewardAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          if (!userSnapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        tx.set(claimRef, <String, dynamic>{
          'type': 'daily',
          'dayKey': dayKey,
          'points': 20,
          'orbs': 0.02,
          'createdAt': FieldValue.serverTimestamp(),
        });

        tx.set(historyRef, <String, dynamic>{
          'type': 'daily',
          'title': '일일 접속 보상',
          'description': '매일 한 번 받을 수 있는 접속 보상',
          'points': 20,
          'orbs': 0.02,
          'dayKey': dayKey,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      _showMessage(
        claimed ? '20 POINT와 0.0200 ORBS가 지급되었습니다.' : '오늘 보상은 이미 받았습니다.',
      );
    } on FirebaseException catch (error) {
      _showMessage(_firebaseErrorMessage(error));
    } catch (error) {
      _showMessage('보상 처리 중 오류가 발생했습니다: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _firebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firestore 권한이 없습니다. 보안 규칙을 확인해 주세요.';
      case 'unavailable':
        return '네트워크 연결이 불안정합니다. 잠시 후 다시 시도해 주세요.';
      case 'failed-precondition':
        return 'Firestore 설정 또는 색인이 필요합니다.';
      default:
        return '보상 처리 실패: ${error.message ?? error.code}';
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: panel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRef = _userRef;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        title: const Text(
          'REWARD CENTER',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body:
          userRef == null
              ? const Center(
                child: Text(
                  '로그인이 필요합니다.',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: userRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '사용자 보상 정보를 불러오지 못했습니다.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data?.data() ?? <String, dynamic>{};
                  final points = (data['points'] as num?)?.toInt() ?? 0;
                  final orbs = _readOrbs(data);

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _box(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AVAILABLE REWARDS',
                              style: TextStyle(
                                color: lime,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$points POINT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${orbs.toStringAsFixed(4)} ORBS',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _box(
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: purple,
                            child: Icon(
                              Icons.card_giftcard,
                              color: Colors.white,
                            ),
                          ),
                          title: const Text(
                            '일일 접속 보상',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: const Text(
                            '+20 POINT · +0.0200 ORBS',
                            style: TextStyle(color: muted),
                          ),
                          trailing: FilledButton(
                            onPressed: _busy ? null : _claimDaily,
                            style: FilledButton.styleFrom(
                              backgroundColor: lime,
                              foregroundColor: Colors.black,
                            ),
                            child: Text(_busy ? '처리 중' : '받기'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '최근 보상',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream:
                            userRef
                                .collection('rewardHistory')
                                .orderBy('createdAt', descending: true)
                                .limit(30)
                                .snapshots(),
                        builder: (context, historySnapshot) {
                          if (historySnapshot.hasError) {
                            return Text(
                              '기록 조회 오류: ${historySnapshot.error}',
                              style: const TextStyle(color: Colors.redAccent),
                            );
                          }

                          if (historySnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !historySnapshot.hasData) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(color: lime),
                              ),
                            );
                          }

                          final docs = historySnapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return const Text(
                              '아직 보상 기록이 없습니다.',
                              style: TextStyle(color: muted),
                            );
                          }

                          return Column(
                            children:
                                docs.map((document) {
                                  final item = document.data();
                                  final itemOrbs =
                                      (item['orbs'] as num?)?.toDouble() ?? 0;

                                  return Card(
                                    color: panel,
                                    child: ListTile(
                                      title: Text(
                                        '${item['title'] ?? '보상'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${item['description'] ?? item['type'] ?? ''}',
                                        style: const TextStyle(color: muted),
                                      ),
                                      trailing: Text(
                                        '+${item['points'] ?? 0}P\n'
                                        '+${itemOrbs.toStringAsFixed(4)}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          color: lime,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
    );
  }

  Widget _box(Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}
