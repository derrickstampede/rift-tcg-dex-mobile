import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff445e91),
      surfaceTint: Color(0xff445e91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd8e2ff),
      onPrimaryContainer: Color(0xff2b4678),
      secondary: Color(0xff88521c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdcc1),
      onSecondaryContainer: Color(0xff6b3b04),
      tertiary: Color(0xff1d6586),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc4e7ff),
      onTertiaryContainer: Color(0xff004c69),
      error: Color(0xff904a41),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad5),
      onErrorContainer: Color(0xff73342b),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff1a1b20),
      onSurfaceVariant: Color(0xff44474f),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc4c6d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffadc6ff),
      primaryFixed: Color(0xffd8e2ff),
      onPrimaryFixed: Color(0xff001a41),
      primaryFixedDim: Color(0xffadc6ff),
      onPrimaryFixedVariant: Color(0xff2b4678),
      secondaryFixed: Color(0xffffdcc1),
      onSecondaryFixed: Color(0xff2e1500),
      secondaryFixedDim: Color(0xffffb779),
      onSecondaryFixedVariant: Color(0xff6b3b04),
      tertiaryFixed: Color(0xffc4e7ff),
      onTertiaryFixed: Color(0xff001e2c),
      tertiaryFixedDim: Color(0xff90cef4),
      onTertiaryFixedVariant: Color(0xff004c69),
      surfaceDim: Color(0xffd9d9e0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe8e7ee),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff183566),
      surfaceTint: Color(0xff445e91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff536da1),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff542c00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff996029),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003b52),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff317495),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff5e241c),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffa2594e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff0f1116),
      onSurfaceVariant: Color(0xff33363e),
      outline: Color(0xff50525a),
      outlineVariant: Color(0xff6a6d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffadc6ff),
      primaryFixed: Color(0xff536da1),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff3a5487),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff996029),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff7c4813),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff317495),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff0a5b7c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc6c6cd),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffe8e7ee),
      surfaceContainerHigh: Color(0xffdcdce3),
      surfaceContainerHighest: Color(0xffd1d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff092b5b),
      surfaceTint: Color(0xff445e91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff2d487a),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff462300),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6e3d07),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003044),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff004f6d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff511a13),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff76362d),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292c33),
      outlineVariant: Color(0xff464951),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffadc6ff),
      primaryFixed: Color(0xff2d487a),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff133162),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6e3d07),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff4f2900),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff004f6d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff00374d),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb8b8bf),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f0f7),
      surfaceContainer: Color(0xffe2e2e9),
      surfaceContainerHigh: Color(0xffd4d4db),
      surfaceContainerHighest: Color(0xffc6c6cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffadc6ff),
      surfaceTint: Color(0xffadc6ff),
      onPrimary: Color(0xff102f60),
      primaryContainer: Color(0xff2b4678),
      onPrimaryContainer: Color(0xffd8e2ff),
      secondary: Color(0xffffb779),
      onSecondary: Color(0xff4c2700),
      secondaryContainer: Color(0xff6b3b04),
      onSecondaryContainer: Color(0xffffdcc1),
      tertiary: Color(0xff90cef4),
      onTertiary: Color(0xff00344a),
      tertiaryContainer: Color(0xff004c69),
      onTertiaryContainer: Color(0xffc4e7ff),
      error: Color(0xffffb4a9),
      onError: Color(0xff561e17),
      errorContainer: Color(0xff73342b),
      onErrorContainer: Color(0xffffdad5),
      surface: Color(0xff111318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc4c6d0),
      outline: Color(0xff8e9099),
      outlineVariant: Color(0xff44474f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff445e91),
      primaryFixed: Color(0xffd8e2ff),
      onPrimaryFixed: Color(0xff001a41),
      primaryFixedDim: Color(0xffadc6ff),
      onPrimaryFixedVariant: Color(0xff2b4678),
      secondaryFixed: Color(0xffffdcc1),
      onSecondaryFixed: Color(0xff2e1500),
      secondaryFixedDim: Color(0xffffb779),
      onSecondaryFixedVariant: Color(0xff6b3b04),
      tertiaryFixed: Color(0xffc4e7ff),
      onTertiaryFixed: Color(0xff001e2c),
      tertiaryFixedDim: Color(0xff90cef4),
      onTertiaryFixedVariant: Color(0xff004c69),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff1a1b20),
      surfaceContainer: Color(0xff1e1f25),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcedcff),
      surfaceTint: Color(0xffadc6ff),
      onPrimary: Color(0xff002454),
      primaryContainer: Color(0xff7791c7),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd4b3),
      onSecondary: Color(0xff3c1e00),
      secondaryContainer: Color(0xffc28349),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffb6e2ff),
      onTertiary: Color(0xff00293b),
      tertiaryContainer: Color(0xff5998bb),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cb),
      onError: Color(0xff48130d),
      errorContainer: Color(0xffcc7b6f),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdadce6),
      outline: Color(0xffb0b1bb),
      outlineVariant: Color(0xff8e9099),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff2c4779),
      primaryFixed: Color(0xffd8e2ff),
      onPrimaryFixed: Color(0xff00102d),
      primaryFixedDim: Color(0xffadc6ff),
      onPrimaryFixedVariant: Color(0xff183566),
      secondaryFixed: Color(0xffffdcc1),
      onSecondaryFixed: Color(0xff1f0c00),
      secondaryFixedDim: Color(0xffffb779),
      onSecondaryFixedVariant: Color(0xff542c00),
      tertiaryFixed: Color(0xffc4e7ff),
      onTertiaryFixed: Color(0xff00131e),
      tertiaryFixedDim: Color(0xff90cef4),
      onTertiaryFixedVariant: Color(0xff003b52),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff43444a),
      surfaceContainerLowest: Color(0xff06070c),
      surfaceContainerLow: Color(0xff1c1d22),
      surfaceContainer: Color(0xff26282d),
      surfaceContainerHigh: Color(0xff313238),
      surfaceContainerHighest: Color(0xff3c3d43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffecefff),
      surfaceTint: Color(0xffadc6ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa8c3fc),
      onPrimaryContainer: Color(0xff000a22),
      secondary: Color(0xffffede0),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xfffbb375),
      onSecondaryContainer: Color(0xff160800),
      tertiary: Color(0xffe2f2ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff8ccaf0),
      onTertiaryContainer: Color(0xff000d15),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea2),
      onErrorContainer: Color(0xff220000),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeeeff9),
      outlineVariant: Color(0xffc0c2cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff2c4779),
      primaryFixed: Color(0xffd8e2ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffadc6ff),
      onPrimaryFixedVariant: Color(0xff00102d),
      secondaryFixed: Color(0xffffdcc1),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb779),
      onSecondaryFixedVariant: Color(0xff1f0c00),
      tertiaryFixed: Color(0xffc4e7ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff90cef4),
      onTertiaryFixedVariant: Color(0xff00131e),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff4e5056),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1e1f25),
      surfaceContainer: Color(0xff2f3036),
      surfaceContainerHigh: Color(0xff3a3b41),
      surfaceContainerHighest: Color(0xff45474c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );

  /// Pro
  static const pro = ExtendedColor(
    seed: Color(0xff6a0dad),
    value: Color(0xff6a0dad),
    light: ColorFamily(
      color: Color(0xff705289),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfff1daff),
      onColorContainer: Color(0xff573a70),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff705289),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfff1daff),
      onColorContainer: Color(0xff573a70),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff705289),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfff1daff),
      onColorContainer: Color(0xff573a70),
    ),
    dark: ColorFamily(
      color: Color(0xffdcb9f8),
      onColor: Color(0xff3f2358),
      colorContainer: Color(0xff573a70),
      onColorContainer: Color(0xfff1daff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffdcb9f8),
      onColor: Color(0xff3f2358),
      colorContainer: Color(0xff573a70),
      onColorContainer: Color(0xfff1daff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffdcb9f8),
      onColor: Color(0xff3f2358),
      colorContainer: Color(0xff573a70),
      onColorContainer: Color(0xfff1daff),
    ),
  );

  /// Success
  static const success = ExtendedColor(
    seed: Color(0xff3d9970),
    value: Color(0xff3d9970),
    light: ColorFamily(
      color: Color(0xff236a4c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffaaf2cb),
      onColorContainer: Color(0xff005235),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff236a4c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffaaf2cb),
      onColorContainer: Color(0xff005235),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff236a4c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffaaf2cb),
      onColorContainer: Color(0xff005235),
    ),
    dark: ColorFamily(
      color: Color(0xff8fd5b0),
      onColor: Color(0xff003824),
      colorContainer: Color(0xff005235),
      onColorContainer: Color(0xffaaf2cb),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff8fd5b0),
      onColor: Color(0xff003824),
      colorContainer: Color(0xff005235),
      onColorContainer: Color(0xffaaf2cb),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff8fd5b0),
      onColor: Color(0xff003824),
      colorContainer: Color(0xff005235),
      onColorContainer: Color(0xffaaf2cb),
    ),
  );

  /// Info
  static const info = ExtendedColor(
    seed: Color(0xff1e88e5),
    value: Color(0xff1e88e5),
    light: ColorFamily(
      color: Color(0xff39608f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd3e4ff),
      onColorContainer: Color(0xff1d4875),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff39608f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd3e4ff),
      onColorContainer: Color(0xff1d4875),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff39608f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd3e4ff),
      onColorContainer: Color(0xff1d4875),
    ),
    dark: ColorFamily(
      color: Color(0xffa3c9fe),
      onColor: Color(0xff00315b),
      colorContainer: Color(0xff1d4875),
      onColorContainer: Color(0xffd3e4ff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffa3c9fe),
      onColor: Color(0xff00315b),
      colorContainer: Color(0xff1d4875),
      onColorContainer: Color(0xffd3e4ff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffa3c9fe),
      onColor: Color(0xff00315b),
      colorContainer: Color(0xff1d4875),
      onColorContainer: Color(0xffd3e4ff),
    ),
  );

  /// Danger
  static const danger = ExtendedColor(
    seed: Color(0xffc0392b),
    value: Color(0xffc0392b),
    light: ColorFamily(
      color: Color(0xff904a41),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdad5),
      onColorContainer: Color(0xff73342b),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff904a41),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdad5),
      onColorContainer: Color(0xff73342b),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff904a41),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdad5),
      onColorContainer: Color(0xff73342b),
    ),
    dark: ColorFamily(
      color: Color(0xffffb4a9),
      onColor: Color(0xff561e17),
      colorContainer: Color(0xff73342b),
      onColorContainer: Color(0xffffdad5),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb4a9),
      onColor: Color(0xff561e17),
      colorContainer: Color(0xff73342b),
      onColorContainer: Color(0xffffdad5),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb4a9),
      onColor: Color(0xff561e17),
      colorContainer: Color(0xff73342b),
      onColorContainer: Color(0xffffdad5),
    ),
  );

  /// Warning
  static const warning = ExtendedColor(
    seed: Color(0xfff39c12),
    value: Color(0xfff39c12),
    light: ColorFamily(
      color: Color(0xff825514),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffddb9),
      onColorContainer: Color(0xff663e00),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff825514),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffddb9),
      onColorContainer: Color(0xff663e00),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff825514),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffddb9),
      onColorContainer: Color(0xff663e00),
    ),
    dark: ColorFamily(
      color: Color(0xfff8bb71),
      onColor: Color(0xff472a00),
      colorContainer: Color(0xff663e00),
      onColorContainer: Color(0xffffddb9),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xfff8bb71),
      onColor: Color(0xff472a00),
      colorContainer: Color(0xff663e00),
      onColorContainer: Color(0xffffddb9),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xfff8bb71),
      onColor: Color(0xff472a00),
      colorContainer: Color(0xff663e00),
      onColorContainer: Color(0xffffddb9),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    pro,
    success,
    info,
    danger,
    warning,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
