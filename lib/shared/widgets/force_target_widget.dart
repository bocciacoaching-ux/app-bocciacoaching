import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
  /// 5 pts – pelota dentro del círculo verde central
  /// 4 pts – pelota dentro del círculo verde medio
  /// 3 pts – pelota dentro del cuadrado verde claro
  /// 2 pts – pelota dentro del cuadrado beige interior
  /// 1 pt  – pelota dentro del cuadrado crema exterior
  /// 0 pts – pelota en la zona ámbar exterior (FUERA DE ZONA)
  int _calculateScore(double relativeX, double relativeY) {
    final dx = relativeX - 50;
    final dy = relativeY - 50;
    final distance = sqrt(dx * dx + dy * dy);

    const ballRadius = 4.5;

    // Radios de las zonas circulares (basados en painter)
    const greenCenterRadius = 12.0;  // circle5Radius = w * 0.12
    const greenOuterRadius = 20.0;   // circle4Radius = w * 0.20

    // Bordes de las zonas cuadradas (half-size basado en painter)
    const zone3HalfSize = 26.0;   // zone3Size = w * 0.52
    const zone2HalfSize = 32.0;   // zone2Size = w * 0.64
    const zone1HalfSize = 39.0;   // zone1Size = w * 0.78

    // ── Distancias clave de la pelota ──
    final ballFarEdge = distance + ballRadius;
    final ballFarEdgeX = dx.abs() + ballRadius;
    final ballFarEdgeY = dy.abs() + ballRadius;

    // ── 5 pts ── pelota dentro del círculo verde central
    if (ballFarEdge <= greenCenterRadius) return 5;

    // ── 4 pts ── pelota dentro del círculo verde exterior
    if (ballFarEdge <= greenOuterRadius) return 4;

    // ── 3 pts ── pelota dentro del cuadrado verde
    if (ballFarEdgeX <= zone3HalfSize &&
        ballFarEdgeY <= zone3HalfSize) return 3;

    // ── 2 pts ── pelota dentro del cuadrado beige
    if (ballFarEdgeX <= zone2HalfSize &&
        ballFarEdgeY <= zone2HalfSize) return 2;

    // ── 1 pt ── pelota dentro del cuadrado crema
    if (ballFarEdgeX <= zone1HalfSize &&
        ballFarEdgeY <= zone1HalfSize) return 1;

    // ── 0 pts ── fuera de zona
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

    // ── 1) Outer amber border (FUERA DE ZONA area) ─────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFC68B3F),
    );

    // ── 2) Zone 0: cream area inside the amber border ──────────────
    final zone0Inset = w * 0.06;
    final zone0Rect = Rect.fromLTWH(zone0Inset, zone0Inset, w - zone0Inset * 2, h - zone0Inset * 2);
    canvas.drawRect(zone0Rect, Paint()..color = const Color(0xFFF5E6C8));

    // ── 3) Zone 1: light tan square ────────────────────────────────
    final zone1Size = w * 0.78;
    final zone1Rect = Rect.fromCenter(center: center, width: zone1Size, height: zone1Size);
    canvas.drawRect(zone1Rect, Paint()..color = const Color(0xFFEDE4C8));

    // ── 4) Zone 2: lighter inner square ────────────────────────────
    final zone2Size = w * 0.64;
    final zone2Rect = Rect.fromCenter(center: center, width: zone2Size, height: zone2Size);
    canvas.drawRect(zone2Rect, Paint()..color = const Color(0xFFE2DEBC));

    // ── 5) Zone 3: light green square ──────────────────────────────
    final zone3Size = w * 0.52;
    final zone3Rect = Rect.fromCenter(center: center, width: zone3Size, height: zone3Size);
    canvas.drawRect(zone3Rect, Paint()..color = const Color(0xFFD4DEB0));

    // ── 6) Zone 4: green circle ────────────────────────────────────
    final circle4Radius = w * 0.20;
    canvas.drawCircle(
      center,
      circle4Radius,
      Paint()..color = const Color(0xFFB8CFA0),
    );
    canvas.drawCircle(
      center,
      circle4Radius,
      Paint()
        ..color = const Color(0xFF8FB87A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.003,
    );

    // ── 7) Zone 5: dark green circle (center) ─────────────────────
    final circle5Radius = w * 0.12;
    canvas.drawCircle(
      center,
      circle5Radius,
      Paint()..color = const Color(0xFF5BA34B),
    );
    canvas.drawCircle(
      center,
      circle5Radius,
      Paint()
        ..color = const Color(0xFF4A8A3D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.003,
    );

    // ── 8) Dashed black crosshair lines ────────────────────────────
    final axisPaint = Paint()
      ..color = const Color(0xFF2C2C2C)
      ..strokeWidth = w * 0.004
      ..style = PaintingStyle.stroke;

    // Vertical
    _drawDashedLine(
      canvas,
      Offset(center.dx, zone0Rect.top),
      Offset(center.dx, zone0Rect.bottom),
      axisPaint,
      dashWidth: w * 0.025,
      dashSpace: w * 0.012,
    );
    // Horizontal
    _drawDashedLine(
      canvas,
      Offset(zone0Rect.left, center.dy),
      Offset(zone0Rect.right, center.dy),
      axisPaint,
      dashWidth: w * 0.025,
      dashSpace: w * 0.012,
    );

    // ── 9) Labels ──────────────────────────────────────────────────
    _drawLabels(canvas, size, center);

    // ── 10) Boccia ball (if user has tapped) ───────────────────────
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

    void drawRotatedText(String text, Offset offset, double fontSize, Color color, double angle) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(angle);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    const labelColor = Color(0xFF424242);
    final labelSize = w * 0.042;
    final fueraSize = w * 0.032;
    const fueraColor = Color(0xFFFFFFFF);

    // "FUERA DE ZONA" labels on amber border
    // Top
    drawText('FUERA DE ZONA', Offset(center.dx, w * 0.03), fueraSize, fueraColor);
    // Bottom
    drawText('FUERA DE ZONA', Offset(center.dx, h - w * 0.03), fueraSize, fueraColor);
    // Left (rotated)
    drawRotatedText('FUERA DE ZONA', Offset(w * 0.03, center.dy), fueraSize, fueraColor, -3.14159 / 2);
    // Right (rotated)
    drawRotatedText('FUERA DE ZONA', Offset(w - w * 0.03, center.dy), fueraSize, fueraColor, 3.14159 / 2);

    // Zone number labels
    // "0" – top-right corner in amber zone
    drawText('0', Offset(w * 0.93, h * 0.07), labelSize, fueraColor);

    // "1" – top-right area in cream zone
    drawText('1', Offset(w * 0.85, h * 0.13), labelSize, labelColor);

    // "2" – inside zone 2, top-right
    drawText('2', Offset(w * 0.77, h * 0.20), labelSize, labelColor);

    // "3" – inside zone 3, top-right
    drawText('3', Offset(w * 0.68, h * 0.28), labelSize, labelColor);

    // "4" – inside zone 4, to the right of center
    drawText('4', Offset(w * 0.62, h * 0.38), labelSize, labelColor);

    // "5" – inside the center green circle
    drawText('5', Offset(center.dx, center.dy + w * 0.02), labelSize, const Color(0xFFFFFFFF));
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
