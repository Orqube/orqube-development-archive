import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orqube_safe_hiking/pages/welcome_page.dart';
import 'package:orqube_safe_hiking/pages/public_help_center_page.dart';
import 'package:orqube_safe_hiking/utils/app_language.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLanguage.initialize('ko');
  });
  testWidgets('Consent gates first entry and uses a light theme', (tester) async {
    await tester.pumpWidget(MaterialApp(home: WelcomeGate()));
    await tester.pumpAndSettle();
    final start = find.byType(FilledButton);
    await tester.scrollUntilVisible(start, 250);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(start).onPressed, isNull);
    final tile = find.byType(CheckboxListTile);
    await tester.scrollUntilVisible(tile, -150);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    final ctx = tester.element(tile);
    expect(Theme.of(ctx).brightness, Brightness.light);
    await tester.scrollUntilVisible(start, 150);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(start).onPressed, isNotNull);
  });
  testWidgets('Guide language changes without recreating the route', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PublicHelpCenterPage(language: 'ko')));
    await tester.pumpAndSettle();
    expect(find.text('안전산행 · 안심귀가 · 가족과 친구'), findsOneWidget);
    await AppLanguage.select('en');
    await tester.pumpAndSettle();
    expect(find.text('Hiking · Safe return · Family and friends'), findsOneWidget);
    await AppLanguage.select('ja');
    await tester.pumpAndSettle();
    expect(find.text('登山・帰宅・家族と友人'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('companion_language'), 'ja');
  });
}
