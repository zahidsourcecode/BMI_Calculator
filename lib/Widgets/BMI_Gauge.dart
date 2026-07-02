import 'package:flutter/material.dart';
import 'dart:math';
import '../constants.dart';

class BMIGaugeWidget extends StatelessWidget {
  const BMIGaugeWidget({required this.bmi});

  final double bmi;

  @override
  Widget build(BuildContext context) {
    final palette = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = MediaQuery.sizeOf(context).width;
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(AppSpacing.scale(context, 220), AppSpacing.scale(context, 360))
            : maxWidth.clamp(AppSpacing.scale(context, 220), AppSpacing.scale(context, 360));
        final radius = width / 2.5;
        final height = radius + AppSpacing.scale(context, 36);

        return SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: BMIGaugePainter(bmi: bmi, palette: palette),
          ),
        );
      },
    );
  }
}

class BMIGaugePainter extends CustomPainter {
  BMIGaugePainter({required this.bmi, required this.palette});

  final double bmi;
  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 300;
    final center = Offset(size.width / 2, size.height - 14 * scale);
    final radius = size.width / 2.5;

    _drawGaugeBackground(canvas, center, radius, scale);
    _drawNeedle(canvas, center, radius, scale);
    _drawCenterCircle(canvas, center, scale);
  }

  void _drawGaugeBackground(Canvas canvas, Offset center, double radius, double scale) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30 * scale;

    paint.color = palette.danger;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi,
      (18.5 / 40) * pi,
      false,
      paint,
    );

    paint.color = palette.primaryDark;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi + (18.5 / 40) * pi,
      ((25 - 18.5) / 40) * pi,
      false,
      paint,
    );

    paint.color = palette.warning;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi + (25 / 40) * pi,
      ((30 - 25) / 40) * pi,
      false,
      paint,
    );

    paint.color = palette.danger;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi + (30 / 40) * pi,
      ((40 - 30) / 40) * pi,
      false,
      paint,
    );

    _drawTickMarks(canvas, center, radius, scale);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius, double scale) {
    final paint = Paint()
      ..color = palette.primaryDark
      ..strokeWidth = 2 * scale;

    final values = [0, 10, 20, 30, 40];
    for (final value in values) {
      final angle = -pi + (value / 40) * pi;
      final start = Offset(
        center.dx + (radius - 8 * scale) * cos(angle),
        center.dy + (radius - 8 * scale) * sin(angle),
      );
      final end = Offset(
        center.dx + (radius + 5 * scale) * cos(angle),
        center.dy + (radius + 5 * scale) * sin(angle),
      );
      canvas.drawLine(start, end, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: value.toString(),
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 10 * scale,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelOffset = Offset(
        center.dx + (radius + 15 * scale) * cos(angle) - textPainter.width / 2,
        center.dy + (radius + 15 * scale) * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius, double scale) {
    final angle = -pi + (bmi.clamp(0, 40) / 40) * pi;

    final needlePaint = Paint()
      ..color = palette.textPrimary
      ..strokeWidth = 3 * scale;

    final needleEnd = Offset(
      center.dx + (radius - 20 * scale) * cos(angle),
      center.dy + (radius - 20 * scale) * sin(angle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);

    final arrowSize = 14.0 * scale;
    final baseCenter = Offset(
      needleEnd.dx - arrowSize * cos(angle),
      needleEnd.dy - arrowSize * sin(angle),
    );

    final arrowAngle1 = angle + pi / 2;
    final arrowAngle2 = angle - pi / 2;
    final baseWidth = 7.0 * scale;

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
      ..color = palette.textPrimary
      ..style = PaintingStyle.fill;

    canvas.drawPath(trianglePath, trianglePaint);
  }

  void _drawCenterCircle(Canvas canvas, Offset center, double scale) {
    final paint = Paint()
      ..color = palette.backgroundTop
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 12 * scale, paint);

    final borderPaint = Paint()
      ..color = palette.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;

    canvas.drawCircle(center, 12 * scale, borderPaint);
  }

  @override
  bool shouldRepaint(covariant BMIGaugePainter oldDelegate) {
    return oldDelegate.bmi != bmi || oldDelegate.palette != palette;
  }
}
