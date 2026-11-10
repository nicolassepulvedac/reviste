import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../domain/entities/prenda.dart';
import '../providers/filtros_provider.dart';
import '../providers/prendas_provider.dart';
import '../widgets/prenda_imagen.dart';

/// Lista de las prendas del usuario con editar (UPDATE) y eliminar (DELETE).
class MisPublicacionesScreen extends ConsumerWidget {
  const MisPublicacionesScreen({super.key});

  Future<void> _confirmarEliminar(
    BuildContext context,
    WidgetRef ref,
    Prenda prenda,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar prenda'),
        content: Text('¿Seguro que quieres eliminar "${prenda.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await ref.read(prendasProvider.notifier).eliminar(prenda.id);
    if (!context.mounted) return;
    mostrarMensaje(context, 'Prenda eliminada');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prendas = ref.watch(misPublicacionesProvider);

    return Scaffold(
      appBar: buildAppBar('Mis publicaciones'),
      body: prendas.isEmpty
          ? const Center(
              child: Text(
                'Aún no has publicado prendas',
                style: TextStyle(color: kGrisTexto),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: prendas.length,
              separatorBuilder: (context, i) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = prendas[i];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: kBorde),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      PrendaImagen(
                        url: p.imagenUrl,
                        width: 64,
                        height: 64,
                        iconSize: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${formatearPrecio(p.precio)} • Talla ${p.talla} • ${p.estado}',
                              style: const TextStyle(
                                color: kGrisTexto,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              p.agotada ? 'Agotada' : 'Stock: ${p.stock}',
                              style: const TextStyle(
                                color: kGrisTexto,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: () => context.push('/editar/${p.id}'),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        onPressed: () => _confirmarEliminar(context, ref, p),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
