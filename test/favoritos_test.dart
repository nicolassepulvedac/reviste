import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reviste/data/repositories/favorito_repository.dart';
import 'package:reviste/data/repositories/prenda_local_repository.dart';
import 'package:reviste/presentation/providers/auth_provider.dart';
import 'package:reviste/presentation/providers/favoritos_provider.dart';
import 'package:reviste/presentation/providers/prendas_provider.dart';
import 'package:reviste/presentation/screens/favoritos_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pruebas de favoritos: se guardan en la cuenta y tienen su propia pantalla.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer crearContenedor(String? uid, FavoritoRepository repo) {
    final c = ProviderContainer(overrides: [
      uidUsuarioProvider.overrideWithValue(uid),
      favoritoRepositoryProvider.overrideWithValue(repo),
      prendaRepositoryProvider.overrideWithValue(PrendaLocalRepository()),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  group('favoritosProvider', () {
    test('sin sesión no hay favoritos', () async {
      final c = crearContenedor(null, FavoritoLocalRepository());
      expect(c.read(favoritosProvider), isEmpty);
    });

    test('marcar y desmarcar', () async {
      final c = crearContenedor('uid-1', FavoritoLocalRepository());
      c.read(favoritosProvider);
      await pumpEventQueue();

      c.read(favoritosProvider.notifier).alternar('a');
      expect(c.read(favoritosProvider), {'a'});
      c.read(favoritosProvider.notifier).alternar('a');
      expect(c.read(favoritosProvider), isEmpty);
    });

    test('se guardan en la cuenta y se recuperan al volver a entrar',
        () async {
      final repo = FavoritoLocalRepository();

      final primera = crearContenedor('uid-1', repo);
      primera.read(favoritosProvider);
      await pumpEventQueue();
      primera.read(favoritosProvider.notifier).alternar('3');
      await pumpEventQueue();
      expect(await repo.obtener('uid-1'), {'3'});

      // "Cerrar y abrir la app": otro contenedor con el mismo repositorio.
      final segunda = crearContenedor('uid-1', repo);
      segunda.read(favoritosProvider);
      await pumpEventQueue();
      expect(segunda.read(favoritosProvider), {'3'});

      // Otra cuenta no ve esos favoritos.
      final otra = crearContenedor('uid-2', repo);
      otra.read(favoritosProvider);
      await pumpEventQueue();
      expect(otra.read(favoritosProvider), isEmpty);
    });

    test('las prendas eliminadas no cuentan como favoritas', () async {
      final c = crearContenedor('uid-1', FavoritoLocalRepository());
      await c.read(prendasProvider.future);
      c.read(favoritosProvider);
      await pumpEventQueue();

      c.read(favoritosProvider.notifier).alternar(prendasEjemplo.first.id);
      c.read(favoritosProvider.notifier).alternar('prenda-que-ya-no-existe');

      expect(c.read(prendasFavoritasProvider).length, 1);
    });
  });

  group('Pantalla Mis favoritos', () {
    Widget app(FavoritoRepository repo) {
      return ProviderScope(
        overrides: [
          uidUsuarioProvider.overrideWithValue('uid-1'),
          favoritoRepositoryProvider.overrideWithValue(repo),
          prendaRepositoryProvider.overrideWithValue(PrendaLocalRepository()),
        ],
        child: const MaterialApp(home: FavoritosScreen()),
      );
    }

    testWidgets('sin favoritos muestra el mensaje vacío', (tester) async {
      await tester.pumpWidget(app(FavoritoLocalRepository()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.textContaining('Aún no tienes favoritos'), findsOneWidget);
    });

    testWidgets('con favoritos muestra las prendas guardadas', (tester) async {
      final repo = FavoritoLocalRepository();
      await repo.guardar('uid-1', {prendasEjemplo.first.id});

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text(prendasEjemplo.first.nombre), findsOneWidget);
      expect(find.textContaining('Aún no tienes favoritos'), findsNothing);
    });
  });
}
