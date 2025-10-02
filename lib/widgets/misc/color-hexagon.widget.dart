import 'package:flutter/material.dart';
import 'dart:math';

class PentagonPart {
  final Path path;
  final Color color;

  PentagonPart(this.path, this.color);
}

class ColorHexagon extends StatelessWidget {
  final double size;
  final String? colors;
  final defaultColor = Colors.grey[400]!;

  ColorHexagon({
    super.key,
    this.size = 24,
    this.colors,
  });

  List<Color> _parseColors() {
    final resultColors = List<Color>.filled(5, defaultColor);

    if (colors == null || colors!.isEmpty) return resultColors;

    final colorInputs = colors!.split(' ');
    for (String colorInput in colorInputs) {
      final parts = colorInput.split('/');
      for (String part in parts) {
        final color = _getColorFromString(part.trim());
        final position = _getColorPosition(part.trim());
        if (position != null) {
          resultColors[position] = color;
        }
      }
    }

    return resultColors;
  }

  int? _getColorPosition(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return 0; // Top
      case 'green':
        return 1; // Top right
      case 'blue':
        return 2; // Bottom right
      case 'yellow':
        return 3; // Bottom left
      case 'black':
        return 4; // Top left
      default:
        return null;
    }
  }

  Color _getColorFromString(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return defaultColor;

    switch (colorStr.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'black':
        return Colors.black;
      case 'yellow':
        return Colors.yellow;
      default:
        return defaultColor;
    }
  }

  List<PentagonPart> _createPentagonParts(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final parts = <PentagonPart>[];
    final sectionColors = _parseColors();

    // Create 5 sections for pentagon (72 degrees each)
    for (int i = 0; i < 5; i++) {
      final path = Path();
      // Start from top and go clockwise (adjust by -90 degrees to start at top)
      final startAngle = (i * 72 - 90) * pi / 180;
      final endAngle = ((i + 1) * 72 - 90) * pi / 180;

      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      );
      path.lineTo(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      );
      path.close();

      parts.add(PentagonPart(path, sectionColors[i]));
    }

    return parts;
  }

  @override
  Widget build(BuildContext context) {
    if (colors == null) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: Size(size, size),
      painter: _PentagonPainter(_createPentagonParts(Size(size, size))),
    );
  }
}

class _PentagonPainter extends CustomPainter {
  final List<PentagonPart> parts;

  _PentagonPainter(this.parts);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final part in parts) {
      paint.color = part.color;
      canvas.drawPath(part.path, paint);
    }
  }

  @override
  bool shouldRepaint(_PentagonPainter oldDelegate) => false;
}
