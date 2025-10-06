import 'package:flutter/material.dart';

class CardFoilWrapper extends StatelessWidget {
  const CardFoilWrapper({super.key, required String print, required Widget child}) : _print = print, _child = child;

  final String _print;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    if (_print == "foil" || _print == "holofoil") {
      return Stack(
        children: [
          _child,
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0],
                  ),
                ),
                child: AnimatedBuilder(
                  animation: const AlwaysStoppedAnimation(0),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: FoilShimmerPainter(),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    return _child;
  }
}

class FoilShimmerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, -0.3),
        radius: 1.0,
        colors: [
          Colors.black.withOpacity(0.0),
          Colors.black.withOpacity(0.05),
          Colors.black.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a subtle shimmer effect
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
