import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'presentation/router.dart';

void main() {
  runApp(const ProviderScope(child: ReViste()));
}

class ReViste extends StatelessWidget {
  const ReViste({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ReViste',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: appRouter,
    );
  }
}
