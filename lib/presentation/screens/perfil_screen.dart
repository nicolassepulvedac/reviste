import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../providers/filtros_provider.dart';

/// Perfil del usuario con accesos a sus publicaciones.
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicadas = ref.watch(misPublicacionesProvider).length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_outline, size: 52),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kUsuarioActual,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Miembro desde Septiembre 2026',
                          style: TextStyle(color: kGrisTexto),
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
                  const Expanded(child: _Dato('4.8', 'Valoración')),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: kBorde),
              ),
              _OpcionMenu(
                icono: Icons.checkroom_outlined,
                titulo: 'Mis publicaciones',
                subtitulo: '$publicadas prendas listadas',
                onTap: () => context.push('/mis-publicaciones'),
              ),
              _OpcionMenu(
                icono: Icons.shopping_bag_outlined,
                titulo: 'Mis compras',
                subtitulo: 'Historial y seguimiento',
                onTap: () => mostrarMensaje(context, 'Próximamente'),
              ),
              _OpcionMenu(
                icono: Icons.settings_outlined,
                titulo: 'Configuración',
                subtitulo: 'Ajustes de cuenta',
                onTap: () => mostrarMensaje(context, 'Próximamente'),
              ),
              _OpcionMenu(
                icono: Icons.logout,
                titulo: 'Cerrar sesión',
                subtitulo: 'Salir de ReViste',
                onTap: () => mostrarMensaje(
                  context,
                  'Disponible cuando se conecte el login con Firebase',
                ),
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

  const _Dato(this.valor, this.etiqueta);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        Text(etiqueta, style: const TextStyle(color: kGrisTexto, fontSize: 12)),
      ],
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
