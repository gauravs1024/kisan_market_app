import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF00C853); // Vibrant Mint Green
  static const Color primaryDark = Color(0xFF007E33);
  static const Color secondary = Color(0xFFFFB300); // Harvest Gold / Amber
  static const Color accent = Color(0xFF00E676);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0A0F0D); // Ultra-deep forest black
  static const Color darkSurface = Color(0xFF131B18); // Dark Emerald Slate Card
  static const Color darkOnSurface = Color(0xFFE8F5E9);
  static const Color darkSubtext = Color(0xFF81C784);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF9FBF9); // Clean soft minty white
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1E2321);
  static const Color lightSubtext = Color(0xFF4E5D56);

  // Utility & Status Colors
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color grey = Colors.grey;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static final Color grey500 = Colors.grey[500]!;

  // Shading & borders
  static final Color lightBorder = Colors.green.shade50;
  static final Color lightGreyShade = Colors.grey.shade100;
  static final Color lightGrey200 = Colors.grey.shade200;
}
