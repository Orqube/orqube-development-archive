import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/welcome_page.dart';
import 'services/invite_inbox.dart';
import 'utils/app_language.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLanguage.initialize(WidgetsBinding.instance.platformDispatcher.locale.languageCode);
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAuth.instance.setLanguageCode(AppLanguage.changed.value);
    AppLanguage.changed.addListener(() { FirebaseAuth.instance.setLanguageCode(AppLanguage.changed.value); });
    if (kIsWeb) await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    // Refresh server-backed verification without signing the user out.
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload().timeout(const Duration(seconds: 5));
        await FirebaseAuth.instance.currentUser?.getIdToken(true).timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      // Temporary offline failures must not clear the persisted login.
    }
    const key = String.fromEnvironment('ORQUBE_RECAPTCHA_V3_SITE_KEY');
    if (!kIsWeb || key.isNotEmpty) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
        webProvider: ReCaptchaV3Provider(key),
      );
    }
    await InviteInbox.initialize();
    runApp(const HikingApp());
  } catch (e) {
    runApp(MaterialApp(home: Scaffold(body: Center(child: SelectableText('초기화 실패: $e\nREADME_KO.txt의 Firebase 설정을 확인하세요.')))));
  }
}
class HikingApp extends StatelessWidget {
  const HikingApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(valueListenable: AppLanguage.changed, builder: (context, language, _) => MaterialApp(
    locale: Locale(language),
    supportedLocales: AppLanguage.names.keys.map((code) => Locale(code)).toList(),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    title: AppLanguage.t('ORQUBE 안심동행'), debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'OrqubeHangul', brightness: Brightness.dark, useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF39D9FF), brightness: Brightness.dark)),
    home: WelcomeGate(),
  ));
}
