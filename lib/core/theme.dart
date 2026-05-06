import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF003EC7);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0052FF);
  static const onPrimaryContainer = Color(0xFFDFE3FF);
  static const primaryFixed = Color(0xFFDDE1FF);
  static const primaryFixedDim = Color(0xFFB7C4FF);
  static const onPrimaryFixed = Color(0xFF001452);
  static const onPrimaryFixedVariant = Color(0xFF0038B6);

  // Secondary
  static const secondary = Color(0xFF7C5800);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFEB700);
  static const onSecondaryContainer = Color(0xFF6B4B00);
  static const secondaryFixed = Color(0xFFFFDEA8);
  static const secondaryFixedDim = Color(0xFFFFBA20);
  static const onSecondaryFixed = Color(0xFF271900);
  static const onSecondaryFixedVariant = Color(0xFF5E4200);

  // Tertiary
  static const tertiary = Color(0xFF064D98);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF2F66B2);
  static const onTertiaryContainer = Color(0xFFDAE5FF);
  static const tertiaryFixed = Color(0xFFD6E3FF);
  static const tertiaryFixedDim = Color(0xFFA9C7FF);
  static const onTertiaryFixed = Color(0xFF001B3D);
  static const onTertiaryFixedVariant = Color(0xFF00468C);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Surface
  static const surface = Color(0xFFF8F9FF);
  static const onSurface = Color(0xFF0B1C30);
  static const surfaceVariant = Color(0xFFD3E4FE);
  static const onSurfaceVariant = Color(0xFF434656);
  static const surfaceBright = Color(0xFFF8F9FF);
  static const surfaceDim = Color(0xFFCBDBF5);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);
  static const inverseSurface = Color(0xFF213145);
  static const inverseOnSurface = Color(0xFFEAF1FF);
  static const inversePrimary = Color(0xFFB7C4FF);

  // Background
  static const background = Color(0xFFF8F9FF);
  static const onBackground = Color(0xFF0B1C30);

  // Outline
  static const outline = Color(0xFF737688);
  static const outlineVariant = Color(0xFFC3C5D9);

  // Surface Tint
  static const surfaceTint = Color(0xFF004CED);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
          letterSpacing: -0.01 * 20,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
    );
  }
}
