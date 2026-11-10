import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/entities/prenda.dart';
import '../providers/filtros_provider.dart';
import 'estado_badge.dart';
import 'prenda_imagen.dart';

/// Card de una prenda para la grilla de Explorar.
class PrendaCard extends ConsumerWidget {
  final Prenda prenda;

  const PrendaCard({super.key, required this.prenda});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esFavorita = ref.watch(favoritosProvider).contains(prenda.id);

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kBorde),
      ),
      child: InkWell(
        onTap: () => context.push('/prenda/${prenda.id}'),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: PrendaImagen(url: prenda.imagenUrl, iconSize: 48),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => ref
                            .read(favoritosProvider.notifier)
                            .alternar(prenda.id),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            esFavorita ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: kNegro,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                prenda.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                'Talla: ${prenda.talla}',
                style: const TextStyle(color: kGrisTexto, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatearPrecio(prenda.precio),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  EstadoBadge(texto: prenda.estado, agotada: prenda.agotada),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
