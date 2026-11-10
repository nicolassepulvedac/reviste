import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reviste/domain/entities/prenda.dart';
import 'package:reviste/presentation/providers/carrito_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const prenda = Prenda(
    id: 'p1',
    nombre: 'Chaqueta de prueba',
    precio: 4500,
    talla: 'M',
    categoria: 'Hombre',
    estado: 'Excelente',
    stock: 2,
    imagenUrl: '',
    descripcion: 'Prenda para pruebas',
    marca: 'Test',
    vendedor: 'Tester',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('agregar suma la cantidad sin duplicar y respeta el stock', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final carrito = container.read(carritoProvider.notifier);

    expect(carrito.agregar(prenda), isNull);
    expect(carrito.agregar(prenda), isNull);

    final items = container.read(carritoProvider);
    expect(items.length, 1);
    expect(items.first.cantidad, 2);
    expect(container.read(carritoTotalProvider), 9000);

    // Stock agotado: no deja agregar una tercera unidad.
    expect(carrito.agregar(prenda), isNotNull);
    expect(container.read(carritoProvider).first.cantidad, 2);
  });

  test('quitar elimina la prenda del carrito', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final carrito = container.read(carritoProvider.notifier);

    carrito.agregar(prenda);
    expect(container.read(carritoProvider).length, 1);

    carrito.quitar('p1');
    expect(container.read(carritoProvider), isEmpty);
    expect(container.read(carritoTotalProvider), 0);
  });
}
