import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'screens/checkout_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'screens/mis_publicaciones_screen.dart';
import 'screens/publicar_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/splash_screen.dart';

/// Avisa al router cuando se inicia o se cierra sesión para que redirija.
class _SesionListenable extends ChangeNotifier {
  late final StreamSubscription<User?> _suscripcion;

  _SesionListenable() {
    _suscripcion = FirebaseAuth.instance
        .authStateChanges()
        .listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}

/// Navegación con go_router. Los parámetros viajan en la ruta (ej: /prenda/3).
/// Sin sesión iniciada solo se puede entrar a /login y /registro.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: _SesionListenable(),
  redirect: (context, state) {
    final ruta = state.matchedLocation;
    debugPrint(
      '[ReViste] ruta $ruta, sesión: ${FirebaseAuth.instance.currentUser != null}',
    );
    if (ruta == '/splash') return null;

    final conSesion = FirebaseAuth.instance.currentUser != null;
    final enAcceso = ruta == '/login' || ruta == '/registro';

    if (!conSesion && !enAcceso) return '/login';
    if (conSesion && enAcceso) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/registro',
      builder: (context, state) => const RegistroScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeShell(),
    ),
    GoRoute(
      path: '/prenda/:id',
      builder: (context, state) =>
          DetalleScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/mis-publicaciones',
      builder: (context, state) => const MisPublicacionesScreen(),
    ),
    GoRoute(
      path: '/editar/:id',
      builder: (context, state) => PublicarScreen(
        prendaId: state.pathParameters['id'],
        onGuardado: () => context.pop(),
      ),
    ),
  ],
);
