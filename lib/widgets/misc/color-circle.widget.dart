import 'package:flutter/material.dart';

import 'package:rift/helpers/util.helper.dart';

class ColorCircle extends StatelessWidget {
  const ColorCircle({super.key, required this.size, required this.colors, this.color});

  final double size;
  final String colors;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    List<Color> deckColors = [Colors.transparent, Colors.transparent];

    if (color == null) {
      final colorSplits = colors.split('/');
      if (colorSplits.length == 1) {
        colorSplits.add(colorSplits[0]);
      }
      deckColors[0] = getColor(colorSplits[0]);
      deckColors[1] = getColor(colorSplits[1]);
    } else {
      deckColors[0] = color!;
      deckColors[1] = color!;
    }

    return CustomPaint(
      size: Size(size, size), // Specify the size of the circle
      painter: SplitCirclePainter(
        leftColor: deckColors[1],
        rightColor: deckColors[0],
      ),
    );
  }
}

class SplitCirclePainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;

  SplitCirclePainter({required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint leftPaint = Paint()..color = leftColor;
    final Paint rightPaint = Paint()..color = rightColor;

    final Path leftPath = Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..arcTo(
        Rect.fromLTWH(0, 0, size.width, size.height),
        -90 * 3.14159 / 180,
        180 * 3.14159 / 180,
        false,
      )
      ..close();

    final Path rightPath = Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..arcTo(
        Rect.fromLTWH(0, 0, size.width, size.height),
        90 * 3.14159 / 180,
        180 * 3.14159 / 180,
        false,
      )
      ..close();

    canvas.drawPath(leftPath, leftPaint);
    canvas.drawPath(rightPath, rightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
