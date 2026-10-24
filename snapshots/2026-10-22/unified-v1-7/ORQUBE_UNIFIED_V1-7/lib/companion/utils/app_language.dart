import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'orqube_i18n.dart';
import 'companion_catalog.dart';
class AppLanguage {
  static final changed = ValueNotifier<String>('ko');
  static const names = {'ko':'한국어', 'en':'English', 'ja':'日本語', 'zh':'中文', 'fr':'Français', 'pt':'Português'};
  static Future<void> initialize(String deviceLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('companion_language');
    final language = names.containsKey(saved) ? saved! : (names.containsKey(deviceLanguage) ? deviceLanguage : 'en');
    OrqubeI18n.setLanguage(language); changed.value = language;
  }
  static Future<void> select(String language) async {
    if (!names.containsKey(language)) return;
    OrqubeI18n.setLanguage(language); changed.value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('companion_language', language);
  }
  static String t(String text) {
    final lang = changed.value;
    if (lang == 'ko') return text;
    final key = text.trim();
    final exact = companionCatalog[key]?[lang];
    if (exact != null) return exact;
    final paired = companionEnglishPairs[key];
    if (paired != null) return OrqubeI18n.nativeTranslation(key, paired);
    return OrqubeI18n.nativeTranslation(key, text);
  }
  static String f(String key, Map<String,String> values) {
    var result = t(key);
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});
  @override Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Language', icon: const Icon(Icons.language),
    initialValue: AppLanguage.changed.value,
    onSelected: (value) { AppLanguage.select(value); },
    itemBuilder: (_) => AppLanguage.names.entries.map((entry) => CheckedPopupMenuItem<String>(value: entry.key, checked: entry.key == AppLanguage.changed.value, child: Text(entry.value))).toList());
}
mixin LanguageAware<T extends StatefulWidget> on State<T> {
  void _languageChanged() { if (mounted) setState(() {}); }
  @override void initState() { super.initState(); AppLanguage.changed.addListener(_languageChanged); }
  @override void dispose() { AppLanguage.changed.removeListener(_languageChanged); super.dispose(); }
}
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextDirection? textDirection;
  final String? semanticsLabel;
  AppText(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.textDirection, this.semanticsLabel});
  @override Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: AppLanguage.changed, builder: (context, language, _) => Text(AppLanguage.t(data), style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow, softWrap: softWrap, textDirection: textDirection, semanticsLabel: semanticsLabel));
}
