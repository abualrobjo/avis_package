import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  /// Returns Inter text style with given parameters
  static TextStyle _interStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double height = 1.5,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }

  // ====================
  // HEADINGS
  // ====================

  /// H1 - 24px
  static TextStyle get h1 =>
      _interStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, height: 1.2);

  /// H2 - 20px
  static TextStyle get h2 =>
      _interStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, height: 1.2);

  /// H3 - 18px
  static TextStyle get h3 =>
      _interStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, height: 1.2);

  // ====================
  // BODY
  // ====================

  /// Body / Large - 16px
  static TextStyle get bodyLarge =>
      _interStyle(fontSize: 16.sp, fontWeight: FontWeight.w400);

  static TextStyle get bodyLargeBold =>
      _interStyle(fontSize: 16.sp, fontWeight: FontWeight.w500);

  /// Body / Medium - 14px
  static TextStyle get bodyMedium =>
      _interStyle(fontSize: 14.sp, fontWeight: FontWeight.w400);

  static TextStyle get bodyMediumBold =>
      _interStyle(fontSize: 14.sp, fontWeight: FontWeight.w500);

  /// Body / Small - 12px
  static TextStyle get bodySmall =>
      _interStyle(fontSize: 12.sp, fontWeight: FontWeight.w400);

  static TextStyle get bodySmallBold =>
      _interStyle(fontSize: 12.sp, fontWeight: FontWeight.w500);

  /// Body / XSmall - 10px
  static TextStyle get bodyXSmall =>
      _interStyle(fontSize: 10.sp, fontWeight: FontWeight.w400);

  static TextStyle get bodyXSmallBold =>
      _interStyle(fontSize: 10.sp, fontWeight: FontWeight.w500);

  /// XXSmall / Label - 8px
  static TextStyle get label =>
      _interStyle(fontSize: 8.sp, fontWeight: FontWeight.w400);

  static TextStyle get labelBold =>
      _interStyle(fontSize: 8.sp, fontWeight: FontWeight.w500);
}
