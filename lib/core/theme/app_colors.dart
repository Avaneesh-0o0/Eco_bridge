import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E8449); // Darker, richer forest green
  static const Color primaryLight = Color(0xFF2ECC71); // Emerald green for gradients
  static const Color secondary = Color(0xFFE67E22); // Deeper warm orange
  static const Color secondaryLight = Color(0xFFF39C12);
  
  static const Color background = Color(0xFFFBFBF9); // Very soft warm white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF1C2833); // Premium dark navy/charcoal
  static const Color secondaryText = Color(0xFF7F8C8D); // Soft slate gray
  
  // Extra semantic colors
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF27AE60);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
