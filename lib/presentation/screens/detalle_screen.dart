import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../providers/carrito_provider.dart';
import '../providers/favoritos_provider.dart';
import '../providers/filtros_provider.dart';
import '../providers/prendas_provider.dart';
import '../widgets/estado_badge.dart';
import '../widgets/prenda_imagen.dart';

/// Detalle de una prenda. Recibe el id por parámetro de ruta.
class DetalleScreen extends ConsumerWidget {
  final String id;

  const DetalleScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prenda =
        ref.watch(prendasProvider).value?.where((p) => p.id == id).firstOrNull;
    final esFavorita = ref.watch(favoritosProvider).contains(id);

    if (prenda == null) {
      return Scaffold(
        appBar: buildAppBar('Detalle'),
        body: const Center(child: Text('Esta prenda ya no está disponible')),
      );
    }

    return Scaffold(
      appBar: buildAppBar(
        'Detalle',
        actions: [
          IconButton(
            onPressed: () => ref.read(favoritosProvider.notifier).alternar(id),
            icon: Icon(esFavorita ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrendaImagen(url: prenda.imagenUrl, height: 260, radio: 16),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          prenda.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatearPrecio(prenda.precio),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Marca: ${prenda.marca}',
                    style: const TextStyle(color: kGrisTexto),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      EstadoBadge(texto: prenda.estado),
                      _Etiqueta('Talla: ${prenda.talla}'),
                      _Etiqueta('Categoría: ${prenda.categoria}'),
                      _Etiqueta(
                        prenda.agotada
                            ? 'Sin stock'
                            : '${prenda.stock} disponible${prenda.stock == 1 ? '' : 's'}',
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: kBorde),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vendido por ${prenda.vendedor}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: kBorde),
                  ),
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prenda.descripcion,
                    style: const TextStyle(color: kGrisTexto, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                onPressed: prenda.agotada
                    ? null
                    : () {
                        final error =
                            ref.read(carritoProvider.notifier).agregar(prenda);
                        if (error != null) {
                          mostrarMensaje(context, error);
                          return;
                        }
                        mostrarMensaje(
                          context,
                          'Agregada al carrito',
                          accion: SnackBarAction(
                            label: 'Ver carrito',
                            onPressed: () {
                              ref.read(tabIndexProvider.notifier).ir(2);
                              context.go('/');
                            },
                          ),
                        );
                      },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(prenda.agotada ? 'Agotada' : 'Agregar al carrito'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;

  const _Etiqueta(this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: kBorde),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
