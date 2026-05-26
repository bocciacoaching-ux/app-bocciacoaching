import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget que dibuja el componente de evaluación de control de dirección.
///
/// Configuración real: 5 boccias alineadas horizontalmente, separadas ~5 cm
/// entre sí. El puntaje se asigna según la zona donde pasa la pelota lanzada:
///
///  ┌─────┬────┬───┬────┬───┬────┬───┬────┬───┬────┬─────┐
///  │FUERA│bola│gap│bola│gap│JACK│gap│bola│gap│bola│FUERA│
///  │  0  │ 1  │ 2 │ 3  │ 4 │ 5  │ 4 │ 3  │ 2 │ 1  │  0  │
///  └─────┴────┴───┴────┴───┴────┴───┴────┴───┴────┴─────┘
///
/// Proporciones basadas en la disposición física:
///   boccia ≈ 8.6 cm, separación ≈ 5 cm → ratio gap/bola ≈ 0.6
///
/// El usuario toca para colocar la pelota; el widget devuelve coordenadas y
/// puntaje calculado mediante [onTargetTap].
class DirectionTargetWidget extends StatefulWidget {
  final void Function(double x, double y, int score)? onTargetTap;
  final Offset? selection;
  final double size;

  const DirectionTargetWidget({
    super.key,
    this.onTargetTap,
    this.selection,
    this.size = 300.0,
  });

  @override
  State<DirectionTargetWidget> createState() => DirectionTargetWidgetState();
}

class DirectionTargetWidgetState extends State<DirectionTargetWidget> {
  Offset? _internalSelection;

  Offset? get selection => widget.selection ?? _internalSelection;

  // ── Proporciones de las 11 zonas (en "unidades bola") ────────────
  // fuera | b1 | gap | b1 | gap | JACK | gap | b1 | gap | b1 | fuera
  static const _zoneUnits = [
    1.0, 1.0, 0.6, 1.0, 0.6, 1.0, 0.6, 1.0, 0.6, 1.0, 1.0,
  ];
  static const _zoneScores = [0, 1, 2, 3, 4, 5, 4, 3, 2, 1, 0];
  static const _totalUnits = 9.4; // sum of _zoneUnits

  /// Límites de cada zona como porcentaje 0-100 del ancho.
  static List<double> get _zoneBoundaries {
    final bounds = <double>[0.0];
    double acc = 0;
    for (final u in _zoneUnits) {
      acc += u;
      bounds.add(acc / _totalUnits * 100);
    }
    return bounds;
  }

  /// Puntaje según posición X relativa (0-100).
  int _calculateScore(double relativeX, double _relativeY) {
    final bounds = _zoneBoundaries;
    for (int i = 0; i < _zoneScores.length; i++) {
      if (relativeX < bounds[i + 1]) return _zoneScores[i];
    }
    return _zoneScores.last;
  }

  void _handleTapDown(TapDownDetails details) {
    final localPosition = details.localPosition;
    final relativeX = (localPosition.dx / widget.size) * 100;
    final relativeY = (localPosition.dy / (widget.size * 0.75)) * 100;
    final score = _calculateScore(relativeX, relativeY);
    setState(() => _internalSelection = Offset(relativeX, relativeY));
    widget.onTargetTap?.call(relativeX, relativeY, score);
  }

  void reset() => setState(() => _internalSelection = null);

  void setPosition(double x, double y, int score) =>
      setState(() => _internalSelection = Offset(x, y));

  @override
  Widget build(BuildContext context) {
    final height = widget.size * 0.75;
    return Center(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        child: Container(
          width: widget.size,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              size: Size(widget.size, height),
              painter: DirectionCourtPainter(selection: selection),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Painter
// ═══════════════════════════════════════════════════════════════════

class DirectionCourtPainter extends CustomPainter {
  final Offset? selection;
  const DirectionCourtPainter({this.selection});

  static const _zoneUnits = [
    1.0, 1.0, 0.6, 1.0, 0.6, 1.0, 0.6, 1.0, 0.6, 1.0, 1.0,
  ];
  static const _zoneScores = [0, 1, 2, 3, 4, 5, 4, 3, 2, 1, 0];
  static const _totalUnits = 9.4;

  static const Map<int, Color> _zoneColors = {
    0: Color(0xFFC9944A), // marrón – fuera de zona
    1: Color(0xFFE8D5A8), // tan claro – bola exterior (directo)
    2: Color(0xFFE0D49E), // beige cálido – gap exterior
    3: Color(0xFFD4CC8E), // oliva-beige – bola lateral (directo)
    4: Color(0xFFC5D6A0), // verde claro – ranura junto al jack
    5: Color(0xFF8FBF6F), // verde – centro / jack
  };

  /// Anchos absolutos de cada zona dado el ancho total.
  List<double> _zoneWidths(double totalWidth) => _zoneUnits
      .map((u) => u / _totalUnits * totalWidth)
      .toList();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ballRowY = h * 0.28;
    final zw = _zoneWidths(w);

    // ── 1) Fondos de zona (ancho proporcional) ────────────────────
    double xCursor = 0;
    for (int i = 0; i < _zoneScores.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(xCursor, 0, zw[i], h),
        Paint()..color = _zoneColors[_zoneScores[i]]!,
      );
      xCursor += zw[i];
    }

    // ── 2) Líneas divisorias ──────────────────────────────────────
    final borderPaint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.45)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    xCursor = 0;
    for (int i = 0; i < _zoneScores.length - 1; i++) {
      xCursor += zw[i];
      canvas.drawLine(Offset(xCursor, 0), Offset(xCursor, h), borderPaint);
    }

    // ── 3) Etiquetas de puntaje ───────────────────────────────────
    _drawScoreLabels(canvas, size, zw);

    // ── 4) Línea horizontal punteada (fila de bolas) ──────────────
    final axisPaint = Paint()
      ..color = const Color(0xFF555555).withValues(alpha: 0.5)
      ..strokeWidth = w * 0.004
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, Offset(0, ballRowY), Offset(w, ballRowY), axisPaint,
        dashWidth: w * 0.02, dashSpace: w * 0.01);

    // ── 5) Línea vertical central punteada ───────────────────────
    _drawDashedLine(canvas, Offset(w / 2, 0), Offset(w / 2, h), axisPaint,
        dashWidth: h * 0.015, dashSpace: h * 0.008);

    // ── 6) Las 5 boccias ─────────────────────────────────────────
    _drawFiveBocciaBalls(canvas, size, zw, ballRowY);

    // ── 7) "FUERA DE ZONA" en extremos ───────────────────────────
    _drawOutOfZoneLabels(canvas, size, zw);

    // ── 8) Pelota seleccionada por el usuario ─────────────────────
    if (selection != null) _drawSelectedBall(canvas, size, selection!);
  }

  // ── Etiquetas de puntaje ─────────────────────────────────────────
  void _drawScoreLabels(Canvas canvas, Size size, List<double> zw) {
    final w = size.width;
    final h = size.height;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    double xCursor = 0;
    for (int i = 0; i < _zoneScores.length; i++) {
      final score = _zoneScores[i];
      if (score != 0) {
        final cx = xCursor + zw[i] / 2;
        final labelColor =
            score >= 4 ? AppColors.white : const Color(0xFF555555);
        tp.text = TextSpan(
          text: '$score',
          style: TextStyle(
            color: labelColor,
            fontSize: w * 0.045,
            fontWeight: FontWeight.bold,
          ),
        );
        tp.layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, h * 0.03));
        tp.paint(canvas, Offset(cx - tp.width / 2, h * 0.92));
      }
      xCursor += zw[i];
    }
  }

  // ── "FUERA DE ZONA" en extremos izq/der ──────────────────────────
  void _drawOutOfZoneLabels(Canvas canvas, Size size, List<double> zw) {
    final h = size.height;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final fontSize = zw[0] * 0.27;

    void drawVertical(String text, Offset offset) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(-pi / 2);
      tp.text = TextSpan(
        text: text,
        style: TextStyle(
          color: AppColors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Extremo izquierdo
    drawVertical('FUERA DE ZONA', Offset(zw[0] / 2, h / 2));

    // Extremo derecho
    final rightStart = zw.sublist(0, zw.length - 1).fold(0.0, (a, b) => a + b);
    drawVertical('FUERA DE ZONA', Offset(rightStart + zw.last / 2, h / 2));
  }

  // ── Las 5 boccias (b1=azul/roja exteriores, jack verde al centro) ─
  void _drawFiveBocciaBalls(
      Canvas canvas, Size size, List<double> zw, double ballRowY) {
    // Centro de cada zona por acumulación
    double acc = 0;
    final centers = <double>[];
    for (final z in zw) {
      centers.add(acc + z / 2);
      acc += z;
    }

    // El radio queda contenido dentro de la zona de bola
    final ballRadius = zw[1] * 0.46;

    // Bolas en los índices de zona 1, 3, 5(jack), 7, 9
    // Colores alternados: azul, rojo, jack, azul, rojo
    _drawDecorativeBall(canvas, Offset(centers[1], ballRowY), ballRadius,
        const Color(0xFF2E5B8B)); // azul exterior izq (score 1)
    _drawDecorativeBall(canvas, Offset(centers[3], ballRowY), ballRadius,
        const Color(0xFFB03A2E)); // roja interior izq (score 3)
    _drawGreenJackBall(canvas, Offset(centers[5], ballRowY), ballRadius);
    _drawDecorativeBall(canvas, Offset(centers[7], ballRowY), ballRadius,
        const Color(0xFFB03A2E)); // roja interior der (score 3)
    _drawDecorativeBall(canvas, Offset(centers[9], ballRowY), ballRadius,
        const Color(0xFF2E5B8B)); // azul exterior der (score 1)

    // Mini-etiquetas de puntaje debajo de cada bola
    final labelY = ballRowY + ballRadius + 4;
    _miniLabel(canvas, '1', centers[1], labelY,
        const Color(0xFF2E5B8B), size.width);
    _miniLabel(canvas, '3', centers[3], labelY,
        const Color(0xFFB03A2E), size.width);
    _miniLabel(canvas, '5', centers[5], labelY,
        const Color(0xFF2E7A2E), size.width);
    _miniLabel(canvas, '3', centers[7], labelY,
        const Color(0xFFB03A2E), size.width);
    _miniLabel(canvas, '1', centers[9], labelY,
        const Color(0xFF2E5B8B), size.width);
  }

  void _miniLabel(Canvas canvas, String text, double cx, double top,
      Color color, double totalWidth) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: totalWidth * 0.031,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, top));
  }

  // ── Green jack ball ───────────────────────────────────────────────
  void _drawGreenJackBall(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      Offset(center.dx + 1, center.dy + 1.5),
      radius,
      Paint()
        ..color = AppColors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: const [Color(0xFF7EC87E), Color(0xFF4A8B4A), Color(0xFF2E6B2E)],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final seamPaint = Paint()
      ..color = const Color(0xFF1A4A1A).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.07;
    canvas.drawPath(
        Path()
          ..moveTo(center.dx - radius * 0.6, center.dy - radius * 0.5)
          ..quadraticBezierTo(center.dx, center.dy - radius * 0.8,
              center.dx + radius * 0.6, center.dy - radius * 0.5),
        seamPaint);
    canvas.drawPath(
        Path()
          ..moveTo(center.dx - radius * 0.6, center.dy + radius * 0.5)
          ..quadraticBezierTo(center.dx, center.dy + radius * 0.8,
              center.dx + radius * 0.6, center.dy + radius * 0.5),
        seamPaint);
    canvas.drawPath(
        Path()
          ..moveTo(center.dx - radius * 0.5, center.dy - radius * 0.6)
          ..quadraticBezierTo(center.dx - radius * 0.3, center.dy,
              center.dx - radius * 0.5, center.dy + radius * 0.6),
        seamPaint);
    canvas.drawPath(
        Path()
          ..moveTo(center.dx + radius * 0.5, center.dy - radius * 0.6)
          ..quadraticBezierTo(center.dx + radius * 0.3, center.dy,
              center.dx + radius * 0.5, center.dy + radius * 0.6),
        seamPaint);
    canvas.drawCircle(center, radius * 0.35,
        Paint()..color = AppColors.white.withValues(alpha: 0.85));
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.45, center.dy - radius * 0.3)
        ..quadraticBezierTo(center.dx, center.dy - radius * 0.7,
            center.dx + radius * 0.45, center.dy - radius * 0.3),
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.25
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFF1A4A1A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.07);
    final tp = TextPainter(
      text: TextSpan(
        text: '5',
        style: TextStyle(
          color: AppColors.white,
          fontSize: radius * 0.9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  // ── Bola decorativa ───────────────────────────────────────────────
  void _drawDecorativeBall(
      Canvas canvas, Offset center, double radius, Color baseColor) {
    final lighter = Color.lerp(baseColor, AppColors.white, 0.3)!;
    final darker = Color.lerp(baseColor, AppColors.black, 0.2)!;
    canvas.drawCircle(
      Offset(center.dx + 1, center.dy + 1),
      radius,
      Paint()
        ..color = AppColors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [lighter, baseColor, darker],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final seamPaint = Paint()
      ..color = darker.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06;
    canvas.drawPath(
        Path()
          ..moveTo(center.dx - radius * 0.6, center.dy - radius * 0.5)
          ..quadraticBezierTo(center.dx, center.dy - radius * 0.8,
              center.dx + radius * 0.6, center.dy - radius * 0.5),
        seamPaint);
    canvas.drawPath(
        Path()
          ..moveTo(center.dx - radius * 0.6, center.dy + radius * 0.5)
          ..quadraticBezierTo(center.dx, center.dy + radius * 0.8,
              center.dx + radius * 0.6, center.dy + radius * 0.5),
        seamPaint);
    canvas.drawPath(
        Path()
          ..moveTo(center.dx - radius * 0.5, center.dy - radius * 0.6)
          ..quadraticBezierTo(center.dx - radius * 0.3, center.dy,
              center.dx - radius * 0.5, center.dy + radius * 0.6),
        seamPaint);
    canvas.drawPath(
        Path()
          ..moveTo(center.dx + radius * 0.5, center.dy - radius * 0.6)
          ..quadraticBezierTo(center.dx + radius * 0.3, center.dy,
              center.dx + radius * 0.5, center.dy + radius * 0.6),
        seamPaint);
    canvas.drawCircle(center, radius * 0.35,
        Paint()..color = AppColors.white.withValues(alpha: 0.85));
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.45, center.dy - radius * 0.3)
        ..quadraticBezierTo(center.dx, center.dy - radius * 0.7,
            center.dx + radius * 0.45, center.dy - radius * 0.3),
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.25
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = darker
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.06);
  }

  // ── Pelota colocada por el usuario ────────────────────────────────
  void _drawSelectedBall(Canvas canvas, Size size, Offset position) {
    final w = size.width;
    final ballX = (position.dx / 100) * w;
    final ballY = (position.dy / 100) * size.height;
    final ballRadius = w * 0.04;

    final arrowStartY = ballY - ballRadius - 2;
    final arrowEndY = size.height * 0.28 - w * 0.065;

    if (arrowStartY > arrowEndY) {
      const arrowColor = Color(0xFF477D9E);
      final strokeW = w * 0.018;
      canvas.drawLine(
        Offset(ballX, arrowStartY),
        Offset(ballX, arrowEndY),
        Paint()
          ..color = arrowColor
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      const headLen = 12.0;
      const headAngle = 0.42;
      const angle = -pi / 2;
      canvas.drawPath(
        Path()
          ..moveTo(ballX, arrowEndY)
          ..lineTo(ballX - headLen * cos(angle - headAngle),
              arrowEndY - headLen * sin(angle - headAngle))
          ..moveTo(ballX, arrowEndY)
          ..lineTo(ballX - headLen * cos(angle + headAngle),
              arrowEndY - headLen * sin(angle + headAngle)),
        Paint()
          ..color = arrowColor
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    canvas.drawCircle(
      Offset(ballX + 1.5, ballY + 1.5),
      ballRadius,
      Paint()
        ..color = AppColors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: const [Color(0xFFFF6B35), Color(0xFFEF4444), Color(0xFFCC2222)],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
            Rect.fromCircle(center: Offset(ballX, ballY), radius: ballRadius)),
    );
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius + 3,
      Paint()
        ..color = const Color(0xFFFF6B35).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
        Offset(ballX, ballY), ballRadius * 0.3, Paint()..color = AppColors.white);
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius,
      Paint()
        ..color = const Color(0xFFAA1111)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.003,
    );
  }

  // ── Línea punteada ────────────────────────────────────────────────
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint,
      {double dashWidth = 4, double dashSpace = 4}) {
    final totalDistance = (p2 - p1).distance;
    final dx = (p2.dx - p1.dx) / totalDistance;
    final dy = (p2.dy - p1.dy) / totalDistance;
    double d = 0;
    while (d < totalDistance) {
      final end = min(d + dashWidth, totalDistance);
      canvas.drawLine(Offset(p1.dx + dx * d, p1.dy + dy * d),
          Offset(p1.dx + dx * end, p1.dy + dy * end), paint);
      d += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DirectionCourtPainter oldDelegate) =>
      oldDelegate.selection != selection;
}
