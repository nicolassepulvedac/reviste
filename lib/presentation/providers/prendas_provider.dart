import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/prenda_firestore_repository.dart';
import '../../data/repositories/prenda_repository.dart';
import '../../domain/entities/carrito_item.dart';
import '../../domain/entities/prenda.dart';
import 'auth_provider.dart';
import 'carrito_provider.dart';

/// Repositorio de prendas (v0.4: Cloud Firestore).
/// Para volver a los datos locales basta con devolver PrendaLocalRepository().
final prendaRepositoryProvider = Provider<PrendaRepository>((ref) {
  return PrendaFirestoreRepository();
});

/// Lista de prendas (con estados de carga y error) + operaciones CRUD.
class PrendasNotifier extends AsyncNotifier<List<Prenda>> {
  PrendaRepository get _repo => ref.read(prendaRepositoryProvider);

  List<Prenda> get _actuales => state.value ?? <Prenda>[];

  /// Las reglas de Firestore exigen sesión: sin usuario no se consulta nada
  /// (lista vacía) y al iniciar o cerrar sesión la lista se vuelve a cargar.
  @override
  Future<List<Prenda>> build() async {
    final uid = ref.watch(uidUsuarioProvider);
    if (uid == null) return <Prenda>[];
    return _repo.obtenerPrendas();
  }

  /// CREATE
  Future<void> crear(Prenda prenda) async {
    final nueva = await _repo.crearPrenda(prenda);
    state = AsyncData([nueva, ..._actuales]);
  }

  /// UPDATE
  Future<void> actualizar(Prenda prenda) async {
    await _repo.actualizarPrenda(prenda);
    state = AsyncData([
      for (final p in _actuales)
        if (p.id == prenda.id) prenda else p,
    ]);
    ref.read(carritoProvider.notifier).sincronizarPrenda(prenda);
  }

  /// DELETE
  Future<void> eliminar(String id) async {
    await _repo.eliminarPrenda(id);
    state = AsyncData(_actuales.where((p) => p.id != id).toList());
    ref.read(carritoProvider.notifier).quitar(id);
  }

  /// Descuenta el stock de lo comprado.
  Future<void> comprar(List<CarritoItem> items) async {
    final cantidades = {for (final i in items) i.prenda.id: i.cantidad};
    final nuevas = <Prenda>[];
    for (final p in _actuales) {
      final comprada = cantidades[p.id];
      if (comprada == null) {
        nuevas.add(p);
        continue;
      }
      final restante = p.stock - comprada;
      final actualizada = p.copyWith(stock: restante < 0 ? 0 : restante);
      await _repo.actualizarPrenda(actualizada);
      nuevas.add(actualizada);
    }
    state = AsyncData(nuevas);
  }
}

final prendasProvider = AsyncNotifierProvider<PrendasNotifier, List<Prenda>>(
  PrendasNotifier.new,
  // Riverpod 3 reintenta solo los providers que fallan, lo que dejaba la
  // carga girando mucho rato. Se desactiva: el error se muestra de inmediato
  // y el botón "Reintentar" de Explorar vuelve a cargar.
  retry: (reintentos, error) => null,
);
