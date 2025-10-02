import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff8b4f24),
      surfaceTint: Color(0xff8b4f24),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdbc7),
      onPrimaryContainer: Color(0xff6e390e),
      secondary: Color(0xff39608f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd3e4ff),
      onSecondaryContainer: Color(0xff1d4875),
      tertiary: Color(0xff6f5d0e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfffae287),
      onTertiaryContainer: Color(0xff544600),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff221a15),
      onSurfaceVariant: Color(0xff52443c),
      outline: Color(0xff84746a),
      outlineVariant: Color(0xffd7c3b8),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e29),
      inversePrimary: Color(0xffffb688),
      primaryFixed: Color(0xffffdbc7),
      onPrimaryFixed: Color(0xff311300),
      primaryFixedDim: Color(0xffffb688),
      onPrimaryFixedVariant: Color(0xff6e390e),
      secondaryFixed: Color(0xffd3e4ff),
      onSecondaryFixed: Color(0xff001c38),
      secondaryFixedDim: Color(0xffa3c9fe),
      onSecondaryFixedVariant: Color(0xff1d4875),
      tertiaryFixed: Color(0xfffae287),
      onTertiaryFixed: Color(0xff221b00),
      tertiaryFixedDim: Color(0xffddc66e),
      onTertiaryFixedVariant: Color(0xff544600),
      surfaceDim: Color(0xffe7d7ce),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ea),
      surfaceContainer: Color(0xfffcebe2),
      surfaceContainerHigh: Color(0xfff6e5dc),
      surfaceContainerHighest: Color(0xfff0dfd7),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff592900),
      surfaceTint: Color(0xff8b4f24),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff9c5e31),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff033764),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff486f9f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff413500),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff7e6c1d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff17100b),
      onSurfaceVariant: Color(0xff40342c),
      outline: Color(0xff5e4f47),
      outlineVariant: Color(0xff7a6a61),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e29),
      inversePrimary: Color(0xffffb688),
      primaryFixed: Color(0xff9c5e31),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff7f461c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff486f9f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2e5785),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff7e6c1d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff645402),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd3c3bb),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ea),
      surfaceContainer: Color(0xfff6e5dc),
      surfaceContainerHigh: Color(0xffeadad1),
      surfaceContainerHighest: Color(0xffdfcec6),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff4a2000),
      surfaceTint: Color(0xff8b4f24),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff713b11),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff002d54),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff204b78),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff352b00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff574800),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff362a22),
      outlineVariant: Color(0xff54463e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e29),
      inversePrimary: Color(0xffffb688),
      primaryFixed: Color(0xff713b11),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff542600),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff204b78),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff00345f),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff574800),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3d3200),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc5b6ae),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffffede5),
      surfaceContainer: Color(0xfff0dfd7),
      surfaceContainerHigh: Color(0xffe1d1c9),
      surfaceContainerHighest: Color(0xffd3c3bb),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb688),
      surfaceTint: Color(0xffffb688),
      onPrimary: Color(0xff512400),
      primaryContainer: Color(0xff6e390e),
      onPrimaryContainer: Color(0xffffdbc7),
      secondary: Color(0xffa3c9fe),
      onSecondary: Color(0xff00315b),
      secondaryContainer: Color(0xff1d4875),
      onSecondaryContainer: Color(0xffd3e4ff),
      tertiary: Color(0xffddc66e),
      onTertiary: Color(0xff3a3000),
      tertiaryContainer: Color(0xff544600),
      onTertiaryContainer: Color(0xfffae287),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff19120d),
      onSurface: Color(0xfff0dfd7),
      onSurfaceVariant: Color(0xffd7c3b8),
      outline: Color(0xff9f8d83),
      outlineVariant: Color(0xff52443c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd7),
      inversePrimary: Color(0xff8b4f24),
      primaryFixed: Color(0xffffdbc7),
      onPrimaryFixed: Color(0xff311300),
      primaryFixedDim: Color(0xffffb688),
      onPrimaryFixedVariant: Color(0xff6e390e),
      secondaryFixed: Color(0xffd3e4ff),
      onSecondaryFixed: Color(0xff001c38),
      secondaryFixedDim: Color(0xffa3c9fe),
      onSecondaryFixedVariant: Color(0xff1d4875),
      tertiaryFixed: Color(0xfffae287),
      onTertiaryFixed: Color(0xff221b00),
      tertiaryFixedDim: Color(0xffddc66e),
      onTertiaryFixedVariant: Color(0xff544600),
      surfaceDim: Color(0xff19120d),
      surfaceBright: Color(0xff413731),
      surfaceContainerLowest: Color(0xff140d08),
      surfaceContainerLow: Color(0xff221a15),
      surfaceContainer: Color(0xff261e19),
      surfaceContainerHigh: Color(0xff312823),
      surfaceContainerHighest: Color(0xff3d332d),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd4ba),
      surfaceTint: Color(0xffffb688),
      onPrimary: Color(0xff401b00),
      primaryContainer: Color(0xffc68051),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc8deff),
      onSecondary: Color(0xff002749),
      secondaryContainer: Color(0xff6d93c5),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff4db81),
      onTertiary: Color(0xff2e2500),
      tertiaryContainer: Color(0xffa4903e),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff19120d),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffedd8cd),
      outline: Color(0xffc1aea4),
      outlineVariant: Color(0xff9f8d83),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd7),
      inversePrimary: Color(0xff703a10),
      primaryFixed: Color(0xffffdbc7),
      onPrimaryFixed: Color(0xff210b00),
      primaryFixedDim: Color(0xffffb688),
      onPrimaryFixedVariant: Color(0xff592900),
      secondaryFixed: Color(0xffd3e4ff),
      onSecondaryFixed: Color(0xff001226),
      secondaryFixedDim: Color(0xffa3c9fe),
      onSecondaryFixedVariant: Color(0xff033764),
      tertiaryFixed: Color(0xfffae287),
      onTertiaryFixed: Color(0xff161100),
      tertiaryFixedDim: Color(0xffddc66e),
      onTertiaryFixedVariant: Color(0xff413500),
      surfaceDim: Color(0xff19120d),
      surfaceBright: Color(0xff4d423c),
      surfaceContainerLowest: Color(0xff0c0603),
      surfaceContainerLow: Color(0xff241c17),
      surfaceContainer: Color(0xff2f2621),
      surfaceContainerHigh: Color(0xff3a312b),
      surfaceContainerHighest: Color(0xff463c36),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece3),
      surfaceTint: Color(0xffffb688),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffb17e),
      onPrimaryContainer: Color(0xff180700),
      secondary: Color(0xffe9f0ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff9fc5fa),
      onSecondaryContainer: Color(0xff000c1c),
      tertiary: Color(0xffffefbe),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffd9c26a),
      onTertiaryContainer: Color(0xff0f0b00),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff19120d),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffece3),
      outlineVariant: Color(0xffd3bfb4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd7),
      inversePrimary: Color(0xff703a10),
      primaryFixed: Color(0xffffdbc7),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb688),
      onPrimaryFixedVariant: Color(0xff210b00),
      secondaryFixed: Color(0xffd3e4ff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffa3c9fe),
      onSecondaryFixedVariant: Color(0xff001226),
      tertiaryFixed: Color(0xfffae287),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffddc66e),
      onTertiaryFixedVariant: Color(0xff161100),
      surfaceDim: Color(0xff19120d),
      surfaceBright: Color(0xff594e48),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff261e19),
      surfaceContainer: Color(0xff382e29),
      surfaceContainerHigh: Color(0xff443934),
      surfaceContainerHighest: Color(0xff4f453f),
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
    success,
    info,
    pro,
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
