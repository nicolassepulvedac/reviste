import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../providers/carrito_provider.dart';
import '../providers/filtros_provider.dart';
import '../providers/prendas_provider.dart';

/// Resumen de compra con formulario de envío validado.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  final _ciudad = TextEditingController();
  final _postal = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    _ciudad.dispose();
    _postal.dispose();
    super.dispose();
  }

  String? _requerido(String? valor, String mensaje, {int minimo = 1}) {
    if (valor == null || valor.trim().length < minimo) return mensaje;
    return null;
  }

  Future<void> _confirmar() async {
    if (!_formKey.currentState!.validate()) {
      mostrarMensaje(context, 'Revisa los campos marcados en rojo');
      return;
    }
    setState(() => _enviando = true);
    final items = ref.read(carritoProvider);
    final nombre = _nombre.text.trim();
    final direccion = _direccion.text.trim();
    final ciudad = _ciudad.text.trim();

    try {
      await ref.read(prendasProvider.notifier).comprar(items);
      ref.read(carritoProvider.notifier).vaciar();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('¡Pedido confirmado!'),
          content: Text(
            'Gracias, $nombre. Enviaremos tu pedido a $direccion, $ciudad.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      ref.read(tabIndexProvider.notifier).ir(0);
      context.go('/');
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviando = false);
      mostrarMensaje(context, 'No se pudo confirmar el pedido. Intenta de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(carritoProvider);
    final total = ref.watch(carritoTotalProvider);

    if (items.isEmpty && !_enviando) {
      return Scaffold(
        appBar: buildAppBar('Resumen de compra'),
        body: const Center(child: Text('No tienes prendas en el carrito')),
      );
    }

    return Scaffold(
      appBar: buildAppBar('Resumen de compra'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorde),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen de artículos (${items.length})',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          for (final item in items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• ${item.prenda.nombre} (${item.prenda.talla}) x${item.cantidad} - ${formatearPrecio(item.subtotal)}',
                                style: const TextStyle(
                                  color: kGrisTexto,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Dirección de Envío',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nombre,
                      textCapitalization: TextCapitalization.words,
                      decoration: campoDeco('Nombre completo'),
                      validator: (v) =>
                          _requerido(v, 'Ingresa tu nombre completo', minimo: 3),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _direccion,
                      decoration: campoDeco('Dirección de envío'),
                      validator: (v) =>
                          _requerido(v, 'Ingresa tu dirección', minimo: 5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ciudad,
                            decoration: campoDeco('Ciudad'),
                            validator: (v) => _requerido(v, 'Ingresa la ciudad'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _postal,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(7),
                            ],
                            decoration: campoDeco('Cód. Postal'),
                            validator: (v) =>
                                _requerido(v, 'Ingresa el código', minimo: 4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Método de Pago',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: kVerde, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.credit_card),
                          SizedBox(width: 10),
                          Expanded(child: Text('Visa terminada en •••• 4820')),
                          Icon(Icons.check_circle, color: kVerde),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(
                onPressed: _enviando ? null : _confirmar,
                child: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text('Confirmar pedido (${formatearPrecio(total)})'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
