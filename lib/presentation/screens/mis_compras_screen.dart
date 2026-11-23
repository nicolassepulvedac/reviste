import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../domain/entities/pedido.dart';
import '../providers/pedidos_provider.dart';
import '../widgets/prenda_imagen.dart';

/// Historial de compras de la cuenta (más recientes primero).
class MisComprasScreen extends ConsumerWidget {
  const MisComprasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidos = ref.watch(pedidosProvider);

    return Scaffold(
      appBar: buildAppBar('Mis compras'),
      body: pedidos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'No se pudieron cargar tus compras',
                  style: TextStyle(color: kGrisTexto),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(pedidosProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (lista) {
          if (lista.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has hecho compras',
                style: TextStyle(color: kGrisTexto),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(pedidosProvider.future),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: lista.length,
              separatorBuilder: (context, i) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _TarjetaPedido(pedido: lista[i]),
            ),
          );
        },
      ),
    );
  }
}

class _TarjetaPedido extends StatelessWidget {
  final Pedido pedido;

  const _TarjetaPedido({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final unidades = pedido.unidades;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorde),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatearFecha(pedido.fecha),
                  style: const TextStyle(color: kGrisTexto, fontSize: 12),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kVerdeClaro,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  pedido.estado,
                  style: const TextStyle(
                    color: kVerde,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in pedido.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  PrendaImagen(
                    url: item.imagenUrl,
                    width: 48,
                    height: 48,
                    iconSize: 22,
                    radio: 8,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Talla ${item.talla} · x${item.cantidad}',
                          style: const TextStyle(
                            color: kGrisTexto,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatearPrecio(item.subtotal),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const Divider(height: 20, color: kBorde),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Envío a ${pedido.direccion}, ${pedido.ciudad}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kGrisTexto, fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Total ${formatearPrecio(pedido.total)}'
                ' ($unidades ${unidades == 1 ? 'prenda' : 'prendas'})',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
