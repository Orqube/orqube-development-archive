import 'package:flutter/material.dart';
import 'utils/app_language.dart';
import 'services/invite_inbox.dart';
import 'pages/welcome_page.dart';
import 'pages/safe_hiking_page.dart';

/// Uses the existing default Firebase app and authenticated ORQUBE session.
class CompanionEntry extends StatefulWidget {
  final String language;
  final bool? safeReturn;
  const CompanionEntry({super.key, required this.language, this.safeReturn});
  @override State<CompanionEntry> createState() => _CompanionEntryState();
}
class _CompanionEntryState extends State<CompanionEntry> {
  late final Future<void> ready = initialize();
  Future<void> initialize() async {
    await AppLanguage.initialize(widget.language);
    await AppLanguage.select(widget.language);
    await InviteInbox.initialize();
  }
  @override Widget build(BuildContext context) => FutureBuilder<void>(
    future: ready,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(appBar: AppBar(title: const Text('ORQUBE')), body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Could not open Safe Companion.'),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ORQUBE')),
        ])));
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
      }
      return WelcomeGate(initialMode: widget.safeReturn == null ? null : widget.safeReturn! ? OrqubeMapMode.safeHome : OrqubeMapMode.safeHiking);
    },
  );
}
