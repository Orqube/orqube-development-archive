import 'package:flutter/material.dart';
import '../utils/app_language.dart';
import '../utils/hiking_guide_sections.dart';
import 'companion_theme.dart';
import 'orqube_domain_button.dart';

class HikingDetailedGuidePage extends StatelessWidget {
  const HikingDetailedGuidePage({super.key});
  @override Widget build(BuildContext context) => Theme(
    data: companionLightTheme(),
    child: Scaffold(
      appBar: AppBar(title: AppText('안전산행 상세 안내'), actions: [OrqubeDomainButton(), const LanguageButton()]),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(
            color: const Color(0xFFE6F1E9), borderRadius: BorderRadius.circular(24)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.hiking, size: 42, color: Color(0xFF176B53)),
              const SizedBox(height: 12),
              AppText('네 가지 수색 보완 기능과 사용 순서', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF183A30))),
              const SizedBox(height: 12),
              AppText('통신두절에 대비해 기록하고, 마지막 관측을 수색의 참고자료로 활용하세요.', style: const TextStyle(height: 1.7)),
            ])),
          const SizedBox(height: 16),
          for (var i = 0; i < hikingGuideSections.length; i++) Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ExpansionTile(
              key: PageStorageKey('hiking-guide-$i'), initiallyExpanded: i == 0,
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: AppText(hikingGuideSections[i][0], style: const TextStyle(fontWeight: FontWeight.w700)),
              children: [Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                child: AppText(hikingGuideSections[i][1], style: const TextStyle(height: 1.9, fontSize: 15)))],
            )),
        ]))),
    ),
  );
}
