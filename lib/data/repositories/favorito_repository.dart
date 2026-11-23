/// Contrato para guardar las prendas favoritas de una cuenta.
abstract class FavoritoRepository {
  /// Ids de las prendas favoritas de la cuenta.
  Future<Set<String>> obtener(String uid);

  /// Reemplaza la lista de favoritas de la cuenta.
  Future<void> guardar(String uid, Set<String> ids);
}

/// Versión en memoria (para pruebas y para trabajar sin Firebase).
class FavoritoLocalRepository implements FavoritoRepository {
  final Map<String, Set<String>> _porCuenta = {};

  @override
  Future<Set<String>> obtener(String uid) async => {...?_porCuenta[uid]};

  @override
  Future<void> guardar(String uid, Set<String> ids) async {
    _porCuenta[uid] = {...ids};
  }
}
