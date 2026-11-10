import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Etiqueta con la condición de la prenda (Excelente, Bueno, Aceptable).
class EstadoBadge extends StatelessWidget {
  final String texto;
  final bool agotada;

  const EstadoBadge({super.key, required this.texto, this.agotada = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: agotada ? kGrisTexto : kNegro,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        agotada ? 'Agotada' : texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
