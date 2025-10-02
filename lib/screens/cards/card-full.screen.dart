import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

import 'package:rift/helpers/analytics.helper.dart';

class CardFullScreen extends StatelessWidget {
  const CardFullScreen({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    logEvent(name: 'card_full_view');
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 4,
              left: -20,
              child: RawMaterialButton(
                onPressed: () => Navigator.of(context).pop(),
                elevation: 2.0,
                fillColor: Colors.black87,
                padding: const EdgeInsets.all(8.0),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.close,
                  size: 32.0,
                  color: Colors.white,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: PinchZoom(
                    maxScale: 2.5,
                    child: Image(
                      image: NetworkImage(image),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
