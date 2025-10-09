import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

import 'package:rift/globals.dart';

import 'package:rift/helpers/analytics.helper.dart';

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}

void showSnackbar(
  String title, {
  String type = 'primary',
  String? subtitle,
  String? image,
  int duration = 4,
  String? linkType,
  String? link,
}) {
  Color containerColor = Theme.of(navigatorKey.currentState!.overlay!.context).colorScheme.primaryContainer;
  Color textColor = Theme.of(navigatorKey.currentState!.overlay!.context).colorScheme.onPrimaryContainer;

  if (type == 'secondary') {
    containerColor = Theme.of(navigatorKey.currentState!.overlay!.context).colorScheme.secondaryContainer;
    textColor = Theme.of(navigatorKey.currentState!.overlay!.context).colorScheme.onSecondaryContainer;
  }
  if (type == 'tertiary') {
    containerColor = Theme.of(navigatorKey.currentState!.overlay!.context).colorScheme.tertiaryContainer;
    textColor = Theme.of(navigatorKey.currentState!.overlay!.context).colorScheme.onTertiaryContainer;
  }
  if (type == 'error') {
    containerColor = Theme.of(navigatorKey.currentState!.overlay!.context).colorScheme.errorContainer;
    textColor = Theme.of(navigatorKey.currentState!.overlay!.context).colorScheme.onErrorContainer;
  }

  final SnackBar snackbar = SnackBar(
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: duration),
    backgroundColor: containerColor,
    showCloseIcon: true,
    closeIconColor: textColor,
    content: GestureDetector(
      onTap: () {
        if (linkType == null || link == null) {
          return;
        }
        if (linkType == "external") {
          _launchUrl(link);
          logEvent(name: 'snackbar_click', parameters: {'value': title});
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (image != null)
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.only(right: 8),
              child: FancyShimmerImage(imageUrl: image, boxFit: BoxFit.contain),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(subtitle, style: TextStyle(color: textColor), maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  snackbarKey.currentState?.hideCurrentSnackBar();
  snackbarKey.currentState?.showSnackBar(snackbar);
}

void hideSnackbar() {
  snackbarKey.currentState?.hideCurrentSnackBar();
}

Color getColor(String color) {
  Color selectedColor = Colors.transparent;
  switch (color) {
    case 'Red':
      selectedColor = Colors.red.shade400;
      break;
    case 'Green':
      selectedColor = Colors.green.shade500;
      break;
    case 'Blue':
      selectedColor = Colors.blue.shade400;
      break;
    case 'Yellow':
      selectedColor = Colors.yellow.shade400;
      break;
    case 'Purple':
      selectedColor = Colors.purple.shade400;
      break;
    case 'Orange':
      selectedColor = Colors.orange.shade400;
      break;
    default:
      selectedColor = Colors.black;
  }

  return selectedColor;
}

class TransparentRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  TransparentRoute({required this.builder})
    : super(
        pageBuilder:
            (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                builder(context),
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          var begin = const Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      );
}
