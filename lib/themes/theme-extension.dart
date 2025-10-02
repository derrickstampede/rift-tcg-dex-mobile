import 'package:flutter/material.dart';
import './theme.dart';

extension ThemeExtension on BuildContext {
  ColorFamily get successColor =>
      Theme.of(this).brightness == Brightness.dark ? MaterialTheme.success.dark : MaterialTheme.success.light;

  ColorFamily get warningColor =>
      Theme.of(this).brightness == Brightness.dark ? MaterialTheme.warning.dark : MaterialTheme.warning.light;

  ColorFamily get infoColor =>
      Theme.of(this).brightness == Brightness.dark ? MaterialTheme.info.dark : MaterialTheme.info.light;

  ColorFamily get proColor =>
      Theme.of(this).brightness == Brightness.dark ? MaterialTheme.pro.dark : MaterialTheme.pro.light;
}
