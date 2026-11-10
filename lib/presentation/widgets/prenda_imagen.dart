import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Muestra la foto de la prenda. Si no hay URL (o falla la carga) muestra
/// el recuadro con ícono, igual que en el diseño de Figma.
class PrendaImagen extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final double iconSize;
  final double radio;

  const PrendaImagen({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.iconSize = 56,
    this.radio = 12,
  });

  Widget _placeholder() {
    return Center(
      child: Icon(Icons.image_outlined, size: iconSize, color: kNegro),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieneUrl = url.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        color: kGrisFondo,
        child: tieneUrl
            ? Image.network(
                url.trim(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => _placeholder(),
                loadingBuilder: (context, child, progreso) {
                  if (progreso == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
            : _placeholder(),
      ),
    );
  }
}
