import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../models/launch_project.dart';
import 'launch_policy.dart';

enum LaunchAiDraftSource { remoteAi, localFallback }

class LaunchAiDraft {
  const LaunchAiDraft({
    required this.name,
    required this.symbol,
    required this.description,
    required this.vision,
    required this.utility,
    required this.tagline,
    required this.category,
    required this.source,
  });

  final String name;
  final String symbol;
  final String description;
  final String vision;
  final String utility;
  final String tagline;
  final LaunchCategory category;
  final LaunchAiDraftSource source;

  bool get usedRemoteAi => source == LaunchAiDraftSource.remoteAi;
}

class LaunchAiDraftException implements Exception {
  const LaunchAiDraftException(this.message);
  final String message;

  @override
  String toString() => message;
}

class LaunchAiDraftService {
  LaunchAiDraftService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    http.Client? client,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final http.Client _client;

  Future<LaunchAiDraft> generate({required String idea}) async {
    final cleanIdea = idea.trim();
    if (cleanIdea.length < 3) {
      throw const LaunchAiDraftException('토큰 아이디어를 조금 더 구체적으로 적어주세요.');
    }

    final inferred = _inferCategory(cleanIdea);
    _assertPolicyAllowed(cleanIdea, inferred);

    final remote = await _tryRemoteAi(cleanIdea, inferred);
    final draft = remote ?? _buildLocalFallback(cleanIdea, inferred);

    _assertPolicyAllowed(
      '${draft.name} ${draft.symbol} ${draft.description} ${draft.vision} ${draft.utility}',
      draft.category,
    );

    return draft;
  }

  Future<LaunchAiDraft?> _tryRemoteAi(
    String idea,
    LaunchCategory fallbackCategory,
  ) async {
    try {
      Map<String, dynamic>? data;
      try {
        final config = await _db.collection('launch_config').doc('ai_generation').get();
        data = config.data();
      } catch (_) {
        // A private config must not prevent calling the authenticated default API.
      }
      if (data != null && data['enabled'] == false) return null;

      final configuredEndpoint = (
        data?['textEndpointUrl'] ?? data?['endpointUrl'] ?? ''
      ).toString().trim();
      final endpoint = configuredEndpoint.isNotEmpty
          ? configuredEndpoint
          : _defaultFunctionUrl('generateLaunchAiDraft');
      if (endpoint.isEmpty) return null;

      final uri = Uri.tryParse(endpoint);
      if (uri == null) return null;
      final localHttp = uri.scheme == 'http' &&
          (uri.host == 'localhost' || uri.host == '127.0.0.1');
      if (uri.scheme != 'https' && !localHttp) return null;

      final headers = <String, String>{
        'content-type': 'application/json; charset=utf-8',
      };
      final idToken = await _auth.currentUser?.getIdToken();
      if (idToken != null && idToken.isNotEmpty) {
        headers['authorization'] = 'Bearer $idToken';
      }

      final response = await _client
          .post(
            uri,
            headers: headers,
            body: jsonEncode({
              'idea': idea,
              'chain': 'Kaia',
              'assetMode': 'publicToken',
              'language': _containsHangul(idea) ? 'ko' : 'auto',
            }),
          )
          .timeout(const Duration(seconds: 35));

      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) return null;
      final root = Map<String, dynamic>.from(decoded);
      final payload = root['data'] is Map
          ? Map<String, dynamic>.from(root['data'] as Map)
          : root;

      final category = _categoryFromAiValue(
        (payload['category'] ?? '').toString(),
        fallbackCategory,
      );
      if (LaunchPolicy.isRestrictedCategory(category)) return null;

      return LaunchAiDraft(
        name: _fitName((payload['name'] ?? '').toString(), category),
        symbol: _fitSymbol((payload['symbol'] ?? '').toString(), category),
        description: _fitText(
          (payload['description'] ?? payload['tokenStory'] ?? '').toString(),
          _fallbackDescription(idea, category),
          500,
        ),
        vision: _fitText(
          (payload['vision'] ?? '').toString(),
          _fallbackVision(idea, category),
          500,
        ),
        utility: _fitText(
          (payload['utility'] ?? '').toString(),
          _fallbackUtility(category),
          500,
        ),
        tagline: _fitText(
          (payload['tagline'] ?? '').toString(),
          _fallbackTagline(category),
          140,
        ),
        category: category,
        source: LaunchAiDraftSource.remoteAi,
      );
    } catch (_) {
      // AI 서버가 아직 연결되지 않았거나 일시적으로 실패해도
      // 사용자의 토큰 생성 흐름을 막지 않고 로컬 안전 초안으로 이어갑니다.
      return null;
    }
  }


  String _defaultFunctionUrl(String functionName) {
    final projectId = Firebase.app().options.projectId.trim();
    if (projectId.isEmpty) return '';
    return 'https://asia-northeast3-$projectId.cloudfunctions.net/$functionName';
  }

  LaunchAiDraft _buildLocalFallback(
    String idea,
    LaunchCategory category,
  ) {
    final identity = _identityForIdea(idea, category);
    return LaunchAiDraft(
      name: identity.$1,
      symbol: identity.$2,
      description: _fallbackDescription(idea, category),
      vision: _fallbackVision(idea, category),
      utility: _fallbackUtility(category),
      tagline: _fallbackTagline(category),
      category: category,
      source: LaunchAiDraftSource.localFallback,
    );
  }

  void _assertPolicyAllowed(String text, LaunchCategory category) {
    final policy = LaunchPolicy.evaluateTokenRequest(
      category: category,
      name: 'AI Draft',
      symbol: 'DRAFT',
      text: text,
    );
    if (!policy.allowed) {
      throw LaunchAiDraftException(policy.message);
    }
  }

  static LaunchCategory _inferCategory(String idea) {
    final s = idea.toLowerCase();

    if (_hasAny(s, const ['밈', '캐릭터', 'meme', 'mascot'])) {
      return LaunchCategory.meme;
    }
    if (_hasAny(s, const ['이벤트', '축제', '행사', '모임', 'event', 'festival', 'meetup'])) {
      return LaunchCategory.event;
    }
    if (_hasAny(s, const ['유튜브', '크리에이터', '작가', '아티스트', 'creator', 'youtube', 'artist', 'streamer'])) {
      return LaunchCategory.creator;
    }
    if (_hasAny(s, const ['가게', '매장', '카페', '식당', '지역상점', 'local business', 'shop', 'restaurant', 'cafe'])) {
      return LaunchCategory.localBusiness;
    }
    if (_hasAny(s, const ['회사', '업무', '프로젝트', '팀 프로젝트', 'company', 'work', 'project', 'startup'])) {
      return LaunchCategory.work;
    }
    if (_hasAny(s, const ['연구', '교육', '전문가', '기술자', 'research', 'education', 'professional', 'expert'])) {
      return LaunchCategory.professional;
    }
    if (_hasAny(s, const ['동호회', '커뮤니티', '클럽', '협회', '회원', '모임', 'community', 'club', 'association', 'members'])) {
      return LaunchCategory.community;
    }
    if (_hasAny(s, const ['취미', '팬', '게임', '음악', '등산', '캠핑', '에어소프트', 'hobby', 'fan', 'game', 'music', 'hiking', 'camping', 'airsoft'])) {
      return LaunchCategory.hobby;
    }
    if (_hasAny(s, const ['일상', '라이프', '반려', '강아지', '고양이', '여행', 'daily', 'life', 'pet', 'dog', 'cat', 'travel'])) {
      return LaunchCategory.dailyLife;
    }
    return LaunchCategory.community;
  }

  static (String, String) _identityForIdea(
    String idea,
    LaunchCategory category,
  ) {
    final s = idea.toLowerCase();

    if (_hasAny(s, const ['강아지', '반려견', 'dog', 'puppy', 'pet'])) {
      return ('Paw Community', 'PAW');
    }
    if (_hasAny(s, const ['고양이', 'cat', 'kitty'])) {
      return ('Cat Circle', 'CAT');
    }
    if (_hasAny(s, const ['등산', '산악', '트레킹', 'hiking', 'trail', 'trekking'])) {
      return ('Trail Community', 'TRAIL');
    }
    if (_hasAny(s, const ['에어소프트', 'airsoft'])) {
      return ('Airsoft Crew', 'AIRX');
    }
    if (_hasAny(s, const ['안심귀가', '안전', 'safety', 'safe return'])) {
      return ('Safe Path', 'SAFE');
    }
    if (_hasAny(s, const ['게임', 'game', 'gaming'])) {
      return ('Game Guild', 'GAME');
    }
    if (_hasAny(s, const ['음악', 'music', 'band'])) {
      return ('Fan Wave', 'FANW');
    }
    if (_hasAny(s, const ['여행', 'travel', 'trip'])) {
      return ('Trip Link', 'TRIP');
    }
    if (_hasAny(s, const ['카페', 'cafe', 'coffee'])) {
      return ('Local Cafe Club', 'CAFE');
    }
    if (_hasAny(s, const ['이벤트', 'event', 'festival'])) {
      return ('Event Link', 'EVNT');
    }
    if (_hasAny(s, const ['크리에이터', 'creator', 'youtube', 'artist'])) {
      return ('Creator Circle', 'CRTR');
    }

    switch (category) {
      case LaunchCategory.dailyLife:
        return ('Life Link', 'LIFE');
      case LaunchCategory.hobby:
        return ('Hobby Club', 'HOBY');
      case LaunchCategory.work:
        return ('Project Link', 'PROJ');
      case LaunchCategory.localBusiness:
        return ('Local Link', 'LOCL');
      case LaunchCategory.professional:
        return ('Pro Network', 'PRON');
      case LaunchCategory.creator:
        return ('Creator Circle', 'CRTR');
      case LaunchCategory.event:
        return ('Event Link', 'EVNT');
      case LaunchCategory.meme:
        return ('Meme Spark', 'MEME');
      case LaunchCategory.community:
      default:
        return ('Community Link', 'COMM');
    }
  }

  static String _fallbackDescription(String idea, LaunchCategory category) {
    if (_containsHangul(idea)) {
      return '$idea. 참여와 활동을 기록하고, 커뮤니티 안에서 기여와 경험을 연결하기 위한 Kaia 기반 공개 토큰입니다.';
    }
    return 'A Kaia-based public token inspired by “$idea”. It is designed to connect participation, contribution and practical community utility.';
  }

  static String _fallbackVision(String idea, LaunchCategory category) {
    if (_containsHangul(idea)) {
      return '사람들의 참여와 기여가 투명하게 기록되고 실제 디지털 가치와 연결되는 지속 가능한 생태계를 만드는 것을 목표로 합니다.';
    }
    return 'Build a sustainable ecosystem where participation and contribution are transparent and connected to practical digital value.';
  }

  static String _fallbackUtility(LaunchCategory category) {
    switch (category) {
      case LaunchCategory.localBusiness:
        return '멤버십 · 방문 참여 · 이벤트 · 로컬 커뮤니티 혜택을 연결하는 유틸리티로 활용합니다.';
      case LaunchCategory.creator:
        return '팬 참여 · 콘텐츠 이벤트 · 멤버십 · 커뮤니티 기여를 연결하는 유틸리티로 활용합니다.';
      case LaunchCategory.event:
        return '이벤트 참여 · 미션 · 기념 리워드 · 커뮤니티 후속 활동을 연결하는 유틸리티로 활용합니다.';
      case LaunchCategory.work:
      case LaunchCategory.professional:
        return '프로젝트 참여 · 기여 기록 · 멤버 활동 · 향후 ORQUBE 서비스 연계를 위한 유틸리티로 활용합니다.';
      default:
        return '커뮤니티 참여 · 활동 기록 · 이벤트 · 멤버십 · 향후 ORQUBE 서비스 연계를 위한 유틸리티로 활용합니다.';
    }
  }

  static String _fallbackTagline(LaunchCategory category) {
    switch (category) {
      case LaunchCategory.dailyLife:
        return 'Everyday participation, connected on Kaia.';
      case LaunchCategory.hobby:
        return 'Turn shared passion into community value.';
      case LaunchCategory.localBusiness:
        return 'Local participation, shared digital value.';
      case LaunchCategory.creator:
        return 'Creators and communities, connected by participation.';
      case LaunchCategory.event:
        return 'One event, one community, lasting participation.';
      default:
        return 'Participation becomes community value.';
    }
  }

  static LaunchCategory _categoryFromAiValue(
    String raw,
    LaunchCategory fallback,
  ) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return fallback;

    for (final category in LaunchCategory.values) {
      if (category.name.toLowerCase() == value) return category;
      if (LaunchPolicy.categoryLabel(category).toLowerCase() == value) {
        return category;
      }
    }

    if (value.contains('life') || value.contains('일상')) return LaunchCategory.dailyLife;
    if (value.contains('hobby') || value.contains('취미')) return LaunchCategory.hobby;
    if (value.contains('work') || value.contains('project') || value.contains('업무')) return LaunchCategory.work;
    if (value.contains('local') || value.contains('로컬')) return LaunchCategory.localBusiness;
    if (value.contains('creator') || value.contains('크리에이터')) return LaunchCategory.creator;
    if (value.contains('event') || value.contains('이벤트')) return LaunchCategory.event;
    if (value.contains('meme') || value.contains('밈')) return LaunchCategory.meme;
    if (value.contains('community') || value.contains('커뮤니티')) return LaunchCategory.community;
    return fallback;
  }

  static String _fitName(String raw, LaunchCategory category) {
    final clean = raw.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    if (clean.length >= 2) {
      return clean.length <= 80 ? clean : clean.substring(0, 80).trim();
    }
    return _identityForIdea('', category).$1;
  }

  static String _fitSymbol(String raw, LaunchCategory category) {
    var clean = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (clean.length > 10) clean = clean.substring(0, 10);
    if (clean.length >= 2) return clean;
    return _identityForIdea('', category).$2;
  }

  static String _fitText(String raw, String fallback, int maxLength) {
    final clean = raw.trim();
    final value = clean.isEmpty ? fallback : clean;
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength).trim();
  }

  static bool _containsHangul(String value) => RegExp(r'[가-힣]').hasMatch(value);

  static bool _hasAny(String source, List<String> terms) {
    for (final term in terms) {
      if (source.contains(term)) return true;
    }
    return false;
  }
}
