import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Usuario con sesión iniciada (null si no hay sesión).
final usuarioProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).cambiosUsuario;
});

User? _usuarioActual(Ref ref) {
  return ref.watch(usuarioProvider).value ??
      ref.read(authServiceProvider).usuarioActual;
}

/// Id del usuario con sesión (null si no hay). Solo avisa cuando cambia la
/// persona, no cuando se actualiza su perfil.
final uidUsuarioProvider = Provider<String?>((ref) {
  return _usuarioActual(ref)?.uid;
});

/// Nombre para mostrar: el nombre registrado, o el correo antes de la @.
final nombreUsuarioProvider = Provider<String>((ref) {
  final usuario = _usuarioActual(ref);
  final nombre = usuario?.displayName?.trim() ?? '';
  if (nombre.isNotEmpty) return nombre;
  final correo = usuario?.email ?? '';
  if (correo.contains('@')) return correo.split('@').first;
  return 'Usuario';
});

final correoUsuarioProvider = Provider<String>((ref) {
  return _usuarioActual(ref)?.email ?? '';
});
