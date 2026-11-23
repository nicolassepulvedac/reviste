import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles de la app. El rol vive en Firestore: `usuarios/{uid}.rol`.
/// Todos parten como [rolUsuario]. El rol [rolAdmin] se asigna a mano en la
/// consola de Firebase, así nadie puede darse ese permiso desde la app.
const String rolUsuario = 'usuario';
const String rolAdmin = 'admin';

class UsuarioRepository {
  UsuarioRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Guarda el nombre nuevo en el perfil de la cuenta (`usuarios/{uid}`).
  Future<void> actualizarNombre(String uid, String nombre) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .update({'nombre': nombre}).timeout(const Duration(seconds: 15));
  }

  /// Rol de la cuenta, actualizado en vivo. Si la cuenta aún no tiene
  /// documento (primer ingreso) se crea con el rol de usuario.
  Stream<String> observarRol({
    required String uid,
    required String nombre,
    required String correo,
  }) async* {
    final doc = _db.collection('usuarios').doc(uid);
    await for (final snap in doc.snapshots()) {
      if (!snap.exists) {
        // Solo se crea con datos del servidor: una lectura de la copia local
        // vacía no significa que la cuenta no exista.
        if (!snap.metadata.isFromCache) {
          await doc.set({
            'nombre': nombre,
            'correo': correo,
            'rol': rolUsuario,
            'creadoEn': FieldValue.serverTimestamp(),
          });
        }
        continue;
      }
      yield (snap.data()?['rol'] as String?) ?? rolUsuario;
    }
  }
}
