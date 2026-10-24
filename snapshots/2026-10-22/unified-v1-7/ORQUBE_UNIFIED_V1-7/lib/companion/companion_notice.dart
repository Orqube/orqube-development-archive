import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'companion_entry.dart';

class CompanionNotice extends StatefulWidget {
  final String language;
  const CompanionNotice({super.key, required this.language});
  @override State<CompanionNotice> createState() => _CompanionNoticeState();
}
class _CompanionNoticeState extends State<CompanionNotice> {
  late final Future<Uri?> release = loadRelease();
  static const copy = <String, List<String>>{
    'ko': ['안심동행 V2.3 · 별도 Android 앱 안내', '안전산행·안심귀가·실시간 이동 지도·가족과 친구 위치 공유를 6개 언어로 이용하세요.', '웹에서 이용하기', 'Android APK 다운로드', 'APK 준비 중 · 웹 기능을 먼저 이용하세요', '휴대폰 설치 테스트용 APK입니다. Google Play 출시본은 준비 중입니다.', '다운로드를 열지 못했습니다. 잠시 후 다시 시도하세요.'],
    'en': ['Safe Companion V2.3 · Android app', 'Safe hiking, safe return, live route maps and location sharing with family and friends in six languages.', 'Use on the web', 'Download Android APK', 'APK coming soon · Use the web app', 'APK for device testing. Google Play release is in preparation.', 'Could not open the download. Please try again.'],
    'ja': ['安心同行 V2.3 · Androidアプリ', '安全登山・安心帰宅・移動地図・家族や友人との位置共有を6言語で利用できます。', 'ウェブで利用', 'Android APKをダウンロード', 'APK準備中 · ウェブ版をご利用ください', '端末テスト用APKです。Google Play公開版は準備中です。', 'ダウンロードを開けませんでした。再度お試しください。'],
    'zh': ['安心同行 V2.3 · Android应用', '使用六种语言体验安全登山、安心回家、实时路线地图及亲友位置共享。', '使用网页版', '下载Android APK', 'APK准备中 · 请先使用网页版', '此APK用于手机安装测试。Google Play发布版正在准备中。', '无法打开下载，请重试。'],
    'fr': ['Accompagnement sûr V2.3 · Android', 'Randonnée, retour sécurisé, itinéraire en direct et partage de position avec vos proches en six langues.', 'Utiliser sur le Web', 'Télécharger l’APK Android', 'APK en préparation · Utilisez le Web', 'APK de test sur appareil. Publication Google Play en préparation.', 'Impossible d’ouvrir le téléchargement. Réessayez.'],
    'pt': ['Companhia segura V2.3 · Android', 'Trilhas, volta segura, mapa do percurso ao vivo e localização compartilhada com pessoas próximas em seis idiomas.', 'Usar na Web', 'Baixar APK Android', 'APK em preparação · Use a versão Web', 'APK para testes no celular. Publicação no Google Play em preparação.', 'Não foi possível abrir o download. Tente novamente.'],
  };
  Future<Uri?> loadRelease() async {
    if (!kIsWeb) return null;
    try {
      final uri = Uri.base.resolve('/downloads/release.json').replace(queryParameters: {'t': DateTime.now().millisecondsSinceEpoch.toString()});
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(response.bodyBytes).replaceFirst('\uFEFF', ''));
      if (data is! Map || data['available'] != true || data['file'] != 'orqube-safe-companion.apk') return null;
      return Uri.base.resolve('/downloads/orqube-safe-companion.apk');
    } catch (_) { return null; }
  }
  @override Widget build(BuildContext context) {
    final text = copy[widget.language] ?? copy['ko']!;
    return ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1040), child: Container(
      width: double.infinity, padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: const Color(0xFF123C39), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF64DDB1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.health_and_safety_outlined, color: Color(0xFF8DEECC), size: 32),
        const SizedBox(height: 10), Text(text[0], style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10), Text(text[1], style: const TextStyle(color: Color(0xFFDDEDE8), height: 1.6)),
        const SizedBox(height: 16),
        FutureBuilder<Uri?>(future: release, builder: (context, snapshot) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => CompanionEntry(language: widget.language))), icon: const Icon(Icons.map_outlined), label: Text(text[2]), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8DEECC), foregroundColor: const Color(0xFF102A25))),
            OutlinedButton.icon(onPressed: snapshot.data == null ? null : () async {
              try {
                if (!await launchUrl(snapshot.data!, webOnlyWindowName: '_blank')) throw StateError('Download unavailable');
              } catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text[6]))); }
            }, icon: const Icon(Icons.download), label: Text(text[3]), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, disabledForegroundColor: const Color(0xFFB5CBC4), side: const BorderSide(color: Color(0xFF6BADA0)))),
          ]),
          const SizedBox(height: 12), Text(snapshot.data == null ? text[4] : text[5], style: const TextStyle(color: Color(0xFFCCE1D9), fontSize: 13, height: 1.5)),
        ])),
      ]),
    ));
  }
}
