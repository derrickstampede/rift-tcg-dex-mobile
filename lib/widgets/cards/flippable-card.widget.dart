import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rift/widgets/cards/card-image.widget.dart';

class FlippableCard extends StatefulWidget {
  const FlippableCard({
    super.key,
    required this.frontImageUrl,
    this.backImageUrl,
    this.width,
    this.height,
    this.onTap,
    this.onTapWithSide,
  });

  final String frontImageUrl;
  final String? backImageUrl;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Function(bool isShowingFront, String currentImageUrl)? onTapWithSide;

  @override
  State<FlippableCard> createState() => _FlippableCardState();
}

class _FlippableCardState extends State<FlippableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isShowingFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    
    if (_isShowingFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isShowingFront = !_isShowingFront;
    });
  }

  void _handleTap() {
    if (widget.onTapWithSide != null) {
      final currentImageUrl = _isShowingFront 
          ? widget.frontImageUrl 
          : (widget.backImageUrl ?? widget.frontImageUrl);
      widget.onTapWithSide!(_isShowingFront, currentImageUrl);
    } else if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onDoubleTap: widget.backImageUrl != null ? _flip : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isShowingFront = _animation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_animation.value * pi),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: isShowingFront
                  ? CardImage(imageUrl: widget.frontImageUrl)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: CardImage(
                        imageUrl: widget.backImageUrl ?? widget.frontImageUrl,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
} 