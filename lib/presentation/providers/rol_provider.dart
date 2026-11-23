import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/usuario_repository.dart';
import 'auth_provider.dart';

final usuarioRepositoryProvider =
    Provider<UsuarioRepository>((ref) => UsuarioRepository());

/// Rol de la persona con sesión ("usuario" o "admin"), en vivo.
final rolProvider = StreamProvider<String>(
  (ref) {
    final uid = ref.watch(uidUsuarioProvider);
    if (uid == null) return Stream.value(rolUsuario);
    return ref.watch(usuarioRepositoryProvider).observarRol(
          uid: uid,
          nombre: ref.read(nombreUsuarioProvider),
          correo: ref.read(correoUsuarioProvider),
        );
  },
  retry: (reintentos, error) => null,
);

/// true si la cuenta es administradora. Ante cualquier duda es false.
final esAdminProvider = Provider<bool>((ref) {
  return ref.watch(rolProvider).value == rolAdmin;
});
