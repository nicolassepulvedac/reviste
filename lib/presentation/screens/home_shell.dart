import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../providers/carrito_provider.dart';
import '../providers/filtros_provider.dart';
import 'carrito_screen.dart';
import 'explorar_screen.dart';
import 'perfil_screen.dart';
import 'publicar_screen.dart';

/// Contenedor principal con el menú inferior (Explorar, Vender, Carrito, Perfil).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indice = ref.watch(tabIndexProvider);
    final cantidad = ref.watch(carritoCantidadProvider);

    return Scaffold(
      body: IndexedStack(
        index: indice,
        children: [
          const ExplorarScreen(),
          PublicarScreen(
            onGuardado: () => ref.read(tabIndexProvider.notifier).ir(0),
          ),
          const CarritoScreen(),
          const PerfilScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kBorde)),
        ),
        child: NavigationBar(
          selectedIndex: indice,
          backgroundColor: kCrema,
          surfaceTintColor: Colors.transparent,
          indicatorColor: kVerdeClaro,
          onDestinationSelected: (i) =>
              ref.read(tabIndexProvider.notifier).ir(i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Explorar',
            ),
            const NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Vender',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cantidad > 0,
                label: Text('$cantidad'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cantidad > 0,
                label: Text('$cantidad'),
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Carrito',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
