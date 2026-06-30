import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_calculator_app/main.dart';

void main() {
  testWidgets('Welcome page loads', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());

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
