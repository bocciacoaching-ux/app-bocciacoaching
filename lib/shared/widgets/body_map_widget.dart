import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'body_muscle_shapes.dart';

export 'body_muscle_shapes.dart'
    show BodyView, BodyGroup, MuscleRegion, MuscleDef;

/// Color usado para marcar las zonas seleccionadas.
const Color kMuscleSelectedColor = Color(0xFFE53935);

/// Mapa corporal interactivo: muestra la imagen anatomica real (frente o
/// espalda) y permite seleccionar grupos musculares tocandolos.
///
/// - [view]            -> vista a mostrar (frente / espalda).
/// - [selectedMuscles] -> conjunto de ids de musculos seleccionados.
/// - [onMuscleTap]     -> callback con el musculo tocado.
/// - [showHints]       -> si es true, marca suavemente todas las zonas
///                        disponibles para que el usuario sepa donde tocar.
/// - [focusedMuscle]   -> id de una zona a resaltar (p. ej. la ultima tocada).
class HumanBodyMap extends StatelessWidget {
  final BodyView view;
  final Set<String> selectedMuscles;
  final ValueChanged<MuscleRegion> onMuscleTap;
  final bool showHints;
  final String? focusedMuscle;

  /// Distancia maxima (px) para aceptar un toque que cae justo fuera de una
  /// zona pequena (tobillos, manos, cuello...). Facilita el uso con el dedo.
  final double touchTolerance;

  const HumanBodyMap({
    super.key,
    required this.view,
    required this.selectedMuscles,
    required this.onMuscleTap,
    this.showHints = true,
    this.focusedMuscle,
    this.touchTolerance = 10,
  });

  /// Devuelve la zona bajo [pos], o la mas cercana dentro de [tolerance].
  static MuscleRegion? hitTest(
      List<MuscleRegion> muscles, Offset pos, double tolerance) {
    // Orden inverso: prioriza las zonas dibujadas encima.
    for (final m in muscles.reversed) {
      if (m.path.contains(pos)) return m;
    }
    if (tolerance <= 0) return null;

    MuscleRegion? best;
    var bestDist = double.infinity;
    for (final m in muscles) {
      final b = m.path.getBounds();
      if (!b.inflate(tolerance).contains(pos)) continue;
      // Busca el punto del contorno mas cercano muestreando alrededor.
      for (var i = 0; i < 16; i++) {
        final angle = i * 3.141592653589793 / 8;
        final probe = pos + Offset.fromDirection(angle, tolerance * 0.75);
        if (m.path.contains(probe)) {
          final d = (b.center - pos).distance;
          if (d < bestDist) {
            bestDist = d;
            best = m;
          }
          break;
        }
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: kBodyAspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final muscles = buildMuscleRegions(size, view);

            return Semantics(
              label: view == BodyView.front
                  ? 'Mapa corporal, vista frontal'
                  : 'Mapa corporal, vista posterior',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final hit =
                      hitTest(muscles, details.localPosition, touchTolerance);
                  if (hit != null) onMuscleTap(hit);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen anatomica real
                    Image.asset(
                      view == BodyView.front
                          ? kBodyFrontAsset
                          : kBodyBackAsset,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => const MissingBodyAsset(),
                    ),

                    // Capa de zonas seleccionables
                    CustomPaint(
                      painter: MuscleOverlayPainter(
                        muscles: muscles,
                        selectedMuscles: selectedMuscles,
                        showHints: showHints,
                        focusedMuscle: focusedMuscle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Aviso que se muestra si las imagenes aun no se han agregado a assets.
class MissingBodyAsset extends StatelessWidget {
  const MissingBodyAsset({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral9,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 40, color: AppColors.neutral5),
          SizedBox(height: 12),
          Text(
            'Falta la imagen anatomica.\n\n'
            'Agrega los archivos:\n'
            'assets/images/body_front.png\n'
            'assets/images/body_back.png',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.neutral4, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Pinta las zonas musculares sobre la imagen.
class MuscleOverlayPainter extends CustomPainter {
  final List<MuscleRegion> muscles;
  final Set<String> selectedMuscles;
  final bool showHints;
  final String? focusedMuscle;

  MuscleOverlayPainter({
    required this.muscles,
    required this.selectedMuscles,
    required this.showHints,
    this.focusedMuscle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final blur = (size.width * 0.006).clamp(1.0, 4.0);

    // Pista sutil de las zonas disponibles: relleno muy suave + borde fino.
    final hintFill = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primary.withValues(alpha: 0.12);
    final hintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..color = Colors.white.withValues(alpha: 0.75);

    // Zona seleccionada: rojo translucido con bordes difuminados.
    final selectedGlow = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
      ..color = kMuscleSelectedColor.withValues(alpha: 0.55);
    final selectedStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..color = const Color(0xFFFFCDD2).withValues(alpha: 0.95);

    // Zona enfocada (ultima tocada): borde mas marcado.
    final focusStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..color = Colors.white;

    MuscleRegion? focused;
    for (final m in muscles) {
      final isSelected = selectedMuscles.contains(m.id);
      if (isSelected) {
        canvas.drawPath(m.path, selectedGlow);
        canvas.drawPath(m.path, selectedStroke);
      } else if (showHints) {
        canvas.drawPath(m.path, hintFill);
        canvas.drawPath(m.path, hintStroke);
      }
      if (m.id == focusedMuscle) focused = m;
    }
    if (focused != null) {
      canvas.drawPath(focused.path, focusStroke);
    }
  }

  @override
  bool shouldRepaint(covariant MuscleOverlayPainter old) {
    return old.selectedMuscles != selectedMuscles ||
        old.showHints != showHints ||
        old.focusedMuscle != focusedMuscle ||
        old.muscles != muscles;
  }
}
