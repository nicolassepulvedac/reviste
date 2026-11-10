import 'package:go_router/go_router.dart';

import 'screens/checkout_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/home_shell.dart';
import 'screens/mis_publicaciones_screen.dart';
import 'screens/publicar_screen.dart';
import 'screens/splash_screen.dart';

/// Navegación con go_router. Los parámetros viajan en la ruta (ej: /prenda/3).
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
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
