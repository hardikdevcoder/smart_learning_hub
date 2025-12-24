import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5548E8);
  static const Color primaryLight = Color(0xFF8D85FF);

  // Secondary Colors
  static const Color secondary = Color(0xFF26C6DA);
  static const Color secondaryDark = Color(0xFF00ACC1);
  static const Color secondaryLight = Color(0xFF4DD0E1);

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);

  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Course Type Colors
  static const Color videoColor = Color(0xFFE91E63);
  static const Color pdfColor = Color(0xFFFF5722);
  static const Color pptColor = Color(0xFFFF9800);
  static const Color mcqColor = Color(0xFF9C27B0);

  // Admin Colors
  static const Color adminPrimary = Color(0xFF1A237E);
  static const Color adminAccent = Color(0xFFFF6F00);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(colors: [primary, primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient cardGradient = LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F7FA)], begin: Alignment.topCenter, end: Alignment.bottomCenter);

  // Shadows
  static List<BoxShadow> cardShadow = [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))];

  static List<BoxShadow> buttonShadow = [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))];
}
