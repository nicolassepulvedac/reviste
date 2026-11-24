import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reviste/data/repositories/prenda_local_repository.dart';
import 'package:reviste/domain/entities/prenda.dart';

/// Las prendas de ejemplo traen foto, y las que ya estaban en Firestore sin
/// foto se completan al leerlas.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('todas las prendas de ejemplo tienen foto', () {
    for (final p in prendasEjemplo) {
      expect(
        p.imagenUrl.startsWith('https://') || p.imagenUrl.startsWith('assets/'),
        isTrue,
        reason: p.nombre,
      );
    }
  });

  test('las fotos que vienen dentro de la app existen', () async {
    final propias =
        prendasEjemplo.where((p) => p.imagenUrl.startsWith('assets/'));
    expect(propias, isNotEmpty);
    for (final p in propias) {
      final datos = await rootBundle.load(p.imagenUrl);
      expect(datos.lengthInBytes, greaterThan(0), reason: p.imagenUrl);
    }
  });

  group('conFotoDeEjemplo', () {
    final sinFoto = prendasEjemplo.first.copyWith(imagenUrl: '');

    test('completa la foto de una prenda de ejemplo sin imagen', () {
      expect(conFotoDeEjemplo(sinFoto).imagenUrl, prendasEjemplo.first.imagenUrl);
    });

    test('no cambia una prenda que ya tiene foto', () {
      final conFoto = sinFoto.copyWith(imagenUrl: 'https://ejemplo.cl/a.jpg');
      expect(conFotoDeEjemplo(conFoto).imagenUrl, 'https://ejemplo.cl/a.jpg');
    });

    test('no toca prendas publicadas por una cuenta', () {
      final propia = sinFoto.copyWith(vendedorUid: 'uid-1');
      expect(conFotoDeEjemplo(propia).imagenUrl, isEmpty);
    });

    test('una prenda desconocida queda igual', () {
      final Prenda otra = sinFoto.copyWith(id: 'no-existe');
      expect(conFotoDeEjemplo(otra).imagenUrl, isEmpty);
    });
  });
}
