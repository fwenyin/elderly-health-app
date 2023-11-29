import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BMIGaugeChart extends StatelessWidget {
  final double bmi;

  BMIGaugeChart({required this.bmi});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
          150, 120), // Give it a fixed height and infinite width
      painter: BMIGaugePainter(bmi),
    );
  }
}

// Custom Painter class to draw the gauge and pointer
class BMIGaugePainter extends CustomPainter {
  final double bmi; // User's current BMI

  BMIGaugePainter(this.bmi);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    // Draw the arc for the gauge
    // Define the angles for underweight, normal, overweight, obese
    double startAngle = -math.pi;
    double sweepAngle = math.pi;
    Rect rect = Rect.fromLTWH(0, size.height / 2, size.width, size.height);

    // Underweight arc
    paint.color = Colors.yellow;
    canvas.drawArc(rect, startAngle, sweepAngle * (18.5 / 40), false, paint);

    // Normal arc
    paint.color = Colors.green;
    canvas.drawArc(rect, startAngle + sweepAngle * (18.5 / 40),
        sweepAngle * ((25 - 18.5) / 40), false, paint);

    // Overweight arc
    paint.color = Colors.orange;
    canvas.drawArc(rect, startAngle + sweepAngle * (25 / 40),
        sweepAngle * ((30 - 25) / 40), false, paint);

    // Obese arc
    paint.color = Colors.red;
    canvas.drawArc(rect, startAngle + sweepAngle * (30 / 40),
        sweepAngle * ((40 - 30) / 40), false, paint);

    // Draw the pointer for the current BMI
    final pointerPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // The angle for the pointer should be calculated based on the current BMI
    double pointerAngle = startAngle + (sweepAngle * (bmi / 40));
    final pointerLength = size.width / 2;
    final pointerStart = Offset(size.width / 2, size.height);
    final pointerEnd = Offset(
        size.width / 2 + pointerLength * math.cos(pointerAngle),
        size.height + pointerLength * math.sin(pointerAngle));
    canvas.drawLine(pointerStart, pointerEnd, pointerPaint);

    final textSpan = TextSpan(
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      text: bmi.toStringAsFixed(1), // One decimal place
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    // Position the text at the bottom center of the widget
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      size.height - textPainter.height - 20, // Adjust the position as needed
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
