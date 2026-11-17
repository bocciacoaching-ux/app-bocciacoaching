import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boccia_coaching_app/shared/widgets/body_map_widget.dart';
import 'package:boccia_coaching_app/shared/widgets/body_muscle_shapes.dart';

/// Tamano nativo de las imagenes anatomicas.
const _size = Size(326, 473);

Offset _at(double x, double y) => Offset(x * _size.width, y * _size.height);

Future<MuscleRegion?> _tap(
    WidgetTester tester, BodyView view, Offset point) async {
  MuscleRegion? tapped;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: _size.width,
            height: _size.height,
            child: HumanBodyMap(
              view: view,
              selectedMuscles: const {},
              onMuscleTap: (m) => tapped = m,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final origin = tester.getTopLeft(find.byType(HumanBodyMap));
  await tester.tapAt(origin + point);
  await tester.pump();
  return tapped;
}

void main() {
  testWidgets('Toque sobre el abdomen selecciona el recto abdominal',
      (tester) async {
    final m = await _tap(tester, BodyView.front, _at(0.50, 0.40));
    expect(m?.id, 'abdomen');
  });

  testWidgets('Los musculos principales caen sobre la anatomia (frente)',
      (tester) async {
    // Puntos medidos sobre body_front.png.
    expect((await _tap(tester, BodyView.front, _at(0.43, 0.27)))?.id,
        'pectoral_der');
    expect((await _tap(tester, BodyView.front, _at(0.325, 0.33)))?.id,
        'biceps_der');
    expect((await _tap(tester, BodyView.front, _at(0.41, 0.58)))?.id,
        'cuadriceps_der');
    expect((await _tap(tester, BodyView.front, _at(0.27, 0.55)))?.id,
        'mano_der_f');
  });

  testWidgets('Los musculos principales caen sobre la anatomia (espalda)',
      (tester) async {
    expect((await _tap(tester, BodyView.back, _at(0.44, 0.49)))?.id,
        'gluteo_izq');
    expect((await _tap(tester, BodyView.back, _at(0.43, 0.61)))?.id,
        'isquio_izq');
    expect((await _tap(tester, BodyView.back, _at(0.415, 0.76)))?.id,
        'gemelo_izq');
    expect((await _tap(tester, BodyView.back, _at(0.41, 0.35)))?.id,
        'dorsal_izq');
  });

  test('Un toque fuera del cuerpo no selecciona nada', () {
    final regions = buildMuscleRegions(_size, BodyView.front);
    expect(HumanBodyMap.hitTest(regions, _at(0.05, 0.05), 10), isNull);
  });

  test('Los ids son unicos entre frente y espalda', () {
    final front = buildMuscleRegions(_size, BodyView.front);
    final back = buildMuscleRegions(_size, BodyView.back);

    expect(front, isNotEmpty);
    expect(back, isNotEmpty);

    final all = [...front, ...back].map((m) => m.id).toList();
    expect(all.toSet().length, all.length);
  });
}
