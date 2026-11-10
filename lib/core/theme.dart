import 'package:flutter/material.dart';

const Color kNegro = Color(0xFF111111);
const Color kBorde = Color(0xFFE8E8E8);
const Color kGrisTexto = Color(0xFF6B6B6B);
const Color kGrisFondo = Color(0xFFF3F3F3);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: kNegro,
      onPrimary: Colors.white,
      secondary: kNegro,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: kNegro,
      error: Color(0xFFB3261E),
    ),
    scaffoldBackgroundColor: Colors.white,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kNegro,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
