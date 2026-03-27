import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget that draws the Boccia direction evaluation court.
///
/// The real-life component measures 60 cm wide with 6 boccia balls
/// (each ~10 cm). The scoring zones are **vertical stripes**:
/// - Center stripe → 5 pts
/// - Stripes immediately to each side → 4 pts
/// - Next pair → 3 pts, then 2, 1, 0.
///
/// Total: 11 vertical stripes (one center + 5 on each side).
///
/// The user taps to place a ball. The widget returns the coordinates
/// and the calculated stripe score via [onTargetTap].
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

  /// Number of stripes on each side of center (excluding center).
  static const int _sidesCount = 5;

  /// Total number of stripes: 1 center + 5 left + 5 right = 11.
  static const int _totalStripes = 2 * _sidesCount + 1;

  /// Calculates the zone score (0-5) based on relative X coordinate.
  ///
  /// Each stripe occupies 1/_totalStripes of the widget width.
  /// The center stripe (index 5) = 5 pts, adjacent (4,6) = 4 pts, etc.
  /// Ball radius is taken into account — the score is determined by
  /// where the **center** of the placed ball falls.
  int _calculateScore(double relativeX, double _relativeY) {
    // Width percentage occupied by each stripe
    const stripeWidth = 100.0 / _totalStripes; // ~9.09 %

    // Determine which stripe index the center of the ball falls in
    int stripeIndex = (relativeX / stripeWidth).floor();
    stripeIndex = stripeIndex.clamp(0, _totalStripes - 1);

    // Map stripe index to score. Center stripe is index 5 → score 5.
    // Distance from center index gives score: score = 5 - |index - 5|.
    final distFromCenter = (stripeIndex - _sidesCount).abs();
    final score = (_sidesCount - distFromCenter).clamp(0, 5);

    return score;
  }

  void _handleTapDown(TapDownDetails details) {
    final localPosition = details.localPosition;
    // The widget aspect ratio is 4:5 (width:height) so we scale accordingly
    final relativeX = (localPosition.dx / widget.size) * 100;
    final relativeY = (localPosition.dy / (widget.size * 1.25)) * 100;

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
    final height = widget.size * 1.25; // 4:5 aspect ratio
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
              )
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

class DirectionCourtPainter extends CustomPainter {
  final Offset? selection;

  DirectionCourtPainter({this.selection});

  /// Stripe scores mapped from left to right (11 stripes).
  /// Index:  0  1  2  3  4  5  6  7  8  9  10
  /// Score:  0  1  2  3  4  5  4  3  2  1   0
  static const List<int> _stripeScores = [0, 1, 2, 3, 4, 5, 4, 3, 2, 1, 0];

  /// Colours per score for the stripe fill (lighter in center, darker outside).
  static const Map<int, Color> _stripeColors = {
    0: Color(0xFFC9944A), // brown – out of zone
    1: Color(0xFFE8D5A8), // light tan
    2: Color(0xFFE0D49E), // warm beige
    3: Color(0xFFD4CC8E), // olive-beige
    4: Color(0xFFC5D6A0), // light green
    5: Color(0xFF8FBF6F), // green – center/jack zone
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;
    final centerY = h / 2;
    final stripeW = w / 11;

    // ── 1) Draw vertical stripes ──────────────────────────────────
    for (int i = 0; i < 11; i++) {
      final score = _stripeScores[i];
      final rect = Rect.fromLTWH(stripeW * i, 0, stripeW, h);
      canvas.drawRect(rect, Paint()..color = _stripeColors[score]!);
    }

    // ── 2) Stripe border lines ────────────────────────────────────
    final borderPaint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.45)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 11; i++) {
      final x = stripeW * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), borderPaint);
    }

    // ── 3) Score labels at top and bottom of each stripe ──────────
    _drawStripeScoreLabels(canvas, size, stripeW);

    // ── 4) Dashed horizontal center line ──────────────────────────
    final axisPaint = Paint()
      ..color = const Color(0xFF555555).withValues(alpha: 0.5)
      ..strokeWidth = w * 0.004
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas,
      Offset(0, centerY),
      Offset(w, centerY),
      axisPaint,
      dashWidth: w * 0.02,
      dashSpace: w * 0.01,
    );

    // ── 5) Dashed vertical center line ────────────────────────────
    _drawDashedLine(
      canvas,
      Offset(centerX, 0),
      Offset(centerX, h),
      axisPaint,
      dashWidth: h * 0.015,
      dashSpace: h * 0.008,
    );

    // ── 6) Boccia balls along horizontal center ───────────────────
    _drawBocciaBallsOnCenterLine(canvas, size, Offset(centerX, centerY));

    // ── 7) "FUERA DE ZONA" labels on outermost stripes ────────────
    _drawOutOfZoneLabels(canvas, size, stripeW);

    // ── 8) User-selected ball ─────────────────────────────────────
    if (selection != null) {
      _drawSelectedBall(canvas, size, selection!);
    }
  }

  // ── Score labels ──────────────────────────────────────────────────
  void _drawStripeScoreLabels(Canvas canvas, Size size, double stripeW) {
    final w = size.width;
    final h = size.height;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 11; i++) {
      final score = _stripeScores[i];
      if (score == 0) continue; // we draw "FUERA DE ZONA" instead

      final cx = stripeW * i + stripeW / 2;
      final labelColor = score >= 4 ? AppColors.white : const Color(0xFF555555);

      tp.text = TextSpan(
        text: '$score',
        style: TextStyle(
          color: labelColor,
          fontSize: w * 0.04,
          fontWeight: FontWeight.bold,
        ),
      );
      tp.layout();

      // Top label
      tp.paint(canvas, Offset(cx - tp.width / 2, h * 0.03));
      // Bottom label
      tp.paint(canvas, Offset(cx - tp.width / 2, h * 0.95));
    }
  }

  // ── "FUERA DE ZONA" on left and right outermost stripes ───────────
  void _drawOutOfZoneLabels(Canvas canvas, Size size, double stripeW) {
    final h = size.height;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final fontSize = stripeW * 0.30;

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
          letterSpacing: 1.5,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Left stripe center
    drawVertical('FUERA DE ZONA', Offset(stripeW / 2, h / 2));
    // Right stripe center
    drawVertical('FUERA DE ZONA', Offset(stripeW * 10 + stripeW / 2, h / 2));
  }

  // ── Dashed line helper ────────────────────────────────────────────
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

  // ── Boccia balls on center line (6 balls = 60 cm) ─────────────────
  void _drawBocciaBallsOnCenterLine(Canvas canvas, Size size, Offset center) {
    final w = size.width;
    final stripeW = w / 11;
    // Ball radius ≈ half a stripe (each ball ~ 10 cm, each stripe ~ 10 cm)
    // We use a slightly smaller radius so there is a small gap between balls.
    final ballRadius = stripeW * 0.42;

    // 6 balls: placed at stripe centers 2,3,4 (left) and 6,7,8 (right)
    // plus the green jack ball at stripe 5 (center).
    // Stripe indices: [2]=score3, [3]=score4 (left), [5]=jack, [6]=score4, [7]=score3, [8]=score2
    // We draw 4 coloured balls + 1 green jack.
    // Let's place them nicely: indices 3, 4 (left of center) and 6, 7 (right of center)
    // plus two outer ones at 2 and 8.
    final ballInfos = <_BallInfo>[
      _BallInfo(stripeIndex: 2, color: const Color(0xFF2E5B8B)), // blue
      _BallInfo(stripeIndex: 3, color: const Color(0xFFB03A2E)), // red
      _BallInfo(stripeIndex: 4, color: const Color(0xFF2E5B8B)), // blue
      // index 5 = green jack
      _BallInfo(stripeIndex: 6, color: const Color(0xFFB03A2E)), // red
      _BallInfo(stripeIndex: 7, color: const Color(0xFF2E5B8B)), // blue
      _BallInfo(stripeIndex: 8, color: const Color(0xFFB03A2E)), // red
    ];

    for (final info in ballInfos) {
      final bx = stripeW * info.stripeIndex + stripeW / 2;
      _drawDecorativeBall(
          canvas, Offset(bx, center.dy), ballRadius, info.color);
    }

    // Green jack ball at center stripe (index 5)
    final jackX = stripeW * 5 + stripeW / 2;
    _drawGreenJackBall(canvas, Offset(jackX, center.dy), ballRadius);
  }

  // ── Green jack ball ───────────────────────────────────────────────
  void _drawGreenJackBall(Canvas canvas, Offset center, double radius) {
    // Shadow
    canvas.drawCircle(
      Offset(center.dx + 1, center.dy + 1.5),
      radius,
      Paint()
        ..color = AppColors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // Body gradient – green
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            const Color(0xFF7EC87E),
            const Color(0xFF4A8B4A),
            const Color(0xFF2E6B2E),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Seams
    final seamPaint = Paint()
      ..color = const Color(0xFF1A4A1A).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.07;

    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.6, center.dy - radius * 0.5)
        ..quadraticBezierTo(center.dx, center.dy - radius * 0.8,
            center.dx + radius * 0.6, center.dy - radius * 0.5),
      seamPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.6, center.dy + radius * 0.5)
        ..quadraticBezierTo(center.dx, center.dy + radius * 0.8,
            center.dx + radius * 0.6, center.dy + radius * 0.5),
      seamPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.5, center.dy - radius * 0.6)
        ..quadraticBezierTo(center.dx - radius * 0.3, center.dy,
            center.dx - radius * 0.5, center.dy + radius * 0.6),
      seamPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + radius * 0.5, center.dy - radius * 0.6)
        ..quadraticBezierTo(center.dx + radius * 0.3, center.dy,
            center.dx + radius * 0.5, center.dy + radius * 0.6),
      seamPaint,
    );

    // White center logo circle
    canvas.drawCircle(
      center,
      radius * 0.35,
      Paint()..color = AppColors.white.withValues(alpha: 0.85),
    );

    // Highlight
    final highlightPath = Path()
      ..moveTo(center.dx - radius * 0.45, center.dy - radius * 0.3)
      ..quadraticBezierTo(center.dx, center.dy - radius * 0.7,
          center.dx + radius * 0.45, center.dy - radius * 0.3);
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.25
        ..strokeCap = StrokeCap.round,
    );

    // Border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF1A4A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.07,
    );

    // "5" label
    final textPainter = TextPainter(
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
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  // ── Decorative ball ───────────────────────────────────────────────
  void _drawDecorativeBall(
      Canvas canvas, Offset center, double radius, Color baseColor) {
    // Shadow
    canvas.drawCircle(
      Offset(center.dx + 1, center.dy + 1),
      radius,
      Paint()
        ..color = AppColors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Main body gradient
    final lighter = Color.lerp(baseColor, AppColors.white, 0.3)!;
    final darker = Color.lerp(baseColor, AppColors.black, 0.2)!;

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

    // Seams (cross pattern)
    final seamPaint = Paint()
      ..color = darker.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06;

    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.6, center.dy - radius * 0.5)
        ..quadraticBezierTo(center.dx, center.dy - radius * 0.8,
            center.dx + radius * 0.6, center.dy - radius * 0.5),
      seamPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.6, center.dy + radius * 0.5)
        ..quadraticBezierTo(center.dx, center.dy + radius * 0.8,
            center.dx + radius * 0.6, center.dy + radius * 0.5),
      seamPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.5, center.dy - radius * 0.6)
        ..quadraticBezierTo(center.dx - radius * 0.3, center.dy,
            center.dx - radius * 0.5, center.dy + radius * 0.6),
      seamPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + radius * 0.5, center.dy - radius * 0.6)
        ..quadraticBezierTo(center.dx + radius * 0.3, center.dy,
            center.dx + radius * 0.5, center.dy + radius * 0.6),
      seamPaint,
    );

    // Center logo circle (white)
    canvas.drawCircle(
      center,
      radius * 0.35,
      Paint()..color = AppColors.white.withValues(alpha: 0.85),
    );

    // Highlight
    final highlightPath = Path()
      ..moveTo(center.dx - radius * 0.45, center.dy - radius * 0.3)
      ..quadraticBezierTo(center.dx, center.dy - radius * 0.7,
          center.dx + radius * 0.45, center.dy - radius * 0.3);
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.25
        ..strokeCap = StrokeCap.round,
    );

    // Border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = darker
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.06,
    );
  }

  // ── User-selected ball ────────────────────────────────────────────
  void _drawSelectedBall(Canvas canvas, Size size, Offset position) {
    final w = size.width;
    final ballX = (position.dx / 100) * w;
    final ballY = (position.dy / 100) * size.height;
    final ballRadius = w * 0.04;

    // Shadow
    canvas.drawCircle(
      Offset(ballX + 1.5, ballY + 1.5),
      ballRadius,
      Paint()
        ..color = AppColors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Main body – bright red/orange highlight
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            const Color(0xFFFF6B35),
            const Color(0xFFEF4444),
            const Color(0xFFCC2222),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
            Rect.fromCircle(center: Offset(ballX, ballY), radius: ballRadius)),
    );

    // Glow ring to indicate selection
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius + 3,
      Paint()
        ..color = const Color(0xFFFF6B35).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // White center dot
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius * 0.3,
      Paint()..color = AppColors.white,
    );

    // Border
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius,
      Paint()
        ..color = const Color(0xFFAA1111)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.003,
    );
  }

  @override
  bool shouldRepaint(DirectionCourtPainter oldDelegate) {
    return oldDelegate.selection != selection;
  }
}

/// Helper class for ball placement info.
class _BallInfo {
  final int stripeIndex;
  final Color color;
  const _BallInfo({required this.stripeIndex, required this.color});
}
