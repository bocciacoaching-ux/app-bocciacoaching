import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ForceTargetWidget extends StatefulWidget {
  final void Function(double x, double y, int score)? onTargetTap;
  final Offset? selection;
  final double size;

  const ForceTargetWidget({
    super.key,
    this.onTargetTap,
    this.selection,
    this.size = 300.0,
  });

  @override
  State<ForceTargetWidget> createState() => ForceTargetWidgetState();
}

class ForceTargetWidgetState extends State<ForceTargetWidget> {
  Offset? _internalSelection;

  Offset? get selection => widget.selection ?? _internalSelection;

  /// Score zones (all values in relative coordinates 0-100, center at 50,50):
  ///
  /// Regla: si la pelota TOCA el borde externo de una zona, obtiene el puntaje
  /// de la zona exterior (una menos).
  ///
  /// 5 pts – pelota completamente dentro del círculo rojo (sin tocar borde)
  /// 4 pts – pelota completamente dentro del círculo blanco (sin tocar borde),
  ///         incluye tocar borde externo del círculo rojo
  /// 3 pts – pelota completamente dentro del cuadrado azul (sin tocar línea),
  ///         incluye tocar borde externo del círculo blanco
  /// 2 pts – pelota toca la línea azul
  /// 1 pt  – pelota completamente dentro de la zona gris-azul (sin tocar borde externo)
  /// 0 pts – pelota toca o está fuera del borde externo de la zona gris-azul
  int _calculateScore(double relativeX, double relativeY) {
    final dx = relativeX - 50;
    final dy = relativeY - 50;
    final distance = sqrt(dx * dx + dy * dy);

    const ballRadius = 4.5;

    // Radios de las zonas circulares
    const redCircleRadius = 10.0;    // circle5Radius = w * 0.14
    const whiteCircleRadius = 28.0;  // circle4Radius = w * 0.28

    // Bordes de las zonas cuadradas
    const innerSquareHalfSize = 37.0; // borde línea azul
    const outerSquareHalfSize = 48.0; // borde zona gris-azul

    // ── Distancias clave de la pelota ──
    // Borde más lejano de la pelota al centro (para verificar "completamente dentro")
    final ballFarEdge = distance + ballRadius;

    // Distancias al borde del cuadrado (la máxima de dx/dy + ballRadius)
    final ballFarEdgeX = dx.abs() + ballRadius;
    final ballFarEdgeY = dy.abs() + ballRadius;
    final ballNearEdgeX = dx.abs() - ballRadius;
    final ballNearEdgeY = dy.abs() - ballRadius;

    // ── 5 pts ── pelota completamente dentro del círculo rojo
    if (ballFarEdge < redCircleRadius) return 5;

    // ── 4 pts ── pelota completamente dentro del círculo blanco
    //             (incluye caso de tocar borde externo del rojo)
    if (ballFarEdge < whiteCircleRadius) return 4;

    // ── 3 pts ── pelota completamente dentro del cuadrado azul sin tocar la línea
    //             (incluye caso de tocar borde externo del círculo blanco)
    if (ballFarEdgeX < innerSquareHalfSize &&
        ballFarEdgeY < innerSquareHalfSize) return 3;

    // ── 2 pts ── pelota toca la línea azul
    //             (alguna parte de la pelota está sobre la línea)
    if (ballNearEdgeX <= innerSquareHalfSize ||
        ballNearEdgeY <= innerSquareHalfSize) {
      // El centro está lo suficientemente cerca para que la pelota toque la línea
      if (dx.abs() <= innerSquareHalfSize + ballRadius &&
          dy.abs() <= innerSquareHalfSize + ballRadius) return 2;
    }

    // ── 1 pt ── pelota completamente dentro de la zona gris-azul sin tocar borde externo
    if (ballFarEdgeX < outerSquareHalfSize &&
        ballFarEdgeY < outerSquareHalfSize) return 1;

    // ── 0 pts ── pelota toca o está fuera del borde externo de la zona gris-azul
    return 0;
  }

  void _handleTapDown(TapDownDetails details) {
    final localPosition = details.localPosition;
    final relativeX = (localPosition.dx / widget.size) * 100;
    final relativeY = (localPosition.dy / widget.size) * 100;

    int score = _calculateScore(relativeX, relativeY);

    setState(() {
      _internalSelection = Offset(relativeX, relativeY);
    });

    widget.onTargetTap?.call(relativeX, relativeY, score);
  }

  void reset() {
    setState(() {
      _internalSelection = null;
    });
  }

  void setPosition(double x, double y, int score) {
    setState(() {
      _internalSelection = Offset(x, y);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.neutral7),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: ForceTargetPainter(selection: selection),
            ),
          ),
        ),
      ),
    );
  }
}

class ForceTargetPainter extends CustomPainter {
  final Offset? selection;

  ForceTargetPainter({this.selection});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;

    // ── 1) Background: zona de 0 puntos (color crema) ─────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFFFF8E1),
    );

    // ── 2) Outer grey border (the outer perimeter line) ────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = const Color(0xFFBDBDBD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.008,
    );

    // ── 3) Zone 1 pt: light blue-grey square (96% of canvas) ──────
    final zone1Size = w * 0.96;
    final zone1Rect = Rect.fromCenter(center: center, width: zone1Size, height: zone1Size);
    canvas.drawRect(zone1Rect, Paint()..color = const Color(0xFFECEFF1));

    // ── 4) Zone 3 pts: inner cream square with thin cyan border ────
    // Tamaño: 74% del canvas (radio blanco 28% + diámetro de 1 bola 9% = 37% × 2 = 74%)
    final innerSquareSize = w * 0.74;
    final innerSquareRect = Rect.fromCenter(center: center, width: innerSquareSize, height: innerSquareSize);
    
    // Fill interior with cream
    canvas.drawRect(innerSquareRect, Paint()..color = const Color(0xFFFFF8E1));
    
    // Draw thin cyan border line
    canvas.drawRect(
      innerSquareRect,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.008,
    );

    // ── 5) Zone 4 pts: white circle (radius ≈ 28% of width) ───────
    final circle4Radius = w * 0.28;
    canvas.drawCircle(center, circle4Radius, Paint()..color = AppColors.white);
    canvas.drawCircle(
      center,
      circle4Radius,
      Paint()
        ..color = const Color(0xFF424242)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.004,
    );

    // ── 6) Zone 5 pts: red/pink circle (radius ≈ 14% of width) ────
    final circle5Radius = w * 0.14;
    canvas.drawCircle(
      center,
      circle5Radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFFFF8A80),
            Color(0xFFEF5350),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: circle5Radius)),
    );
    canvas.drawCircle(
      center,
      circle5Radius,
      Paint()
        ..color = const Color(0xFFE53935)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.004,
    );

    // ── 7) Dashed red crosshair lines ──────────────────────────────
    final axisPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = w * 0.005
      ..style = PaintingStyle.stroke;

    // Horizontal
    _drawDashedLine(
      canvas,
      Offset(w * 0.04, center.dy),
      Offset(w * 0.96, center.dy),
      axisPaint,
      dashWidth: w * 0.025,
      dashSpace: w * 0.012,
    );
    // Vertical
    _drawDashedLine(
      canvas,
      Offset(center.dx, h * 0.04),
      Offset(center.dx, h * 0.96),
      axisPaint,
      dashWidth: w * 0.025,
      dashSpace: w * 0.012,
    );

    // ── 8) Labels ──────────────────────────────────────────────────
    _drawLabels(canvas, size, center);

    // ── 9) Boccia ball (if user has tapped) ────────────────────────
    if (selection != null) {
      _drawBocciaBall(canvas, size, selection!);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashWidth = 4,
    double dashSpace = 4,
  }) {
    final totalDistance = (p2 - p1).distance;
    final dx = (p2.dx - p1.dx) / totalDistance;
    final dy = (p2.dy - p1.dy) / totalDistance;
    double currentDist = 0;
    while (currentDist < totalDistance) {
      final end = min(currentDist + dashWidth, totalDistance);
      canvas.drawLine(
        Offset(p1.dx + dx * currentDist, p1.dy + dy * currentDist),
        Offset(p1.dx + dx * end, p1.dy + dy * end),
        paint,
      );
      currentDist += dashWidth + dashSpace;
    }
  }

  void _drawLabels(Canvas canvas, Size size, Offset center) {
    final w = size.width;
    final h = size.height;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawText(String text, Offset offset, double fontSize, Color color, {FontWeight weight = FontWeight.bold}) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        offset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    const labelColor = Color(0xFF424242);
    final labelSize = w * 0.038;

    // "5 pts" – inside the red circle, slightly below center
    drawText('5 pts', Offset(center.dx, center.dy + w * 0.04), labelSize, labelColor);

    // "4 pts" – to the right of the white circle, on the horizontal dashed line
    drawText('4 pts', Offset(w * 0.72, center.dy - w * 0.02), labelSize, labelColor);

    // "3 pts" – top-right area inside the blue square
    drawText('3 pts', Offset(w * 0.77, h * 0.20), labelSize, labelColor);

    // "2 pts" – near the top-right of the blue border
    drawText('2 pts', Offset(w * 0.80, h * 0.17), labelSize * 0.85, const Color(0xFF616161));

    // "1 pt" – top-right corner in the cream zone
    drawText('1 pt', Offset(w * 0.90, h * 0.07), labelSize * 0.85, const Color(0xFF757575));
  }

  void _drawBocciaBall(Canvas canvas, Size size, Offset position) {
    final w = size.width;
    final ballX = (position.dx / 100) * w;
    final ballY = (position.dy / 100) * size.height;
    final ballRadius = w * 0.038;

    // Shadow
    canvas.drawCircle(
      Offset(ballX + 1.5, ballY + 1.5),
      ballRadius,
      Paint()
        ..color = AppColors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Main body – red gradient
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [
            Color(0xFFEF4444),
            Color(0xFFDC2626),
            Color(0xFFB91C1C),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(ballX, ballY), radius: ballRadius)),
    );

    // Seams
    final seamPaint = Paint()
      ..color = const Color(0xFF7F1D1D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.0025;

    // Top seam
    canvas.drawPath(
      Path()
        ..moveTo(ballX - ballRadius * 0.7, ballY - ballRadius * 0.5)
        ..quadraticBezierTo(ballX, ballY - ballRadius * 0.85, ballX + ballRadius * 0.7, ballY - ballRadius * 0.5),
      seamPaint,
    );

    // Bottom seam
    canvas.drawPath(
      Path()
        ..moveTo(ballX - ballRadius * 0.7, ballY + ballRadius * 0.5)
        ..quadraticBezierTo(ballX, ballY + ballRadius * 0.85, ballX + ballRadius * 0.7, ballY + ballRadius * 0.5),
      seamPaint,
    );

    // Left vertical seam
    canvas.drawPath(
      Path()
        ..moveTo(ballX - ballRadius * 0.5, ballY - ballRadius * 0.7)
        ..quadraticBezierTo(ballX - ballRadius * 0.35, ballY, ballX - ballRadius * 0.5, ballY + ballRadius * 0.7),
      seamPaint,
    );

    // Right vertical seam
    canvas.drawPath(
      Path()
        ..moveTo(ballX + ballRadius * 0.5, ballY - ballRadius * 0.7)
        ..quadraticBezierTo(ballX + ballRadius * 0.35, ballY, ballX + ballRadius * 0.5, ballY + ballRadius * 0.7),
      seamPaint,
    );

    // Center logo circle (white)
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius * 0.4,
      Paint()..color = AppColors.white.withValues(alpha: 0.9),
    );

    // Highlight (gloss)
    final highlightPath = Path()
      ..moveTo(ballX - ballRadius * 0.5, ballY - ballRadius * 0.35)
      ..quadraticBezierTo(ballX, ballY - ballRadius * 0.8, ballX + ballRadius * 0.5, ballY - ballRadius * 0.35);
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ballRadius * 0.3
        ..strokeCap = StrokeCap.round,
    );

    // Outer border
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius,
      Paint()
        ..color = const Color(0xFF991B1B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.003,
    );
  }

  @override
  bool shouldRepaint(ForceTargetPainter oldDelegate) {
    return oldDelegate.selection != selection;
  }
}
