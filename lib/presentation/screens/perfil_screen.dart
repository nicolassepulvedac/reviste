import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/carrito_provider.dart';
import '../providers/favoritos_provider.dart';
import '../providers/filtros_provider.dart';
import '../providers/pedidos_provider.dart';
import '../providers/rol_provider.dart';

/// Perfil del usuario con accesos a sus publicaciones y cierre de sesión.
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    // El carrito es de cada persona: se limpia antes de salir.
    ref.read(carritoProvider.notifier).vaciar();
    ref.read(tabIndexProvider.notifier).ir(0);
    await ref.read(authServiceProvider).cerrarSesion();
    // El router detecta que no hay sesión y vuelve al login.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicadas = ref.watch(misPublicacionesProvider).length;
    final nombre = ref.watch(nombreUsuarioProvider);
    final correo = ref.watch(correoUsuarioProvider);
    final esAdmin = ref.watch(esAdminProvider);
    final favoritos = ref.watch(prendasFavoritasProvider).length;
    final compras = ref.watch(pedidosProvider).value?.length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          correo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: kGrisTexto),
                        ),
                        if (esAdmin)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: kVerdeClaro,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Administrador',
                              style: TextStyle(
                                color: kVerde,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _Dato('$publicadas', 'Publicadas')),
                  Expanded(
                    child: _Dato(
                      '$favoritos',
                      'Favoritos',
                      onTap: () => context.push('/favoritos'),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: kBorde),
              ),
              _OpcionMenu(
                icono: Icons.checkroom_outlined,
                titulo: esAdmin ? 'Gestionar publicaciones' : 'Mis publicaciones',
                subtitulo: esAdmin
                    ? 'Todas las prendas (administrador)'
                    : '$publicadas prendas listadas',
                onTap: () => context.push('/mis-publicaciones'),
              ),
              _OpcionMenu(
                icono: Icons.favorite_border,
                titulo: 'Mis favoritos',
                subtitulo: favoritos == 1
                    ? '1 prenda guardada'
                    : '$favoritos prendas guardadas',
                onTap: () => context.push('/favoritos'),
              ),
              _OpcionMenu(
                icono: Icons.shopping_bag_outlined,
                titulo: 'Mis compras',
                subtitulo: compras == null
                    ? 'Historial de pedidos'
                    : compras == 1
                        ? '1 pedido realizado'
                        : '$compras pedidos realizados',
                onTap: () => context.push('/mis-compras'),
              ),
              _OpcionMenu(
                icono: Icons.settings_outlined,
                titulo: 'Configuración',
                subtitulo: 'Ajustes de cuenta',
                onTap: () => context.push('/configuracion'),
              ),
              _OpcionMenu(
                icono: Icons.logout,
                titulo: 'Cerrar sesión',
                subtitulo: 'Salir de ReViste',
                onTap: () => _cerrarSesion(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final VoidCallback? onTap;

  const _Dato(this.valor, this.etiqueta, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(
              valor,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              etiqueta,
              style: const TextStyle(color: kGrisTexto, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionMenu extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _OpcionMenu({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: kBorde),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icono),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        subtitulo,
                        style:
                            const TextStyle(color: kGrisTexto, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: kGrisTexto),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
