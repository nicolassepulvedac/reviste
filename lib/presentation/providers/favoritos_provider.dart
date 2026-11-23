import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/favorito_firestore_repository.dart';
import '../../data/repositories/favorito_repository.dart';
import '../../domain/entities/prenda.dart';
import 'auth_provider.dart';
import 'prendas_provider.dart';

/// Repositorio de favoritas (Cloud Firestore). En pruebas se reemplaza por
/// FavoritoLocalRepository.
final favoritoRepositoryProvider = Provider<FavoritoRepository>((ref) {
  return FavoritoFirestoreRepository();
});

/// Ids de las prendas favoritas de la cuenta con sesión. Se marcan al
/// instante y se guardan en su cuenta; al iniciar sesión se cargan.
class FavoritosNotifier extends Notifier<Set<String>> {
  // Mientras no se hayan cargado las guardadas no se escribe nada, para no
  // pisar la lista de la cuenta con una lista incompleta.
  bool _cargado = false;

  @override
  Set<String> build() {
    _cargado = false;
    final uid = ref.watch(uidUsuarioProvider);
    if (uid == null) return <String>{};
    _cargar(uid);
    return <String>{};
  }

  Future<void> _cargar(String uid) async {
    try {
      final guardadas =
          await ref.read(favoritoRepositoryProvider).obtener(uid);
      if (!ref.mounted) return;
      _cargado = true;
      // Se suman las que la persona marcó mientras cargaba.
      final union = {...guardadas, ...state};
      final hayNuevas = union.length != guardadas.length;
      state = union;
      if (hayNuevas) _guardar(union);
    } catch (_) {
      // Sin conexión los favoritos funcionan solo en esta sesión.
    }
  }

  Future<void> _guardar(Set<String> ids) async {
    final uid = ref.read(uidUsuarioProvider);
    if (uid == null || !_cargado) return;
    try {
      await ref.read(favoritoRepositoryProvider).guardar(uid, ids);
    } catch (_) {
      // Best effort: la marca sigue visible aunque no se pueda guardar.
    }
  }

  void alternar(String id) {
    final nuevo = {...state};
    if (!nuevo.remove(id)) nuevo.add(id);
    state = nuevo;
    _guardar(nuevo);
  }
}

final favoritosProvider =
    NotifierProvider<FavoritosNotifier, Set<String>>(FavoritosNotifier.new);

/// Prendas favoritas que siguen publicadas (las eliminadas no cuentan).
final prendasFavoritasProvider = Provider<List<Prenda>>((ref) {
  final ids = ref.watch(favoritosProvider);
  final lista = ref.watch(prendasProvider).value ?? <Prenda>[];
  return lista.where((p) => ids.contains(p.id)).toList();
});
