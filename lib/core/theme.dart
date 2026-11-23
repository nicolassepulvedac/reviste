import 'package:flutter/material.dart';

// Paleta ReViste: verde salvia y crema (segunda mano, sustentable, cálida).
const Color kVerde = Color(0xFF4A6B4F); // color principal (salvia profundo)
const Color kVerdeClaro = Color(0xFFDCE6D5); // fondo suave del verde
const Color kCrema = Color(0xFFFBF8F1); // fondo de las pantallas
const Color kCoral = Color(0xFFC8553D); // acento (favoritos)

const Color kNegro = Color(0xFF1F2B24); // texto principal (verde casi negro)
const Color kBorde = Color(0xFFE6E0D0);
const Color kGrisTexto = Color(0xFF6B6F66);
const Color kGrisFondo = Color(0xFFEFEADB); // fondo de fotos y placeholders

/// Colores de la etiqueta de condición: (fondo, texto).
(Color, Color) coloresEstado(String estado) {
  switch (estado) {
    case 'Excelente':
      return (const Color(0xFFDCEBDD), const Color(0xFF2F5E3A));
    case 'Bueno':
      return (const Color(0xFFF6E7B8), const Color(0xFF6E5200));
    default: // Aceptable
      return (const Color(0xFFF8DCCB), const Color(0xFF86391A));
  }
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: kVerde,
      onPrimary: Colors.white,
      secondary: kVerde,
      onSecondary: Colors.white,
      secondaryContainer: kVerdeClaro,
      onSecondaryContainer: kVerde,
      surface: Colors.white,
      onSurface: kNegro,
      error: Color(0xFFB3261E),
    ),
    scaffoldBackgroundColor: kCrema,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kVerde,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: kVerde),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kCrema,
      surfaceTintColor: Colors.transparent,
      indicatorColor: kVerdeClaro,
      iconTheme: WidgetStateProperty.resolveWith((estados) {
        final activo = estados.contains(WidgetState.selected);
        return IconThemeData(color: activo ? kVerde : kGrisTexto);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((estados) {
        final activo = estados.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
          color: activo ? kVerde : kGrisTexto,
        );
      }),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kNegro,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: kVerde),
  );
}
