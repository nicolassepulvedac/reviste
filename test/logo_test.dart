import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reviste/presentation/widgets/logo_reviste.dart';

/// El logo se carga desde assets/icon/icon.png (declarado en pubspec.yaml).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('el logo de ReViste se muestra sin errores', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: LogoReViste()))),
    );
    await tester.pump();
    expect(find.byType(LogoReViste), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
