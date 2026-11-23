import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Etiqueta con la condición de la prenda (Excelente, Bueno, Aceptable).
class EstadoBadge extends StatelessWidget {
  final String texto;
  final bool agotada;

  const EstadoBadge({super.key, required this.texto, this.agotada = false});

  @override
  Widget build(BuildContext context) {
    final (fondo, letra) =
        agotada ? (kGrisTexto, Colors.white) : coloresEstado(texto);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        agotada ? 'Agotada' : texto,
        style: TextStyle(
          color: letra,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
