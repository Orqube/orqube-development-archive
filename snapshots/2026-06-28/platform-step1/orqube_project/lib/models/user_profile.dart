import '../utils/app_assets.dart';

class UserProfile {
  String nickname;
  String country;
  String team;
  String role;
  String bio;
  int points;
  int orbs;
  int nftCount;
  String selectedNft;
  int attendanceCount;
  int referralCount;
  int teamActiveCount;
  bool minedToday;
  DateTime? lastMiningAt;

  UserProfile({
    required this.nickname,
    required this.country,
    required this.team,
    required this.role,
    required this.bio,
    required this.selectedNft,
    this.points = 1250,
    this.orbs = 125,
    this.nftCount = 5,
    this.attendanceCount = 12,
    this.referralCount = 5,
    this.teamActiveCount = 5,
    this.minedToday = false,
    this.lastMiningAt,
  });

  factory UserProfile.defaultProfile({String? nickname}) => UserProfile(
        nickname: nickname ?? 'OrqubeUser',
        country: 'Korea',
        team: 'ORQUBE Alpha',
        role: 'Rifleman',
        bio: 'ORQUBE 초기 멤버입니다.',
        selectedNft: AppAssets.nfts.first,
      );

  factory UserProfile.fromMap(Map<String, dynamic> data) => UserProfile(
        nickname: data['nickname'] ?? 'OrqubeUser',
        country: data['country'] ?? 'Korea',
        team: data['team'] ?? 'ORQUBE Alpha',
        role: data['role'] ?? 'Rifleman',
        bio: data['bio'] ?? 'ORQUBE 초기 멤버입니다.',
        points: data['points'] ?? 1250,
        orbs: data['orbs'] ?? 125,
        nftCount: data['nftCount'] ?? 5,
        selectedNft: data['selectedNft'] ?? AppAssets.nfts.first,
        attendanceCount: data['attendanceCount'] ?? 12,
        referralCount: data['referralCount'] ?? 5,
        teamActiveCount: data['teamActiveCount'] ?? 5,
        minedToday: data['minedToday'] ?? false,
        lastMiningAt: data['lastMiningAt']?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'nickname': nickname,
        'country': country,
        'team': team,
        'role': role,
        'bio': bio,
        'points': points,
        'orbs': orbs,
        'nftCount': nftCount,
        'selectedNft': selectedNft,
        'attendanceCount': attendanceCount,
        'referralCount': referralCount,
        'teamActiveCount': teamActiveCount,
        'minedToday': minedToday,
        'lastMiningAt': lastMiningAt,
      };
}
