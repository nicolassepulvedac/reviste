import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reviste/data/repositories/prenda_local_repository.dart';
import 'package:reviste/domain/entities/carrito_item.dart';
import 'package:reviste/domain/entities/prenda.dart';
import 'package:reviste/presentation/providers/auth_provider.dart';
import 'package:reviste/presentation/providers/filtros_provider.dart';
import 'package:reviste/presentation/providers/prendas_provider.dart';
import 'package:reviste/presentation/providers/rol_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pruebas de la capa de datos: CRUD del repositorio (mismo contrato que usa
/// Firestore), serialización de la entidad, compra y permisos por rol.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const base = Prenda(
    id: '',
    nombre: 'Prenda de prueba',
    precio: 3000,
    talla: 'M',
    categoria: 'Mujer',
    estado: 'Bueno',
    stock: 2,
    imagenUrl: '',
    descripcion: 'Prenda para pruebas de datos',
    marca: 'Test',
    vendedor: 'Tester',
    vendedorUid: 'uid-1',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Repositorio de prendas (CRUD)', () {
    test('crear, leer, actualizar y eliminar', () async {
      final repo = PrendaLocalRepository();
      expect((await repo.obtenerPrendas()).length, prendasEjemplo.length);

      // CREATE
      final nueva = await repo.crearPrenda(base);
      expect(nueva.id, isNotEmpty);
      final tras = await repo.obtenerPrendas();
      expect(tras.length, prendasEjemplo.length + 1);

      // UPDATE
      await repo.actualizarPrenda(nueva.copyWith(precio: 9999));
      final editada =
          (await repo.obtenerPrendas()).firstWhere((p) => p.id == nueva.id);
      expect(editada.precio, 9999);

      // DELETE
      await repo.eliminarPrenda(nueva.id);
      final final_ = await repo.obtenerPrendas();
      expect(final_.length, prendasEjemplo.length);
      expect(final_.any((p) => p.id == nueva.id), isFalse);
    });
  });

  group('Entidad Prenda', () {
    test('toMap y fromMap conservan los datos, incluida la dueña', () {
      final copia = Prenda.fromMap({...base.toMap(), 'id': 'abc'});
      expect(copia.id, 'abc');
      expect(copia.nombre, base.nombre);
      expect(copia.precio, base.precio);
      expect(copia.vendedorUid, 'uid-1');
    });

    test('un documento antiguo sin vendedorUid queda sin dueña', () {
      final mapa = Map<String, dynamic>.from(base.toMap())
        ..remove('vendedorUid');
      expect(Prenda.fromMap(mapa).vendedorUid, '');
    });
  });

  group('Provider de prendas', () {
    ProviderContainer crear({String? uid = 'uid-1'}) {
      final c = ProviderContainer(
        overrides: [
          prendaRepositoryProvider.overrideWithValue(PrendaLocalRepository()),
          uidUsuarioProvider.overrideWithValue(uid),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('sin sesión no se cargan prendas', () async {
      final c = crear(uid: null);
      expect(await c.read(prendasProvider.future), isEmpty);
    });

    test('comprar descuenta el stock y nunca baja de cero', () async {
      final c = crear();
      final lista = await c.read(prendasProvider.future);
      final prenda = lista.first;

      await c
          .read(prendasProvider.notifier)
          .comprar([CarritoItem(prenda: prenda, cantidad: prenda.stock + 5)]);

      final despues =
          c.read(prendasProvider).value!.firstWhere((p) => p.id == prenda.id);
      expect(despues.stock, 0);
    });
  });

  group('Permisos por rol', () {
    test('el usuario gestiona solo sus prendas y el admin todas', () async {
      final repo = PrendaLocalRepository();
      await repo.crearPrenda(base.copyWith(nombre: 'Mía', vendedorUid: 'uid-1'));
      await repo.crearPrenda(base.copyWith(nombre: 'Ajena', vendedorUid: 'uid-2'));

      ProviderContainer contenedor({required bool admin}) {
        final c = ProviderContainer(
          overrides: [
            prendaRepositoryProvider.overrideWithValue(repo),
            uidUsuarioProvider.overrideWithValue('uid-1'),
            esAdminProvider.overrideWithValue(admin),
          ],
        );
        addTearDown(c.dispose);
        return c;
      }

      final usuario = contenedor(admin: false);
      await usuario.read(prendasProvider.future);
      expect(
        usuario.read(prendasGestionablesProvider).map((p) => p.nombre),
        ['Mía'],
      );

      final admin = contenedor(admin: true);
      await admin.read(prendasProvider.future);
      expect(
        admin.read(prendasGestionablesProvider).length,
        prendasEjemplo.length + 2,
      );
    });
  });
}
