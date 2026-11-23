import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reviste/data/repositories/prenda_local_repository.dart';
import 'package:reviste/presentation/providers/auth_provider.dart';
import 'package:reviste/presentation/providers/prendas_provider.dart';
import 'package:reviste/presentation/screens/publicar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// El selector de talla del formulario de publicar y editar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// Abre el formulario en modo edición de la prenda de ejemplo [id].
  Future<void> abrirEdicion(WidgetTester tester, String id) async {
    final contenedor = ProviderContainer(overrides: [
      uidUsuarioProvider.overrideWithValue('uid-test'),
      prendaRepositoryProvider.overrideWithValue(PrendaLocalRepository()),
    ]);
    addTearDown(contenedor.dispose);

    // La lista tiene que estar cargada antes de abrir el formulario.
    await tester.runAsync(() => contenedor.read(prendasProvider.future));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: contenedor,
        child: MaterialApp(home: PublicarScreen(prendaId: id)),
      ),
    );
    await tester.pump();
  }

  testWidgets('una talla de la lista se elige en el desplegable',
      (tester) async {
    await abrirEdicion(tester, '1'); // talla M
    expect(find.text('M'), findsOneWidget);
    expect(find.text('Escribe la talla'), findsNothing);
  });

  testWidgets('una talla numérica aparece como "Otra…" con su valor',
      (tester) async {
    await abrirEdicion(tester, '3'); // talla 32
    expect(find.text('Otra…'), findsOneWidget);
    expect(find.text('Escribe la talla'), findsOneWidget);
    expect(find.text('32'), findsOneWidget);
  });

  testWidgets('elegir "Otra…" muestra el campo para escribir la talla',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidUsuarioProvider.overrideWithValue('uid-test'),
          prendaRepositoryProvider.overrideWithValue(PrendaLocalRepository()),
        ],
        child: const MaterialApp(home: PublicarScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Escribe la talla'), findsNothing);

    await tester.tap(find.text('Talla'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Otra…').last);
    await tester.pumpAndSettle();

    expect(find.text('Escribe la talla'), findsOneWidget);
  });
}
