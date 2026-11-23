import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reviste/data/repositories/prenda_local_repository.dart';
import 'package:reviste/domain/entities/prenda.dart';
import 'package:reviste/presentation/providers/auth_provider.dart';
import 'package:reviste/presentation/providers/prendas_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Al cambiar el nombre de una cuenta, sus prendas publicadas se actualizan.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const propia = Prenda(
    id: '',
    nombre: 'Prenda de Ana',
    precio: 3000,
    talla: 'M',
    categoria: 'Mujer',
    estado: 'Bueno',
    stock: 1,
    imagenUrl: '',
    descripcion: 'Prenda para pruebas',
    marca: 'Test',
    vendedor: 'Ana',
    vendedorUid: 'uid-1',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('el repositorio solo cambia las prendas de esa cuenta', () async {
    final repo = PrendaLocalRepository();
    final creada = await repo.crearPrenda(propia);

    await repo.actualizarVendedor('uid-1', 'Ana María');

    final lista = await repo.obtenerPrendas();
    expect(lista.firstWhere((p) => p.id == creada.id).vendedor, 'Ana María');
    // Las demás (ejemplos) no cambian.
    expect(
      lista.where((p) => p.id != creada.id).any((p) => p.vendedor == 'Ana María'),
      isFalse,
    );
  });

  test('un uid vacío no modifica las prendas de ejemplo', () async {
    final repo = PrendaLocalRepository();
    await repo.actualizarVendedor('', 'Nadie');
    final lista = await repo.obtenerPrendas();
    expect(lista.any((p) => p.vendedor == 'Nadie'), isFalse);
  });

  test('el provider actualiza el vendedor en la lista', () async {
    final repo = PrendaLocalRepository();
    final creada = await repo.crearPrenda(propia);

    final c = ProviderContainer(overrides: [
      uidUsuarioProvider.overrideWithValue('uid-1'),
      prendaRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(c.dispose);

    await c.read(prendasProvider.future);
    await c
        .read(prendasProvider.notifier)
        .renombrarVendedor('uid-1', 'Ana María');

    final lista = c.read(prendasProvider).value!;
    expect(lista.firstWhere((p) => p.id == creada.id).vendedor, 'Ana María');
  });
}
