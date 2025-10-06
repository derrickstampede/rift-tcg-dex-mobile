import 'dart:math';
import 'package:flutter/material.dart';

class CardRarityBadge extends StatelessWidget {
  const CardRarityBadge({
    super.key,
    required String rarity,
  }) : _rarity = rarity;

  final String _rarity;

  @override
  Widget build(BuildContext context) {
    Color shapeColor = Colors.grey;
    Widget shape = Container();

    switch (_rarity) {
      case 'Common': // Common - Pearl-colored circle
        shapeColor = const Color(0xffE8E8E8); // Pearl color
        shape = Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: shapeColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
        );
        break;
      case 'Uncommon': // Uncommon - Aquamarine triangle
        shapeColor = const Color(0xff7FDBDA); // Aquamarine color
        shape = CustomPaint(
          size: const Size(16, 16),
          painter: TrianglePainter(shapeColor),
        );
        break;
      case 'Rare': // Rare - Pink diamond
        shapeColor = const Color(0xffFF69B4); // Pink color
        shape = Transform.rotate(
          angle: 0.785398, // 45 degrees in radians
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: shapeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
        break;
      case 'Epic': // Epic - Orange pentagon
        shapeColor = const Color(0xffFF8C00); // Orange color
        shape = CustomPaint(
          size: const Size(16, 16),
          painter: PentagonPainter(shapeColor),
        );
        break;
      case 'Legendary': // Legendary - Yellow hexagon
        shapeColor = const Color(0xffFFD700); // Yellow color
        shape = CustomPaint(
          size: const Size(16, 16),
          painter: HexagonPainter(shapeColor),
        );
        break;
      default:
        shape = Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              _rarity,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      child: shape,
    );
  }
}

// Custom painters for the shapes
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PentagonPainter extends CustomPainter {
  final Color color;

  PentagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create pentagon points
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * 3.14159 / 5) - (3.14159 / 2); // Start from top
      final x = center.dx + radius * 0.8 * cos(angle);
      final y = center.dy + radius * 0.8 * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create hexagon points
    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * 3.14159 / 6) - (3.14159 / 2); // Start from top
      final x = center.dx + radius * 0.8 * cos(angle);
      final y = center.dy + radius * 0.8 * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
