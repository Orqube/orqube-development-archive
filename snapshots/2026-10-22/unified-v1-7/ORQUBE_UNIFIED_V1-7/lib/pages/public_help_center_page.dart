import 'package:flutter/material.dart';

/// ORQUBE GUIDE
///
/// 안심귀가 · 안전산행 · AIRSOFT HUB 사용법을 한 화면에서 6개국어로 제공합니다.
/// 모든 설명 문자열은 앱 번들에 포함되므로 안전산행 설명은 인터넷 연결 없이도
/// 열람할 수 있습니다. 기존 기능/라우팅에는 영향을 주지 않습니다.
class PublicHelpCenterPage extends StatefulWidget {
  final String language;

  const PublicHelpCenterPage({super.key, required this.language});

  @override
  State<PublicHelpCenterPage> createState() => _PublicHelpCenterPageState();
}

class _PublicHelpCenterPageState extends State<PublicHelpCenterPage> {
  static const Color _bg = Color(0xFF050711);
  static const Color _panel = Color(0xFF10172A);
  static const Color _purple = Color(0xFF8B2CF6);
  static const Color _lime = Color(0xFFD7FF35);
  static const Color _cyan = Color(0xFF35E7F2);

  late String _language;

  @override
  void initState() {
    super.initState();
    _language = _normalize(widget.language);
  }

  String _normalize(String value) {
    const supported = <String>{'ko', 'en', 'ja', 'zh', 'fr', 'pt'};
    return supported.contains(value) ? value : 'ko';
  }

  String _t({
    required String ko,
    required String en,
    required String ja,
    required String zh,
    required String fr,
    required String pt,
  }) {
    switch (_language) {
      case 'en':
        return en;
      case 'ja':
        return ja;
      case 'zh':
        return zh;
      case 'fr':
        return fr;
      case 'pt':
        return pt;
      default:
        return ko;
    }
  }

  String get _languageName {
    switch (_language) {
      case 'en': return 'English';
      case 'ja': return '日本語';
      case 'zh': return '中文';
      case 'fr': return 'Français';
      case 'pt': return 'Português';
      default: return '한국어';
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeHome = _safeHomeSection();
    final hiking = _safeHikingSection();
    final airsoft = _airsoftSection();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: const Text(
          'ORQUBE GUIDE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: PopupMenuButton<String>(
                tooltip: _t(
                  ko: '언어 선택', en: 'Select language', ja: '言語選択',
                  zh: '选择语言', fr: 'Choisir la langue', pt: 'Selecionar idioma',
                ),
                initialValue: _language,
                onSelected: (value) => setState(() => _language = value),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'ko', child: Text('한국어')),
                  PopupMenuItem(value: 'en', child: Text('English')),
                  PopupMenuItem(value: 'ja', child: Text('日本語')),
                  PopupMenuItem(value: 'zh', child: Text('中文')),
                  PopupMenuItem(value: 'fr', child: Text('Français')),
                  PopupMenuItem(value: 'pt', child: Text('Português')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.language_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(_languageName, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _hero(),
          const SizedBox(height: 16),
          _quickFlowCard(),
          const SizedBox(height: 16),
          _GuideCard(section: safeHome),
          _GuideCard(section: hiking, expanded: true),
          _GuideCard(section: airsoft),
          const SizedBox(height: 2),
          _safetyNotice(),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF17102E), Color(0xFF071826)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x558B2CF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: _lime, size: 28),
              SizedBox(width: 10),
              Text(
                'ORQUBE GUIDE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _t(
              ko: '안심귀가 · 안전산행 · AIRSOFT HUB를 처음 사용하는 분도 순서대로 따라 할 수 있는 통합 사용설명서입니다.',
              en: 'A single step-by-step guide for Safe Home, Safe Hiking, and AIRSOFT HUB, designed for first-time users.',
              ja: '安心帰宅・安全登山・AIRSOFT HUBを初めて使う方でも順番に操作できる統合ガイドです。',
              zh: '面向初次使用者的安心回家、安全徒步和 AIRSOFT HUB 一体化分步指南。',
              fr: 'Un guide unique, étape par étape, pour Retour sécurisé, Randonnée sûre et AIRSOFT HUB, même lors de la première utilisation.',
              pt: 'Um guia único e passo a passo para Volta Segura, Trilha Segura e AIRSOFT HUB, inclusive para quem usa pela primeira vez.',
            ),
            style: const TextStyle(color: Colors.white70, height: 1.55, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.offline_bolt_rounded, color: _cyan, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _t(
                    ko: '안전산행 설명은 앱 안에 저장되어 인터넷이 끊겨도 볼 수 있습니다.',
                    en: 'The Safe Hiking instructions are stored inside the app and remain available without Internet.',
                    ja: '安全登山ガイドはアプリ内に保存され、圏外でも閲覧できます。',
                    zh: '安全徒步说明保存在应用内，断网时也可查看。',
                    fr: 'Le guide Randonnée sûre est intégré à l’application et reste consultable sans Internet.',
                    pt: 'As instruções de Trilha Segura ficam no aplicativo e podem ser vistas sem Internet.',
                  ),
                  style: const TextStyle(color: _cyan, fontWeight: FontWeight.w700, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickFlowCard() {
    final items = <String>[
      _t(
        ko: '산행 전 필요한 지역을 지도에 맞춘 뒤 “현재 지도 저장”',
        en: 'Before hiking, frame the needed area and tap “Save Visible Map”',
        ja: '登山前に必要な範囲を表示し「現在の地図を保存」',
        zh: '徒步前调整到所需区域，然后点击“保存当前地图”',
        fr: 'Avant la randonnée, cadrez la zone voulue puis touchez « Enregistrer la carte visible »',
        pt: 'Antes da trilha, enquadre a área necessária e toque em “Salvar mapa visível”',
      ),
      _t(
        ko: '인터넷 단절 시 저장 지도 + 현재 GPS + 청록색 이동경로 + 출발점 확인',
        en: 'Offline: use the saved map + current GPS + cyan route + start point',
        ja: '圏外では保存地図＋現在GPS＋水色の移動経路＋出発点を確認',
        zh: '断网时查看已保存地图 + 当前 GPS + 青色轨迹 + 出发点',
        fr: 'Hors ligne : carte enregistrée + GPS actuel + trace cyan + point de départ',
        pt: 'Sem Internet: mapa salvo + GPS atual + rota ciano + ponto de partida',
      ),
      _t(
        ko: '통신 복구 후 보호자 공유·서버 전달 재개',
        en: 'When connectivity returns, guardian sharing/server delivery can resume',
        ja: '通信復旧後、保護者共有・サーバー送信を再開',
        zh: '网络恢复后继续监护人共享与服务器传送',
        fr: 'Au retour du réseau, le partage avec le proche et les envois serveur peuvent reprendre',
        pt: 'Quando a conexão voltar, o compartilhamento e o envio ao servidor podem continuar',
      ),
      _t(
        ko: '하산 완료 후 “안전하게 하산했습니다”로 종료',
        en: 'After descending, finish with “I Arrived Safely”',
        ja: '下山後「安全に下山しました」で終了',
        zh: '下山后点击“我已安全下山”结束',
        fr: 'Après la descente, terminez avec « Je suis arrivé en sécurité »',
        pt: 'Após descer, finalize com “Cheguei em segurança”',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1820),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x6635E7F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t(
              ko: '안전산행 핵심 흐름', en: 'Safe Hiking core flow', ja: '安全登山の基本フロー',
              zh: '安全徒步核心流程', fr: 'Flux essentiel Randonnée sûre', pt: 'Fluxo principal da Trilha Segura',
            ),
            style: const TextStyle(color: _cyan, fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 11),
          for (var i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: _purple, shape: BoxShape.circle),
                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(items[i], style: const TextStyle(color: Colors.white70, height: 1.45))),
              ],
            ),
            if (i != items.length - 1) const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }

  _GuideSection _safeHomeSection() {
    return _GuideSection(
      icon: Icons.shield_rounded,
      iconColor: _lime,
      title: _t(ko: '안심귀가 사용법', en: 'Safe Home guide', ja: '安心帰宅の使い方', zh: '安心回家使用方法', fr: 'Guide Retour sécurisé', pt: 'Guia Volta Segura'),
      subtitle: _t(
        ko: '귀가 중 현재 위치와 도착 예상 정보를 활용하는 안전 보조 기능',
        en: 'A safety aid for using your live location and arrival estimate while going home.',
        ja: '帰宅中の現在地と到着予想情報を活用する安全補助機能です。',
        zh: '回家途中利用实时位置和预计到达信息的安全辅助功能。',
        fr: 'Une fonction d’assistance utilisant votre position et l’estimation d’arrivée pendant le retour.',
        pt: 'Um recurso de apoio que usa sua localização e previsão de chegada durante o retorno.',
      ),
      steps: [
        _t(ko: 'ORQUBE에 로그인한 뒤 안심귀가를 엽니다. 처음 사용할 때는 휴대전화의 위치 권한을 허용합니다.', en: 'Log in to ORQUBE and open Safe Home. On first use, allow the phone’s location permission.', ja: 'ORQUBEにログインして安心帰宅を開きます。初回は端末の位置情報を許可します。', zh: '登录 ORQUBE 后打开安心回家。首次使用时允许手机定位权限。', fr: 'Connectez-vous à ORQUBE et ouvrez Retour sécurisé. Lors de la première utilisation, autorisez la localisation.', pt: 'Entre no ORQUBE e abra Volta Segura. No primeiro uso, permita a localização do telefone.'),
        _t(ko: '지도에서 목적지를 정합니다. 목적지가 설정되면 거리와 예상 도착시간(ETA)을 확인할 수 있습니다.', en: 'Set a destination on the map. Once selected, check distance and estimated arrival time (ETA).', ja: '地図で目的地を設定します。設定後、距離と到着予定時刻（ETA）を確認できます。', zh: '在地图上设置目的地。设置后可查看距离和预计到达时间（ETA）。', fr: 'Définissez une destination sur la carte. Vous pourrez ensuite voir la distance et l’heure d’arrivée estimée (ETA).', pt: 'Defina um destino no mapa. Depois, confira a distância e o horário estimado de chegada (ETA).'),
        _t(ko: '보호자 또는 가족에게 위치 공유가 필요한 경우 화면의 공유 기능을 사용합니다.', en: 'If a guardian or family member needs your location, use the sharing function on the screen.', ja: '保護者や家族に位置共有が必要な場合は、画面の共有機能を使います。', zh: '如需向监护人或家人共享位置，请使用页面上的共享功能。', fr: 'Si un proche doit connaître votre position, utilisez la fonction de partage affichée.', pt: 'Se um responsável ou familiar precisar da sua localização, use o compartilhamento da tela.'),
        _t(ko: '이동을 시작하면 현재 위치를 확인하면서 귀가합니다. ETA는 GPS와 상황에 따라 달라질 수 있습니다.', en: 'Start moving and follow your current location. ETA can vary with GPS and real-world conditions.', ja: '移動を開始し、現在地を確認しながら帰宅します。ETAはGPSや状況により変わります。', zh: '开始移动并查看当前位置。ETA 会因 GPS 和实际情况而变化。', fr: 'Commencez le trajet en suivant votre position. L’ETA peut varier selon le GPS et les conditions réelles.', pt: 'Inicie o deslocamento acompanhando sua posição. O ETA pode variar conforme o GPS e as condições reais.'),
        _t(ko: '도착하면 추적/공유를 종료합니다. SOS는 긴급 상황을 위한 보조 기능이며 실제 구조를 보장하는 기능은 아닙니다.', en: 'When you arrive, stop tracking/sharing. SOS is an emergency support feature and does not guarantee rescue.', ja: '到着したら追跡・共有を終了します。SOSは緊急時の補助機能であり、救助を保証するものではありません。', zh: '到达后结束追踪/共享。SOS 是紧急辅助功能，并不保证救援。', fr: 'À l’arrivée, arrêtez le suivi/partage. SOS est une aide d’urgence et ne garantit pas une intervention.', pt: 'Ao chegar, encerre o rastreamento/compartilhamento. SOS é um apoio de emergência e não garante resgate.'),
      ],
    );
  }

  _GuideSection _safeHikingSection() {
    return _GuideSection(
      icon: Icons.terrain_rounded,
      iconColor: _cyan,
      title: _t(ko: '안전산행 사용법 · 오프라인 포함', en: 'Safe Hiking guide · including offline use', ja: '安全登山の使い方・オフライン対応', zh: '安全徒步使用方法 · 含离线模式', fr: 'Guide Randonnée sûre · avec mode hors ligne', pt: 'Guia Trilha Segura · incluindo uso offline'),
      subtitle: _t(
        ko: '인터넷이 끊겨도 저장 지도와 기기 GPS를 이용해 현재 위치·이동경로·출발점을 확인합니다.',
        en: 'Even without Internet, use the saved map and device GPS to check your position, route, and start point.',
        ja: '圏外でも保存地図と端末GPSで現在地・移動経路・出発点を確認できます。',
        zh: '即使断网，也可利用已保存地图和设备 GPS 查看当前位置、轨迹和出发点。',
        fr: 'Même sans Internet, utilisez la carte enregistrée et le GPS de l’appareil pour voir position, trajet et départ.',
        pt: 'Mesmo sem Internet, use o mapa salvo e o GPS do aparelho para ver posição, rota e ponto de partida.',
      ),
      steps: [
        _t(ko: '산에 들어가기 전, 인터넷이 연결된 곳에서 ORQUBE → 안전산행을 열고 위치 권한을 허용합니다.', en: 'Before entering the mountain, while Internet is available, open ORQUBE → Safe Hiking and allow location permission.', ja: '入山前、通信できる場所で ORQUBE → 安全登山を開き、位置情報を許可します。', zh: '进山前在有网络的地方打开 ORQUBE → 安全徒步，并允许定位权限。', fr: 'Avant d’entrer en montagne, avec Internet disponible, ouvrez ORQUBE → Randonnée sûre et autorisez la localisation.', pt: 'Antes de entrar na montanha, com Internet disponível, abra ORQUBE → Trilha Segura e permita a localização.'),
        _t(ko: '지도를 산행할 지역으로 이동한 뒤 확대/축소하여 필요한 범위가 화면에 보이도록 맞춥니다.', en: 'Pan and zoom the map until the area you will hike is visible on screen.', ja: '地図を登山地域へ移動し、拡大・縮小して必要な範囲を画面に表示します。', zh: '将地图移动到徒步区域，并缩放到屏幕上能看到所需范围。', fr: 'Déplacez et zoomez la carte pour afficher à l’écran toute la zone de randonnée nécessaire.', pt: 'Mova e ajuste o zoom do mapa até que a área necessária da trilha apareça na tela.'),
        _t(ko: '오프라인 안전 정보에서 “현재 지도 저장”을 누릅니다. “지도 저장됨” 상태가 보이면 준비가 끝난 것입니다. 이 저장 기능은 모바일 앱에서 사용합니다.', en: 'In Offline Safety, tap “Save Visible Map”. When the status shows the map is saved, preparation is complete. This saving feature is for the mobile app.', ja: '「オフライン安全情報」で「現在の地図を保存」を押します。「保存済み」と表示されれば準備完了です。この保存機能はモバイルアプリ用です。', zh: '在“离线安全信息”中点击“保存当前地图”。显示地图已保存即表示准备完成。此保存功能用于手机应用。', fr: 'Dans Sécurité hors ligne, touchez « Enregistrer la carte visible ». Lorsque l’état indique qu’elle est enregistrée, la préparation est terminée. Cette fonction est destinée à l’application mobile.', pt: 'Em Segurança Offline, toque em “Salvar mapa visível”. Quando o status indicar mapa salvo, a preparação terminou. Esse recurso é para o aplicativo móvel.'),
        _t(ko: '보호자 정보와 귀환 예정시간을 확인한 뒤 “산행 시작”을 누릅니다. 시작 순간의 위치가 출발점으로 저장되고 GPS 이동경로 기록이 시작됩니다.', en: 'Check guardian information and planned return time, then tap “Start Hiking”. Your position at that moment becomes the start point and GPS route recording begins.', ja: '保護者情報と帰還予定時刻を確認し「登山開始」を押します。その時点の位置が出発点として保存され、GPS経路記録が始まります。', zh: '确认监护人信息和预计返回时间后点击“开始徒步”。此时位置会保存为出发点，并开始记录 GPS 轨迹。', fr: 'Vérifiez le proche et l’heure de retour prévue, puis touchez « Démarrer la randonnée ». La position devient le point de départ et l’enregistrement GPS commence.', pt: 'Confira o responsável e o horário previsto de retorno, depois toque em “Iniciar trilha”. A posição vira o ponto de partida e o registro GPS começa.'),
        _t(ko: '인터넷이 끊겨도 당황하지 마세요. 휴대전화의 위치 서비스(GPS)가 켜져 있으면 저장된 지도 위에 현재 GPS, 청록색 이동경로, 출발점, 좌표·고도·이동거리 등을 계속 확인할 수 있습니다.', en: 'If Internet disconnects, the hike can still use device GPS. With location services on, the saved map can continue showing current GPS, the cyan route, start point, coordinates, altitude, and traveled distance.', ja: '圏外になっても、端末の位置情報（GPS）が有効なら、保存地図上で現在GPS、水色の移動経路、出発点、座標・高度・移動距離などを確認できます。', zh: '断网后只要手机定位服务（GPS）开启，仍可在已保存地图上查看当前 GPS、青色轨迹、出发点、坐标、高度和移动距离等。', fr: 'Si Internet se coupe, le GPS de l’appareil reste utilisable. Avec la localisation activée, la carte enregistrée peut afficher GPS actuel, trace cyan, départ, coordonnées, altitude et distance parcourue.', pt: 'Se a Internet cair, o GPS do aparelho ainda pode funcionar. Com a localização ativa, o mapa salvo mostra GPS atual, rota ciano, início, coordenadas, altitude e distância percorrida.'),
        _t(ko: '길을 되돌아가야 할 때는 “출발점 귀환”을 눌러 출발점을 귀환 기준점으로 설정하고, 청록색으로 기록된 실제 이동경로를 함께 참고합니다.', en: 'If you need to return, tap “Return to Start” to set the start point as the return reference, and use the recorded cyan route as a guide.', ja: '戻る必要がある場合は「出発点へ戻る」を押して出発点を帰還基準にし、水色で記録された実際の経路も参考にします。', zh: '需要返回时点击“返回出发点”，将出发点设为返回参考，同时参考青色记录的实际移动轨迹。', fr: 'Pour revenir, touchez « Retour au départ » afin de définir le départ comme référence et suivez aussi la trace cyan enregistrée.', pt: 'Para retornar, toque em “Voltar ao início” para usar o ponto inicial como referência e consulte também a rota ciano gravada.'),
        _t(ko: '인터넷이 끊긴 동안에는 주소 검색, 보호자 원격 공유, SOS의 서버 전달이 지연될 수 있습니다. 통신이 복구되면 서버 기반 기능을 다시 사용할 수 있습니다.', en: 'While offline, address search, remote guardian sharing, and server delivery of SOS can be delayed. Server-based functions can resume when connectivity returns.', ja: '圏外中は住所検索、保護者への遠隔共有、SOSのサーバー送信が遅れる場合があります。通信復旧後にサーバー機能を再利用できます。', zh: '断网期间，地址搜索、监护人远程共享和 SOS 服务器传送可能延迟。网络恢复后可继续使用服务器功能。', fr: 'Hors ligne, la recherche d’adresse, le partage distant et l’envoi SOS au serveur peuvent être retardés. Ils reprennent lorsque la connexion revient.', pt: 'Sem Internet, busca de endereço, compartilhamento remoto e envio de SOS ao servidor podem atrasar. Eles voltam quando a conexão é restabelecida.'),
        _t(ko: '안전하게 하산한 뒤 반드시 “안전하게 하산했습니다” 또는 산행 종료 기능으로 세션을 끝냅니다.', en: 'After safely descending, always finish the session with “I Arrived Safely” or the hike end function.', ja: '安全に下山したら、必ず「安全に下山しました」または登山終了機能でセッションを終了します。', zh: '安全下山后，请务必点击“我已安全下山”或使用结束徒步功能终止会话。', fr: 'Après une descente sûre, terminez toujours la session avec « Je suis arrivé en sécurité » ou la fonction de fin de randonnée.', pt: 'Depois de descer com segurança, sempre finalize a sessão com “Cheguei em segurança” ou a função de encerrar trilha.'),
      ],
      notes: [
        _t(ko: '오프라인 지도는 “현재 화면에 보이는 범위”를 저장합니다. 산행 전에 필요한 구역이 충분히 들어오도록 확대/축소한 뒤 저장하세요.', en: 'The offline map saves the area currently visible on screen. Before hiking, zoom so the required area is fully included before saving.', ja: 'オフライン地図は「現在画面に見えている範囲」を保存します。必要地域が十分入るよう調整してから保存してください。', zh: '离线地图保存的是“当前屏幕可见范围”。徒步前请缩放到覆盖所需区域后再保存。', fr: 'La carte hors ligne enregistre la zone visible à l’écran. Avant de partir, ajustez le zoom pour inclure toute la zone nécessaire.', pt: 'O mapa offline salva a área visível na tela. Antes da trilha, ajuste o zoom para incluir toda a região necessária.'),
        _t(ko: 'GPS는 인터넷과 별개지만, 실내·협곡·짙은 수목·기상·배터리 상태 등에 따라 오차나 지연이 생길 수 있습니다.', en: 'GPS is separate from Internet, but accuracy or updates can be affected by buildings, valleys, dense trees, weather, or battery conditions.', ja: 'GPSはインターネットとは別ですが、建物・谷・樹木・天候・電池状態などで誤差や遅延が生じる場合があります。', zh: 'GPS 与互联网相互独立，但建筑、峡谷、密林、天气或电池状态可能造成误差或延迟。', fr: 'Le GPS est indépendant d’Internet, mais bâtiments, vallées, végétation dense, météo ou batterie peuvent réduire la précision ou retarder les mises à jour.', pt: 'O GPS é independente da Internet, mas prédios, vales, mata fechada, clima ou bateria podem causar erros ou atrasos.'),
      ],
    );
  }

  _GuideSection _airsoftSection() {
    return _GuideSection(
      icon: Icons.sports_martial_arts_rounded,
      iconColor: const Color(0xFFFFB74D),
      title: 'AIRSOFT HUB',
      subtitle: _t(
        ko: '경기·팀·필드·업체·마켓 등 에어소프트 활동을 한 공간에서 연결하는 허브',
        en: 'A hub that connects matches, teams, fields, businesses, marketplace, and other Airsoft activity in one place.',
        ja: '試合・チーム・フィールド・事業者・マーケットなどを一か所でつなぐエアソフトハブです。',
        zh: '在一个空间连接比赛、团队、场地、商家、市场等 Airsoft 活动的中心。',
        fr: 'Un hub réunissant parties, équipes, terrains, entreprises, marché et autres activités Airsoft.',
        pt: 'Um hub que reúne jogos, equipes, campos, empresas, mercado e outras atividades de Airsoft.',
      ),
      steps: [
        _t(ko: 'ORQUBE에 로그인한 뒤 AIRSOFT HUB를 엽니다.', en: 'Log in to ORQUBE and open AIRSOFT HUB.', ja: 'ORQUBEにログインして AIRSOFT HUB を開きます。', zh: '登录 ORQUBE 后打开 AIRSOFT HUB。', fr: 'Connectez-vous à ORQUBE puis ouvrez AIRSOFT HUB.', pt: 'Entre no ORQUBE e abra o AIRSOFT HUB.'),
        _t(ko: '지도에서 주변 경기장 또는 등록된 장소의 마커를 눌러 위치와 상세 정보를 확인합니다.', en: 'On the map, tap a nearby field or registered-place marker to view its location and details.', ja: '地図上の周辺フィールドや登録地点のマーカーを押して、位置と詳細を確認します。', zh: '在地图上点击附近场地或已登记地点的标记，查看位置和详细信息。', fr: 'Sur la carte, touchez un terrain proche ou un lieu enregistré pour voir sa position et ses détails.', pt: 'No mapa, toque em um campo próximo ou marcador de local cadastrado para ver localização e detalhes.'),
        _t(ko: '경기를 만들려면 경기 등록에서 경기명·장소·일시·설명을 입력합니다. 참가자는 등록된 경기의 안내와 승인 절차를 따릅니다.', en: 'To create a match, enter name, place, date/time, and description in Match Registration. Participants follow the displayed registration/approval flow.', ja: '試合を作る場合は、試合登録で名称・場所・日時・説明を入力します。参加者は表示される申請・承認手順に従います。', zh: '创建比赛时，在比赛登记中填写名称、地点、日期时间和说明。参与者按照显示的申请与审核流程操作。', fr: 'Pour créer une partie, renseignez nom, lieu, date/heure et description. Les participants suivent ensuite le processus d’inscription et de validation affiché.', pt: 'Para criar um jogo, informe nome, local, data/hora e descrição. Os participantes seguem o fluxo de inscrição e aprovação exibido.'),
        _t(ko: '팀 기능에서는 팀 등록과 팀 정보를 관리하고, 필요한 경우 참가자·팀원 간 커뮤니티/채팅 기능을 이용합니다.', en: 'Use team features to register/manage a team and, where available, communicate through community/chat functions.', ja: 'チーム機能でチーム登録・情報管理を行い、必要に応じてコミュニティやチャットを利用します。', zh: '使用团队功能登记和管理团队，并在需要时通过社区/聊天功能沟通。', fr: 'Les fonctions d’équipe permettent d’enregistrer et gérer une équipe et, si disponible, d’utiliser communauté/chat pour communiquer.', pt: 'Use os recursos de equipe para cadastrar e gerenciar a equipe e, quando disponível, comunicar-se pela comunidade/chat.'),
        _t(ko: '필드 또는 업체를 등록할 때는 화면 안내에 따라 위치·주소·설명 등 필수 정보를 입력합니다. 일부 등록은 관리자 승인 전까지 제한적으로 보일 수 있습니다.', en: 'When registering a field or business, enter required location, address, and description information. Some entries may have limited visibility before administrator approval.', ja: 'フィールドや事業者登録では、案内に従い位置・住所・説明など必須情報を入力します。管理者承認前は表示が制限される場合があります。', zh: '登记场地或商家时，请按页面说明填写位置、地址、说明等必填信息。部分内容在管理员审核前可能仅有限显示。', fr: 'Pour enregistrer un terrain ou une entreprise, saisissez les informations requises. Certains éléments peuvent rester à visibilité limitée avant validation administrateur.', pt: 'Ao cadastrar campo ou empresa, preencha localização, endereço, descrição e demais dados obrigatórios. Alguns cadastros podem ter visibilidade limitada até aprovação.'),
        _t(ko: '마켓 기능을 사용할 때는 상품명·가격·설명을 정확히 입력하고, 실제 거래 시에는 현지 법규와 안전수칙을 반드시 확인합니다.', en: 'When using marketplace features, enter item name, price, and description accurately, and always check local laws and safety rules for actual transactions.', ja: 'マーケット利用時は商品名・価格・説明を正確に入力し、実際の取引では現地法令と安全ルールを必ず確認してください。', zh: '使用市场功能时请准确填写商品名、价格和说明，实际交易务必遵守当地法律和安全规则。', fr: 'Pour le marché, renseignez précisément article, prix et description, et vérifiez toujours la réglementation locale et les règles de sécurité avant toute transaction.', pt: 'No mercado, informe corretamente item, preço e descrição e verifique sempre as leis locais e regras de segurança antes de qualquer transação.'),
      ],
    );
  }

  Widget _safetyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15112B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x558B2CF6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: _lime),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              _t(
                ko: 'ORQUBE의 위치·SOS·공유 기능은 안전을 돕는 보조 수단입니다. 긴급 상황에서는 주변의 실제 안전수단과 해당 지역의 공식 긴급 구조 체계를 함께 이용하세요.',
                en: 'ORQUBE location, SOS, and sharing features are safety aids. In an emergency, also use real-world safety resources and the official emergency services available in your area.',
                ja: 'ORQUBEの位置・SOS・共有機能は安全を補助する手段です。緊急時は周囲の実際の安全手段と地域の公的緊急サービスも利用してください。',
                zh: 'ORQUBE 的定位、SOS 和共享功能属于安全辅助工具。紧急情况下，请同时使用现实中的安全措施和当地官方紧急救援体系。',
                fr: 'Les fonctions de localisation, SOS et partage d’ORQUBE sont des aides. En urgence, utilisez aussi les moyens de sécurité réels et les services d’urgence officiels de votre zone.',
                pt: 'Localização, SOS e compartilhamento do ORQUBE são recursos de apoio. Em emergência, use também meios reais de segurança e os serviços oficiais de emergência da sua região.',
              ),
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideSection {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<String> steps;
  final List<String> notes;

  const _GuideSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.steps,
    this.notes = const [],
  });
}

class _GuideCard extends StatelessWidget {
  final _GuideSection section;
  final bool expanded;

  const _GuideCard({required this.section, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: const Color(0xFF10172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: section.iconColor.withOpacity(0.25)),
      ),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        iconColor: section.iconColor,
        collapsedIconColor: Colors.white70,
        leading: Icon(section.icon, color: section.iconColor, size: 27),
        title: Text(section.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(section.subtitle, style: const TextStyle(color: Colors.white54, height: 1.35, fontSize: 12.5)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              children: [
                for (var i = 0; i < section.steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: section.iconColor.withOpacity(0.18), shape: BoxShape.circle, border: Border.all(color: section.iconColor.withOpacity(0.5))),
                          child: Text('${i + 1}', style: TextStyle(color: section.iconColor, fontSize: 12, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 11),
                        Expanded(child: Text(section.steps[i], style: const TextStyle(color: Colors.white70, height: 1.55))),
                      ],
                    ),
                  ),
                if (section.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tips_and_updates_outlined, color: Color(0xFFD7FF35), size: 18),
                            SizedBox(width: 7),
                            Text('TIP', style: TextStyle(color: Color(0xFFD7FF35), fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final note in section.notes)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $note', style: const TextStyle(color: Colors.white60, height: 1.45)),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
