import 'package:flutter/material.dart';

/// Design tokens for the jewellery store admin app — black/white base with a
/// blush-pink accent, matching the reference dashboard/analytics/orders design.
class AppColors {
  static const ink = Color(0xFF15161A);        // near-black, used for text + primary CTAs
  static const inkSoft = Color(0xFF6B6E76);
  static const inkFaint = Color(0xFFA0A3AA);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F7F8);
  static const border = Color(0xFFEDEDEF);

  static const primary = ink;                   // black CTA / selected state
  static const primaryLight = Color(0xFFF8E9EE); // pale blush, selected chip bg

  static const blush = Color(0xFFE9AEC2);        // chart bars / soft accent
  static const blushDeep = Color(0xFFD98CA6);    // chart line / stronger accent
  static const cardMuted = Color(0xFFF1F2F3);    // light gray card fill (2nd chart series)

  static const success = Color(0xFF1E9E52);
  static const danger = Color(0xFFDC2626);
  static const warning = Color(0xFFB78103);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ink,
        primary: AppColors.ink,
        secondary: AppColors.blushDeep,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: -0.4,
        ),
        titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
        titleMedium: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
        bodyLarge: const TextStyle(fontSize: 14, color: AppColors.ink),
        bodyMedium: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
        labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkFaint, letterSpacing: 0.4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.4),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.ink, width: 1.6)),
        labelStyle: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
        hintStyle: const TextStyle(color: AppColors.inkFaint, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(fontSize: 12.5, color: AppColors.ink, fontWeight: FontWeight.w500),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w800 : FontWeight.w500, color: selected ? AppColors.ink : AppColors.inkFaint);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? AppColors.ink : AppColors.inkFaint, size: 22);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
