import 'package:flutter/material.dart';

/// App-wide color palette tailored for Haventra Wedding Planner.
/// Haventra logo palette: two violet brand colors with neutral surfaces.
class AppColors {
  AppColors._();

  // Haventra logo: rich violet with a lighter violet supporting accent.
  static const Color primaryPlum = Color(0xFF4B1FA8);
  static const Color darkPlum = Color(0xFF351078);
  static const Color burgundy = Color(0xFF6338C5);
  static const Color plumLight = Color(0xFF8359D6);
  static const Color plumTint = Color(0xFFF3EFFB);
  static const Color plumOverlay = Color(0x1A4B1FA8);

  // Royal Gold Accents
  static const Color royalGold = Color(0xFF7C3AED);
  static const Color brightGold = Color(0xFF9B6BFA);
  static const Color deepGold = Color(0xFF5B21B6);
  static const Color secondaryPurple = royalGold;
  static const Color softChampagne = Color(0xFFF5F1FC);
  static const Color goldBorder = Color(0xFFD9CBEF);

  // Ivory & Cream Backgrounds
  static const Color ivoryBackground = Color(0xFFFAF9FD);
  static const Color warmCream = Color(0xFFF5F2FA);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardSurfaceTint = Color(0xFFFAF7F0);
  static const Color borderLight = Color(0xFFEAE5F2);

  // Text & Typography
  static const Color textPrimary = Color(0xFF211B2D);
  static const Color textSecondary = Color(0xFF665F70);
  static const Color textMuted = Color(0xFF91899B);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnGold = Color(0xFF2A082B);

  // Status & Utility
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFEF6C00);
  static const Color ratingStar = Color(0xFFE5A110);

  // Luxury Gradients
  static const LinearGradient plumGradient = LinearGradient(
    colors: [primaryPlum, burgundy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroPlumGradient = LinearGradient(
    colors: [darkPlum, primaryPlum, burgundy],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [royalGold, brightGold, deepGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardFoilGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAF6EE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
