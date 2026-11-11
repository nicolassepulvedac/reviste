import 'package:firebase_auth/firebase_auth.dart';

/// Acceso a Firebase Authentication (inicio de sesión, registro y cierre).
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get usuarioActual => _auth.currentUser;

  /// Emite el usuario actual y vuelve a emitir cuando cambia (sesión o perfil).
  Stream<User?> get cambiosUsuario => _auth.userChanges();

  Future<void> iniciarSesion(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credencial.user?.updateDisplayName(nombre.trim());
    await credencial.user?.reload();
  }

  Future<void> cerrarSesion() => _auth.signOut();
}

/// Traduce los errores de Firebase Auth a mensajes en español.
String mensajeErrorAuth(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Correo o contraseña incorrectos';
      case 'user-not-found':
        return 'No existe una cuenta con ese correo';
      case 'invalid-email':
        return 'El formato del correo no es válido';
      case 'user-disabled':
        return 'Esta cuenta está desactivada';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde';
      case 'network-request-failed':
        return 'Problema de red. Revisa tu conexión';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres)';
      case 'operation-not-allowed':
        return 'El acceso con correo no está habilitado en Firebase';
      default:
        return 'Error de autenticación (${error.code})';
    }
  }
  return 'Ocurrió un error inesperado. Intenta de nuevo';
}
