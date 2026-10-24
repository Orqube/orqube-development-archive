import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orqube_safe_hiking/utils/app_language.dart';
import 'package:orqube_safe_hiking/utils/companion_catalog.dart';
import 'package:orqube_safe_hiking/utils/hiking_guide_sections.dart';
import 'package:orqube_safe_hiking/pages/hiking_detailed_guide_page.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLanguage.initialize('ko');
  });
  test('Every catalog row supplies five complete target translations and matching placeholders', () {
    final placeholder = RegExp(r'\{([a-zA-Z]+)\}');
    for (final entry in companionCatalog.entries) {
      final expected = placeholder.allMatches(entry.key).map((m) => m.group(1)).toSet();
      for (final lang in ['en','ja','zh','fr','pt']) {
        final text = entry.value[lang];
        expect(text, isNotNull, reason: '${entry.key}: $lang');
        expect(text!.trim(), isNotEmpty);
        expect(RegExp(r'[가-힣]').hasMatch(text), false, reason: '${entry.key}: $lang');
        expect(placeholder.allMatches(text).map((m) => m.group(1)).toSet(), expected);
      }
    }
  });
  test('Reported dashboard and account messages translate as whole messages in all locales', () async {
    const labels = [
      '한 걸음의 설렘부터\n집으로 돌아오는 순간까지.',
      '안심동행 · 로그인 / 계정',
      '로그인 → 내 위치 확인 → 목적지 선택 → 귀가 시작. 승인된 보호자와 공유하려면 위치 공유를 켜주세요.',
      '로그인 → 내 위치 확인 → 산행 시작. 승인된 보호자와 공유하려면 위치 공유를 켜주세요.',
      '서버 위치 공유 • 비활성',
      '개인 이동 기록은 본인 계정에 저장됩니다. 별도로 승인한 보호자는 위치 공유 중 현재 위치와 최근 경로를 볼 수 있습니다. 아래 문자·메신저 버튼은 현재 좌표를 직접 보내는 기능입니다.',
      '위치 공유는 이동 화면에서 시작·중지할 수 있습니다. 계정 관리 후 이동 상태와 공유 상태를 확인하세요.',
    ];
    for (final lang in ['ko','en','ja','zh','fr','pt']) {
      await AppLanguage.select(lang);
      for (final text in labels) {
        expect(AppLanguage.t(text), lang == 'ko' ? text : companionCatalog[text]![lang]);
      }
      final result = AppLanguage.f('보호자: {name} • 자동 알림 미지원', {'name': 'TEST_NAME'});
      expect(result, contains('TEST_NAME'));
      expect(result, isNot(contains('{name}')));
    }
  });
  testWidgets('Detailed guide switches all sections without recreating the page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390,844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: HikingDetailedGuidePage()));
    await tester.pumpAndSettle();
    for (final lang in ['ko','en','ja','zh','fr','pt']) {
      await AppLanguage.select(lang);
      await tester.pumpAndSettle();
      final title = hikingGuideSections.first.first;
      expect(find.text(lang == 'ko' ? title : companionCatalog[title]![lang]!), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
