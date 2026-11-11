import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../domain/entities/prenda.dart';
import '../providers/auth_provider.dart';
import '../providers/prendas_provider.dart';
import '../widgets/prenda_imagen.dart';

/// Formulario para publicar una prenda nueva (CREATE) o editar una existente
/// (UPDATE) cuando se entrega [prendaId].
class PublicarScreen extends ConsumerStatefulWidget {
  final String? prendaId;
  final VoidCallback? onGuardado;

  const PublicarScreen({super.key, this.prendaId, this.onGuardado});

  @override
  ConsumerState<PublicarScreen> createState() => _PublicarScreenState();
}

class _PublicarScreenState extends ConsumerState<PublicarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final _precio = TextEditingController();
  final _talla = TextEditingController();
  final _marca = TextEditingController();
  final _stock = TextEditingController(text: '1');
  final _imagen = TextEditingController();

  String _categoria = kCategorias.first;
  String _estado = kEstados.first;
  Prenda? _editando;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final id = widget.prendaId;
    if (id != null) {
      final prenda =
          ref.read(prendasProvider).value?.where((p) => p.id == id).firstOrNull;
      if (prenda != null) {
        _editando = prenda;
        _titulo.text = prenda.nombre;
        _descripcion.text = prenda.descripcion;
        _precio.text = prenda.precio.toString();
        _talla.text = prenda.talla;
        _marca.text = prenda.marca == 'Sin marca' ? '' : prenda.marca;
        _stock.text = prenda.stock.toString();
        _imagen.text = prenda.imagenUrl;
        _categoria = prenda.categoria;
        _estado = prenda.estado;
      }
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _talla.dispose();
    _marca.dispose();
    _stock.dispose();
    _imagen.dispose();
    super.dispose();
  }

  void _limpiar() {
    _formKey.currentState?.reset();
    _titulo.clear();
    _descripcion.clear();
    _precio.clear();
    _talla.clear();
    _marca.clear();
    _imagen.clear();
    _stock.text = '1';
    setState(() {
      _categoria = kCategorias.first;
      _estado = kEstados.first;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      mostrarMensaje(context, 'Revisa los campos marcados en rojo');
      return;
    }
    setState(() => _guardando = true);
    final base = _editando;
    final marca = _marca.text.trim();
    final prenda = Prenda(
      id: base?.id ?? '',
      nombre: _titulo.text.trim(),
      precio: int.parse(_precio.text.trim()),
      talla: _talla.text.trim(),
      categoria: _categoria,
      estado: _estado,
      stock: int.parse(_stock.text.trim()),
      imagenUrl: _imagen.text.trim(),
      descripcion: _descripcion.text.trim(),
      marca: marca.isEmpty ? 'Sin marca' : marca,
      vendedor: base?.vendedor ?? ref.read(nombreUsuarioProvider),
    );

    try {
      final notifier = ref.read(prendasProvider.notifier);
      if (base == null) {
        await notifier.crear(prenda);
      } else {
        await notifier.actualizar(prenda);
      }
      if (!mounted) return;
      mostrarMensaje(
        context,
        base == null ? 'Prenda publicada con éxito' : 'Cambios guardados',
      );
      if (base == null) _limpiar();
      setState(() => _guardando = false);
      widget.onGuardado?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      mostrarMensaje(context, 'No se pudo guardar. Intenta de nuevo.');
    }
  }

  String? _numeroPositivo(String? valor, String mensaje) {
    final n = int.tryParse(valor?.trim() ?? '');
    if (n == null || n <= 0) return mensaje;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editando = _editando != null;

    return Scaffold(
      appBar: buildAppBar(editando ? 'Editar prenda' : 'Publicar una prenda'),
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
                    PrendaImagen(url: _imagen.text, height: 150, iconSize: 40),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imagen,
                      keyboardType: TextInputType.url,
                      onChanged: (_) => setState(() {}),
                      decoration: campoDeco(
                        'URL de la foto (opcional)',
                        prefixIcon: const Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titulo,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: campoDeco('Título del producto'),
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? 'Ingresa un título de al menos 3 letras'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descripcion,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: campoDeco('Descripción (Estado, detalles...)'),
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Describe la prenda (mínimo 10 caracteres)'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _precio,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ],
                            decoration: campoDeco('Precio (\$)'),
                            validator: (v) =>
                                _numeroPositivo(v, 'Precio mayor a 0'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _talla,
                            decoration: campoDeco('Talla'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Ingresa la talla'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _marca,
                            decoration: campoDeco('Marca (opcional)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stock,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            decoration: campoDeco('Unidades'),
                            validator: (v) =>
                                _numeroPositivo(v, 'Mínimo 1 unidad'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _categoria,
                      decoration: campoDeco('Categoría'),
                      items: [
                        for (final c in kCategorias)
                          DropdownMenuItem(value: c, child: Text(c)),
                      ],
                      onChanged: (valor) {
                        if (valor != null) setState(() => _categoria = valor);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Condición de la prenda',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final e in kEstados)
                          ChoiceChip(
                            label: Text(e),
                            selected: _estado == e,
                            showCheckmark: false,
                            selectedColor: kNegro,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: kBorde),
                            shape: const StadiumBorder(),
                            labelStyle: TextStyle(
                              color: _estado == e ? Colors.white : kNegro,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) => setState(() => _estado = e),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(editando ? 'Guardar cambios' : 'Publicar artículo'),
            ),
          ),
        ],
      ),
    );
  }
}
