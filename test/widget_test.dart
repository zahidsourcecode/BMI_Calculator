import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_calculator_app/main.dart';

void main() {
  testWidgets('App shows landing page', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(MyApp());

    expect(find.text('BMI CALCULATOR'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
  });
}
