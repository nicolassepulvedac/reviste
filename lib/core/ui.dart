import 'package:flutter/material.dart';

import 'theme.dart';

/// Muestra un SnackBar (feedback visual) reemplazando el anterior.
void mostrarMensaje(BuildContext context, String mensaje,
    {SnackBarAction? accion}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(mensaje),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      // Desde Flutter 3.29 un SnackBar con acción no se cierra solo salvo
      // que se indique persist: false.
      persist: false,
      action: accion,
    ),
  );
}

/// AppBar con el estilo de ReViste (crema, sin sombra).
AppBar buildAppBar(String titulo, {List<Widget>? actions}) {
  return AppBar(
    title: Text(
      titulo,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
    ),
    backgroundColor: kCrema,
    foregroundColor: kNegro,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    actions: actions,
  );
}

/// Decoración común para los campos de formulario.
InputDecoration campoDeco(String label, {String? hint, Widget? prefixIcon}) {
  OutlineInputBorder borde(Color color, [double ancho = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: borde(kBorde),
    enabledBorder: borde(kBorde),
    focusedBorder: borde(kVerde, 1.5),
    errorBorder: borde(const Color(0xFFB3261E)),
    focusedErrorBorder: borde(const Color(0xFFB3261E), 1.5),
  );
}
