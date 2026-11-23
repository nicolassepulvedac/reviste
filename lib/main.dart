import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'presentation/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
//testeo@gmail.com  test123
//admin@reviste.cl Admin1234