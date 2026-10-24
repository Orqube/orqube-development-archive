import 'package:flutter/material.dart';

class PublicRewardGuidePage extends StatelessWidget {
  final String language;

  const PublicRewardGuidePage({super.key, required this.language});

  String _t({
    required String ko,
    required String en,
    required String ja,
    required String zh,
    required String fr,
    required String pt,
  }) {
    switch (language) {
      case 'en': return en;
      case 'ja': return ja;
      case 'zh': return zh;
      case 'fr': return fr;
      case 'pt': return pt;
      default: return ko;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <_RewardItem>[
      _RewardItem(Icons.bolt_rounded, _t(ko: '일일 채굴', en: 'Daily mining', ja: 'デイリーマイニング', zh: '每日挖矿', fr: 'Minage quotidien', pt: 'Mineração diária'), _t(ko: '로그인 후 하루 단위 채굴 세션을 시작하고 누적 보상을 확인합니다.', en: 'Start a daily mining session after login and review accumulated rewards.', ja: 'ログイン後に1日単位のマイニングを開始し、累積報酬を確認します。', zh: '登录后启动每日挖矿，并查看累计奖励。', fr: 'Après connexion, lancez une session quotidienne et consultez les récompenses cumulées.', pt: 'Após entrar, inicie uma sessão diária e acompanhe as recompensas acumuladas.')),
      _RewardItem(Icons.calendar_month_rounded, _t(ko: '출석 보상', en: 'Attendance rewards', ja: '出席報酬', zh: '签到奖励', fr: 'Récompenses de présence', pt: 'Recompensas de presença'), _t(ko: '연속 출석과 운영 정책에 따라 추가 포인트 또는 보상이 제공될 수 있습니다.', en: 'Additional points or rewards may be provided according to attendance streaks and operating policy.', ja: '連続出席と運営方針に応じて追加ポイントや報酬が提供される場合があります。', zh: '根据连续签到和运营政策，可能提供额外积分或奖励。', fr: 'Des points ou récompenses supplémentaires peuvent être accordés selon les séries de présence et la politique du service.', pt: 'Pontos ou recompensas extras podem ser concedidos conforme a sequência de presença e a política do serviço.')),
      _RewardItem(Icons.groups_rounded, _t(ko: '친구·커뮤니티 참여', en: 'Friends and community', ja: '友だち・コミュニティ参加', zh: '好友与社区参与', fr: 'Amis et communauté', pt: 'Amigos e comunidade'), _t(ko: '친구초대, 커뮤니티 활동, 이벤트 참여는 별도 조건에 따라 보상에 반영될 수 있습니다.', en: 'Invites, community activity, and events may affect rewards under separate conditions.', ja: '友だち招待、コミュニティ活動、イベント参加は条件に応じて報酬へ反映される場合があります。', zh: '邀请好友、社区活动和参与活动可能按相应条件计入奖励。', fr: 'Les invitations, l’activité communautaire et les événements peuvent contribuer aux récompenses selon leurs conditions.', pt: 'Convites, atividades da comunidade e eventos podem contribuir para recompensas conforme suas regras.')),
      _RewardItem(Icons.extension_rounded, _t(ko: '아이템 이벤트', en: 'Item events', ja: 'アイテムイベント', zh: '道具活动', fr: 'Événements d’objets', pt: 'Eventos de itens'), _t(ko: '수집소 참여와 아이템 조합 등 이벤트 조건을 충족하면 채굴 효율 또는 추가 보상이 적용될 수 있습니다.', en: 'Completing collection-room and item-combination conditions may unlock mining boosts or extra rewards.', ja: '収集所への参加やアイテム組み合わせ条件を満たすと、採掘効率や追加報酬が適用される場合があります。', zh: '满足收集室参与和道具组合条件后，可能获得挖矿加成或额外奖励。', fr: 'Les conditions liées aux salles de collecte et aux combinaisons d’objets peuvent débloquer des bonus de minage.', pt: 'Condições de salas de coleta e combinações de itens podem liberar bônus de mineração.')),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050711),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: Text(_t(ko: '보상 안내', en: 'Reward Guide', ja: '報酬ガイド', zh: '奖励说明', fr: 'Guide des récompenses', pt: 'Guia de recompensas')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(_t(ko: 'ORQUBE 보상은 참여 기록과 각 기능의 운영 조건에 따라 반영됩니다.', en: 'ORQUBE rewards are reflected according to participation records and the operating conditions of each feature.', ja: 'ORQUBEの報酬は参加履歴と各機能の運営条件に基づいて反映されます。', zh: 'ORQUBE奖励根据参与记录及各功能的运营条件进行计算。', fr: 'Les récompenses ORQUBE dépendent des activités enregistrées et des conditions de chaque fonctionnalité.', pt: 'As recompensas ORQUBE dependem dos registros de participação e das condições de cada recurso.'), style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800, height: 1.35)),
          const SizedBox(height: 12),
          Text(_t(ko: '정확한 지급 수량과 조건은 서비스 운영 정책 및 화면에 표시되는 최신 안내를 우선합니다.', en: 'The latest conditions and amounts shown in the service take priority.', ja: '正確な支給数量と条件は、サービス画面に表示される最新案内を優先します。', zh: '具体发放数量与条件以服务页面的最新说明为准。', fr: 'Les conditions et montants les plus récents affichés dans le service prévalent.', pt: 'As condições e valores mais recentes exibidos no serviço têm prioridade.'), style: const TextStyle(color: Colors.white60, fontSize: 15, height: 1.55)),
          const SizedBox(height: 24),
          ...items.map((item) => _RewardCard(item: item)),
        ],
      ),
    );
  }
}

class _RewardItem {
  final IconData icon;
  final String title;
  final String body;
  const _RewardItem(this.icon, this.title, this.body);
}

class _RewardCard extends StatelessWidget {
  final _RewardItem item;
  const _RewardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: const Color(0xFF10172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Colors.white12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(item.icon, color: const Color(0xFFD7FF35), size: 28),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            Text(item.body, style: const TextStyle(color: Colors.white70, height: 1.55)),
          ])),
        ]),
      ),
    );
  }
}
