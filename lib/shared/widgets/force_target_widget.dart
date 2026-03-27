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
  /// 5 pts – pelota dentro del círculo verde central (oscuro)
  /// 4 pts – pelota dentro del círculo verde exterior (claro)
  /// 3 pts – pelota dentro del cuadrado verde (sin tocar la línea del cuadro)
  /// 2 pts – pelota toca/está sobre la línea del cuadro
  /// 1 pt  – pelota fuera del cuadro pero dentro de la zona crema
  /// 0 pts – pelota en la franja ámbar (FUERA DE ZONA)
  int _calculateScore(double relativeX, double relativeY) {
    final dx = relativeX - 50;
    final dy = relativeY - 50;
    final distance = sqrt(dx * dx + dy * dy);

    const ballRadius = 4.5;

    // Radios de las zonas circulares (basados en painter)
    const greenCenterRadius = 14.0;  // circle5Radius = w * 0.14
    const greenOuterRadius = 24.0;   // circle4Radius = w * 0.24

    // Borde del cuadro interior (half-size)
    const squareHalfSize = 34.0;     // innerSquareSize = w * 0.68 → half = 34%

    // Borde de la zona crema (half-size)
    const creamHalfSize = 44.0;      // zone1Inset = w * 0.06 → half = 50 - 6 = 44%

    // Grosor de la línea del cuadro en coordenadas relativas
    const lineHalfThickness = 1.0;

    // ── Distancias clave de la pelota ──
    final ballFarEdge = distance + ballRadius;
    final ballFarEdgeX = dx.abs() + ballRadius;
    final ballFarEdgeY = dy.abs() + ballRadius;
    final ballNearEdgeX = dx.abs() - ballRadius;
    final ballNearEdgeY = dy.abs() - ballRadius;

    // ── 5 pts ── pelota dentro del círculo verde central
    if (ballFarEdge <= greenCenterRadius) return 5;

    // ── 4 pts ── pelota dentro del círculo verde exterior
    if (ballFarEdge <= greenOuterRadius) return 4;

    // ── 3 pts ── pelota completamente dentro del cuadrado verde
    //             (sin tocar la línea del borde)
    if (ballFarEdgeX < squareHalfSize - lineHalfThickness &&
        ballFarEdgeY < squareHalfSize - lineHalfThickness) return 3;

    // ── 2 pts ── pelota toca/está sobre la línea del cuadro
    //             (alguna parte de la pelota está sobre la línea del borde)
    if (ballNearEdgeX <= squareHalfSize + lineHalfThickness &&
        ballNearEdgeY <= squareHalfSize + lineHalfThickness) {
      // Verificar que la pelota realmente toca la línea
      final touchesLineX = ballFarEdgeX >= squareHalfSize - lineHalfThickness;
      final touchesLineY = ballFarEdgeY >= squareHalfSize - lineHalfThickness;
      final insideX = ballNearEdgeX <= squareHalfSize + lineHalfThickness;
      final insideY = ballNearEdgeY <= squareHalfSize + lineHalfThickness;
      if ((touchesLineX || touchesLineY) && insideX && insideY) return 2;
    }

    // ── 1 pt ── pelota fuera del cuadro, dentro de la zona crema
    if (ballFarEdgeX <= creamHalfSize &&
        ballFarEdgeY <= creamHalfSize) return 1;

    // ── 0 pts ── FUERA DE ZONA (franja ámbar)
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

    // ── 0) Outer amber border (FUERA DE ZONA = 0 pts) ──────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFC68B3F),
    );

    // ── 1) Zone 1: cream area inside amber border ──────────────────
    final zone1Inset = w * 0.06;
    final zone1Rect = Rect.fromLTWH(
      zone1Inset, zone1Inset,
      w - zone1Inset * 2, h - zone1Inset * 2,
    );
    canvas.drawRect(zone1Rect, Paint()..color = const Color(0xFFF5E6C8));

    // ── 3) Zone 3: light green square (inside the square line) ─────
    //    The square line itself is zone 2 (drawn on top as stroke)
    final innerSquareSize = w * 0.68;
    final innerSquareRect = Rect.fromCenter(
      center: center,
      width: innerSquareSize,
      height: innerSquareSize,
    );
    canvas.drawRect(
      innerSquareRect,
      Paint()..color = const Color(0xFFDAE5C5),
    );

    // ── 4) Zone 4: lighter green circle ────────────────────────────
    final circle4Radius = w * 0.24;
    canvas.drawCircle(
      center,
      circle4Radius,
      Paint()..color = const Color(0xFFC2D6A8),
    );

    // ── 5) Zone 5: dark green circle (center) ─────────────────────
    final circle5Radius = w * 0.14;
    canvas.drawCircle(
      center,
      circle5Radius,
      Paint()..color = const Color(0xFF4E9A3D),
    );

    // ── 2) Zone 2: the square border line (stroke) ─────────────────
    canvas.drawRect(
      innerSquareRect,
      Paint()
        ..color = const Color(0xFFBDB89A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.006,
    );

    // ── Dashed black crosshair lines ───────────────────────────────
    final axisPaint = Paint()
      ..color = const Color(0xFF2C2C2C)
      ..strokeWidth = w * 0.005
      ..style = PaintingStyle.stroke;

    // Vertical (full height of cream zone)
    _drawDashedLine(
      canvas,
      Offset(center.dx, zone1Rect.top),
      Offset(center.dx, zone1Rect.bottom),
      axisPaint,
      dashWidth: w * 0.025,
      dashSpace: w * 0.015,
    );
    // Horizontal (full width — extends into amber border)
    _drawDashedLine(
      canvas,
      Offset(0, center.dy),
      Offset(w, center.dy),
      axisPaint,
      dashWidth: w * 0.025,
      dashSpace: w * 0.015,
    );

    // ── Labels ─────────────────────────────────────────────────────
    _drawLabels(canvas, size, center);

    // ── Boccia ball (if user has tapped) ───────────────────────────
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
    final labelSize = w * 0.048;
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

    // Zone number labels (positioned like the reference image)
    // "0" – top-right corner in amber zone
    drawText('0', Offset(w * 0.94, h * 0.04), labelSize, fueraColor);

    // "1" – top-right area in cream zone (between amber border and square line)
    drawText('1', Offset(w * 0.87, h * 0.11), labelSize, labelColor);

    // "2" – on the square line, top-right corner area
    drawText('2', Offset(w * 0.78, h * 0.19), labelSize, labelColor);

    // "3" – inside the green square, upper-right
    drawText('3', Offset(w * 0.70, h * 0.27), labelSize, labelColor);

    // "4" – inside the lighter green circle area
    drawText('4', Offset(w * 0.61, h * 0.36), labelSize, labelColor);

    // "5" – inside the dark green center circle
    drawText('5', Offset(center.dx - w * 0.02, center.dy + w * 0.02), labelSize, const Color(0xFFFFFFFF));
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
