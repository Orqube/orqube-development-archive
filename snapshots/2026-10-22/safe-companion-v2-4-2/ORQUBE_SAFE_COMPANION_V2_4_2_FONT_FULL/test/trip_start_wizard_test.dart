import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:orqube_safe_hiking/utils/app_language.dart';
import 'package:orqube_safe_hiking/pages/trip_start_wizard.dart';
void main(){
  setUp(()async{SharedPreferences.setMockInitialValues({});await AppLanguage.initialize('ko');});
  testWidgets('Mobile wizard gates explanation and consent without requesting GPS automatically',(tester)async{
    await tester.binding.setSurfaceSize(const Size(390,844));addTearDown(()=>tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home:TripStartWizard(hiking:true,hasSavedRecord:false,searchAddress:(_)async=>const LatLng(37,127))));
    await tester.pumpAndSettle();
    final next=find.widgetWithText(FilledButton,'다음');
    expect(tester.widget<FilledButton>(next).onPressed,isNull);
    await tester.ensureVisible(find.byType(CheckboxListTile));await tester.tap(find.byType(CheckboxListTile));await tester.pump();
    expect(tester.widget<FilledButton>(next).onPressed,isNotNull);
    await tester.tap(next);await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(next).onPressed,isNull);
    final checks=find.byType(CheckboxListTile);
    await tester.ensureVisible(checks.at(0));await tester.tap(checks.at(0));await tester.pump();
    expect(tester.widget<FilledButton>(next).onPressed,isNull);
    await tester.ensureVisible(checks.at(1));await tester.tap(checks.at(1));await tester.pump();
    expect(tester.widget<FilledButton>(next).onPressed,isNotNull);
    expect(tester.takeException(),isNull);
  });
  testWidgets('Intro remains readable at a phone width in all six languages',(tester)async{
    await tester.binding.setSurfaceSize(const Size(390,844));addTearDown(()=>tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home:TripStartWizard(hiking:false,hasSavedRecord:false,searchAddress:(_)async=>null)));
    for(final lang in ['ko','en','ja','zh','fr','pt']){
      await AppLanguage.select(lang);await tester.pumpAndSettle();
      expect(find.text(AppLanguage.t('귀가 시작 도우미')),findsOneWidget);
      expect(tester.takeException(),isNull);
    }
  });
}
