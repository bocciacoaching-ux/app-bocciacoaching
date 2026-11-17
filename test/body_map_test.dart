import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boccia_coaching_app/shared/widgets/body_map_widget.dart';
import 'package:boccia_coaching_app/shared/widgets/body_muscle_shapes.dart';

void main() {
  testWidgets('HumanBodyMap permite seleccionar una zona muscular',
      (tester) async {
    MuscleRegion? tapped;
    final selected = <String>{};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 326,
            height: 473,
            child: HumanBodyMap(
              view: BodyView.front,
              selectedMuscles: selected,
              onMuscleTap: (m) => tapped = m,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // El widget se construye correctamente.
    expect(find.byType(HumanBodyMap), findsOneWidget);

    // Tocar sobre el abdomen (centro del torso) selecciona esa zona.
    final center = tester.getTopLeft(find.byType(HumanBodyMap));
    await tester.tapAt(center + const Offset(163, 148));
    await tester.pump();

    expect(tapped, isNotNull);
    expect(tapped!.id, 'abdomen');
  });

  test('Las zonas de frente y espalda tienen ids unicos', () {
    const size = Size(326, 473);

    final front = buildMuscleRegions(size, BodyView.front);
    final back = buildMuscleRegions(size, BodyView.back);

    expect(front, isNotEmpty);
    expect(back, isNotEmpty);

    expect(front.map((m) => m.id).toSet().length, front.length);
    expect(back.map((m) => m.id).toSet().length, back.length);
  });
}
