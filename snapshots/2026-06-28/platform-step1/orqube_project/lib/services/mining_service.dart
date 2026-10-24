import '../models/user_profile.dart';

class MiningService {
  static const int dailyReward = 10;
  static const double baseOrbsPerHour = 0.20;

  int boostRate(UserProfile p) {
    int rate = 100;
    if (p.referralCount >= 5) rate += 50;
    if (p.teamActiveCount >= 5) rate += 30;
    if (p.attendanceCount >= 7) rate += 20;
    return rate;
  }

  double orbsPerHour(UserProfile p) => baseOrbsPerHour * boostRate(p) / 100;

  bool canMine(UserProfile p) {
    if (p.lastMiningAt == null) return true;
    return DateTime.now().difference(p.lastMiningAt!).inHours >= 24;
  }

  Duration remaining(UserProfile p) {
    if (p.lastMiningAt == null) return Duration.zero;
    final next = p.lastMiningAt!.add(const Duration(hours: 24));
    final diff = next.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  void mine(UserProfile p) {
    if (!canMine(p)) return;
    p.points += dailyReward;
    p.orbs = p.points ~/ 10;
    p.lastMiningAt = DateTime.now();
    p.minedToday = true;
  }
}
