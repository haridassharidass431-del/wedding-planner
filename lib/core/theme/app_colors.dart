import 'package:flutter/material.dart';

/// App-wide color palette tailored for Haventra Wedding Planner.
/// Implements deep plum/burgundy, royal gold accents, and ivory/cream surfaces.
class AppColors {
  AppColors._();

  // Primary Plum & Burgundy
  static const Color primaryPlum = Color(0xFF4A154B);
  static const Color darkPlum = Color(0xFF2A082B);
  static const Color burgundy = Color(0xFF67194A);
  static const Color plumLight = Color(0xFF832B6E);
  static const Color plumTint = Color(0xFFF6EEF6);
  static const Color plumOverlay = Color(0x1A4A154B);

  // Royal Gold Accents
  static const Color royalGold = Color(0xFFD4AF37);
  static const Color brightGold = Color(0xFFE5C158);
  static const Color deepGold = Color(0xFFB58E26);
  static const Color softChampagne = Color(0xFFFBF4E2);
  static const Color goldBorder = Color(0xFFE2C97E);

  // Ivory & Cream Backgrounds
  static const Color ivoryBackground = Color(0xFFFCFBF7);
  static const Color warmCream = Color(0xFFF7F2E8);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardSurfaceTint = Color(0xFFFAF7F0);
  static const Color borderLight = Color(0xFFEBE5D8);

  // Text & Typography
  static const Color textPrimary = Color(0xFF221124);
  static const Color textSecondary = Color(0xFF67586A);
  static const Color textMuted = Color(0xFF9E92A0);
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
