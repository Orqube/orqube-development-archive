import 'package:cloud_firestore/cloud_firestore.dart';

class LaunchRepository {
  LaunchRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _db.collection('launch_projects');

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProject(String id) {
    return _projects.doc(id).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMine(String ownerUid) {
    return _projects.where('ownerUid', isEqualTo: ownerUid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPublishedTokens() {
    return _projects.where('status', isEqualTo: 'published').limit(8).snapshots();
  }

  Future<String> createDraft({
    required String ownerUid,
    required String name,
    required String symbol,
    required String description,
    required String category,
    required String assetMode,
    String? imageUrl,
    Map<String, String>? logoSpec,
    String tagline = '',
    String vision = '',
    String utility = '',
    required int totalSupply,
    bool burnable = true,
    bool mintable = false,
    bool pausable = false,
    int? capSupply,
    String chain = 'Kaia',
    String aiIdea = '',
    String aiGenerationSource = '',
  }) async {
    final ref = _projects.doc();

    await ref.set({
      'ownerUid': ownerUid,
      'name': name.trim(),
      'symbol': symbol.trim().toUpperCase(),
      'tagline': _nullIfEmpty(tagline),
      'description': description.trim(),
      'vision': _nullIfEmpty(vision),
      'utility': _nullIfEmpty(utility),
      'aiIdea': _nullIfEmpty(aiIdea),
      'aiGenerationSource': _nullIfEmpty(aiGenerationSource),
      'category': category,
      'assetMode': assetMode,
      'status': 'draft',
      'imageUrl': imageUrl,
      if (logoSpec != null) 'logoSpec': logoSpec,
      'coverImageUrl': null,
      'websiteUrl': null,
      'youtubeUrl': null,
      'instagramUrl': null,
      'facebookUrl': null,
      'xUrl': null,

      // TOKEN / CHAIN PREP
      'chain': chain,
      'contractAddress': null,
      'walletAddress': null,
      'deploymentStatus': 'not_ready',
      'totalSupply': totalSupply,
      'decimals': 18,
      'tokenFeatures': {
        'fixedSupply': !mintable,
        'mintable': mintable,
        'burnable': burnable,
        'pausable': pausable,
        'capped': mintable,
        'capSupply': mintable ? capSupply : null,
      },

      // LIVE DATA - 실제 배포/시장 연결 후 갱신
      'price': null,
      'priceChange24h': null,
      'holders': 0,
      'volume24h': null,
      'marketCap': null,
      'externalMarketUrl': null,

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  Future<void> updateProfile({
    required String projectId,
    required String name,
    required String symbol,
    required String tagline,
    required String description,
    required String imageUrl,
    required String coverImageUrl,
    required String websiteUrl,
    required String youtubeUrl,
    required String instagramUrl,
    required String facebookUrl,
    required String xUrl,
    String vision = '',
    String utility = '',
  }) {
    return _projects.doc(projectId).update({
      'name': name.trim(),
      'symbol': symbol.trim().toUpperCase(),
      'tagline': _nullIfEmpty(tagline),
      'description': description.trim(),
      'vision': _nullIfEmpty(vision),
      'utility': _nullIfEmpty(utility),
      'imageUrl': _nullIfEmpty(imageUrl),
      'coverImageUrl': _nullIfEmpty(coverImageUrl),
      'websiteUrl': _nullIfEmpty(websiteUrl),
      'youtubeUrl': _nullIfEmpty(youtubeUrl),
      'instagramUrl': _nullIfEmpty(instagramUrl),
      'facebookUrl': _nullIfEmpty(facebookUrl),
      'xUrl': _nullIfEmpty(xUrl),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> publish(String projectId) {
    return _projects.doc(projectId).update({
      'status': 'published',
      'publishedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> makeDraft(String projectId) {
    return _projects.doc(projectId).update({
      'status': 'draft',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> archive(String projectId) {
    return _projects.doc(projectId).update({
      'status': 'archived',
      'archivedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> restore(String projectId) {
    return _projects.doc(projectId).update({
      'status': 'draft',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> attachWalletToProject({
    required String projectId,
    required String walletAddress,
  }) {
    return _projects.doc(projectId).update({
      'walletAddress': walletAddress.trim(),
      'deploymentStatus': 'wallet_ready',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestTokenDeployment({
    required String projectId,
    required String ownerUid,
    required String walletAddress,
    required double deployFeeOrbs,
  }) async {
    final request = _db.collection('launch_deployment_requests').doc();

    await _db.runTransaction((tx) async {
      final projectRef = _projects.doc(projectId);
      final projectSnap = await tx.get(projectRef);
      final data = projectSnap.data();
      if (data == null) {
        throw StateError('토큰 프로젝트를 찾을 수 없습니다.');
      }
      if ((data['ownerUid'] ?? '').toString() != ownerUid) {
        throw StateError('토큰 소유자만 배포를 요청할 수 있습니다.');
      }
      if ((data['contractAddress'] ?? '').toString().isNotEmpty) {
        throw StateError('이미 배포된 토큰입니다.');
      }

      tx.set(request, {
        'projectId': projectId,
        'ownerUid': ownerUid,
        'walletAddress': walletAddress.trim(),
        'deployFeeOrbs': deployFeeOrbs,
        'status': 'review_requested',
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(projectRef, {
        'walletAddress': walletAddress.trim(),
        'deploymentStatus': 'review_requested',
        'deploymentRequestId': request.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static String? _nullIfEmpty(String value) {
    final v = value.trim();
    return v.isEmpty ? null : v;
  }
}
