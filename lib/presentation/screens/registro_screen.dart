import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/services/auth_service.dart';
import '../providers/auth_provider.dart';

/// Crear una cuenta nueva con nombre, correo y contraseña.
class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  bool _ocultar = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).registrar(
            nombre: _nombre.text,
            email: _email.text,
            password: _password.text,
          );
      // Al crear la cuenta se inicia sesión y el router entra a la app.
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
                  const Icon(Icons.recycling, size: 52, color: kNegro),
                  const SizedBox(height: 12),
                  const Text(
                    'Crear cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Únete a ReViste y dale segunda vida a la ropa',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kGrisTexto),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nombre,
                    textCapitalization: TextCapitalization.words,
                    decoration: campoDeco(
                      'Nombre completo',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Ingresa tu nombre (mínimo 3 letras)'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
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
                    validator: (v) => (v == null || v.length < 6)
                        ? 'La contraseña debe tener al menos 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmar,
                    obscureText: _ocultar,
                    decoration: campoDeco(
                      'Repite la contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v != _password.text
                        ? 'Las contraseñas no coinciden'
                        : null,
                    onFieldSubmitted: (_) => _cargando ? null : _registrar(),
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
                    onPressed: _cargando ? null : _registrar,
                    child: _cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Crear cuenta'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _cargando ? null : () => context.go('/login'),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
