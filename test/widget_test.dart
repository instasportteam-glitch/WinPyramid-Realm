import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pyramid_of_kings/main.dart';

void main() {
  testWidgets('Phone navigation and workout validation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(Kingdom(await SharedPreferences.getInstance()));
    await tester.pumpAndSettle();
    expect(find.text('Your throne'), findsOneWidget);
    await tester.tap(find.text('Train'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add your workout'));
    await tester.tap(find.text('Add your workout'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save completed workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save completed workout'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a workout name'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Evening strength');
    await tester.ensureVisible(find.text('Save completed workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save completed workout'));
    await tester.pumpAndSettle();
    expect(find.text('Your legacy'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getString('records'),
      contains('Evening strength'),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('iPad uses a navigation rail', (tester) async {
    tester.view.physicalSize = const Size(2048, 2732);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(Kingdom(await SharedPreferences.getInstance()));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
