import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boccia_coaching_app/shared/widgets/adaptive_layout.dart';
import 'package:boccia_coaching_app/shared/widgets/app_scaffold.dart';

/// Menu de prueba que se comporta como AppDrawer: muestra si esta fijo.
class _FakeDrawer extends StatelessWidget {
  const _FakeDrawer();

  @override
  Widget build(BuildContext context) {
    final embedded = AppDrawerScope.isEmbedded(context);
    return Drawer(child: Text(embedded ? 'menu-fijo' : 'menu-cajon'));
  }
}

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump();
}

void main() {
  group('AppScaffold', () {
    testWidgets('en escritorio el menu se muestra fijo', (tester) async {
      await _pumpAt(
        tester,
        const Size(1440, 900),
        AppScaffold(
          appBar: AppBar(title: const Text('t')),
          drawer: const _FakeDrawer(),
          body: const SizedBox.expand(),
        ),
      );
      expect(find.text('menu-fijo'), findsOneWidget);
    });

    testWidgets('en movil el menu sigue siendo un cajon', (tester) async {
      final key = GlobalKey<ScaffoldState>();
      await _pumpAt(
        tester,
        const Size(390, 844),
        AppScaffold(
          key: key,
          appBar: AppBar(title: const Text('t')),
          drawer: const _FakeDrawer(),
          body: const SizedBox.expand(),
        ),
      );
      // Cerrado por defecto...
      expect(find.text('menu-cajon'), findsNothing);
      // ...y el GlobalKey sigue llegando al Scaffold interno.
      key.currentState!.openDrawer();
      await tester.pumpAndSettle();
      expect(find.text('menu-cajon'), findsOneWidget);
    });

    testWidgets('limita el ancho del contenido', (tester) async {
      const bodyKey = Key('body');
      await _pumpAt(
        tester,
        const Size(1600, 900),
        const AppScaffold(
          maxContentWidth: AppContentWidth.compact,
          body: SizedBox.expand(key: bodyKey),
        ),
      );
      expect(tester.getSize(find.byKey(bodyKey)).width,
          AppContentWidth.compact);
    });
  });

  group('AdaptiveStatGrid.columnsFor', () {
    int cols(double width) => AdaptiveStatGrid.columnsFor(
        count: 4, width: width, minItemWidth: 140, spacing: 12);

    test('movil: 2 columnas', () => expect(cols(358), 2));
    test('tablet / escritorio: 4 columnas', () => expect(cols(900), 4));
    test('nunca deja tarjetas huerfanas (no usa 3 con 4 tarjetas)', () {
      for (var w = 200.0; w < 2000; w += 10) {
        expect(4 % cols(w), 0, reason: 'ancho $w');
      }
    });
  });
}
