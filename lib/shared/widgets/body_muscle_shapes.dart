import 'package:flutter/material.dart';

/// Vista del cuerpo que se esta mostrando.
enum BodyView { front, back }

/// Rutas de las imagenes anatomicas.
const String kBodyFrontAsset = 'assets/images/body_front.png';
const String kBodyBackAsset = 'assets/images/body_back.png';

/// Relacion de aspecto (ancho / alto) de las imagenes anatomicas.
const double kBodyAspectRatio = 326 / 473;

/// Forma geometrica de una zona muscular, definida en coordenadas
/// normalizadas (0.0 - 1.0) relativas al tamano de la imagen.
abstract class BodyShape {
  const BodyShape();
  Path toPath(Size s);

  /// Devuelve la misma forma reflejada horizontalmente (lado opuesto).
  BodyShape mirrored();
}

/// Contorno cerrado y suave (Catmull-Rom -> Bezier cubicas) que pasa por
/// todos los puntos dados, sin esquinas.
Path _smoothClosedPath(List<Offset> pts) {
  final n = pts.length;
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 0; i < n; i++) {
    final p0 = pts[(i - 1 + n) % n];
    final p1 = pts[i];
    final p2 = pts[(i + 1) % n];
    final p3 = pts[(i + 2) % n];
    final c1 = p1 + (p2 - p0) / 6;
    final c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path..close();
}

/// Elipse normalizada (para articulaciones: rodillas, tobillos...).
class Ell extends BodyShape {
  final double cx, cy, rx, ry;
  const Ell(this.cx, this.cy, this.rx, this.ry);

  @override
  Path toPath(Size s) => Path()
    ..addOval(Rect.fromCenter(
      center: Offset(cx * s.width, cy * s.height),
      width: rx * 2 * s.width,
      height: ry * 2 * s.height,
    ));

  @override
  BodyShape mirrored() => Ell(1 - cx, cy, rx, ry);
}

/// Contorno organico definido por puntos normalizados.
class Smooth extends BodyShape {
  final List<Offset> points;
  const Smooth(this.points);

  @override
  Path toPath(Size s) => _smoothClosedPath(
        points.map((p) => Offset(p.dx * s.width, p.dy * s.height)).toList(),
      );

  @override
  BodyShape mirrored() =>
      Smooth(points.map((p) => Offset(1 - p.dx, p.dy)).toList());
}

/// Musculo fusiforme (forma de huso) orientado a lo largo de un eje:
/// biceps, antebrazos, cuadriceps, gemelos, etc.
///
/// - (x1, y1) -> (x2, y2): eje del musculo.
/// - [wTop], [wMid], [wBot]: anchos (fraccion del ancho de la imagen).
/// - [bulge]: posicion relativa (0..1) del vientre muscular.
class Spindle extends BodyShape {
  final double x1, y1, x2, y2;
  final double wTop, wMid, wBot;
  final double bulge;

  const Spindle(
    this.x1,
    this.y1,
    this.x2,
    this.y2, {
    required this.wTop,
    required this.wMid,
    required this.wBot,
    this.bulge = 0.45,
  });

  @override
  Path toPath(Size s) {
    final a = Offset(x1 * s.width, y1 * s.height);
    final b = Offset(x2 * s.width, y2 * s.height);
    final d = b - a;
    final dir = d / d.distance;
    final nrm = Offset(-dir.dy, dir.dx);

    final ht = wTop * s.width / 2;
    final hm = wMid * s.width / 2;
    final hb = wBot * s.width / 2;
    final m = Offset.lerp(a, b, bulge)!;

    return _smoothClosedPath([
      a - dir * (ht * 0.55),
      a + nrm * ht,
      m + nrm * hm,
      b + nrm * hb,
      b + dir * (hb * 0.6),
      b - nrm * hb,
      m - nrm * hm,
      a - nrm * ht,
    ]);
  }

  @override
  BodyShape mirrored() => Spindle(1 - x1, y1, 1 - x2, y2,
      wTop: wTop, wMid: wMid, wBot: wBot, bulge: bulge);
}

/// Zona muscular interactiva resuelta a pixeles.
class MuscleRegion {
  final String id;
  final String label;
  final BodyView view;
  final Path path;

  const MuscleRegion({
    required this.id,
    required this.label,
    required this.view,
    required this.path,
  });
}

/// Definicion estatica de una zona (sin resolver a pixeles).
class MuscleDef {
  final String id;
  final String label;
  final List<BodyShape> shapes;
  const MuscleDef(this.id, this.label, this.shapes);
}

// ====================================================================
//  Formas base (lado izquierdo de la IMAGEN, x < 0.5). El lado opuesto
//  se obtiene con `mirrored()` para mantener simetria perfecta.
// ====================================================================

const _deltoid = Smooth([
  Offset(0.372, 0.170),
  Offset(0.338, 0.165),
  Offset(0.306, 0.176),
  Offset(0.290, 0.198),
  Offset(0.294, 0.222),
  Offset(0.308, 0.230),
  Offset(0.326, 0.214),
  Offset(0.352, 0.192),
]);

const _pectoral = Smooth([
  Offset(0.495, 0.188),
  Offset(0.440, 0.182),
  Offset(0.388, 0.188),
  Offset(0.360, 0.204),
  Offset(0.378, 0.238),
  Offset(0.425, 0.258),
  Offset(0.475, 0.257),
  Offset(0.495, 0.245),
]);

const _upperArm = Spindle(0.326, 0.220, 0.306, 0.298,
    wTop: 0.046, wMid: 0.058, wBot: 0.040, bulge: 0.45);

const _forearm = Spindle(0.302, 0.302, 0.270, 0.390,
    wTop: 0.050, wMid: 0.054, wBot: 0.030, bulge: 0.28);

const _hand = Smooth([
  Offset(0.272, 0.394),
  Offset(0.252, 0.400),
  Offset(0.240, 0.425),
  Offset(0.245, 0.448),
  Offset(0.262, 0.452),
  Offset(0.280, 0.432),
  Offset(0.288, 0.408),
]);

const _oblique = Smooth([
  Offset(0.444, 0.268),
  Offset(0.410, 0.268),
  Offset(0.392, 0.300),
  Offset(0.396, 0.340),
  Offset(0.420, 0.368),
  Offset(0.446, 0.362),
  Offset(0.449, 0.315),
]);

const _adductor = Spindle(0.474, 0.438, 0.482, 0.545,
    wTop: 0.040, wMid: 0.036, wBot: 0.014, bulge: 0.25);

const _quad = Spindle(0.428, 0.440, 0.432, 0.602,
    wTop: 0.078, wMid: 0.090, wBot: 0.052, bulge: 0.42);

const _tibialis = Spindle(0.428, 0.660, 0.432, 0.815,
    wTop: 0.058, wMid: 0.062, wBot: 0.030, bulge: 0.30);

const _foot = Smooth([
  Offset(0.418, 0.872),
  Offset(0.444, 0.872),
  Offset(0.456, 0.900),
  Offset(0.462, 0.930),
  Offset(0.440, 0.942),
  Offset(0.408, 0.938),
  Offset(0.400, 0.910),
]);

const _latissimus = Smooth([
  Offset(0.398, 0.205),
  Offset(0.440, 0.228),
  Offset(0.482, 0.270),
  Offset(0.494, 0.320),
  Offset(0.486, 0.350),
  Offset(0.450, 0.352),
  Offset(0.420, 0.322),
  Offset(0.400, 0.268),
]);

const _glute = Smooth([
  Offset(0.497, 0.402),
  Offset(0.458, 0.396),
  Offset(0.420, 0.410),
  Offset(0.406, 0.442),
  Offset(0.420, 0.474),
  Offset(0.458, 0.486),
  Offset(0.497, 0.474),
]);

const _hamstring = Spindle(0.440, 0.484, 0.434, 0.604,
    wTop: 0.072, wMid: 0.084, wBot: 0.052, bulge: 0.45);

const _calf = Spindle(0.430, 0.648, 0.432, 0.782,
    wTop: 0.062, wMid: 0.080, wBot: 0.032, bulge: 0.32);

const _achilles = Spindle(0.432, 0.790, 0.432, 0.860,
    wTop: 0.030, wMid: 0.024, wBot: 0.030, bulge: 0.5);

// ====================================================================
//  Vista FRONTAL ("Izq"/"Der" = lado del SUJETO).
// ====================================================================
final List<MuscleDef> kFrontMuscles = [
  const MuscleDef('rostro', 'Rostro / mandibula', [
    Smooth([
      Offset(0.500, 0.016),
      Offset(0.542, 0.026),
      Offset(0.552, 0.058),
      Offset(0.538, 0.090),
      Offset(0.500, 0.104),
      Offset(0.462, 0.090),
      Offset(0.448, 0.058),
      Offset(0.458, 0.026),
    ]),
  ]),
  const MuscleDef('cuello_f', 'Cuello (esternocleidomastoideo)', [
    Smooth([
      Offset(0.470, 0.096),
      Offset(0.530, 0.096),
      Offset(0.540, 0.134),
      Offset(0.500, 0.142),
      Offset(0.460, 0.134),
    ]),
  ]),
  const MuscleDef('trapecio_sup_f', 'Trapecio superior', [
    Smooth([
      Offset(0.458, 0.136),
      Offset(0.500, 0.150),
      Offset(0.542, 0.136),
      Offset(0.600, 0.156),
      Offset(0.640, 0.170),
      Offset(0.590, 0.174),
      Offset(0.500, 0.170),
      Offset(0.410, 0.174),
      Offset(0.360, 0.170),
      Offset(0.400, 0.156),
    ]),
  ]),
  const MuscleDef('deltoides_der_f', 'Deltoides derecho', [_deltoid]),
  MuscleDef('deltoides_izq_f', 'Deltoides izquierdo', [_deltoid.mirrored()]),
  const MuscleDef('pectoral_der', 'Pectoral derecho', [_pectoral]),
  MuscleDef('pectoral_izq', 'Pectoral izquierdo', [_pectoral.mirrored()]),
  const MuscleDef('biceps_der', 'Biceps derecho', [_upperArm]),
  MuscleDef('biceps_izq', 'Biceps izquierdo', [_upperArm.mirrored()]),
  const MuscleDef('abdomen', 'Recto abdominal', [
    Smooth([
      Offset(0.500, 0.262),
      Offset(0.546, 0.266),
      Offset(0.550, 0.315),
      Offset(0.540, 0.362),
      Offset(0.500, 0.376),
      Offset(0.460, 0.362),
      Offset(0.450, 0.315),
      Offset(0.454, 0.266),
    ]),
  ]),
  const MuscleDef('oblicuo_der', 'Oblicuo derecho', [_oblique]),
  MuscleDef('oblicuo_izq', 'Oblicuo izquierdo', [_oblique.mirrored()]),
  const MuscleDef('antebrazo_der_f', 'Antebrazo derecho', [_forearm]),
  MuscleDef('antebrazo_izq_f', 'Antebrazo izquierdo', [_forearm.mirrored()]),
  const MuscleDef('mano_der_f', 'Mano derecha', [_hand]),
  MuscleDef('mano_izq_f', 'Mano izquierda', [_hand.mirrored()]),
  const MuscleDef('cadera_flexores', 'Flexores de cadera / ingle', [
    Smooth([
      Offset(0.428, 0.372),
      Offset(0.500, 0.390),
      Offset(0.572, 0.372),
      Offset(0.556, 0.408),
      Offset(0.500, 0.432),
      Offset(0.444, 0.408),
    ]),
  ]),
  const MuscleDef('aductor_der', 'Aductor derecho', [_adductor]),
  MuscleDef('aductor_izq', 'Aductor izquierdo', [_adductor.mirrored()]),
  const MuscleDef('cuadriceps_der', 'Cuadriceps derecho', [_quad]),
  MuscleDef('cuadriceps_izq', 'Cuadriceps izquierdo', [_quad.mirrored()]),
  const MuscleDef('rodilla_der', 'Rodilla derecha', [
    Ell(0.430, 0.627, 0.032, 0.026),
  ]),
  const MuscleDef('rodilla_izq', 'Rodilla izquierda', [
    Ell(0.570, 0.627, 0.032, 0.026),
  ]),
  const MuscleDef('tibial_der', 'Tibial anterior derecho', [_tibialis]),
  MuscleDef('tibial_izq', 'Tibial anterior izquierdo', [_tibialis.mirrored()]),
  const MuscleDef('tobillo_der_f', 'Tobillo derecho', [
    Ell(0.432, 0.842, 0.022, 0.022),
  ]),
  const MuscleDef('tobillo_izq_f', 'Tobillo izquierdo', [
    Ell(0.568, 0.842, 0.022, 0.022),
  ]),
  const MuscleDef('pie_der_f', 'Pie derecho', [_foot]),
  MuscleDef('pie_izq_f', 'Pie izquierdo', [_foot.mirrored()]),
];

// ====================================================================
//  Vista POSTERIOR (el lado izquierdo del sujeto queda a la izquierda).
// ====================================================================
final List<MuscleDef> kBackMuscles = [
  const MuscleDef('nuca', 'Nuca / cervicales', [
    Smooth([
      Offset(0.470, 0.092),
      Offset(0.530, 0.092),
      Offset(0.538, 0.132),
      Offset(0.500, 0.138),
      Offset(0.462, 0.132),
    ]),
  ]),
  const MuscleDef('trapecio', 'Trapecio', [
    Smooth([
      Offset(0.500, 0.140),
      Offset(0.560, 0.150),
      Offset(0.640, 0.172),
      Offset(0.600, 0.196),
      Offset(0.545, 0.236),
      Offset(0.500, 0.290),
      Offset(0.455, 0.236),
      Offset(0.400, 0.196),
      Offset(0.360, 0.172),
      Offset(0.440, 0.150),
    ]),
  ]),
  const MuscleDef(
      'deltoides_izq_b', 'Deltoides posterior izquierdo', [_deltoid]),
  MuscleDef('deltoides_der_b', 'Deltoides posterior derecho',
      [_deltoid.mirrored()]),
  const MuscleDef('dorsal_izq', 'Dorsal ancho izquierdo', [_latissimus]),
  MuscleDef('dorsal_der', 'Dorsal ancho derecho', [_latissimus.mirrored()]),
  const MuscleDef('triceps_izq', 'Triceps izquierdo', [_upperArm]),
  MuscleDef('triceps_der', 'Triceps derecho', [_upperArm.mirrored()]),
  const MuscleDef('antebrazo_izq_b', 'Antebrazo izquierdo', [_forearm]),
  MuscleDef('antebrazo_der_b', 'Antebrazo derecho', [_forearm.mirrored()]),
  const MuscleDef('mano_izq_b', 'Mano izquierda', [_hand]),
  MuscleDef('mano_der_b', 'Mano derecha', [_hand.mirrored()]),
  const MuscleDef('lumbar', 'Zona lumbar', [
    Smooth([
      Offset(0.500, 0.344),
      Offset(0.552, 0.350),
      Offset(0.562, 0.380),
      Offset(0.530, 0.400),
      Offset(0.500, 0.404),
      Offset(0.470, 0.400),
      Offset(0.438, 0.380),
      Offset(0.448, 0.350),
    ]),
  ]),
  const MuscleDef('gluteo_izq', 'Gluteo izquierdo', [_glute]),
  MuscleDef('gluteo_der', 'Gluteo derecho', [_glute.mirrored()]),
  const MuscleDef('isquio_izq', 'Isquiotibial izquierdo', [_hamstring]),
  MuscleDef('isquio_der', 'Isquiotibial derecho', [_hamstring.mirrored()]),
  const MuscleDef('popliteo_izq', 'Hueco popliteo izquierdo', [
    Ell(0.433, 0.627, 0.028, 0.020),
  ]),
  const MuscleDef('popliteo_der', 'Hueco popliteo derecho', [
    Ell(0.567, 0.627, 0.028, 0.020),
  ]),
  const MuscleDef('gemelo_izq', 'Gemelo izquierdo', [_calf]),
  MuscleDef('gemelo_der', 'Gemelo derecho', [_calf.mirrored()]),
  const MuscleDef('aquiles_izq', 'Tendon de Aquiles izquierdo', [_achilles]),
  MuscleDef(
      'aquiles_der', 'Tendon de Aquiles derecho', [_achilles.mirrored()]),
  const MuscleDef('pie_izq_b', 'Pie izquierdo', [_foot]),
  MuscleDef('pie_der_b', 'Pie derecho', [_foot.mirrored()]),
];

/// Construye las zonas musculares interactivas resueltas al tamano dado.
List<MuscleRegion> buildMuscleRegions(Size s, BodyView view) {
  final defs = view == BodyView.front ? kFrontMuscles : kBackMuscles;

  return defs.map((d) {
    var path = d.shapes.first.toPath(s);
    for (final shape in d.shapes.skip(1)) {
      path = Path.combine(PathOperation.union, path, shape.toPath(s));
    }
    return MuscleRegion(id: d.id, label: d.label, view: view, path: path);
  }).toList();
}
