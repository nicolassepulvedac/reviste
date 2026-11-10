import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../domain/entities/prenda.dart';
import 'prendas_provider.dart';

/// Categoría seleccionada en Explorar ("Todo" = sin filtro).
class CategoriaNotifier extends Notifier<String> {
  @override
  String build() => 'Todo';

  void seleccionar(String categoria) => state = categoria;
}

final categoriaProvider =
    NotifierProvider<CategoriaNotifier, String>(CategoriaNotifier.new);

/// Texto de búsqueda en Explorar.
class BusquedaNotifier extends Notifier<String> {
  @override
  String build() => '';

  void cambiar(String texto) => state = texto;
}

final busquedaProvider =
    NotifierProvider<BusquedaNotifier, String>(BusquedaNotifier.new);

/// Pestaña activa del menú inferior (0 Explorar, 1 Vender, 2 Carrito, 3 Perfil).
class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void ir(int indice) => state = indice;
}

final tabIndexProvider =
    NotifierProvider<TabIndexNotifier, int>(TabIndexNotifier.new);

/// Ids de prendas marcadas como favoritas (en memoria).
class FavoritosNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void alternar(String id) {
    final nuevo = {...state};
    if (!nuevo.remove(id)) nuevo.add(id);
    state = nuevo;
  }
}

final favoritosProvider =
    NotifierProvider<FavoritosNotifier, Set<String>>(FavoritosNotifier.new);

/// Prendas filtradas por categoría y búsqueda (conserva loading/error).
final prendasFiltradasProvider =
    Provider<AsyncValue<List<Prenda>>>((ref) {
  final prendas = ref.watch(prendasProvider);
  final categoria = ref.watch(categoriaProvider);
  final texto = ref.watch(busquedaProvider).trim().toLowerCase();

  return prendas.whenData((lista) {
    return lista.where((p) {
      final coincideCategoria = categoria == 'Todo' || p.categoria == categoria;
      final coincideTexto = texto.isEmpty ||
          p.nombre.toLowerCase().contains(texto) ||
          p.marca.toLowerCase().contains(texto);
      return coincideCategoria && coincideTexto;
    }).toList();
  });
});

/// Prendas publicadas por el usuario actual.
final misPublicacionesProvider = Provider<List<Prenda>>((ref) {
  final lista = ref.watch(prendasProvider).value ?? <Prenda>[];
  return lista.where((p) => p.vendedor == kUsuarioActual).toList();
});
