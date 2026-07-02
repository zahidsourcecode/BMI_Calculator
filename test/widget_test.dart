import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:bmi_calculator_app/main.dart';
import 'package:bmi_calculator_app/Services/database_helper.dart';
import 'package:bmi_calculator_app/Services/results_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    final testDbPath = p.join(Directory.current.path, 'database', 'test_widget.db');
    await File(testDbPath).parent.create(recursive: true);
    if (await File(testDbPath).exists()) {
      await File(testDbPath).delete();
    }

    DatabaseHelper.setTestInstance(
      DatabaseHelper.forPath(() async => testDbPath),
    );

    await ResultsRepository.instance.initialize();
  });

  tearDown(() {
    DatabaseHelper.setTestInstance(null);
  });

  testWidgets('Welcome page loads', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to BMI Calculator'), findsOneWidget);
    expect(find.text('Measure your BMI'), findsOneWidget);
    expect(find.text('See history'), findsOneWidget);

    await tester.tap(find.text('Measure your BMI'));
    await tester.pumpAndSettle();

    expect(find.text('Your BMI'), findsOneWidget);
    expect(find.byIcon(Icons.history_rounded), findsNothing);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
