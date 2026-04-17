import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Luxlog — "The Darkroom Editorial" Design System
/// Based on Stitch project 6660914350535156406
class AppColors {
  // ── Surfaces ──────────────────────────────────────────────
  static const background = Color(0xFF0E0E0E);          // Deepest Charcoal
  static const surface = Color(0xFF0E0E0E);
  static const surfaceContainerLowest = Color(0xFF000000);
  static const surfaceContainerLow = Color(0xFF131313);
  static const surfaceContainer = Color(0xFF191919);
  static const surfaceContainerHigh = Color(0xFF1F1F1F);
  static const surfaceContainerHighest = Color(0xFF262626);
  static const surfaceBright = Color(0xFF2C2C2C);
  static const surfaceVariant = Color(0xFF262626);
  static const surfaceDim = Color(0xFF0E0E0E);

  // ── Primary — Vintage Gold ─────────────────────────────────
  static const primary = Color(0xFFE2C19B);
  static const primaryContainer = Color(0xFF594325);
  static const primaryDim = Color(0xFFD3B38E);
  static const primaryFixed = Color(0xFFFFDDB6);
  static const onPrimary = Color(0xFF523C1F);
  static const onPrimaryContainer = Color(0xFFECCBA4);
  static const inversePrimary = Color(0xFF745B3B);

  // ── Secondary — Muted Silver ──────────────────────────────
  static const secondary = Color(0xFF9F9D9D);
  static const secondaryContainer = Color(0xFF3C3B3B);
  static const onSecondary = Color(0xFF202020);
  static const onSecondaryContainer = Color(0xFFC1BFBE);

  // ── Tertiary ──────────────────────────────────────────────
  static const tertiary = Color(0xFFFFF8F2);
  static const tertiaryContainer = Color(0xFFFEE9C2);
  static const onTertiary = Color(0xFF6C5D3F);

  // ── Text ──────────────────────────────────────────────────
  static const onBackground = Color(0xFFE5E5E5);    // Never pure white
  static const onSurface = Color(0xFFE5E5E5);
  static const onSurfaceVariant = Color(0xFFABABAB);

  // ── Borders ───────────────────────────────────────────────
  static const outline = Color(0xFF757575);
  static const outlineVariant = Color(0xFF484848);

  // ── Error ─────────────────────────────────────────────────
  static const error = Color(0xFFED7F64);
  static const errorContainer = Color(0xFF7E2B17);
  static const onError = Color(0xFF450900);

  // ── Glassmorphism ─────────────────────────────────────────
  static const glassBackground = Color(0x992C2C2C);  // rgba(44,44,44,0.6)
  static const glassBorder = Color(0x0DFFFFFF);       // rgba(255,255,255,0.05)

  AppColors._();
}

class AppTextStyles {
  static TextStyle get heroTitle => GoogleFonts.manrope(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.12, // -2% tracking
    color: AppColors.onSurface,
    height: 1.1,
  );

  static TextStyle get sectionHeader => GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.48,
    color: AppColors.onSurface,
  );

  static TextStyle get headline => GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle get titleLarge => GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle get titleMedium => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  /// EXIF metadata — Space Grotesk monospace feel
  static TextStyle get exifData => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
    letterSpacing: 0.5,
  );

  /// EXIF label
  static TextStyle get exifLabel => GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.8,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  AppTextStyles._();
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
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
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        inversePrimary: AppColors.inversePrimary,
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.heroTitle,
        headlineMedium: AppTextStyles.sectionHeader,
        headlineSmall: AppTextStyles.headline,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.bodySmall,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.caption,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.glassBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        surfaceTintColor: Colors.transparent,
      ),

      // Cards — no border, tonal layering
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Sharp, professional
        ),
      ),

      // Primary button — Vintage Gold fill, sharp corners
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // Ghost button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outline, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      iconTheme: const IconThemeData(color: AppColors.onSurface, size: 20),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: AppTextStyles.label,
        hintStyle: AppTextStyles.bodySmall,
      ),

      dividerTheme: const DividerThemeData(
        color: Colors.transparent, // No-Line Rule — use color shifts instead
        space: 0,
        thickness: 0,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.glassBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        selectedColor: AppColors.primaryContainer,
        labelStyle: AppTextStyles.exifData,
        side: const BorderSide(color: Colors.transparent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      extensions: const [DarkroomExtension()],
    );
  }

  AppTheme._();
}

/// Custom theme extension for Darkroom-specific tokens
class DarkroomExtension extends ThemeExtension<DarkroomExtension> {
  final Color glassBg;
  final Color ghostBorder;
  final Color goldAccent;
  final Color exifBackground;

  const DarkroomExtension({
    this.glassBg = AppColors.glassBackground,
    this.ghostBorder = const Color(0x26484848), // outlineVariant at 15%
    this.goldAccent = AppColors.primary,
    this.exifBackground = AppColors.surfaceContainerHighest,
  });

  @override
  DarkroomExtension copyWith({
    Color? glassBg,
    Color? ghostBorder,
    Color? goldAccent,
    Color? exifBackground,
  }) {
    return DarkroomExtension(
      glassBg: glassBg ?? this.glassBg,
      ghostBorder: ghostBorder ?? this.ghostBorder,
      goldAccent: goldAccent ?? this.goldAccent,
      exifBackground: exifBackground ?? this.exifBackground,
    );
  }

  @override
  DarkroomExtension lerp(DarkroomExtension? other, double t) {
    if (other is! DarkroomExtension) return this;
    return DarkroomExtension(
      glassBg: Color.lerp(glassBg, other.glassBg, t)!,
      ghostBorder: Color.lerp(ghostBorder, other.ghostBorder, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      exifBackground: Color.lerp(exifBackground, other.exifBackground, t)!,
    );
  }
}
