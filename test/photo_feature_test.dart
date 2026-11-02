import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pyramid_of_kings/exercise_library.dart';
import 'package:pyramid_of_kings/main.dart';
import 'package:pyramid_of_kings/photos.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'Imported photos survive deletion of the temporary picker file',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'kingdom_photos_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final source = File('${directory.path}/picker.jpg');
      await source.writeAsBytes([1, 2, 3, 4]);
      final store = PhotoStore(directoryProvider: () async => directory);
      final filename = await store.importPhoto(XFile(source.path));
      await source.delete();
      expect(filename, isNot(contains('/')));
      expect(await (await store.file(filename)).readAsBytes(), [1, 2, 3, 4]);
      await expectLater(store.file('../outside.jpg'), throwsFormatException);
      await store.remove(filename);
      expect(await (await store.file(filename)).exists(), isFalse);
      await store.remove(filename);
    },
  );

  test('Every training section contains at least ten distinct exercises', () {
    for (final section in trainingSections) {
      expect(section.exercises.length, greaterThanOrEqualTo(10));
      expect(
        section.exercises.map((e) => e.name).toSet().length,
        section.exercises.length,
      );
      for (final exercise in section.exercises) {
        expect(exercise.dose, isNotEmpty);
        expect(exercise.instruction, isNotEmpty);
      }
    }
  });

  for (final section in trainingSections) {
    testWidgets('${section.type} exercise opens a correctly typed workout', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(Kingdom(prefs));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Train'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(section.title));
      await tester.tap(find.text(section.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(section.exercises.first.name));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Log this exercise'));
      await tester.tap(find.text('Log this exercise'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextFormField, section.exercises.first.name),
        findsOneWidget,
      );
      if (section.type == 'Strength') {
        await tester
            .widget<PhotoEditor>(find.byType(PhotoEditor))
            .onChanged('photo_new.jpg');
        await tester.pumpAndSettle();
      }
      await tester.scrollUntilVisible(
        find.text('Save completed workout'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save completed workout'));
      await tester.pumpAndSettle();
      final record = (jsonDecode(prefs.getString('records')!) as List).single;
      expect(record['type'], section.type);
      expect(record['name'], section.exercises.first.name);
      if (section.type == 'Strength') expect(record['photo'], 'photo_new.jpg');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Profile photo reference persists and can be removed', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(Kingdom(prefs));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester
        .widget<PhotoEditor>(find.byType(PhotoEditor))
        .onChanged('photo_test.jpg');
    await tester.pumpAndSettle();
    expect(prefs.getString('profilePhoto'), 'photo_test.jpg');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(Kingdom(prefs));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PhotoEditor>(find.byType(PhotoEditor)).filename,
      'photo_test.jpg',
    );
    await tester.widget<PhotoEditor>(find.byType(PhotoEditor)).onChanged(null);
    await tester.pumpAndSettle();
    expect(prefs.getString('profilePhoto'), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Existing workout accepts a photo without changing its stats', (
    tester,
  ) async {
    final original = {
      'name': 'Old workout',
      'type': 'Strength',
      'minutes': 30,
      'intensity': 'Moderate',
      'points': 45,
      'date': '2026-11-02T12:00:00',
    };
    SharedPreferences.setMockInitialValues({
      'records': jsonEncode([original]),
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(Kingdom(prefs));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    await tester
        .widget<PhotoEditor>(find.byType(PhotoEditor))
        .onChanged('photo_workout.jpg');
    await tester.pumpAndSettle();
    final saved = (jsonDecode(prefs.getString('records')!) as List).single;
    expect(saved, {...original, 'photo': 'photo_workout.jpg'});
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cancelling photo selection leaves workout unchanged', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WorkoutForm('Walk')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add workout photo'));
    await tester.tap(find.text('Add workout photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PhotoEditor>(find.byType(PhotoEditor)).filename,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
}
