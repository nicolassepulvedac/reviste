import '../../domain/entities/pedido.dart';

/// Contrato para guardar y leer el historial de compras.
abstract class PedidoRepository {
  /// Pedidos de una cuenta, los más nuevos primero.
  Future<List<Pedido>> obtenerPedidos(String uid);

  /// Guarda un pedido y lo devuelve con su id y fecha definitivos.
  Future<Pedido> crearPedido(Pedido pedido);
}

/// Versión en memoria (para pruebas y para trabajar sin Firebase).
class PedidoLocalRepository implements PedidoRepository {
  final List<Pedido> _pedidos = [];
  int _contador = 0;

  @override
  Future<List<Pedido>> obtenerPedidos(String uid) async {
    final propios = _pedidos.where((p) => p.uid == uid).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return propios;
  }

  @override
  Future<Pedido> crearPedido(Pedido pedido) async {
    _contador++;
    final guardado = pedido.copyWith(id: 'p$_contador', fecha: DateTime.now());
    _pedidos.add(guardado);
    return guardado;
  }
}
