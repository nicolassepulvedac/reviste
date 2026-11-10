import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../providers/filtros_provider.dart';
import '../providers/prendas_provider.dart';
import '../widgets/prenda_card.dart';

/// Home: buscador, filtros por categoría y grilla de prendas.
class ExplorarScreen extends ConsumerWidget {
  const ExplorarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prendas = ref.watch(prendasFiltradasProvider);
    final categoria = ref.watch(categoriaProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Text(
                    'ReViste',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        mostrarMensaje(context, 'No tienes notificaciones'),
                    icon: const Icon(Icons.notifications_none),
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: kBorde),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                onChanged: (texto) =>
                    ref.read(busquedaProvider.notifier).cambiar(texto),
                decoration: campoDeco(
                  'Buscar ropa, marcas y más...',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  for (final filtro in kFiltros)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filtro),
                        selected: categoria == filtro,
                        showCheckmark: false,
                        selectedColor: kNegro,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: kBorde),
                        shape: const StadiumBorder(),
                        labelStyle: TextStyle(
                          color: categoria == filtro ? Colors.white : kNegro,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => ref
                            .read(categoriaProvider.notifier)
                            .seleccionar(filtro),
                      ),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Novedades de la semana',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: prendas.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 40),
                        const SizedBox(height: 8),
                        const Text(
                          'No pudimos cargar las prendas',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(prendasProvider),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (lista) {
                  if (lista.isEmpty) {
                    return const Center(
                      child: Text(
                        'No encontramos prendas con esos filtros',
                        style: TextStyle(color: kGrisTexto),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 250,
                    ),
                    itemCount: lista.length,
                    itemBuilder: (context, i) => PrendaCard(prenda: lista[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
