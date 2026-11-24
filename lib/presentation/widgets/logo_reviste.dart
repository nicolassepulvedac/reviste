import 'package:flutter/material.dart';

/// Logo de ReViste (el mismo de la app en el celular): una percha sobre
/// fondo verde, en círculo.
class LogoReViste extends StatelessWidget {
  final double size;

  const LogoReViste({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/icon/icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'Logo de ReViste',
      ),
    );
  }
}
