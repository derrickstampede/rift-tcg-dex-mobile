import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CardImage extends StatelessWidget {
  const CardImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final isBlurred = bool.parse(dotenv.env['BLUR_CARDS']!);
    final shimmerImage = ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 300,
        maxHeight: 420,
      ),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FancyShimmerImage(
          imageUrl: imageUrl,
          boxFit: BoxFit.contain,
          shimmerBaseColor: Colors.grey[300],
          shimmerHighlightColor: Colors.grey[100],
          errorWidget: Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error, color: Colors.grey),
          ),
        ),
      ),
    );

    return isBlurred
        ? ClipRRect(
            child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaY: 4, sigmaX: 4), child: shimmerImage),
          )
        : shimmerImage;
  }
}
