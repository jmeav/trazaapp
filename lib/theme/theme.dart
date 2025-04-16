import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);
static MaterialScheme lightScheme() {
  return const MaterialScheme(
    brightness: Brightness.light,
    primary: Color.fromARGB(255, 76, 175, 80),         // Verde más oscuro
    surfaceTint: Color.fromARGB(255, 76, 175, 80),
    onPrimary: Color(0xFFFFFFFF),                       // Blanco
    primaryContainer: Color(0xFFC8E6C9),                // Verde más suave
    onPrimaryContainer: Color(0xFF1B5E20),              // Verde oscuro

    secondary: Color(0xFF5E6472),                       // Gris elegante
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE3E6EB),
    onSecondaryContainer: Color(0xFF1C1F24),

    tertiary: Color(0xFFFFB74D),                        // Naranja pastel cálido
    onTertiary: Color(0xFF442C00),
    tertiaryContainer: Color(0xFFFFE0B2),
    onTertiaryContainer: Color(0xFF2C1C00),

    error: Color(0xFFB00020),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD4),
    onErrorContainer: Color(0xFF410001),

    background: Color(0xFFFFFFFF),
    onBackground: Color(0xFF1A1C1E),
    surface: Color(0xFFF5F5F5),
    onSurface: Color(0xFF1A1C1E),

    surfaceVariant: Color(0xFFE0F7FA),
    onSurfaceVariant: Color(0xFF37474F),

    outline: Color(0xFF90A4AE),
    outlineVariant: Color(0xFFD1E3E6),

    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),

    inverseSurface: Color(0xFF2E3B3E),
    inverseOnSurface: Color(0xFFF1F1F1),
    inversePrimary: Color(0xFF00ACC1),

    primaryFixed: Color(0xFFB2EBF2),
    onPrimaryFixed: Color(0xFF00363A),
    primaryFixedDim: Color(0xFF00BCD4),
    onPrimaryFixedVariant: Color(0xFF004D40),

    secondaryFixed: Color(0xFFE8EAED),
    onSecondaryFixed: Color(0xFF2E3137),
    secondaryFixedDim: Color(0xFF5E6472),
    onSecondaryFixedVariant: Color(0xFF1C1F24),

    tertiaryFixed: Color(0xFFFFF3E0),
    onTertiaryFixed: Color(0xFF3E2723),
    tertiaryFixedDim: Color(0xFFFFB74D),
    onTertiaryFixedVariant: Color(0xFF2C1C00),

    surfaceDim: Color(0xFFFAFAFA),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F9FA),
    surfaceContainer: Color(0xFFF0F2F4),
    surfaceContainerHigh: Color(0xFFEAECEE),
    surfaceContainerHighest: Color(0xFFE3E6E8),
  );
}


  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4281420306),
      surfaceTint: Color(4283196971),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4284579135),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282140207),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285429854),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4279913031),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283399545),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294572783),
      onBackground: Color(4279901206),
      surface: Color(4294572783),
      onSurface: Color(4279901206),
      surfaceVariant: Color(4292994261),
      onSurfaceVariant: Color(4282401849),
      outline: Color(4284309845),
      outlineVariant: Color(4286086256),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282858),
      inverseOnSurface: Color(4294046438),
      inversePrimary: Color(4289843594),
      primaryFixed: Color(4284579135),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282999849),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285429854),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283785031),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283399545),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4281754720),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292533200),
      surfaceBright: Color(4294572783),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294178025),
      surfaceContainer: Color(4293849059),
      surfaceContainerHigh: Color(4293454302),
      surfaceContainerHighest: Color(4293059544),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4279510784),
      surfaceTint: Color(4283196971),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4281420306),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280034577),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4282140207),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278200101),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4279913031),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294572783),
      onBackground: Color(4279901206),
      surface: Color(4294572783),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4292994261),
      onSurfaceVariant: Color(4280362268),
      outline: Color(4282401849),
      outlineVariant: Color(4282401849),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282858),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4292278188),
      primaryFixed: Color(4281420306),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4280038144),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4282140207),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280692763),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4279913031),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278203185),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292533200),
      surfaceBright: Color(4294572783),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294178025),
      surfaceContainer: Color(4293849059),
      surfaceContainerHigh: Color(4293454302),
      surfaceContainerHighest: Color(4293059544),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }
static MaterialScheme darkScheme() {
  return const MaterialScheme(
    brightness: Brightness.dark,

    // 🟦 Primario (turquesa brillante sobre fondo oscuro)
    primary: Color.fromARGB(255, 17, 207, 216),
    surfaceTint: Color.fromARGB(255, 17, 207, 216),
    onPrimary: Color(0xFF001F20),
    primaryContainer: Color(0xFF004F52),
    onPrimaryContainer: Color(0xFF96F1F6),

    // 🟩 Secundario (verde-gris elegante)
    secondary: Color(0xFFB0BEC5),
    onSecondary: Color(0xFF212121),
    secondaryContainer: Color(0xFF37474F),
    onSecondaryContainer: Color(0xFFECEFF1),

    // 🟧 Terciario (naranja suave para resaltar)
    tertiary: Color(0xFFFFB74D),
    onTertiary: Color(0xFF3E2723),
    tertiaryContainer: Color(0xFF5D4037),
    onTertiaryContainer: Color(0xFFFFE0B2),

    // ❌ Errores
    error: Color(0xFFFF6659),
    onError: Color(0xFF370B0E),
    errorContainer: Color(0xFFB00020),
    onErrorContainer: Color(0xFFFFDAD4),

    // 🖤 Fondo y superficies
    background: Color(0xFF121212),
    onBackground: Color(0xFFE0F7FA),
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFE0F7FA),

    surfaceVariant: Color(0xFF263238),
    onSurfaceVariant: Color(0xFFB0BEC5),

    outline: Color(0xFF78909C),
    outlineVariant: Color(0xFF37474F),

    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),

    // 🔄 Inversos (modo claro)
    inverseSurface: Color(0xFFE0F7FA),
    inverseOnSurface: Color(0xFF00363A),
    inversePrimary: Color(0xFF00ACC1),

    // 🔒 Fijos (accesibilidad)
    primaryFixed: Color(0xFF00BCD4),
    onPrimaryFixed: Color(0xFF002022),
    primaryFixedDim: Color(0xFF00ACC1),
    onPrimaryFixedVariant: Color(0xFF004C4F),

    secondaryFixed: Color(0xFF90A4AE),
    onSecondaryFixed: Color(0xFF263238),
    secondaryFixedDim: Color(0xFF78909C),
    onSecondaryFixedVariant: Color(0xFFCFD8DC),

    tertiaryFixed: Color(0xFFFFCC80),
    onTertiaryFixed: Color(0xFF3E2723),
    tertiaryFixedDim: Color(0xFFFFB74D),
    onTertiaryFixedVariant: Color(0xFF4E342E),

    surfaceDim: Color(0xFF101010),
    surfaceBright: Color(0xFF2C2C2C),
    surfaceContainerLowest: Color(0xFF0A0A0A),
    surfaceContainerLow: Color(0xFF141414),
    surfaceContainer: Color(0xFF1C1C1C),
    surfaceContainerHigh: Color(0xFF222222),
    surfaceContainerHighest: Color(0xFF2A2A2A),
  );
}


  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color.fromARGB(255, 1, 242, 238),
      surfaceTint: Color.fromARGB(255, 138, 198, 209),
      onPrimary: Color(4278983168),
      primaryContainer: Color(4286421593),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4291088305),
      onSecondary: Color(4279245063),
      secondaryContainer: Color(4287272313),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4288992464),
      onTertiary: Color(4278196761),
      tertiaryContainer: Color(4285241749),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      background: Color(4279374862),
      onBackground: Color(4293059544),
      surface: Color(4279374862),
      onSurface: Color(4294704368),
      surfaceVariant: Color(4282665021),
      onSurfaceVariant: Color(4291415230),
      outline: Color(4288783511),
      outlineVariant: Color(4286678392),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059544),
      inverseOnSurface: Color(4280822564),
      inversePrimary: Color(4281749271),
      primaryFixed: Color(4291685795),
      onPrimaryFixed: Color(4278719488),
      primaryFixedDim: Color(4289843594),
      onPrimaryFixedVariant: Color(4280630533),
      secondaryFixed: Color(4292667336),
      onSecondaryFixed: Color(4278916099),
      secondaryFixedDim: Color(4290759597),
      onSecondaryFixedVariant: Color(4281350436),
      tertiaryFixed: Color(4290571495),
      onTertiaryFixed: Color(4278195219),
      tertiaryFixedDim: Color(4288729291),
      onTertiaryFixedVariant: Color(4278730042),
      surfaceDim: Color(4279374862),
      surfaceBright: Color(4281874994),
      surfaceContainerLowest: Color(4278980361),
      surfaceContainerLow: Color(4279901206),
      surfaceContainer: Color(4280164378),
      surfaceContainerHigh: Color(4280822564),
      surfaceContainerHighest: Color(4281546286),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294246367),
      surfaceTint: Color(4289843594),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4290106766),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294246367),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4291088305),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4293591036),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4288992464),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279374862),
      onBackground: Color(4293059544),
      surface: Color(4279374862),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4282665021),
      onSurfaceVariant: Color(4294573293),
      outline: Color(4291415230),
      outlineVariant: Color(4291415230),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059544),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4279906304),
      primaryFixed: Color(4291949223),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4290106766),
      onPrimaryFixedVariant: Color(4278983168),
      secondaryFixed: Color(4292930508),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4291088305),
      onSecondaryFixedVariant: Color(4279245063),
      tertiaryFixed: Color(4290834668),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4288992464),
      onTertiaryFixedVariant: Color(4278196761),
      surfaceDim: Color(4279374862),
      surfaceBright: Color(4281874994),
      surfaceContainerLowest: Color(4278980361),
      surfaceContainerLow: Color(4279901206),
      surfaceContainer: Color(4280164378),
      surfaceContainerHigh: Color(4280822564),
      surfaceContainerHighest: Color(4281546286),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
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
  appBarTheme: AppBarTheme(
    titleTextStyle: TextStyle(
      fontSize: 20, // Tamaño de fuente
      fontWeight: FontWeight.bold, // Negrita
      color: colorScheme.onSurface, // Color del texto
    ),
    elevation: 4, // Elevación del AppBar
  ),
);
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary, 
    required this.surfaceTint, 
    required this.onPrimary, 
    required this.primaryContainer, 
    required this.onPrimaryContainer, 
    required this.secondary, 
    required this.onSecondary, 
    required this.secondaryContainer, 
    required this.onSecondaryContainer, 
    required this.tertiary, 
    required this.onTertiary, 
    required this.tertiaryContainer, 
    required this.onTertiaryContainer, 
    required this.error, 
    required this.onError, 
    required this.errorContainer, 
    required this.onErrorContainer, 
    required this.background, 
    required this.onBackground, 
    required this.surface, 
    required this.onSurface, 
    required this.surfaceVariant, 
    required this.onSurfaceVariant, 
    required this.outline, 
    required this.outlineVariant, 
    required this.shadow, 
    required this.scrim, 
    required this.inverseSurface, 
    required this.inverseOnSurface, 
    required this.inversePrimary, 
    required this.primaryFixed, 
    required this.onPrimaryFixed, 
    required this.primaryFixedDim, 
    required this.onPrimaryFixedVariant, 
    required this.secondaryFixed, 
    required this.onSecondaryFixed, 
    required this.secondaryFixedDim, 
    required this.onSecondaryFixedVariant, 
    required this.tertiaryFixed, 
    required this.onTertiaryFixed, 
    required this.tertiaryFixedDim, 
    required this.onTertiaryFixedVariant, 
    required this.surfaceDim, 
    required this.surfaceBright, 
    required this.surfaceContainerLowest, 
    required this.surfaceContainerLow, 
    required this.surfaceContainer, 
    required this.surfaceContainerHigh, 
    required this.surfaceContainerHighest, 
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
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
