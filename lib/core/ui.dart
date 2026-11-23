import 'package:flutter/material.dart';

import 'theme.dart';

/// Muestra un SnackBar (feedback visual) reemplazando el anterior.
/// Se cierra solo a los 3 segundos.
void mostrarMensaje(BuildContext context, String mensaje,
    {SnackBarAction? accion}) {
  const duracion = Duration(seconds: 3);
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  final controlador = messenger.showSnackBar(
    SnackBar(
      content: Text(mensaje),
      behavior: SnackBarBehavior.floating,
      duration: duracion,
      persist: false,
      action: accion,
    ),
  );

  // Un SnackBar con acción ("Ver carrito") puede quedarse fijo (por ejemplo
  // si el dispositivo tiene opciones de accesibilidad activas), así que se
  // cierra con un temporizador propio.
  var cerrado = false;
  controlador.closed.then((_) => cerrado = true);
  Future<void>.delayed(duracion, () {
    if (!cerrado) messenger.hideCurrentSnackBar();
  });
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
