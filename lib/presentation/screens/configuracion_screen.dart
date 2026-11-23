import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../providers/prendas_provider.dart';
import '../providers/rol_provider.dart';

/// Ajustes de la cuenta: ver los datos, cambiar el nombre y cambiar la
/// contraseña (pidiendo la actual).
class ConfiguracionScreen extends ConsumerWidget {
  const ConfiguracionScreen({super.key});

  Future<void> _cambiarNombre(BuildContext context, WidgetRef ref) async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (ctx) => _DialogoNombre(inicial: ref.read(nombreUsuarioProvider)),
    );
    if (nombre == null) return;
    try {
      await ref.read(authServiceProvider).cambiarNombre(nombre);
    } catch (error) {
      if (!context.mounted) return;
      mostrarMensaje(context, mensajeErrorAuth(error));
      return;
    }

    // El nombre también está en el perfil de Firestore y en las prendas
    // publicadas, así que se actualiza ahí. (Los pedidos no se tocan: son el
    // registro de cada compra.)
    var completo = true;
    final uid = ref.read(uidUsuarioProvider);
    if (uid != null) {
      try {
        await ref.read(usuarioRepositoryProvider).actualizarNombre(uid, nombre);
      } catch (_) {
        completo = false;
      }
      try {
        await ref.read(prendasProvider.notifier).renombrarVendedor(uid, nombre);
      } catch (_) {
        completo = false;
      }
    }
    if (!context.mounted) return;
    mostrarMensaje(
      context,
      completo
          ? 'Nombre actualizado'
          : 'Nombre actualizado, pero no en todas tus publicaciones',
    );
  }

  Future<void> _cambiarClave(BuildContext context, WidgetRef ref) async {
    final claves = await showDialog<(String, String)>(
      context: context,
      builder: (ctx) => const _DialogoClave(),
    );
    if (claves == null) return;
    try {
      await ref
          .read(authServiceProvider)
          .cambiarClave(actual: claves.$1, nueva: claves.$2);
      if (!context.mounted) return;
      mostrarMensaje(context, 'Contraseña actualizada');
    } catch (error) {
      if (!context.mounted) return;
      final claveMala = error is FirebaseAuthException &&
          (error.code == 'invalid-credential' ||
              error.code == 'wrong-password');
      mostrarMensaje(
        context,
        claveMala ? 'La contraseña actual es incorrecta' : mensajeErrorAuth(error),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nombre = ref.watch(nombreUsuarioProvider);
    final correo = ref.watch(correoUsuarioProvider);
    final esAdmin = ref.watch(esAdminProvider);

    return Scaffold(
      appBar: buildAppBar('Configuración'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Caja(
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        correo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: kGrisTexto),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        esAdmin ? 'Cuenta de administrador' : 'Cuenta de usuario',
                        style: const TextStyle(color: kGrisTexto, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Caja(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_outlined),
              title: const Text(
                'Cambiar nombre',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('El nombre que ven los demás'),
              trailing: const Icon(Icons.chevron_right, color: kGrisTexto),
              onTap: () => _cambiarNombre(context, ref),
            ),
          ),
          const SizedBox(height: 12),
          _Caja(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline),
              title: const Text(
                'Cambiar contraseña',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Necesitas tu contraseña actual'),
              trailing: const Icon(Icons.chevron_right, color: kGrisTexto),
              onTap: () => _cambiarClave(context, ref),
            ),
          ),
          const SizedBox(height: 12),
          const _Caja(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline),
              title: Text(
                'Acerca de ReViste',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('Tienda de ropa de segunda mano · versión 0.8'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Caja extends StatelessWidget {
  final Widget child;

  const _Caja({required this.child});

  @override
  Widget build(BuildContext context) {
    // Material (y no un Container con color) para que el efecto al tocar los
    // ListTile se vea.
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: kBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: child,
      ),
    );
  }
}

/// Cuadro para escribir el nombre nuevo (mínimo 3 letras).
class _DialogoNombre extends StatefulWidget {
  final String inicial;

  const _DialogoNombre({required this.inicial});

  @override
  State<_DialogoNombre> createState() => _DialogoNombreState();
}

class _DialogoNombreState extends State<_DialogoNombre> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controlador =
      TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controlador.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar nombre'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controlador,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: campoDeco('Nombre'),
          validator: (v) => (v == null || v.trim().length < 3)
              ? 'Ingresa al menos 3 letras'
              : null,
          onFieldSubmitted: (_) => _guardar(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}

/// Cuadro para cambiar la contraseña: actual, nueva y repetir la nueva.
class _DialogoClave extends StatefulWidget {
  const _DialogoClave();

  @override
  State<_DialogoClave> createState() => _DialogoClaveState();
}

class _DialogoClaveState extends State<_DialogoClave> {
  final _formKey = GlobalKey<FormState>();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _repetir = TextEditingController();

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _repetir.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((_actual.text, _nueva.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar contraseña'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _actual,
                obscureText: true,
                decoration: campoDeco('Contraseña actual'),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Ingresa tu contraseña actual'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nueva,
                obscureText: true,
                decoration: campoDeco('Contraseña nueva'),
                validator: (v) {
                  if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
                  if (v == _actual.text) return 'Debe ser distinta a la actual';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _repetir,
                obscureText: true,
                decoration: campoDeco('Repetir contraseña nueva'),
                validator: (v) =>
                    v != _nueva.text ? 'Las contraseñas no coinciden' : null,
                onFieldSubmitted: (_) => _guardar(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
