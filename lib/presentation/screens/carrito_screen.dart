import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../domain/entities/carrito_item.dart';
import '../providers/carrito_provider.dart';
import '../providers/filtros_provider.dart';
import '../widgets/prenda_imagen.dart';

/// Carrito: lista de prendas, cantidades, subtotales y total.
class CarritoScreen extends ConsumerWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(carritoProvider);
    final total = ref.watch(carritoTotalProvider);

    return Scaffold(
      appBar: buildAppBar('Carrito de compras'),
      body: items.isEmpty
          ? _CarritoVacio(
              onExplorar: () => ref.read(tabIndexProvider.notifier).ir(0),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _ItemCarrito(item: items[i]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: kBorde)),
                  ),
                  child: Column(
                    children: [
                      _FilaTotal('Subtotal', formatearPrecio(total)),
                      const SizedBox(height: 4),
                      const _FilaTotal('Envío (Estándar)', 'Gratis'),
                      const Divider(height: 20, color: kBorde),
                      _FilaTotal('Total', formatearPrecio(total), grande: true),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.push('/checkout'),
                        child: const Text('Ir a checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CarritoVacio extends StatelessWidget {
  final VoidCallback onExplorar;

  const _CarritoVacio({required this.onExplorar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 56, color: kGrisTexto),
            const SizedBox(height: 12),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Agrega prendas desde Explorar para verlas aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kGrisTexto),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onExplorar,
              child: const Text('Explorar prendas'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCarrito extends ConsumerWidget {
  final CarritoItem item;

  const _ItemCarrito({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prenda = item.prenda;
    final carrito = ref.read(carritoProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: kBorde),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          PrendaImagen(url: prenda.imagenUrl, width: 72, height: 72, iconSize: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prenda.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Talla: ${prenda.talla} • ${formatearPrecio(prenda.precio)} c/u',
                  style: const TextStyle(color: kGrisTexto, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        final error = carrito.cambiarCantidad(prenda.id, -1);
                        if (error != null) mostrarMensaje(context, error);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '${item.cantidad}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        final error = carrito.cambiarCantidad(prenda.id, 1);
                        if (error != null) mostrarMensaje(context, error);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Eliminar del carrito',
                onPressed: () {
                  carrito.quitar(prenda.id);
                  mostrarMensaje(context, 'Prenda eliminada del carrito');
                },
                icon: const Icon(Icons.delete_outline),
              ),
              Text(
                formatearPrecio(item.subtotal),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaTotal extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool grande;

  const _FilaTotal(this.etiqueta, this.valor, {this.grande = false});

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(
      fontSize: grande ? 18 : 14,
      fontWeight: grande ? FontWeight.w800 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(etiqueta, style: estilo), Text(valor, style: estilo)],
    );
  }
}
