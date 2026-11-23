import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reviste/data/repositories/prenda_repository.dart';
import 'package:reviste/data/repositories/usuario_repository.dart';
import 'package:reviste/data/services/auth_service.dart';
import 'package:reviste/domain/entities/prenda.dart';
import 'package:reviste/presentation/providers/auth_provider.dart';
import 'package:reviste/presentation/providers/prendas_provider.dart';
import 'package:reviste/presentation/providers/rol_provider.dart';
import 'package:reviste/presentation/screens/configuracion_screen.dart';

/// Servicio de autenticación falso: registra lo que la pantalla le pide,
/// así la prueba no necesita Firebase.
class _AuthFalso implements AuthService {
  String? nombreGuardado;
  String? claveActual;
  String? claveNueva;

  @override
  Future<void> cambiarNombre(String nombre) async {
    nombreGuardado = nombre.trim();
  }

  @override
  Future<void> cambiarClave({
    required String actual,
    required String nueva,
  }) async {
    claveActual = actual;
    claveNueva = nueva;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Perfil de Firestore falso: guarda el último nombre recibido.
class _UsuariosFalso implements UsuarioRepository {
  String? uid;
  String? nombre;

  @override
  Future<void> actualizarNombre(String uid, String nombre) async {
    this.uid = uid;
    this.nombre = nombre;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Prendas falsas (sin demora): no tiene prendas y registra el cambio de
/// nombre del vendedor.
class _PrendasFalsas implements PrendaRepository {
  String? vendedorUid;
  String? nombre;

  @override
  Future<List<Prenda>> obtenerPrendas() async => <Prenda>[];

  @override
  Future<void> actualizarVendedor(String vendedorUid, String nombre) async {
    this.vendedorUid = vendedorUid;
    this.nombre = nombre;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pruebas de la pantalla Configuración.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget app(
    _AuthFalso auth, {
    _UsuariosFalso? usuarios,
    _PrendasFalsas? prendas,
  }) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        uidUsuarioProvider.overrideWithValue('uid-1'),
        usuarioRepositoryProvider
            .overrideWithValue(usuarios ?? _UsuariosFalso()),
        prendaRepositoryProvider.overrideWithValue(prendas ?? _PrendasFalsas()),
        nombreUsuarioProvider.overrideWithValue('Ana'),
        correoUsuarioProvider.overrideWithValue('ana@correo.cl'),
        esAdminProvider.overrideWithValue(false),
      ],
      child: const MaterialApp(home: ConfiguracionScreen()),
    );
  }

  /// El aviso (SnackBar) se cierra solo a los 3 segundos.
  Future<void> esperarAviso(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra los datos de la cuenta', (tester) async {
    await tester.pumpWidget(app(_AuthFalso()));
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('ana@correo.cl'), findsOneWidget);
    expect(find.text('Cuenta de usuario'), findsOneWidget);
  });

  testWidgets('cambiar nombre valida y guarda', (tester) async {
    final auth = _AuthFalso();
    final usuarios = _UsuariosFalso();
    final prendas = _PrendasFalsas();
    await tester.pumpWidget(app(auth, usuarios: usuarios, prendas: prendas));

    await tester.tap(find.text('Cambiar nombre'));
    await tester.pumpAndSettle();

    // Un nombre muy corto no se acepta.
    await tester.enterText(find.byType(TextFormField), 'ab');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa al menos 3 letras'), findsOneWidget);
    expect(auth.nombreGuardado, isNull);

    // Un nombre válido se guarda.
    await tester.enterText(find.byType(TextFormField), '  Ana María ');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(auth.nombreGuardado, 'Ana María');
    // También se actualiza el perfil de Firestore y las prendas de la cuenta.
    expect(usuarios.uid, 'uid-1');
    expect(usuarios.nombre, 'Ana María');
    expect(prendas.vendedorUid, 'uid-1');
    expect(prendas.nombre, 'Ana María');
    expect(find.text('Nombre actualizado'), findsOneWidget);

    await esperarAviso(tester);
  });

  testWidgets('cambiar contraseña valida y guarda', (tester) async {
    final auth = _AuthFalso();
    await tester.pumpWidget(app(auth));

    await tester.tap(find.text('Cambiar contraseña'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    expect(campos, findsNWidgets(3));

    // Las dos contraseñas nuevas no coinciden.
    await tester.enterText(campos.at(0), 'actual123');
    await tester.enterText(campos.at(1), 'nueva456');
    await tester.enterText(campos.at(2), 'otra789');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(auth.claveNueva, isNull);

    // La nueva no puede ser igual a la actual.
    await tester.enterText(campos.at(1), 'actual123');
    await tester.enterText(campos.at(2), 'actual123');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Debe ser distinta a la actual'), findsOneWidget);
    expect(auth.claveNueva, isNull);

    // Mínimo 6 caracteres.
    await tester.enterText(campos.at(1), 'abc');
    await tester.enterText(campos.at(2), 'abc');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    expect(auth.claveNueva, isNull);

    // Datos válidos.
    await tester.enterText(campos.at(1), 'nueva456');
    await tester.enterText(campos.at(2), 'nueva456');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(auth.claveActual, 'actual123');
    expect(auth.claveNueva, 'nueva456');
    expect(find.text('Contraseña actualizada'), findsOneWidget);

    await esperarAviso(tester);
  });
}
