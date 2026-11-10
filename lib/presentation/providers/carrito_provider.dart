import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/carrito_item.dart';
import '../../domain/entities/prenda.dart';

/// Lógica del carrito: suma de cantidades sin duplicar, validación de stock,
/// cálculo de subtotales y persistencia local con shared_preferences.
class CarritoNotifier extends Notifier<List<CarritoItem>> {
  static const _clave = 'reviste_carrito';

  @override
  List<CarritoItem> build() {
    _cargar();
    return [];
  }

  Future<void> _cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_clave);
      if (raw == null) return;
      final guardados = (jsonDecode(raw) as List)
          .map((e) => CarritoItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (state.isEmpty) state = guardados;
    } catch (_) {
      // Si falla la lectura, se parte con el carrito vacío.
    }
  }

  Future<void> _guardar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _clave,
        jsonEncode(state.map((e) => e.toMap()).toList()),
      );
    } catch (_) {
      // La persistencia es "best effort": el carrito sigue funcionando.
    }
  }

  /// Agrega una prenda. Si ya está, suma 1 a la cantidad.
  /// Devuelve un mensaje de error o null si salió bien.
  String? agregar(Prenda prenda) {
    if (prenda.stock < 1) return 'Esta prenda está agotada';
    final i = state.indexWhere((e) => e.prenda.id == prenda.id);
    if (i == -1) {
      state = [...state, CarritoItem(prenda: prenda, cantidad: 1)];
    } else {
      final item = state[i];
      if (item.cantidad >= prenda.stock) {
        return 'No hay más unidades disponibles';
      }
      state = [
        for (var j = 0; j < state.length; j++)
          if (j == i) item.copyWith(cantidad: item.cantidad + 1) else state[j],
      ];
    }
    _guardar();
    return null;
  }

  /// Suma o resta unidades. Devuelve un mensaje de error o null.
  String? cambiarCantidad(String idPrenda, int delta) {
    final i = state.indexWhere((e) => e.prenda.id == idPrenda);
    if (i == -1) return null;
    final item = state[i];
    final nueva = item.cantidad + delta;
    if (nueva < 1) return 'La cantidad mínima es 1';
    if (nueva > item.prenda.stock) return 'No hay más unidades disponibles';
    state = [
      for (var j = 0; j < state.length; j++)
        if (j == i) item.copyWith(cantidad: nueva) else state[j],
    ];
    _guardar();
    return null;
  }

  void quitar(String idPrenda) {
    state = state.where((e) => e.prenda.id != idPrenda).toList();
    _guardar();
  }

  void vaciar() {
    state = [];
    _guardar();
  }

  /// Si una prenda cambia (precio, stock...), se refleja en el carrito.
  void sincronizarPrenda(Prenda prenda) {
    final nuevo = <CarritoItem>[];
    for (final item in state) {
      if (item.prenda.id != prenda.id) {
        nuevo.add(item);
      } else if (prenda.stock >= 1) {
        final cantidad =
            item.cantidad > prenda.stock ? prenda.stock : item.cantidad;
        nuevo.add(CarritoItem(prenda: prenda, cantidad: cantidad));
      }
    }
    state = nuevo;
    _guardar();
  }
}

final carritoProvider =
    NotifierProvider<CarritoNotifier, List<CarritoItem>>(CarritoNotifier.new);

/// Total a pagar (suma de subtotales).
final carritoTotalProvider = Provider<int>((ref) {
  return ref.watch(carritoProvider).fold(0, (suma, e) => suma + e.subtotal);
});

/// Cantidad total de unidades (para el globo del ícono del carrito).
final carritoCantidadProvider = Provider<int>((ref) {
  return ref.watch(carritoProvider).fold(0, (suma, e) => suma + e.cantidad);
});
