import 'package:flutter/material.dart';

/// Premium palette anchored to the Olpo logo.
class AppColors {
  // Core brand
  static const Color primary = Color(0xFF0EA5E9); // vibrant teal-blue
  static const Color primaryDeep = Color(0xFF0369A1); // deeper anchor
  static const Color secondary = Color(0xFFF97316); // warm accent from logo

  // Neutrals
  static const Color neutralBg = Color(0xFFF7F9FC);
  static const Color neutralCard = Colors.white;
  static const Color border = Color(0xFFE5E7EB);

  // Text
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textMuted = Colors.black38;

  // Supporting
  static const Color success = Color(0xFF22C55E);
  static const Color info = Color(0xFF0EA5E9);
  static const Color warning = Color(0xFFFBBF24);

  // Ready-made gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primary, primaryDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
