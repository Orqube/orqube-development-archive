import 'package:cloud_firestore/cloud_firestore.dart';

import 'token_use_progress.dart';

/// Persists TOKEN USE CENTER operating configuration without touching
/// deployment/market fields. Real on-chain transfers are deliberately kept
/// separate and can be connected after a contract is deployed.
class TokenUseService {
  TokenUseService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _project(String projectId) =>
      _db.collection('launch_projects').doc(projectId);

  Future<void> saveStageConfig({
    required String projectId,
    required TokenUseStage stage,
    required Map<String, dynamic> config,
  }) async {
    final clean = <String, dynamic>{
      ...config,
      'configured': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _project(projectId).update({
      'tokenUseConfig.${stage.id}': clean,
      'utilityUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> startMarketStage({
    required String projectId,
    required TokenMarketStage stage,
  }) async {
    final snap = await _project(projectId).get();
    final data = snap.data();
    if (data == null) throw StateError('토큰 프로젝트를 찾을 수 없습니다.');

    final core = TokenUseProgress.fromData(data);
    if (!core.isComplete) {
      throw StateError('Liquidity Ready까지 먼저 완료해야 합니다.');
    }

    final market = TokenMarketProgress.fromData(data);
    final expected = market.next;
    if (expected != stage) {
      if (market.isActive(stage)) return;
      throw StateError('DROPS → LIQUIDITY → SWAP 순서대로 진행해야 합니다.');
    }

    final index = TokenMarketStage.values.indexOf(stage);
    await _project(projectId).set({
      'marketStageIndex': index,
      'marketStage': stage.id,
      'marketStages': {
        for (var i = 0; i <= index; i++) TokenMarketStage.values[i].id: true,
      },
      'marketActivatedAt': {stage.id: FieldValue.serverTimestamp()},
      'marketExpansion': {
        'drops': index >= TokenMarketStage.values.indexOf(TokenMarketStage.drops),
        'liquidity': index >= TokenMarketStage.values.indexOf(TokenMarketStage.liquidity),
        'swap': index >= TokenMarketStage.values.indexOf(TokenMarketStage.swap),
        'gate': index < 0 ? 'liquidity_ready_required' : 'sequential_market_stage',
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
