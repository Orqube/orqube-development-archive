import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/orqube_i18n.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  static const Color _bg = Color(0xFF03040B);
  static const Color _panel = Color(0xFF0A0B18);
  static const Color _panel2 = Color(0xFF111326);
  static const Color _purple = Color(0xFF8B2CF6);
  static const Color _lime = Color(0xFFD7FF35);

  bool _loading = true;
  bool _claiming = false;
  bool _checkedToday = false;
  int _streak = 0;
  int _total = 0;
  int _points = 0;
  double _orbs = 0;
  List<String> _days = const [];

  String _dayKey(DateTime value) {
    final date = value.toLocal();
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  double _readOrbs(Map<String, dynamic> data) {
    final orbs = data['orbs'];
    if (orbs is num) return orbs.toDouble();

    final storedOrbs = data['storedOrbs'];
    if (storedOrbs is num) return storedOrbs.toDouble();

    return 0;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final results = await Future.wait([
        userRef.get(),
        userRef
            .collection('attendance')
            .orderBy('checkedAt', descending: true)
            .limit(31)
            .get(),
      ]);

      final userSnapshot = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final attendanceSnapshot =
          results[1] as QuerySnapshot<Map<String, dynamic>>;

      final data = userSnapshot.data() ?? <String, dynamic>{};
      final attendanceKeys =
          attendanceSnapshot.docs.map((document) => document.id).toList();

      if (!mounted) return;

      setState(() {
        _streak = (data['attendanceStreak'] as num?)?.toInt() ?? 0;
        _total = (data['attendance'] as num?)?.toInt() ?? attendanceKeys.length;
        _points = (data['points'] as num?)?.toInt() ?? 0;
        _orbs = _readOrbs(data);
        _days = attendanceKeys;
        _checkedToday = attendanceKeys.contains(_dayKey(DateTime.now()));
      });
    } on FirebaseException catch (error) {
      _show(_firebaseErrorMessage(error));
    } catch (error) {
      _show('출석 정보를 불러오지 못했습니다: $error');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _claimAttendance() async {
    if (_claiming || _checkedToday) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _show('로그인 후 이용할 수 있습니다.');
      return;
    }

    setState(() => _claiming = true);

    final db = FirebaseFirestore.instance;
    final userRef = db.collection('users').doc(user.uid);
    final now = DateTime.now();
    final todayKey = _dayKey(now);
    final yesterdayKey = _dayKey(now.subtract(const Duration(days: 1)));
    final attendanceRef = userRef.collection('attendance').doc(todayKey);
    final rewardRef = userRef
        .collection('rewardHistory')
        .doc('attendance_$todayKey');

    try {
      final result = await db.runTransaction<Map<String, dynamic>>((tx) async {
        final attendanceSnapshot = await tx.get(attendanceRef);

        if (attendanceSnapshot.exists) {
          return <String, dynamic>{'claimed': false};
        }

        final userSnapshot = await tx.get(userRef);
        final data = userSnapshot.data() ?? <String, dynamic>{};

        final lastDayKey = (data['lastAttendanceDayKey'] ?? '').toString();
        final oldStreak = (data['attendanceStreak'] as num?)?.toInt() ?? 0;
        final newStreak = lastDayKey == yesterdayKey ? oldStreak + 1 : 1;

        int rewardPoints = 20;
        double rewardOrbs = 0.02;
        String bonusText = '';

        if (newStreak % 30 == 0) {
          rewardPoints += 300;
          rewardOrbs += 0.30;
          bonusText = '30일 연속 보너스 포함';
        } else if (newStreak % 14 == 0) {
          rewardPoints += 150;
          rewardOrbs += 0.14;
          bonusText = '14일 연속 보너스 포함';
        } else if (newStreak % 7 == 0) {
          rewardPoints += 100;
          rewardOrbs += 0.07;
          bonusText = '7일 연속 보너스 포함';
        }

        final currentPoints = (data['points'] as num?)?.toInt() ?? 0;
        final currentOrbs = _readOrbs(data);
        final nextOrbs = currentOrbs + rewardOrbs;
        final currentAttendance = (data['attendance'] as num?)?.toInt() ?? 0;

        tx.set(attendanceRef, <String, dynamic>{
          'uid': user.uid,
          'dayKey': todayKey,
          'checkedAt': FieldValue.serverTimestamp(),
          'rewardPoints': rewardPoints,
          'rewardOrbs': rewardOrbs,
          'streak': newStreak,
          'bonusText': bonusText,
        });

        tx.set(rewardRef, <String, dynamic>{
          'uid': user.uid,
          'type': 'attendance',
          'title': '출석 보상',
          'description': bonusText.isEmpty ? '일일 출석체크 완료' : bonusText,
          'points': rewardPoints,
          'orbs': rewardOrbs,
          'dayKey': todayKey,
          'createdAt': FieldValue.serverTimestamp(),
        });

        tx.set(userRef, <String, dynamic>{
          'uid': user.uid,
          'email': user.email,
          'attendance': currentAttendance + 1,
          'attendanceStreak': newStreak,
          'lastAttendanceDayKey': todayKey,
          'lastAttendanceAt': FieldValue.serverTimestamp(),
          'points': currentPoints + rewardPoints,
          'orbs': nextOrbs,
          'storedOrbs': nextOrbs,
          'updatedAt': FieldValue.serverTimestamp(),
          if (!userSnapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return <String, dynamic>{
          'claimed': true,
          'points': rewardPoints,
          'orbs': rewardOrbs,
          'bonusText': bonusText,
        };
      });

      if (result['claimed'] != true) {
        if (mounted) {
          setState(() => _checkedToday = true);
        }
        _show('오늘 출석 보상은 이미 받았습니다.');
        return;
      }

      await _load();

      final rewardPoints = (result['points'] as num?)?.toInt() ?? 20;
      final rewardOrbs = (result['orbs'] as num?)?.toDouble() ?? 0.02;
      final bonusText = (result['bonusText'] ?? '').toString();

      _show(
        '출석 완료! +$rewardPoints POINT / '
        '+${rewardOrbs.toStringAsFixed(4)} ORBS'
        '${bonusText.isEmpty ? '' : ' · $bonusText'}',
      );
    } on FirebaseException catch (error) {
      _show(_firebaseErrorMessage(error));
    } catch (error) {
      _show('출석 처리에 실패했습니다: $error');
    } finally {
      if (mounted) {
        setState(() => _claiming = false);
      }
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
      case 'unauthenticated':
        return '로그인 정보가 만료되었습니다. 다시 로그인해 주세요.';
      default:
        return 'Firebase 오류: ${error.message ?? error.code}';
    }
  }

  void _show(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: _panel2,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text(
          'ATTENDANCE',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body:
          user == null
              ? const Center(
                child: Text(
                  '로그인 후 이용할 수 있습니다.',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : _loading
              ? const Center(child: CircularProgressIndicator(color: _lime))
              : RefreshIndicator(
                color: _purple,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildBalance(),
                    const SizedBox(height: 14),
                    _buildAttendanceCard(),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _stat(
                            OrqubeI18n.currentPair('연속 출석', 'Streak'),
                            '$_streak일',
                            Icons.local_fire_department_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _stat(
                            OrqubeI18n.currentPair('누적 출석', 'Total Attendance'),
                            '$_total일',
                            Icons.calendar_month_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      OrqubeI18n.currentPair('최근 14일 출석 기록', 'Last 14 Days'),
                      style: TextStyle(
                        color: _lime,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCalendar(),
                  ],
                ),
              ),
    );
  }

  Widget _buildBalance() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _box(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: _purple,
            child: Icon(Icons.workspace_premium_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '$_points POINT',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '${_orbs.toStringAsFixed(4)} ORBS',
            style: const TextStyle(
              color: _lime,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        children: [
          Icon(
            _checkedToday
                ? Icons.verified_rounded
                : Icons.event_available_rounded,
            color: _checkedToday ? _lime : _purple,
            size: 62,
          ),
          const SizedBox(height: 10),
          Text(
            _checkedToday ? '오늘 출석 완료' : OrqubeI18n.currentPair('오늘의 출석 보상', 'Today’s Attendance Reward'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '+20 POINT · +0.0200 ORBS',
            style: TextStyle(color: _lime, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            OrqubeI18n.currentPair('7일·14일·30일 연속 출석 시 추가 보상', 'Extra rewards for 7, 14 and 30-day streaks'),
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _checkedToday || _claiming ? null : _claimAttendance,
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                disabledBackgroundColor: Colors.white12,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon:
                  _claiming
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(
                        _checkedToday
                            ? Icons.check_rounded
                            : Icons.touch_app_rounded,
                      ),
              label: Text(_checkedToday ? OrqubeI18n.currentPair('내일 다시 참여하세요', 'Come back tomorrow') : OrqubeI18n.currentPair('출석체크', 'Check In')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final attended = _days.toSet();
    final days = List.generate(
      14,
      (index) => now.subtract(Duration(days: 13 - index)),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: days.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 7,
          mainAxisSpacing: 8,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          final date = days[index];
          final key = _dayKey(date);
          final checked = attended.contains(key);
          final today = key == _dayKey(now);

          return Container(
            decoration: BoxDecoration(
              color:
                  checked
                      ? _purple.withOpacity(0.30)
                      : Colors.white.withOpacity(0.035),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color:
                    today
                        ? _lime
                        : checked
                        ? _purple
                        : Colors.white10,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: today ? _lime : Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Icon(
                  checked ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 15,
                  color: checked ? _lime : Colors.white24,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        children: [
          Icon(icon, color: _purple, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _lime,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white12),
    );
  }
}
