import 'package:flutter/material.dart';

/// Couleurs de l'application : sarcelle des maquettes du TP, bleu nuit pour
/// les textes, corail pour les prix, fond sable.
abstract final class AppColors {
  static const teal = Color(0xFF0E8A82);
  static const ink = Color(0xFF13293D);
  static const coral = Color(0xFFFF6B4A);
  static const sand = Color(0xFFF7F4EF);
  static const line = Color(0xFFE8E2D9);
  static const muted = Color(0xFF66768A);

  /// Dégradé des en-têtes (connexion, profil).
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1BB5A7), teal, ink],
  );
}

/// Ombre douce des cartes posées sur le fond.
const cardShadow = [
  BoxShadow(color: Color(0x1A13293D), blurRadius: 22, offset: Offset(0, 10)),
];

/// Ombre des barres fixées en bas d'écran.
const barShadow = [
  BoxShadow(color: Color(0x1413293D), blurRadius: 20, offset: Offset(0, -6)),
];

/// Thème Material 3 de l'application, avec la police Poppins (fonts/).
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    primary: AppColors.teal,
    secondary: AppColors.coral,
    surface: AppColors.sand,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
  );
  final base = ThemeData(colorScheme: scheme, fontFamily: 'Poppins');
  final text = base.textTheme;
  final buttonText = text.titleSmall?.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );
  OutlineInputBorder fieldBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.sand,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      // Même marge que le contenu des pages.
      titleSpacing: 20,
      titleTextStyle: text.titleLarge?.copyWith(
        color: AppColors.ink,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      prefixIconColor: AppColors.muted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: fieldBorder(AppColors.line),
      enabledBorder: fieldBorder(AppColors.line),
      focusedBorder: fieldBorder(AppColors.teal, 1.8),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 54),
        shape: rounded,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 54),
        shape: rounded,
        textStyle: buttonText,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line, width: 1.5),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 0,
      selectedItemColor: AppColors.teal,
      unselectedItemColor: AppColors.muted,
      selectedLabelStyle: text.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: text.labelMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
