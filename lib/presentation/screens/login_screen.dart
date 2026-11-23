import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/services/auth_service.dart';
import '../providers/auth_provider.dart';

/// Inicio de sesión con correo y contraseña (Firebase Auth).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _ocultar = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .iniciarSesion(_email.text, _password.text);
      // El router detecta la sesión y entra solo a la app.
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = mensajeErrorAuth(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.recycling, size: 52, color: kVerde),
                  const SizedBox(height: 12),
                  const Text(
                    'ReViste',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kGrisTexto),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: campoDeco(
                      'Correo electrónico',
                      prefixIcon: const Icon(Icons.mail_outline),
                    ),
                    validator: (v) {
                      final texto = v?.trim() ?? '';
                      if (texto.isEmpty) return 'Ingresa tu correo';
                      final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!valido.hasMatch(texto)) return 'Correo no válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _ocultar,
                    autofillHints: const [AutofillHints.password],
                    decoration: campoDeco(
                      'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _ocultar = !_ocultar),
                        icon: Icon(
                          _ocultar
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Ingresa tu contraseña'
                        : null,
                    onFieldSubmitted: (_) => _cargando ? null : _entrar(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFB3261E)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _cargando ? null : _entrar,
                    child: _cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _cargando ? null : () => context.go('/registro'),
                    child: const Text('¿No tienes cuenta? Regístrate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
