import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../providers/favoritos_provider.dart';
import '../widgets/prenda_card.dart';

/// Prendas marcadas con el corazón. Tocar el corazón de una la quita.
class FavoritosScreen extends ConsumerWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prendas = ref.watch(prendasFavoritasProvider);

    return Scaffold(
      appBar: buildAppBar('Mis favoritos'),
      body: prendas.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no tienes favoritos.\n'
                  'Toca el corazón de una prenda para guardarla aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kGrisTexto),
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 250,
              ),
              itemCount: prendas.length,
              itemBuilder: (context, i) => PrendaCard(prenda: prendas[i]),
            ),
    );
  }
}
