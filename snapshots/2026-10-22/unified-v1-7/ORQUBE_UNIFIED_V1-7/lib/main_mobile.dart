import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/orqube_v14_entry.dart';
import 'pages/v17_web_home_page.dart';
import 'utils/orqube_i18n.dart';
import 'services/firebase_service.dart';
import 'services/visitor_analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  // AdMob은 Android/iOS 앱에서만 초기화합니다. 웹에서는 지원되지 않습니다.
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  unawaited(VisitorAnalyticsService.instance.start());

  runApp(const OrqubeMobileApp());
}

class OrqubeMobileApp extends StatefulWidget {
  const OrqubeMobileApp({super.key});

  @override
  State<OrqubeMobileApp> createState() => _OrqubeMobileAppState();
}

class _OrqubeMobileAppState extends State<OrqubeMobileApp> {
  String _language = 'ko';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ORQUBE Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF050510),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B2CF6),
          brightness: Brightness.dark,
        ),
      ),
      // 앱도 웹과 같은 ORQUBE 첫 화면으로 시작합니다.
      // 로그인은 기록·공유·보상·자산 기능을 실제 실행하는 시점에 요청합니다.
      home: V17WebHomePage(
        language: _language,
        onLanguageChanged: (value) {
          OrqubeI18n.setLanguage(value);
          setState(() => _language = value);
        },
      ),
    );
  }
}

/// Firebase 로그인 상태만 기준으로 화면을 교체합니다.
///
/// 중요한 점:
/// LoginPage 내부에서 로그인에 성공하면 FirebaseAuth의 authStateChanges가
/// 자동으로 새 User를 전달합니다. 따라서 여기서 Navigator.pushReplacement를
/// 다시 호출하면 안 됩니다. StreamBuilder가 화면을 직접 바꾸도록 두어야
/// 위젯 트리 충돌과 `_dependents.isEmpty` 오류를 피할 수 있습니다.
class MobileAuthGate extends StatefulWidget {
  const MobileAuthGate({super.key});

  @override
  State<MobileAuthGate> createState() => _MobileAuthGateState();
}

class _MobileAuthGateState extends State<MobileAuthGate> {
  String? _preparedUserUid;
  Future<void>? _profileFuture;

  Future<void> _prepareProfileFor(User user) {
    if (_preparedUserUid != user.uid || _profileFuture == null) {
      _preparedUserUid = user.uid;
      _profileFuture = FirebaseService.createUserProfileIfNeeded();
    }

    return _profileFuture!;
  }

  void _resetPreparedProfile() {
    _preparedUserUid = null;
    _profileFuture = null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const MobileSplashScreen();
        }

        if (authSnapshot.hasError) {
          return MobileStartupErrorScreen(
            message:
                '로그인 상태 확인 중 오류가 발생했습니다.\n'
                '${authSnapshot.error}',
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          _resetPreparedProfile();
          return const OrqubeV14Entry();
        }

        return FutureBuilder<void>(
          future: _prepareProfileFor(user),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState != ConnectionState.done) {
              return const MobileSplashScreen();
            }

            if (profileSnapshot.hasError) {
              return MobileStartupErrorScreen(
                message:
                    '사용자 프로필 준비 중 오류가 발생했습니다.\n'
                    '${profileSnapshot.error}',
                onRetry: () {
                  setState(() {
                    _preparedUserUid = null;
                    _profileFuture = null;
                  });
                },
              );
            }

            return const OrqubeV14Entry();
          },
        );
      },
    );
  }
}

/// 별도 mobile_splash_screen.dart 파일은 필요하지 않습니다.
/// 이 클래스가 main_mobile.dart 안에 포함되어 있습니다.
class MobileSplashScreen extends StatelessWidget {
  const MobileSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF050510),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OrqubeSplashLogo(),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Color(0xFFD7FF35)),
              SizedBox(height: 18),
              Text(
                'ORQUBE Mobile Loading...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrqubeSplashLogo extends StatelessWidget {
  const _OrqubeSplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF9B35FF), Color(0xFF2E1065), Color(0xFF050510)],
        ),
        border: Border.all(color: const Color(0xFFD7FF35), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x668B2CF6), blurRadius: 32, spreadRadius: 6),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo/orqube_plane_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.flight_takeoff_rounded,
              size: 56,
              color: Colors.white,
            );
          },
        ),
      ),
    );
  }
}

class MobileStartupErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const MobileStartupErrorScreen({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 58,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 18),
                const Text(
                  'ORQUBE 시작 오류',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('다시 시도'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
