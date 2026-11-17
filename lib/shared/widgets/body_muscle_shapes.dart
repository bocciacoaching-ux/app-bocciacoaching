import 'package:flutter/material.dart';

/// Vista del cuerpo que se esta mostrando.
enum BodyView { front, back }

/// Rutas de las imagenes anatomicas.
const String kBodyFrontAsset = 'assets/images/body_front.png';
const String kBodyBackAsset = 'assets/images/body_back.png';

/// Relacion de aspecto (ancho / alto) de las imagenes anatomicas.
const double kBodyAspectRatio = 326 / 473;

/// Grupo corporal al que pertenece una zona (para listar y agrupar).
enum BodyGroup {
  headNeck('Cabeza y cuello'),
  shouldersArms('Hombros y brazos'),
  trunk('Tronco'),
  hipsLegs('Cadera y piernas');

  final String label;
  const BodyGroup(this.label);
}

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
  final BodyGroup group;
  final Path path;

  const MuscleRegion({
    required this.id,
    required this.label,
    required this.view,
    required this.group,
    required this.path,
  });
}

/// Definicion estatica de una zona (sin resolver a pixeles).
class MuscleDef {
  final String id;
  final String label;
  final BodyGroup group;
  final List<BodyShape> shapes;
  const MuscleDef(this.id, this.label, this.group, this.shapes);
}

// ====================================================================
//  Formas base. Coordenadas medidas sobre body_front.png / body_back.png
//  (326 x 473). Se definen para el lado IZQUIERDO de la imagen (x < 0.5)
//  y el lado opuesto se obtiene con `mirrored()` (las imagenes son
//  simetricas respecto a x = 0.5).
// ====================================================================

// ── Comunes a ambas vistas ──────────────────────────────────────────

const _deltoid = Smooth([
  Offset(0.372, 0.214),
  Offset(0.338, 0.210),
  Offset(0.313, 0.230),
  Offset(0.303, 0.262),
  Offset(0.310, 0.290),
  Offset(0.332, 0.300),
  Offset(0.354, 0.284),
  Offset(0.370, 0.250),
]);

const _upperArm = Spindle(0.332, 0.288, 0.321, 0.370,
    wTop: 0.044, wMid: 0.052, wBot: 0.040, bulge: 0.45);

const _forearm = Spindle(0.318, 0.374, 0.283, 0.488,
    wTop: 0.052, wMid: 0.062, wBot: 0.036, bulge: 0.30);

const _hand = Smooth([
  Offset(0.283, 0.494),
  Offset(0.258, 0.502),
  Offset(0.242, 0.528),
  Offset(0.244, 0.562),
  Offset(0.258, 0.590),
  Offset(0.284, 0.586),
  Offset(0.300, 0.552),
  Offset(0.302, 0.510),
]);

// ── Vista frontal ───────────────────────────────────────────────────

const _trapFront = Smooth([
  Offset(0.458, 0.190),
  Offset(0.420, 0.197),
  Offset(0.380, 0.203),
  Offset(0.352, 0.212),
  Offset(0.366, 0.224),
  Offset(0.405, 0.220),
  Offset(0.442, 0.214),
  Offset(0.462, 0.208),
]);

const _pectoral = Smooth([
  Offset(0.493, 0.226),
  Offset(0.442, 0.218),
  Offset(0.394, 0.223),
  Offset(0.374, 0.246),
  Offset(0.378, 0.284),
  Offset(0.402, 0.304),
  Offset(0.442, 0.312),
  Offset(0.480, 0.309),
  Offset(0.493, 0.298),
]);

const _oblique = Smooth([
  Offset(0.453, 0.322),
  Offset(0.412, 0.316),
  Offset(0.388, 0.338),
  Offset(0.389, 0.390),
  Offset(0.394, 0.432),
  Offset(0.414, 0.450),
  Offset(0.444, 0.458),
  Offset(0.456, 0.430),
  Offset(0.452, 0.372),
]);

/// Flexores de cadera / ingle: banda bajo el ligamento inguinal.
const _hipFlexor = Smooth([
  Offset(0.388, 0.452),
  Offset(0.420, 0.463),
  Offset(0.456, 0.486),
  Offset(0.486, 0.514),
  Offset(0.474, 0.532),
  Offset(0.444, 0.520),
  Offset(0.408, 0.494),
  Offset(0.384, 0.474),
]);

const _quad = Spindle(0.408, 0.478, 0.418, 0.676,
    wTop: 0.072, wMid: 0.092, wBot: 0.060, bulge: 0.40);

const _adductor = Spindle(0.466, 0.505, 0.470, 0.625,
    wTop: 0.046, wMid: 0.040, wBot: 0.016, bulge: 0.30);

const _tibialis = Spindle(0.405, 0.744, 0.410, 0.866,
    wTop: 0.066, wMid: 0.072, wBot: 0.040, bulge: 0.35);

const _footFront = Smooth([
  Offset(0.392, 0.897),
  Offset(0.424, 0.897),
  Offset(0.436, 0.920),
  Offset(0.430, 0.948),
  Offset(0.392, 0.958),
  Offset(0.346, 0.955),
  Offset(0.336, 0.940),
  Offset(0.360, 0.917),
]);

// ── Vista posterior ─────────────────────────────────────────────────

const _scapula = Smooth([
  Offset(0.436, 0.238),
  Offset(0.402, 0.232),
  Offset(0.374, 0.244),
  Offset(0.370, 0.274),
  Offset(0.384, 0.298),
  Offset(0.420, 0.304),
  Offset(0.450, 0.296),
  Offset(0.454, 0.268),
]);

const _latissimus = Smooth([
  Offset(0.454, 0.302),
  Offset(0.420, 0.308),
  Offset(0.386, 0.304),
  Offset(0.386, 0.336),
  Offset(0.393, 0.372),
  Offset(0.404, 0.396),
  Offset(0.446, 0.404),
  Offset(0.478, 0.394),
  Offset(0.486, 0.360),
  Offset(0.472, 0.330),
]);

const _glute = Smooth([
  Offset(0.497, 0.456),
  Offset(0.470, 0.445),
  Offset(0.430, 0.448),
  Offset(0.400, 0.466),
  Offset(0.392, 0.496),
  Offset(0.405, 0.525),
  Offset(0.440, 0.538),
  Offset(0.476, 0.536),
  Offset(0.496, 0.520),
]);

const _hamstring = Spindle(0.434, 0.536, 0.428, 0.690,
    wTop: 0.086, wMid: 0.092, wBot: 0.060, bulge: 0.35);

const _calf = Spindle(0.414, 0.714, 0.420, 0.806,
    wTop: 0.072, wMid: 0.086, wBot: 0.050, bulge: 0.45);

const _achilles = Spindle(0.416, 0.812, 0.410, 0.884,
    wTop: 0.040, wMid: 0.030, wBot: 0.036, bulge: 0.5);

const _heel = Smooth([
  Offset(0.398, 0.890),
  Offset(0.430, 0.892),
  Offset(0.442, 0.915),
  Offset(0.432, 0.936),
  Offset(0.396, 0.941),
  Offset(0.362, 0.936),
  Offset(0.355, 0.915),
  Offset(0.374, 0.895),
]);

// ====================================================================
//  Vista FRONTAL. En la imagen de frente, el lado izquierdo de la
//  imagen es el lado DERECHO del sujeto.
//
//  El orden importa: las zonas posteriores en la lista se dibujan encima
//  y tienen prioridad al tocar.
// ====================================================================
final List<MuscleDef> kFrontMuscles = [
  const MuscleDef('cabeza_f', 'Cabeza / rostro', BodyGroup.headNeck, [
    Smooth([
      Offset(0.500, 0.055),
      Offset(0.540, 0.065),
      Offset(0.556, 0.100),
      Offset(0.550, 0.140),
      Offset(0.530, 0.166),
      Offset(0.500, 0.174),
      Offset(0.470, 0.166),
      Offset(0.450, 0.140),
      Offset(0.444, 0.100),
      Offset(0.460, 0.065),
    ]),
  ]),
  MuscleDef('trapecio_sup_f', 'Trapecio superior', BodyGroup.headNeck,
      [_trapFront, _trapFront.mirrored()]),
  const MuscleDef('cuello_f', 'Cuello (esternocleidomastoideo)',
      BodyGroup.headNeck, [
    Smooth([
      Offset(0.462, 0.170),
      Offset(0.538, 0.170),
      Offset(0.548, 0.200),
      Offset(0.532, 0.222),
      Offset(0.500, 0.226),
      Offset(0.468, 0.222),
      Offset(0.452, 0.200),
    ]),
  ]),
  const MuscleDef('pectoral_der', 'Pectoral derecho', BodyGroup.trunk,
      [_pectoral]),
  MuscleDef('pectoral_izq', 'Pectoral izquierdo', BodyGroup.trunk,
      [_pectoral.mirrored()]),
  const MuscleDef('deltoides_der_f', 'Deltoides anterior derecho',
      BodyGroup.shouldersArms, [_deltoid]),
  MuscleDef('deltoides_izq_f', 'Deltoides anterior izquierdo',
      BodyGroup.shouldersArms, [_deltoid.mirrored()]),
  const MuscleDef('biceps_der', 'Biceps derecho', BodyGroup.shouldersArms,
      [_upperArm]),
  MuscleDef('biceps_izq', 'Biceps izquierdo', BodyGroup.shouldersArms,
      [_upperArm.mirrored()]),
  const MuscleDef('antebrazo_der_f', 'Antebrazo derecho (flexores)',
      BodyGroup.shouldersArms, [_forearm]),
  MuscleDef('antebrazo_izq_f', 'Antebrazo izquierdo (flexores)',
      BodyGroup.shouldersArms, [_forearm.mirrored()]),
  const MuscleDef('mano_der_f', 'Mano derecha (palma)',
      BodyGroup.shouldersArms, [_hand]),
  MuscleDef('mano_izq_f', 'Mano izquierda (palma)', BodyGroup.shouldersArms,
      [_hand.mirrored()]),
  const MuscleDef('abdomen', 'Recto abdominal', BodyGroup.trunk, [
    Smooth([
      Offset(0.500, 0.312),
      Offset(0.540, 0.314),
      Offset(0.548, 0.360),
      Offset(0.545, 0.420),
      Offset(0.534, 0.478),
      Offset(0.500, 0.518),
      Offset(0.466, 0.478),
      Offset(0.455, 0.420),
      Offset(0.452, 0.360),
      Offset(0.460, 0.314),
    ]),
  ]),
  const MuscleDef('oblicuo_der', 'Oblicuo derecho', BodyGroup.trunk,
      [_oblique]),
  MuscleDef('oblicuo_izq', 'Oblicuo izquierdo', BodyGroup.trunk,
      [_oblique.mirrored()]),
  const MuscleDef('cuadriceps_der', 'Cuadriceps derecho', BodyGroup.hipsLegs,
      [_quad]),
  MuscleDef('cuadriceps_izq', 'Cuadriceps izquierdo', BodyGroup.hipsLegs,
      [_quad.mirrored()]),
  const MuscleDef('aductor_der', 'Aductores derechos', BodyGroup.hipsLegs,
      [_adductor]),
  MuscleDef('aductor_izq', 'Aductores izquierdos', BodyGroup.hipsLegs,
      [_adductor.mirrored()]),
  const MuscleDef('flexor_cadera_der', 'Flexores de cadera / ingle derecha',
      BodyGroup.hipsLegs, [_hipFlexor]),
  MuscleDef('flexor_cadera_izq', 'Flexores de cadera / ingle izquierda',
      BodyGroup.hipsLegs, [_hipFlexor.mirrored()]),
  const MuscleDef('rodilla_der', 'Rodilla derecha', BodyGroup.hipsLegs, [
    Ell(0.418, 0.708, 0.042, 0.027),
  ]),
  const MuscleDef('rodilla_izq', 'Rodilla izquierda', BodyGroup.hipsLegs, [
    Ell(0.582, 0.708, 0.042, 0.027),
  ]),
  const MuscleDef('tibial_der', 'Tibial anterior derecho', BodyGroup.hipsLegs,
      [_tibialis]),
  MuscleDef('tibial_izq', 'Tibial anterior izquierdo', BodyGroup.hipsLegs,
      [_tibialis.mirrored()]),
  const MuscleDef('tobillo_der_f', 'Tobillo derecho', BodyGroup.hipsLegs, [
    Ell(0.404, 0.884, 0.030, 0.014),
  ]),
  const MuscleDef('tobillo_izq_f', 'Tobillo izquierdo', BodyGroup.hipsLegs, [
    Ell(0.596, 0.884, 0.030, 0.014),
  ]),
  const MuscleDef('pie_der_f', 'Pie derecho (empeine)', BodyGroup.hipsLegs,
      [_footFront]),
  MuscleDef('pie_izq_f', 'Pie izquierdo (empeine)', BodyGroup.hipsLegs,
      [_footFront.mirrored()]),
];

// ====================================================================
//  Vista POSTERIOR. En la imagen de espalda, el lado izquierdo de la
//  imagen es el lado IZQUIERDO del sujeto.
// ====================================================================
final List<MuscleDef> kBackMuscles = [
  const MuscleDef('cabeza_b', 'Cabeza (occipital)', BodyGroup.headNeck, [
    Smooth([
      Offset(0.500, 0.055),
      Offset(0.540, 0.065),
      Offset(0.556, 0.100),
      Offset(0.548, 0.128),
      Offset(0.500, 0.136),
      Offset(0.452, 0.128),
      Offset(0.444, 0.100),
      Offset(0.460, 0.065),
    ]),
  ]),
  const MuscleDef('trapecio', 'Trapecio', BodyGroup.trunk, [
    Smooth([
      Offset(0.500, 0.176),
      Offset(0.540, 0.182),
      Offset(0.580, 0.198),
      Offset(0.630, 0.209),
      Offset(0.648, 0.218),
      Offset(0.600, 0.228),
      Offset(0.565, 0.238),
      Offset(0.548, 0.280),
      Offset(0.530, 0.330),
      Offset(0.500, 0.376),
      Offset(0.470, 0.330),
      Offset(0.452, 0.280),
      Offset(0.435, 0.238),
      Offset(0.400, 0.228),
      Offset(0.352, 0.218),
      Offset(0.370, 0.209),
      Offset(0.420, 0.198),
      Offset(0.460, 0.182),
    ]),
  ]),
  const MuscleDef('nuca', 'Nuca / cervicales', BodyGroup.headNeck, [
    Smooth([
      Offset(0.462, 0.132),
      Offset(0.538, 0.132),
      Offset(0.546, 0.160),
      Offset(0.530, 0.186),
      Offset(0.500, 0.192),
      Offset(0.470, 0.186),
      Offset(0.454, 0.160),
    ]),
  ]),
  const MuscleDef('deltoides_izq_b', 'Deltoides posterior izquierdo',
      BodyGroup.shouldersArms, [_deltoid]),
  MuscleDef('deltoides_der_b', 'Deltoides posterior derecho',
      BodyGroup.shouldersArms, [_deltoid.mirrored()]),
  const MuscleDef('escapula_izq', 'Infraespinoso / escapula izquierda',
      BodyGroup.trunk, [_scapula]),
  MuscleDef('escapula_der', 'Infraespinoso / escapula derecha',
      BodyGroup.trunk, [_scapula.mirrored()]),
  const MuscleDef('dorsal_izq', 'Dorsal ancho izquierdo', BodyGroup.trunk,
      [_latissimus]),
  MuscleDef('dorsal_der', 'Dorsal ancho derecho', BodyGroup.trunk,
      [_latissimus.mirrored()]),
  const MuscleDef('triceps_izq', 'Triceps izquierdo', BodyGroup.shouldersArms,
      [_upperArm]),
  MuscleDef('triceps_der', 'Triceps derecho', BodyGroup.shouldersArms,
      [_upperArm.mirrored()]),
  const MuscleDef('antebrazo_izq_b', 'Antebrazo izquierdo (extensores)',
      BodyGroup.shouldersArms, [_forearm]),
  MuscleDef('antebrazo_der_b', 'Antebrazo derecho (extensores)',
      BodyGroup.shouldersArms, [_forearm.mirrored()]),
  const MuscleDef('mano_izq_b', 'Mano izquierda (dorso)',
      BodyGroup.shouldersArms, [_hand]),
  MuscleDef('mano_der_b', 'Mano derecha (dorso)', BodyGroup.shouldersArms,
      [_hand.mirrored()]),
  const MuscleDef('lumbar', 'Zona lumbar (erectores)', BodyGroup.trunk, [
    Smooth([
      Offset(0.500, 0.384),
      Offset(0.540, 0.388),
      Offset(0.565, 0.405),
      Offset(0.570, 0.430),
      Offset(0.545, 0.445),
      Offset(0.500, 0.450),
      Offset(0.455, 0.445),
      Offset(0.430, 0.430),
      Offset(0.435, 0.405),
      Offset(0.460, 0.388),
    ]),
  ]),
  const MuscleDef('gluteo_izq', 'Gluteo izquierdo', BodyGroup.hipsLegs,
      [_glute]),
  MuscleDef('gluteo_der', 'Gluteo derecho', BodyGroup.hipsLegs,
      [_glute.mirrored()]),
  const MuscleDef('isquio_izq', 'Isquiotibiales izquierdos',
      BodyGroup.hipsLegs, [_hamstring]),
  MuscleDef('isquio_der', 'Isquiotibiales derechos', BodyGroup.hipsLegs,
      [_hamstring.mirrored()]),
  const MuscleDef('popliteo_izq', 'Hueco popliteo izquierdo',
      BodyGroup.hipsLegs, [Ell(0.425, 0.704, 0.030, 0.016)]),
  const MuscleDef('popliteo_der', 'Hueco popliteo derecho',
      BodyGroup.hipsLegs, [Ell(0.575, 0.704, 0.030, 0.016)]),
  const MuscleDef('gemelo_izq', 'Gemelo izquierdo', BodyGroup.hipsLegs,
      [_calf]),
  MuscleDef('gemelo_der', 'Gemelo derecho', BodyGroup.hipsLegs,
      [_calf.mirrored()]),
  const MuscleDef('aquiles_izq', 'Tendon de Aquiles izquierdo',
      BodyGroup.hipsLegs, [_achilles]),
  MuscleDef('aquiles_der', 'Tendon de Aquiles derecho', BodyGroup.hipsLegs,
      [_achilles.mirrored()]),
  const MuscleDef('talon_izq', 'Talon izquierdo', BodyGroup.hipsLegs,
      [_heel]),
  MuscleDef('talon_der', 'Talon derecho', BodyGroup.hipsLegs,
      [_heel.mirrored()]),
];

/// Definiciones de la vista indicada.
List<MuscleDef> muscleDefsFor(BodyView view) =>
    view == BodyView.front ? kFrontMuscles : kBackMuscles;

/// Busca una definicion por id en ambas vistas.
MuscleDef? findMuscleDef(String id) {
  for (final d in [...kFrontMuscles, ...kBackMuscles]) {
    if (d.id == id) return d;
  }
  return null;
}

/// Vista a la que pertenece un id de zona.
BodyView? viewOfMuscle(String id) {
  if (kFrontMuscles.any((d) => d.id == id)) return BodyView.front;
  if (kBackMuscles.any((d) => d.id == id)) return BodyView.back;
  return null;
}

/// Construye las zonas musculares interactivas resueltas al tamano dado.
List<MuscleRegion> buildMuscleRegions(Size s, BodyView view) {
  return muscleDefsFor(view).map((d) {
    var path = d.shapes.first.toPath(s);
    for (final shape in d.shapes.skip(1)) {
      path = Path.combine(PathOperation.union, path, shape.toPath(s));
    }
    return MuscleRegion(
      id: d.id,
      label: d.label,
      view: view,
      group: d.group,
      path: path,
    );
  }).toList();
}
