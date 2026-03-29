// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark backgrounds
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgCardLight = Color(0xFF1A2235);
  static const Color bgSurface = Color(0xFF162032);

  // Primary
  static const Color primary = Color(0xFF00E5A0);
  static const Color primaryDim = Color(0xFF00B37A);
  static const Color primaryGlow = Color(0x2200E5A0);

  // Accent
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Danger
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerDim = Color(0xFFDC2626);
  static const Color dangerGlow = Color(0x22EF4444);

  // Warning
  static const Color warning = Color(0xFFF59E0B);

  // Text (dark mode)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);
  static const Color textGreen = Color(0xFF00E5A0);

  // Status
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusFailure = Color(0xFFEF4444);
  static const Color statusManual = Color(0xFF8B5CF6);
  static const Color statusOnline = Color(0xFF22C55E);

  // Nav
  static const Color navBg = Color(0xFF0D1520);
  static const Color navActive = Color(0xFF1E3A5F);

  // Light mode colors
  static const Color lightBg = Color(0xFFF4F6FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightNavBg = Color(0xFFFFFFFF);
}

class AppTheme {
  // ─── DARK THEME ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accentBlue,
        surface: AppColors.bgCard,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      dividerColor: AppColors.bgCardLight,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.bgCardLight,
        ),
      ),
    );
  }

  // ─── LIGHT THEME ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDim,
        secondary: AppColors.accentBlue,
        surface: AppColors.lightCard,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightCard,
        elevation: 0,
        shadowColor: Colors.black12,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.lightCardBorder),
        ),
      ),
      dividerColor: AppColors.lightCardBorder,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryDim
              : Colors.grey.shade400,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryDim.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
    );
  }
}
