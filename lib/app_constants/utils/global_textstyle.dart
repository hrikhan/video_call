import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalTextStyle {
  static TextStyle heading({
    Color color = Colors.white,
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return GoogleFonts.lato(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.1,
    );
  }

  static TextStyle body({
    Color color = Colors.white70,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.poppins(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.4,
    );
  }
}
