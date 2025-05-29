import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Font Family
  static const String fontFamily = 'Poppins';

  // Font Weight
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Text Styles
  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: bold,
    color: AppColors.textColor,
  );
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semibold,
    color: AppColors.textColor,
  );
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: medium,
    color: AppColors.textColor,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.textColor,
  );

  static const TextStyle buttonLogin = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: medium,
    color: Colors.white,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    color: Colors.white,
  );

  // Border Radius
  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(8),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(16),
  );
  static const BorderRadius borderRadiusEkstraLarge = BorderRadius.all(
    Radius.circular(20),
  );

  static List<BoxShadow> cardShadow = [
    // Berupa List<BoxShadow>
    BoxShadow(
      color: Colors.grey.withOpacity(0.2),
      spreadRadius: 2, // Seberapa jauh shadow menyebar
      blurRadius: 5, // Seberapa blur shadow tersebut
      offset: Offset(0, 3), // Posisi shadow (horizontal, vertical)
    ),
  ];
}
