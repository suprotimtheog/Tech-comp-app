import 'package:flutter/material.dart';

abstract class AppColors {
  // Base App Colors
  static const Color background = Color(0xFF0F172A); // Dark Slate
  static const Color surface = Color(0xFF1E293B);    // Card Surface
  static const Color primary = Color(0xFF6366F1);    // Indigo Accent
  static const Color secondary = Color(0xFFA855F7);  // Purple Accent
  
  // Slot & Card Colors
  static const Color cardBorder = Color(0xFF334155);
  static const Color emptySlotBg = Color(0xFF1E293B);
  
  // Background Gradient (Dark Navy/Slate)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF020617),
    ],
  );

  // Accent Gradient (For Buttons, Icons & Highlights)
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFFA855F7),
    ],
  );
}