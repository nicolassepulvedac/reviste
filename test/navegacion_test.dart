import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:reviste/data/repositories/favorito_repository.dart';
import 'package:reviste/data/repositories/prenda_local_repository.dart';
import 'package:reviste/presentation/providers/auth_provider.dart';
import 'package:reviste/presentation/providers/favoritos_provider.dart';
import 'package:reviste/presentation/providers/prendas_provider.dart';
import 'package:reviste/presentation/screens/detalle_screen.dart';
import 'package:reviste/presentation/screens/explorar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prueba de navegación: Explorar -> Detalle (con el id en la ruta) -> volver.
/// Usa el repositorio local y una sesión simulada, así no necesita Firebase.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tocar una prenda abre su detalle y se puede volver',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const ExplorarScreen()),
        GoRoute(
          path: '/prenda/:id',
          builder: (context, state) =>
              DetalleScreen(id: state.pathParameters['id']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prendaRepositoryProvider.overrideWithValue(PrendaLocalRepository()),
          favoritoRepositoryProvider
              .overrideWithValue(FavoritoLocalRepository()),
          uidUsuarioProvider.overrideWithValue('uid-test'),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // Espera la carga de las prendas (el repositorio simula latencia).
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(ExplorarScreen), findsOneWidget);
    expect(find.text('Chaqueta de Cuero'), findsOneWidget);

    // Ir al detalle de la prenda (parámetro :id en la ruta).
    await tester.tap(find.text('Chaqueta de Cuero'));
    await tester.pumpAndSettle();
    expect(find.byType(DetalleScreen), findsOneWidget);
    expect(find.text('Agregar al carrito'), findsOneWidget);

    // Volver a Explorar.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ExplorarScreen), findsOneWidget);
    expect(find.byType(DetalleScreen), findsNothing);
  });
}
