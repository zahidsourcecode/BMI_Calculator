import 'package:flutter/material.dart';
import 'dart:math';
import '../constants.dart';

class BMIGaugeWidget extends StatelessWidget {
  final double bmi;

  const BMIGaugeWidget({
    required this.bmi,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(220.0, 360.0)
            : 300.0;
        final height = width * 0.52;

        return SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: BMIGaugePainter(bmi: bmi),
          ),
        );
      },
    );
  }
}

class BMIGaugePainter extends CustomPainter {
  final double bmi;

  BMIGaugePainter({required this.bmi});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    final radius = size.width / 2.5;

    _drawGaugeBackground(canvas, center, radius);
    _drawNeedle(canvas, center, radius);
    _drawCenterCircle(canvas, center);
  }

  void _drawGaugeBackground(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    paint.color = const Color(0xFFF87171);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi,
      (18.5 / 40) * pi,
      false,
      paint,
    );

    paint.color = AppColors.primaryDark;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi + (18.5 / 40) * pi,
      ((25 - 18.5) / 40) * pi,
      false,
      paint,
    );

    paint.color = const Color(0xFFFBBF24);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi + (25 / 40) * pi,
      ((30 - 25) / 40) * pi,
      false,
      paint,
    );

    paint.color = const Color(0xFFF87171);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi + (30 / 40) * pi,
      ((40 - 30) / 40) * pi,
      false,
      paint,
    );

    _drawTickMarks(canvas, center, radius);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 2;

    final values = [0, 10, 20, 30, 40];
    for (var value in values) {
      final angle = -pi + (value / 40) * pi;
      final start = Offset(
        center.dx + (radius - 8) * cos(angle),
        center.dy + (radius - 8) * sin(angle),
      );
      final end = Offset(
        center.dx + (radius + 5) * cos(angle),
        center.dy + (radius + 5) * sin(angle),
      );
      canvas.drawLine(start, end, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: value.toString(),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelOffset = Offset(
        center.dx + (radius + 15) * cos(angle) - textPainter.width / 2,
        center.dy + (radius + 15) * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final angle = -pi + (bmi.clamp(0, 40) / 40) * pi;

    final needlePaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 3;

    final needleEnd = Offset(
      center.dx + (radius - 20) * cos(angle),
      center.dy + (radius - 20) * sin(angle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);

    final arrowSize = 14.0;
    final baseCenter = Offset(
      needleEnd.dx - arrowSize * cos(angle),
      needleEnd.dy - arrowSize * sin(angle),
    );

    final arrowAngle1 = angle + pi / 2;
    final arrowAngle2 = angle - pi / 2;
    final baseWidth = 7.0;

    final arrowPoint1 = Offset(
      baseCenter.dx + baseWidth * cos(arrowAngle1),
      baseCenter.dy + baseWidth * sin(arrowAngle1),
    );
    final arrowPoint2 = Offset(
      baseCenter.dx + baseWidth * cos(arrowAngle2),
      baseCenter.dy + baseWidth * sin(arrowAngle2),
    );

    final trianglePath = Path()
      ..moveTo(needleEnd.dx, needleEnd.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    final trianglePaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.fill;

    canvas.drawPath(trianglePath, trianglePaint);
  }

  void _drawCenterCircle(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = AppColors.backgroundTop
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 12, paint);

    final borderPaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 12, borderPaint);
  }

  @override
  bool shouldRepaint(covariant BMIGaugePainter oldDelegate) {
    return oldDelegate.bmi != bmi;
  }
}
