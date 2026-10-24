import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/firebase_service.dart';
import '../services/referral_service.dart';
import '../utils/orqube_i18n.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  static const _bg = Color(0xFF020811);
  static const _navy = Color(0xFF061426);
  static const _panel = Color(0xF20A1728);
  static const _panel2 = Color(0xE60D1D33);
  static const _line = Color(0xFF29496E);
  static const _cyan = Color(0xFF17DFF5);
  static const _blue = Color(0xFF1677FF);
  static const _purple = Color(0xFF7B3CFF);
  static const _lime = Color(0xFFDFFF24);
  static const _green = Color(0xFF1BE89B);
  static const _gold = Color(0xFFFFD51C);

  final _db = FirebaseFirestore.instance;
  final _service = ReferralService.instance;

  bool _loading = true;
  String? _error;
  String _inviteCode = '';
  String _inviteLink = '';
  String _referrerCode = '';
  int _rewardPoints = 0;
  double _rewardOrbs = 0;

  User? get _user => FirebaseAuth.instance.currentUser;

  String get _language => OrqubeI18n.normalize(OrqubeI18n.currentLanguage);

  static const Map<String, Map<String, String>> _translations = {
    '친구초대 기능은 로그인 후 사용할 수 있습니다.': {
      'ko': '친구초대 기능은 로그인 후 사용할 수 있습니다.',
      'en': 'Friend Invite is available after sign-in.',
      'ja': '友達招待はログイン後に利用できます。',
      'zh': '登录后即可使用好友邀请功能。',
      'fr': 'La fonction d’invitation est disponible après connexion.',
      'pt': 'O convite de amigos fica disponível após o login.',
    },
    '친구초대 정보를 준비하지 못했습니다.': {
      'ko': '친구초대 정보를 준비하지 못했습니다.',
      'en': 'Could not prepare Friend Invite information.',
      'ja': '友達招待情報を準備できませんでした。',
      'zh': '无法准备好友邀请信息。',
      'fr': 'Impossible de préparer les informations d’invitation.',
      'pt': 'Não foi possível preparar as informações de convite.',
    },
    '복사 완료': {
      'ko': '복사 완료',
      'en': 'copied',
      'ja': 'コピーしました',
      'zh': '已复制',
      'fr': 'copié',
      'pt': 'copiado',
    },
    '공유 앱을 열 수 없습니다.': {
      'ko': '공유 앱을 열 수 없습니다.',
      'en': 'Could not open the sharing app.',
      'ja': '共有アプリを開けませんでした。',
      'zh': '无法打开分享应用。',
      'fr': 'Impossible d’ouvrir l’application de partage.',
      'pt': 'Não foi possível abrir o aplicativo de compartilhamento.',
    },
    '카카오톡 초대문구를 복사했습니다. 모바일에서는 공유창에서 카카오톡을 선택해 주세요.': {
      'ko': '카카오톡 초대문구를 복사했습니다. 모바일에서는 공유창에서 카카오톡을 선택해 주세요.',
      'en':
          'The KakaoTalk invite message was copied. On mobile, choose KakaoTalk from the share sheet.',
      'ja': 'カカオトーク用の招待文をコピーしました。モバイルでは共有メニューからカカオトークを選択してください。',
      'zh': '已复制 KakaoTalk 邀请文案。移动端请在系统分享菜单中选择 KakaoTalk。',
      'fr':
          'Le message d’invitation KakaoTalk a été copié. Sur mobile, choisissez KakaoTalk dans le menu de partage.',
      'pt':
          'A mensagem de convite do KakaoTalk foi copiada. No celular, escolha KakaoTalk no menu de compartilhamento.',
    },
    '공유창을 열 수 없어 카카오톡 초대문구를 복사했습니다.': {
      'ko': '공유창을 열 수 없어 카카오톡 초대문구를 복사했습니다.',
      'en':
          'The share sheet could not be opened, so the KakaoTalk invite message was copied.',
      'ja': '共有メニューを開けなかったため、カカオトーク用の招待文をコピーしました。',
      'zh': '无法打开分享菜单，因此已复制 KakaoTalk 邀请文案。',
      'fr':
          'Le menu de partage n’a pas pu être ouvert ; le message KakaoTalk a donc été copié.',
      'pt':
          'Não foi possível abrir o menu de compartilhamento; a mensagem do KakaoTalk foi copiada.',
    },
    'SNS 초대문구를 복사했습니다. 붙여넣어 보내 주세요.': {
      'ko': 'SNS 초대문구를 복사했습니다. 붙여넣어 보내 주세요.',
      'en':
          'The ORQUBE invite message was copied. Paste it into the SNS message and send it.',
      'ja': 'ORQUBEの招待文をコピーしました。SNSのメッセージに貼り付けて送信してください。',
      'zh': '已复制 ORQUBE 邀请文案。请粘贴到社交应用消息中发送。',
      'fr':
          'Le message d’invitation ORQUBE a été copié. Collez-le dans votre message SNS puis envoyez-le.',
      'pt':
          'A mensagem de convite da ORQUBE foi copiada. Cole-a na mensagem da rede social e envie.',
    },
    '시스템 공유': {
      'ko': '시스템 공유',
      'en': 'System Share',
      'ja': 'システム共有',
      'zh': '系统分享',
      'fr': 'Partage système',
      'pt': 'Compartilhar pelo sistema',
    },
    '친구 초대': {
      'ko': '친구 초대',
      'en': 'Invite Friends',
      'ja': '友達招待',
      'zh': '邀请好友',
      'fr': 'Inviter des amis',
      'pt': 'Convidar amigos',
    },
    '친구를 초대하고 함께 ORQUBE를 즐겨보세요!': {
      'ko': '친구를 초대하고 함께 ORQUBE를 즐겨보세요!',
      'en': 'Invite friends and enjoy ORQUBE together!',
      'ja': '友達を招待して、一緒にORQUBEを楽しみましょう！',
      'zh': '邀请好友，一起体验 ORQUBE！',
      'fr': 'Invitez vos amis et profitez d’ORQUBE ensemble !',
      'pt': 'Convide amigos e aproveitem a ORQUBE juntos!',
    },
    '함께 채굴하고': {
      'ko': '함께 채굴하고',
      'en': 'Mine together',
      'ja': '一緒にマイニング',
      'zh': '一起挖矿',
      'fr': 'Miner ensemble',
      'pt': 'Minerar juntos',
    },
    'ORQ 보상 받기': {
      'ko': 'ORQ 보상 받기',
      'en': 'Earn ORQ rewards',
      'ja': 'ORQ報酬を獲得',
      'zh': '获得 ORQ 奖励',
      'fr': 'Gagner des récompenses ORQ',
      'pt': 'Ganhar recompensas ORQ',
    },
    '안심귀가': {
      'ko': '안심귀가',
      'en': 'Safe Return',
      'ja': '安心帰宅',
      'zh': '安全回家',
      'fr': 'Retour sécurisé',
      'pt': 'Volta segura',
    },
    '안전한 귀가 지원': {
      'ko': '안전한 귀가 지원',
      'en': 'Safer trips home',
      'ja': '安全な帰宅を支援',
      'zh': '守护安全回家',
      'fr': 'Aide au retour en sécurité',
      'pt': 'Apoio para voltar em segurança',
    },
    '에어소프트 허브': {
      'ko': '에어소프트 허브',
      'en': 'Airsoft Hub',
      'ja': 'エアソフトハブ',
      'zh': 'Airsoft 中心',
      'fr': 'Hub Airsoft',
      'pt': 'Hub Airsoft',
    },
    '다양한 정보 공유': {
      'ko': '다양한 정보 공유',
      'en': 'Share useful info',
      'ja': '多彩な情報を共有',
      'zh': '分享多样信息',
      'fr': 'Partager des informations',
      'pt': 'Compartilhar informações',
    },
    '내 초대코드': {
      'ko': '내 초대코드',
      'en': 'My Invite Code',
      'ja': '自分の招待コード',
      'zh': '我的邀请码',
      'fr': 'Mon code d’invitation',
      'pt': 'Meu código de convite',
    },
    '초대코드 복사': {
      'ko': '초대코드 복사',
      'en': 'Copy Invite Code',
      'ja': '招待コードをコピー',
      'zh': '复制邀请码',
      'fr': 'Copier le code',
      'pt': 'Copiar código',
    },
    '초대코드': {
      'ko': '초대코드',
      'en': 'Invite code',
      'ja': '招待コード',
      'zh': '邀请码',
      'fr': 'Code d’invitation',
      'pt': 'Código de convite',
    },
    '초대링크 복사': {
      'ko': '초대링크 복사',
      'en': 'Copy Invite Link',
      'ja': '招待リンクをコピー',
      'zh': '复制邀请链接',
      'fr': 'Copier le lien',
      'pt': 'Copiar link',
    },
    '초대링크': {
      'ko': '초대링크',
      'en': 'Invite link',
      'ja': '招待リンク',
      'zh': '邀请链接',
      'fr': 'Lien d’invitation',
      'pt': 'Link de convite',
    },
    '추천인 자동 연결 완료': {
      'ko': '추천인 자동 연결 완료',
      'en': 'Referrer linked automatically',
      'ja': '紹介者の自動連携完了',
      'zh': '推荐人已自动绑定',
      'fr': 'Parrain relié automatiquement',
      'pt': 'Indicador vinculado automaticamente',
    },
    '친구에게 초대하기': {
      'ko': '친구에게 초대하기',
      'en': 'Invite a Friend',
      'ja': '友達を招待する',
      'zh': '邀请好友',
      'fr': 'Inviter un ami',
      'pt': 'Convidar um amigo',
    },
    '연락처 초대': {
      'ko': '연락처 초대',
      'en': 'Contacts',
      'ja': '連絡先から招待',
      'zh': '联系人邀请',
      'fr': 'Contacts',
      'pt': 'Contatos',
    },
    'SMS로 보내기': {
      'ko': 'SMS로 보내기',
      'en': 'Send by SMS',
      'ja': 'SMSで送信',
      'zh': '通过短信发送',
      'fr': 'Envoyer par SMS',
      'pt': 'Enviar por SMS',
    },
    '카카오톡': {
      'ko': '카카오톡',
      'en': 'KakaoTalk',
      'ja': 'カカオトーク',
      'zh': 'KakaoTalk',
      'fr': 'KakaoTalk',
      'pt': 'KakaoTalk',
    },
    '친구에게 보내기': {
      'ko': '친구에게 보내기',
      'en': 'Send to a friend',
      'ja': '友達に送る',
      'zh': '发送给好友',
      'fr': 'Envoyer à un ami',
      'pt': 'Enviar a um amigo',
    },
    '페이스북': {
      'ko': '페이스북',
      'en': 'Facebook',
      'ja': 'Facebook',
      'zh': 'Facebook',
      'fr': 'Facebook',
      'pt': 'Facebook',
    },
    '텔레그램': {
      'ko': '텔레그램',
      'en': 'Telegram',
      'ja': 'Telegram',
      'zh': 'Telegram',
      'fr': 'Telegram',
      'pt': 'Telegram',
    },
    '인스타그램': {
      'ko': '인스타그램',
      'en': 'Instagram',
      'ja': 'Instagram',
      'zh': 'Instagram',
      'fr': 'Instagram',
      'pt': 'Instagram',
    },
    '공유하기': {
      'ko': '공유하기',
      'en': 'Share',
      'ja': '共有する',
      'zh': '分享',
      'fr': 'Partager',
      'pt': 'Compartilhar',
    },
    '기타 공유': {
      'ko': '기타 공유',
      'en': 'More',
      'ja': 'その他の共有',
      'zh': '更多分享',
      'fr': 'Autres partages',
      'pt': 'Mais opções',
    },
    '더 많은 앱': {
      'ko': '더 많은 앱',
      'en': 'More apps',
      'ja': 'その他のアプリ',
      'zh': '更多应用',
      'fr': 'Plus d’apps',
      'pt': 'Mais apps',
    },
    '내 초대 링크': {
      'ko': '내 초대 링크',
      'en': 'My Invite Link',
      'ja': '自分の招待リンク',
      'zh': '我的邀请链接',
      'fr': 'Mon lien d’invitation',
      'pt': 'Meu link de convite',
    },
    '링크 복사': {
      'ko': '링크 복사',
      'en': 'Copy Link',
      'ja': 'リンクをコピー',
      'zh': '复制链接',
      'fr': 'Copier le lien',
      'pt': 'Copiar link',
    },
    '링크를 통해 가입하면 자동으로 추천인이 연결됩니다.': {
      'ko': '링크를 통해 가입하면 자동으로 추천인이 연결됩니다.',
      'en': 'Signing up through this link automatically connects the referrer.',
      'ja': 'このリンクから登録すると紹介者が自動的に連携されます。',
      'zh': '通过此链接注册后将自动绑定推荐人。',
      'fr': 'L’inscription via ce lien relie automatiquement le parrain.',
      'pt':
          'Ao se cadastrar por este link, o indicador é vinculado automaticamente.',
    },
    'QR 코드': {
      'ko': 'QR 코드',
      'en': 'QR Code',
      'ja': 'QRコード',
      'zh': '二维码',
      'fr': 'Code QR',
      'pt': 'Código QR',
    },
    'QR 코드를 친구에게 보여주세요.\n간편하게 가입할 수 있습니다!': {
      'ko': 'QR 코드를 친구에게 보여주세요.\n간편하게 가입할 수 있습니다!',
      'en': 'Show this QR code to a friend.\nThey can join in just a few taps!',
      'ja': 'このQRコードを友達に見せてください。\n簡単に登録できます！',
      'zh': '将此二维码展示给好友。\n即可轻松注册！',
      'fr': 'Montrez ce code QR à un ami.\nIl pourra s’inscrire facilement !',
      'pt':
          'Mostre este código QR a um amigo.\nEle poderá se cadastrar facilmente!',
    },
    '가입 1명당': {
      'ko': '가입 1명당',
      'en': 'Per joined friend',
      'ja': '友達1人の登録につき',
      'zh': '每成功邀请 1 人',
      'fr': 'Par ami inscrit',
      'pt': 'Por amigo cadastrado',
    },
    '초대 현황': {
      'ko': '초대 현황',
      'en': 'Invite Status',
      'ja': '招待状況',
      'zh': '邀请状态',
      'fr': 'Statut des invitations',
      'pt': 'Status dos convites',
    },
    '초대한 친구': {
      'ko': '초대한 친구',
      'en': 'Invited',
      'ja': '招待した友達',
      'zh': '已邀请好友',
      'fr': 'Amis invités',
      'pt': 'Amigos convidados',
    },
    '가입한 친구': {
      'ko': '가입한 친구',
      'en': 'Joined',
      'ja': '登録した友達',
      'zh': '已注册好友',
      'fr': 'Amis inscrits',
      'pt': 'Amigos cadastrados',
    },
    '명': {'ko': '명', 'en': '', 'ja': '人', 'zh': '人', 'fr': '', 'pt': ''},
    '추천 포인트': {
      'ko': '추천 포인트',
      'en': 'Referral Points',
      'ja': '紹介ポイント',
      'zh': '推荐积分',
      'fr': 'Points de parrainage',
      'pt': 'Pontos de indicação',
    },
    '추천 보상': {
      'ko': '추천 보상',
      'en': 'Referral Reward',
      'ja': '紹介報酬',
      'zh': '推荐奖励',
      'fr': 'Récompense de parrainage',
      'pt': 'Recompensa de indicação',
    },
    '친구를 초대할 때마다 더 큰 보상을!': {
      'ko': '친구를 초대할 때마다 더 큰 보상을!',
      'en': 'Invite friends and grow your rewards!',
      'ja': '友達を招待するたびに、さらに大きな報酬を！',
      'zh': '每邀请一位好友，获得更多奖励！',
      'fr': 'Invitez des amis et augmentez vos récompenses !',
      'pt': 'Convide amigos e aumente suas recompensas!',
    },
    '함께 성장하고 더 많은 혜택을 받아가세요.': {
      'ko': '함께 성장하고 더 많은 혜택을 받아가세요.',
      'en': 'Grow together and unlock more benefits.',
      'ja': '一緒に成長し、より多くの特典を受け取りましょう。',
      'zh': '一起成长，获得更多权益。',
      'fr': 'Grandissez ensemble et profitez de plus d’avantages.',
      'pt': 'Cresçam juntos e aproveitem mais benefícios.',
    },
    '초대한 회원 · 가입현황': {
      'ko': '초대한 회원 · 가입현황',
      'en': 'Invited Members · Join Status',
      'ja': '招待メンバー・登録状況',
      'zh': '已邀请会员 · 注册状态',
      'fr': 'Membres invités · Statut',
      'pt': 'Membros convidados · Status',
    },
    '가입현황을 읽지 못했습니다.': {
      'ko': '가입현황을 읽지 못했습니다.',
      'en': 'Could not load join status.',
      'ja': '登録状況を読み込めませんでした。',
      'zh': '无法读取注册状态。',
      'fr': 'Impossible de charger le statut des inscriptions.',
      'pt': 'Não foi possível carregar o status dos cadastros.',
    },
    '아직 초대로 가입한 회원이 없습니다.': {
      'ko': '아직 초대로 가입한 회원이 없습니다.',
      'en': 'No one has joined through your invite yet.',
      'ja': 'まだ招待から登録したメンバーはいません。',
      'zh': '目前还没有通过您的邀请注册的会员。',
      'fr': 'Aucun membre ne s’est encore inscrit via votre invitation.',
      'pt': 'Ainda não há membros cadastrados pelo seu convite.',
    },
    '가입 완료': {
      'ko': '가입 완료',
      'en': 'Joined',
      'ja': '登録完了',
      'zh': '已注册',
      'fr': 'Inscrit',
      'pt': 'Cadastrado',
    },
    '확인 중': {
      'ko': '확인 중',
      'en': 'Pending',
      'ja': '確認中',
      'zh': '确认中',
      'fr': 'En attente',
      'pt': 'Pendente',
    },
    '다시 시도': {
      'ko': '다시 시도',
      'en': 'Try Again',
      'ja': '再試行',
      'zh': '重试',
      'fr': 'Réessayer',
      'pt': 'Tentar novamente',
    },
    'ORQUBE 친구초대': {
      'ko': 'ORQUBE 친구초대',
      'en': 'ORQUBE Friend Invite',
      'ja': 'ORQUBE 友達招待',
      'zh': 'ORQUBE 好友邀请',
      'fr': 'Invitation ORQUBE',
      'pt': 'Convite ORQUBE',
    },
    'FRIEND INVITE': {
      'ko': 'FRIEND INVITE',
      'en': 'FRIEND INVITE',
      'ja': '友達招待',
      'zh': '好友邀请',
      'fr': 'INVITER DES AMIS',
      'pt': 'CONVIDAR AMIGOS',
    },
  };

  String _tr(String ko) =>
      _translations[ko]?[_language] ?? _translations[ko]?['en'] ?? ko;

  String get _shareText {
    final intro = switch (_language) {
      'en' =>
        'You are invited to ORQUBE!\nA global Airsoft platform for Safe Return, Safe Hiking, community, and mining rewards.',
      'ja' =>
        'ORQUBEへご招待します！\nエアソフトを中心に、安心帰宅・安全登山・コミュニティ・マイニング報酬をつなぐグローバルプラットフォームです。',
      'zh' => '邀请您加入 ORQUBE！\n这是一个以 Airsoft 为核心，融合安全回家、安全徒步、社区与挖矿奖励的全球平台。',
      'fr' =>
        'Vous êtes invité sur ORQUBE !\nUne plateforme Airsoft mondiale réunissant retour sécurisé, randonnée sûre, communauté et récompenses de minage.',
      'pt' =>
        'Você está convidado para a ORQUBE!\nUma plataforma global de Airsoft com volta segura, trilha segura, comunidade e recompensas de mineração.',
      _ => 'ORQUBE에 초대합니다!\n에어소프트를 중심으로 안심귀가·안전산행·커뮤니티·채굴 보상을 함께하는 글로벌 플랫폼입니다.',
    };
    final codeLabel = switch (_language) {
      'en' => 'Personal invite code',
      'ja' => '個人招待コード',
      'zh' => '个人邀请码',
      'fr' => 'Code d’invitation personnel',
      'pt' => 'Código pessoal de convite',
      _ => '개인 초대코드',
    };
    return '$intro\nwww.orqubic.com\n$codeLabel: $_inviteCode';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = _user;
    if (user == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = _tr('친구초대 기능은 로그인 후 사용할 수 있습니다.');
        });
      }
      return;
    }

    try {
      await FirebaseService.createUserProfileIfNeeded();
      final identity = await _service.ensureInviteIdentity(user);
      await _service.claimPendingRewards(user);
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final data = userDoc.data() ?? <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        _inviteCode = identity.code;
        _inviteLink = identity.link;
        _referrerCode = '${data['referrerInviteCode'] ?? ''}'.trim();
        _rewardPoints = (data['referralRewardPoints'] as num?)?.toInt() ?? 0;
        _rewardOrbs = (data['referralRewardOrbs'] as num?)?.toDouble() ?? 0;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '${_tr('친구초대 정보를 준비하지 못했습니다.')}\n$e';
      });
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: const Color(0xFF14233A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    _message('$label ${_tr('복사 완료')}');
  }

  Future<bool> _tryOpenUri(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }

  Future<void> _openUri(Uri uri) async {
    final ok = await _tryOpenUri(uri);
    if (!ok) _message(_tr('공유 앱을 열 수 없습니다.'));
  }

  Future<void> _shareSms() async {
    await _openUri(Uri(scheme: 'sms', queryParameters: {'body': _shareText}));
  }

  Future<void> _shareKakao(BuildContext buttonContext) async {
    if (kIsWeb) {
      await Clipboard.setData(ClipboardData(text: _shareText));
      _message(_tr('카카오톡 초대문구를 복사했습니다. 모바일에서는 공유창에서 카카오톡을 선택해 주세요.'));
      return;
    }

    try {
      await _shareSystem(buttonContext);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: _shareText));
      _message(_tr('공유창을 열 수 없어 카카오톡 초대문구를 복사했습니다.'));
    }
  }

  Future<void> _shareTelegram() async {
    await _openUri(
      Uri.https('t.me', '/share/url', {
        'url': 'https://www.orqubic.com',
        'text': _shareText,
      }),
    );
  }

  Future<void> _shareInstagram() async {
    await Clipboard.setData(ClipboardData(text: _shareText));
    final opened =
        kIsWeb
            ? false
            : await _tryOpenUri(Uri.parse('instagram://direct-inbox'));
    if (!opened) {
      await _tryOpenUri(Uri.https('www.instagram.com', '/'));
    }
    _message(_tr('SNS 초대문구를 복사했습니다. 붙여넣어 보내 주세요.'));
  }

  Future<void> _shareWhatsApp() async {
    await _openUri(Uri.https('wa.me', '/', {'text': _shareText}));
  }

  Future<void> _shareFacebook() async {
    await Clipboard.setData(ClipboardData(text: _shareText));
    await _openUri(
      Uri.https('www.facebook.com', '/sharer/sharer.php', {
        'u': 'https://www.orqubic.com',
        'quote': _shareText,
      }),
    );
  }

  Future<void> _shareX() async {
    await _openUri(Uri.https('x.com', '/intent/post', {'text': _shareText}));
  }

  Future<void> _shareEmail() async {
    await _openUri(
      Uri(
        scheme: 'mailto',
        queryParameters: {'subject': _tr('ORQUBE 친구초대'), 'body': _shareText},
      ),
    );
  }

  Future<void> _shareSystem(BuildContext buttonContext) async {
    final box = buttonContext.findRenderObject() as RenderBox?;
    await Share.share(
      _shareText,
      subject: _tr('ORQUBE 친구초대'),
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _showMoreShare() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF071426),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        Widget item(IconData icon, String title, VoidCallback onTap) {
          return ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _cyan),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () {
              Navigator.pop(sheetContext);
              onTap();
            },
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                item(Icons.chat_rounded, 'WhatsApp', _shareWhatsApp),
                item(Icons.alternate_email_rounded, 'X', _shareX),
                item(Icons.email_rounded, 'Email', _shareEmail),
                Builder(
                  builder:
                      (buttonContext) => item(
                        Icons.share_rounded,
                        _tr('시스템 공유'),
                        () => _shareSystem(buttonContext),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime _dateFrom(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _dateLabel(dynamic value) {
    final d = _dateFrom(value).toLocal();
    if (d.year == 1970) return '-';
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }

  BoxDecoration _panelDecoration({
    Color borderColor = _line,
    List<Color>? gradientColors,
  }) {
    return BoxDecoration(
      color: gradientColors == null ? _panel : null,
      gradient:
          gradientColors == null
              ? null
              : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: borderColor.withOpacity(.72)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.26),
          blurRadius: 24,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  Widget _logo({double size = 74}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _gold, width: 2),
        boxShadow: [BoxShadow(color: _gold.withOpacity(.18), blurRadius: 18)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/logo/orqube_plane_logo.png',
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B0D16), Color(0xFF101927)],
                ),
              ),
              child: Icon(Icons.flight_rounded, color: Colors.white, size: 34),
            ),
      ),
    );
  }

  Widget _inviteGem({double size = 104}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _gold.withOpacity(.88), width: 2),
        boxShadow: [BoxShadow(color: _gold.withOpacity(.16), blurRadius: 20)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/nft/orqube_invite_gem.png',
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Container(
              color: const Color(0xFF071426),
              alignment: Alignment.center,
              child: const Icon(Icons.diamond_rounded, color: _gold, size: 46),
            ),
      ),
    );
  }

  Widget _topHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 14),
      child: Row(
        children: [
          _logo(size: 64),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORQUBE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'AIRSOFT • WEB3 • AI PLATFORM',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .65,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF07111F),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _line.withOpacity(.8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC600),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.diamond_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  '${_rewardOrbs.toStringAsFixed(4)} ORBS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitTile(IconData icon, String title, String sub, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      decoration: _panelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 198),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/background/orqube_invite_space_airsoft.jpg',
                ),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF061426).withOpacity(.98),
                    const Color(0xFF061426).withOpacity(.83),
                    const Color(0xFF061426).withOpacity(.18),
                  ],
                  stops: const [0, .48, 1],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 25, 24, 25),
                child: Row(
                  children: [
                    _inviteGem(size: 104),
                    const SizedBox(width: 22),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _tr('친구 초대'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.4,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _tr('친구를 초대하고 함께 ORQUBE를 즐겨보세요!'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xE80A1728),
              border: Border(top: BorderSide(color: Color(0xFF29496E))),
            ),
            child: Row(
              children: [
                _benefitTile(
                  Icons.card_giftcard_rounded,
                  _tr('함께 채굴하고'),
                  _tr('ORQ 보상 받기'),
                  _gold,
                ),
                Container(width: 1, height: 56, color: Colors.white10),
                _benefitTile(
                  Icons.shield_outlined,
                  _tr('안심귀가'),
                  _tr('안전한 귀가 지원'),
                  _green,
                ),
                Container(width: 1, height: 56, color: Colors.white10),
                _benefitTile(
                  Icons.gps_fixed_rounded,
                  _tr('에어소프트 허브'),
                  _tr('다양한 정보 공유'),
                  _gold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return SizedBox(
      height: 48,
      child:
          filled
              ? FilledButton.icon(
                onPressed: onTap,
                icon: Icon(icon, size: 19),
                label: Text(label),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              )
              : OutlinedButton.icon(
                onPressed: onTap,
                icon: Icon(icon, size: 19),
                label: Text(label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
    );
  }

  Widget _inviteCodeCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 19),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          Text(
            _tr('내 초대코드'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF020913),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(
              _inviteCode,
              style: const TextStyle(
                color: _cyan,
                fontSize: 31,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _primaryButton(
                  icon: Icons.copy_rounded,
                  label: _tr('초대코드 복사'),
                  onTap: () => _copy(_inviteCode, _tr('초대코드')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _primaryButton(
                  icon: Icons.link_rounded,
                  label: _tr('초대링크 복사'),
                  onTap: () => _copy(_inviteLink, _tr('초대링크')),
                  filled: true,
                ),
              ),
            ],
          ),
          if (_referrerCode.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_rounded, color: _green, size: 18),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    '${_tr('추천인 자동 연결 완료')} · $_referrerCode',
                    style: const TextStyle(
                      color: _green,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _shareTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required List<Color> colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(.16)),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 15, 12, 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shareSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 19),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          Text(
            _tr('친구에게 초대하기'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, c) {
              final count = c.maxWidth < 620 ? 2 : (c.maxWidth < 820 ? 3 : 6);
              final itemWidth = (c.maxWidth - (count - 1) * 10) / count;
              final items = <Widget>[
                _shareTile(
                  icon: Icons.phone_rounded,
                  title: _tr('연락처 초대'),
                  subtitle: _tr('SMS로 보내기'),
                  onTap: _shareSms,
                  colors: const [Color(0xFF50D62C), Color(0xFF168A26)],
                ),
                Builder(
                  builder:
                      (buttonContext) => _shareTile(
                        icon: Icons.chat_bubble_rounded,
                        title: _tr('카카오톡'),
                        subtitle: _tr('친구에게 보내기'),
                        onTap: () => _shareKakao(buttonContext),
                        colors: const [Color(0xFFFFD82B), Color(0xFFD59200)],
                      ),
                ),
                _shareTile(
                  icon: Icons.facebook_rounded,
                  title: _tr('페이스북'),
                  subtitle: _tr('공유하기'),
                  onTap: _shareFacebook,
                  colors: const [Color(0xFF2B80FF), Color(0xFF164ABF)],
                ),
                _shareTile(
                  icon: Icons.send_rounded,
                  title: _tr('텔레그램'),
                  subtitle: _tr('친구에게 보내기'),
                  onTap: _shareTelegram,
                  colors: const [Color(0xFF42A5F5), Color(0xFF1677C8)],
                ),
                _shareTile(
                  icon: Icons.camera_alt_rounded,
                  title: _tr('인스타그램'),
                  subtitle: _tr('친구에게 보내기'),
                  onTap: _shareInstagram,
                  colors: const [Color(0xFFE95DB1), Color(0xFF6A3FD1)],
                ),
                _shareTile(
                  icon: Icons.share_rounded,
                  title: _tr('기타 공유'),
                  subtitle: _tr('더 많은 앱'),
                  onTap: _showMoreShare,
                  colors: const [Color(0xFFA04CFF), Color(0xFF6030C7)],
                ),
              ];
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    items
                        .map(
                          (item) => SizedBox(
                            width: itemWidth,
                            height: 146,
                            child: item,
                          ),
                        )
                        .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _linkCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr('내 초대 링크'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF020B16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: SelectableText(
                    _inviteLink,
                    maxLines: 2,
                    style: const TextStyle(
                      color: _cyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _copy(_inviteLink, _tr('초대링크')),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(_tr('링크 복사')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _tr('링크를 통해 가입하면 자동으로 추천인이 연결됩니다.'),
            style: TextStyle(color: Colors.white60, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _qrCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
      decoration: _panelDecoration(),
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = c.maxWidth < 520;
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tr('QR 코드'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                _tr('QR 코드를 친구에게 보여주세요.\n간편하게 가입할 수 있습니다!'),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${_tr('가입 1명당')} ${ReferralService.rewardPoints}P + ${ReferralService.rewardOrbs.toStringAsFixed(2)} ORBS',
                style: const TextStyle(
                  color: _gold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          );
          final qr = Container(
            width: 168,
            height: 168,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: QrImageView(
              data: _inviteLink,
              version: QrVersions.auto,
              backgroundColor: Colors.white,
            ),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [info, const SizedBox(height: 18), Center(child: qr)],
            );
          }
          return Row(
            children: [Expanded(child: info), const SizedBox(width: 20), qr],
          );
        },
      ),
    );
  }

  Widget _statItem(IconData icon, String title, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 29),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsCard(int total, int joined) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr('초대 현황'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _statItem(
                Icons.group_outlined,
                _tr('초대한 친구'),
                '${total}${_tr('명')}',
                _cyan,
              ),
              Container(width: 1, height: 55, color: Colors.white10),
              _statItem(
                Icons.check_circle_outline_rounded,
                _tr('가입한 친구'),
                '${joined}${_tr('명')}',
                _cyan,
              ),
              Container(width: 1, height: 55, color: Colors.white10),
              _statItem(
                Icons.monetization_on_rounded,
                _tr('추천 포인트'),
                '$_rewardPoints P',
                _green,
              ),
              Container(width: 1, height: 55, color: Colors.white10),
              _statItem(
                Icons.card_giftcard_rounded,
                _tr('추천 보상'),
                '${_rewardOrbs.toStringAsFixed(2)} ORBS',
                _gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rewardBanner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 17),
      decoration: _panelDecoration(
        borderColor: const Color(0xFF5D53FF),
        gradientColors: const [
          Color(0xFF111D55),
          Color(0xFF24106C),
          Color(0xFF0C193A),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr('친구를 초대할 때마다 더 큰 보상을!'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  _tr('함께 성장하고 더 많은 혜택을 받아가세요.'),
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB870FF), Color(0xFF5C20E5)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: _purple.withOpacity(.45), blurRadius: 20),
              ],
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberList(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tr('초대한 회원 · 가입현황'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${docs.length}',
                style: const TextStyle(
                  color: _cyan,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (snapshot.hasError)
            Text(
              '${_tr('가입현황을 읽지 못했습니다.')}\n${snapshot.error}',
              style: const TextStyle(color: Colors.orangeAccent),
            )
          else if (!snapshot.hasData)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(color: _cyan),
              ),
            )
          else if (docs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  _tr('아직 초대로 가입한 회원이 없습니다.'),
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            ...docs.map((doc) {
              final d = doc.data();
              final name =
                  '${d['inviteeName'] ?? d['inviteeEmail'] ?? 'ORQUBE User'}';
              final email = '${d['inviteeEmail'] ?? ''}';
              final joined = d['status'] == 'joined';
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.025),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          joined ? _blue.withOpacity(.22) : Colors.white10,
                      child: Icon(
                        joined
                            ? Icons.person_rounded
                            : Icons.hourglass_bottom_rounded,
                        color: joined ? _cyan : Colors.white54,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${email.isEmpty ? '' : '$email · '}${_dateLabel(d['joinedAt'])}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      joined ? _tr('가입 완료') : _tr('확인 중'),
                      style: TextStyle(
                        color: joined ? _green : Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tr('FRIEND INVITE'),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                fontSize: 18,
              ),
            ),
            Text(
              _tr('ORQUBE 친구초대'),
              style: TextStyle(
                color: _lime,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: _bg,
          image: DecorationImage(
            image: AssetImage(
              'assets/images/background/orqube_invite_space_airsoft.jpg',
            ),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            colorFilter: ColorFilter.mode(Color(0xA8020811), BlendMode.darken),
          ),
        ),
        child:
            _loading
                ? const Center(child: CircularProgressIndicator(color: _cyan))
                : _error != null
                ? _errorView()
                : _body(),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: _panelDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.orangeAccent,
                  size: 54,
                ),
                const SizedBox(height: 14),
                Text(
                  _tr('친구초대 정보를 준비하지 못했습니다.'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white60,
                    height: 1.5,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(_tr('다시 시도')),
                  style: FilledButton.styleFrom(backgroundColor: _purple),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    final user = _user!;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.referralsFor(user.uid),
      builder: (context, snapshot) {
        final docs =
            snapshot.data?.docs.toList() ??
            <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        docs.sort(
          (a, b) => _dateFrom(
            b.data()['joinedAt'],
          ).compareTo(_dateFrom(a.data()['joinedAt'])),
        );
        final joinedCount =
            docs.where((d) => d.data()['status'] == 'joined').length;

        return Scrollbar(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 32),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      _topHeader(),
                      _heroCard(),
                      const SizedBox(height: 12),
                      _inviteCodeCard(),
                      const SizedBox(height: 12),
                      _shareSection(),
                      const SizedBox(height: 12),
                      _linkCard(),
                      const SizedBox(height: 12),
                      _qrCard(),
                      const SizedBox(height: 12),
                      _statsCard(docs.length, joinedCount),
                      const SizedBox(height: 12),
                      _rewardBanner(),
                      const SizedBox(height: 12),
                      _memberList(snapshot, docs),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
