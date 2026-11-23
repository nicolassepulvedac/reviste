import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reviste/data/repositories/pedido_repository.dart';
import 'package:reviste/data/repositories/prenda_local_repository.dart';
import 'package:reviste/domain/entities/carrito_item.dart';
import 'package:reviste/domain/entities/pedido.dart';
import 'package:reviste/presentation/providers/auth_provider.dart';
import 'package:reviste/presentation/providers/pedidos_provider.dart';
import 'package:reviste/presentation/screens/mis_compras_screen.dart';

/// Pruebas del historial de compras ("Mis compras").
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final items = [
    CarritoItem(prenda: prendasEjemplo.first, cantidad: 2),
  ];

  ProviderContainer crearContenedor(String? uid, PedidoRepository repo) {
    final c = ProviderContainer(overrides: [
      uidUsuarioProvider.overrideWithValue(uid),
      pedidoRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  group('Pedido', () {
    test('toMap y fromMap conservan los datos', () {
      final pedido = Pedido(
        id: 'p1',
        uid: 'uid-1',
        items: items.map(PedidoItem.desdeCarrito).toList(),
        total: 9000,
        nombre: 'Ana Pérez',
        direccion: 'Calle 123',
        ciudad: 'Valparaíso',
        fecha: DateTime(2026, 11, 23, 18, 2),
      );
      final copia = Pedido.fromMap(
        pedido.toMap(),
        id: 'p1',
        fecha: pedido.fecha,
      );
      expect(copia.uid, 'uid-1');
      expect(copia.total, 9000);
      expect(copia.unidades, 2);
      expect(copia.items.single.nombre, prendasEjemplo.first.nombre);
      expect(copia.items.single.subtotal, prendasEjemplo.first.precio * 2);
      expect(copia.ciudad, 'Valparaíso');
      expect(copia.estado, 'Confirmado');
    });
  });

  group('Repositorio de pedidos', () {
    test('cada cuenta solo ve sus pedidos', () async {
      final repo = PedidoLocalRepository();
      Pedido nuevo(String uid) => Pedido(
            id: '',
            uid: uid,
            items: items.map(PedidoItem.desdeCarrito).toList(),
            total: 100,
            nombre: 'Test',
            direccion: 'Calle 1',
            ciudad: 'Santiago',
            fecha: DateTime.now(),
          );

      final guardado = await repo.crearPedido(nuevo('a'));
      await repo.crearPedido(nuevo('b'));

      expect(guardado.id, isNotEmpty);
      expect((await repo.obtenerPedidos('a')).length, 1);
      expect((await repo.obtenerPedidos('b')).length, 1);
      expect(await repo.obtenerPedidos('c'), isEmpty);
    });
  });

  group('pedidosProvider', () {
    test('sin sesión el historial está vacío', () async {
      final c = crearContenedor(null, PedidoLocalRepository());
      expect(await c.read(pedidosProvider.future), isEmpty);
    });

    test('registrar agrega la compra al inicio del historial', () async {
      final c = crearContenedor('uid-1', PedidoLocalRepository());
      expect(await c.read(pedidosProvider.future), isEmpty);

      await c.read(pedidosProvider.notifier).registrar(
            items: items,
            total: 9000,
            nombre: 'Ana',
            direccion: 'Calle 123',
            ciudad: 'Santiago',
          );

      final historial = c.read(pedidosProvider).value!;
      expect(historial.length, 1);
      expect(historial.first.uid, 'uid-1');
      expect(historial.first.total, 9000);
    });
  });

  group('Pantalla Mis compras', () {
    Widget app(PedidoRepository repo) {
      return ProviderScope(
        overrides: [
          uidUsuarioProvider.overrideWithValue('uid-1'),
          pedidoRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: MisComprasScreen()),
      );
    }

    testWidgets('sin compras muestra el mensaje vacío', (tester) async {
      await tester.pumpWidget(app(PedidoLocalRepository()));
      await tester.pumpAndSettle();
      expect(find.text('Aún no has hecho compras'), findsOneWidget);
    });

    testWidgets('con una compra muestra prenda y total', (tester) async {
      final repo = PedidoLocalRepository();
      await repo.crearPedido(Pedido(
        id: '',
        uid: 'uid-1',
        items: items.map(PedidoItem.desdeCarrito).toList(),
        total: prendasEjemplo.first.precio * 2,
        nombre: 'Ana',
        direccion: 'Calle 123',
        ciudad: 'Santiago',
        fecha: DateTime.now(),
      ));

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      expect(find.text(prendasEjemplo.first.nombre), findsOneWidget);
      expect(find.text('Confirmado'), findsOneWidget);
      expect(find.textContaining('Total'), findsOneWidget);
    });
  });
}
