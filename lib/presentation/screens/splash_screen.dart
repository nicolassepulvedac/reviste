import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../providers/prendas_provider.dart';

/// Pantalla de carga inicial: espera las prendas y entra a la app.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    try {
      await Future.wait<Object?>([
        ref.read(prendasProvider.future),
        Future<void>.delayed(const Duration(milliseconds: 1500)),
      ]);
    } catch (_) {
      // Si falla la carga, Explorar mostrará el error con opción de reintentar.
    }
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.recycling, size: 56, color: kNegro),
            SizedBox(height: 16),
            Text(
              'ReViste',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Text('Moda con segunda vida', style: TextStyle(color: kGrisTexto)),
            SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: kNegro),
            ),
          ],
        ),
      ),
    );
  }
}
