import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/pedido_firestore_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../domain/entities/carrito_item.dart';
import '../../domain/entities/pedido.dart';
import 'auth_provider.dart';

/// Repositorio de pedidos (Cloud Firestore). En pruebas se reemplaza por
/// PedidoLocalRepository.
final pedidoRepositoryProvider = Provider<PedidoRepository>((ref) {
  return PedidoFirestoreRepository();
});

/// Historial de compras de la cuenta con sesión (con carga y error).
class PedidosNotifier extends AsyncNotifier<List<Pedido>> {
  @override
  Future<List<Pedido>> build() async {
    final uid = ref.watch(uidUsuarioProvider);
    if (uid == null) return <Pedido>[];
    return ref.read(pedidoRepositoryProvider).obtenerPedidos(uid);
  }

  /// Guarda la compra recién confirmada y la agrega al inicio del historial.
  Future<void> registrar({
    required List<CarritoItem> items,
    required int total,
    required String nombre,
    required String direccion,
    required String ciudad,
  }) async {
    final uid = ref.read(uidUsuarioProvider);
    if (uid == null) return;
    final pedido = Pedido(
      id: '',
      uid: uid,
      items: items.map(PedidoItem.desdeCarrito).toList(),
      total: total,
      nombre: nombre,
      direccion: direccion,
      ciudad: ciudad,
      fecha: DateTime.now(),
    );
    final guardado =
        await ref.read(pedidoRepositoryProvider).crearPedido(pedido);
    state = AsyncData([guardado, ...(state.value ?? <Pedido>[])]);
  }
}

final pedidosProvider = AsyncNotifierProvider<PedidosNotifier, List<Pedido>>(
  PedidosNotifier.new,
  // Igual que prendas: el error se muestra de inmediato, sin reintentos
  // automáticos que dejen la pantalla cargando.
  retry: (reintentos, error) => null,
);
