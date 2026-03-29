import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Diámetro oficial de una bola de boccia en metros.
const double kBocciaBallDiameterM = 0.086; // 8.6 cm
const double kBocciaBallRadiusM = kBocciaBallDiameterM / 2;

/// Resultado devuelto por el diálogo de la cancha de boccia.
class BocciaCourtResult {
  final Offset whiteBallPosition; // en metros (x = ancho 0-6, y = largo 0-12.5)
  final Offset colorBallPosition; // en metros
  final Offset launchPoint; // punto de lanzamiento en metros
  final double edgeToEdgeDistance; // distancia borde-a-borde entre bolas
  final double launchToJackDistance; // distancia del punto de lanzamiento al jack

  const BocciaCourtResult({
    required this.whiteBallPosition,
    required this.colorBallPosition,
    required this.launchPoint,
    required this.edgeToEdgeDistance,
    required this.launchToJackDistance,
  });
}

/// Widget interactivo — cancha de boccia vertical con zoom.
///
/// Orientación vertical (arriba → abajo):
///   Y=0..2.50    Cajas 1-6 (1m ancho × 2.50m alto)
///   Y=2.50→5.50  Zona V (punta central Y=4.0, esquinas Y=5.5)
///   Y=7.50       Cruz central
///   Y=12.50      Borde inferior
///
/// Parámetros de diagonal:
///   - Roja  → lanza desde Box 3 (X: 2-3m)
///   - Azul  → lanza desde Box 4 (X: 3-4m)
class BocciaCourtWidget extends StatefulWidget {
  final Offset? initialWhiteBall;
  final Offset? initialColorBall;
  final Offset? initialLaunchPoint;
  final Color teamBallColor;

  /// Número de box de lanzamiento (1-6). Box 3 para roja, Box 4 para azul.
  final int launchBox;

  final ValueChanged<BocciaCourtResult>? onResult;

  const BocciaCourtWidget({
    super.key,
    this.initialWhiteBall,
    this.initialColorBall,
    this.initialLaunchPoint,
    this.teamBallColor = Colors.red,
    this.launchBox = 3,
    this.onResult,
  });

  @override
  State<BocciaCourtWidget> createState() => _BocciaCourtWidgetState();
}

class _BocciaCourtWidgetState extends State<BocciaCourtWidget> {
  static const double courtWidthM = 6.00;
  static const double courtLengthM = 12.50;
  static const double boxesHeightM = 2.50;
  static const double boxWidthM = 1.00;

  Offset? _whiteBall;
  Offset? _colorBall;
  Offset? _launchPoint;
  String? _draggingBall; // 'white' | 'color' | 'launch'

  // Estado de colocación secuencial
  // 0 = colocar launch, 1 = colocar white, 2 = colocar color, 3 = done
  int _placingStep = 0;

  // Zoom
  final TransformationController _transformController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _launchPoint = widget.initialLaunchPoint;
    _whiteBall = widget.initialWhiteBall;
    _colorBall = widget.initialColorBall;

    // Si no hay launch point, poner uno por defecto en el centro del box
    // Los boxes se numeran de derecha (1) a izquierda (6):
    //   box 1 → columna 5 (más a la derecha), box 6 → columna 0 (más a la izquierda)
    if (_launchPoint == null) {
      final colIndex = 6 - widget.launchBox; // 0-indexed desde la izquierda
      _launchPoint = Offset(
        colIndex * boxWidthM + boxWidthM / 2, // centro X del box
        boxesHeightM - 0.30, // cerca del borde inferior del box
      );
    }

    // Determinar paso de colocación
    if (_whiteBall == null) {
      _placingStep = 1; // launch ya tiene default, colocar white
    } else if (_colorBall == null) {
      _placingStep = 2;
    } else {
      _placingStep = 3;
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  /// Distancia centro-a-centro entre bolas.
  double get _centerDistance {
    if (_whiteBall == null || _colorBall == null) return 0.0;
    return _offsetDistance(_whiteBall!, _colorBall!);
  }

  /// Distancia borde-a-borde = centro-a-centro − diámetro de una bola.
  double get _edgeToEdgeDistance {
    final d = _centerDistance - kBocciaBallDiameterM;
    return d < 0 ? 0.0 : d;
  }

  /// Distancia del punto de lanzamiento al jack (bola blanca).
  double get _launchToJackDistance {
    if (_launchPoint == null || _whiteBall == null) return 0.0;
    return _offsetDistance(_launchPoint!, _whiteBall!);
  }

  double _offsetDistance(Offset a, Offset b) {
    final dx = a.dx - b.dx;
    final dy = a.dy - b.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  void _emitResult() {
    if (_whiteBall != null &&
        _colorBall != null &&
        _launchPoint != null &&
        widget.onResult != null) {
      widget.onResult!(BocciaCourtResult(
        whiteBallPosition: _whiteBall!,
        colorBallPosition: _colorBall!,
        launchPoint: _launchPoint!,
        edgeToEdgeDistance: _edgeToEdgeDistance,
        launchToJackDistance: _launchToJackDistance,
      ));
    }
  }

  Offset _pixelToMeters(Offset pixel, Size courtSize) {
    final x = (pixel.dx / courtSize.width) * courtWidthM;
    final y = (pixel.dy / courtSize.height) * courtLengthM;
    return Offset(x.clamp(0.0, courtWidthM), y.clamp(0.0, courtLengthM));
  }

  Offset _metersToPixel(Offset meters, Size courtSize) {
    final x = (meters.dx / courtWidthM) * courtSize.width;
    final y = (meters.dy / courtLengthM) * courtSize.height;
    return Offset(x, y);
  }

  String? _hitTestBall(Offset pixelPos, Size courtSize) {
    const toleranceM = 0.40;
    final tolerancePx = (toleranceM / courtWidthM) * courtSize.width;

    // Prioridad: launch > white > color
    if (_launchPoint != null) {
      final lp = _metersToPixel(_launchPoint!, courtSize);
      if ((pixelPos - lp).distance < tolerancePx) return 'launch';
    }
    if (_whiteBall != null) {
      final wp = _metersToPixel(_whiteBall!, courtSize);
      if ((pixelPos - wp).distance < tolerancePx) return 'white';
    }
    if (_colorBall != null) {
      final cp = _metersToPixel(_colorBall!, courtSize);
      if ((pixelPos - cp).distance < tolerancePx) return 'color';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusBar(),
        const SizedBox(height: 8),

        // ── Leyenda de bolas ─────────────────────────────────────
        _buildLegend(),
        const SizedBox(height: 8),

        // ── Cancha con zoom ──────────────────────────────────────
        AspectRatio(
          aspectRatio: courtWidthM / courtLengthM,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final courtSize =
                  Size(constraints.maxWidth, constraints.maxHeight);
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 1.0,
                  maxScale: 5.0,
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onPanStart: (details) {
                      final hit =
                          _hitTestBall(details.localPosition, courtSize);
                      if (hit != null) {
                        setState(() => _draggingBall = hit);
                      }
                    },
                    onPanUpdate: (details) {
                      if (_draggingBall != null) {
                        final meters = _pixelToMeters(
                            details.localPosition, courtSize);
                        setState(() {
                          if (_draggingBall == 'white') {
                            _whiteBall = meters;
                          } else if (_draggingBall == 'color') {
                            _colorBall = meters;
                          } else if (_draggingBall == 'launch') {
                            // Restringir launch point dentro del box
                            // Numeración derecha→izquierda: box N → columna (6-N)
                            final colIdx = 6 - widget.launchBox;
                            final minX = colIdx * boxWidthM;
                            final maxX = minX + boxWidthM;
                            _launchPoint = Offset(
                              meters.dx.clamp(minX, maxX),
                              meters.dy.clamp(0, boxesHeightM),
                            );
                          }
                        });
                        _emitResult();
                      }
                    },
                    onPanEnd: (_) =>
                        setState(() => _draggingBall = null),
                    onTapUp: (details) {
                      if (_draggingBall != null) return;
                      final meters = _pixelToMeters(
                          details.localPosition, courtSize);
                      setState(() {
                        if (_placingStep == 0) {
                          // Colocar launch — numeración derecha→izquierda
                          final colIdx = 6 - widget.launchBox;
                          final minX = colIdx * boxWidthM;
                          final maxX = minX + boxWidthM;
                          _launchPoint = Offset(
                            meters.dx.clamp(minX, maxX),
                            meters.dy.clamp(0, boxesHeightM),
                          );
                          _placingStep = 1;
                        } else if (_placingStep == 1) {
                          _whiteBall = meters;
                          _placingStep = 2;
                        } else if (_placingStep == 2) {
                          _colorBall = meters;
                          _placingStep = 3;
                        } else {
                          // Todo colocado: mover la bola más cercana
                          final dw = _whiteBall != null
                              ? (meters - _whiteBall!).distance
                              : double.infinity;
                          final dc = _colorBall != null
                              ? (meters - _colorBall!).distance
                              : double.infinity;
                          if (dw < dc) {
                            _whiteBall = meters;
                          } else {
                            _colorBall = meters;
                          }
                        }
                      });
                      _emitResult();
                    },
                    child: CustomPaint(
                      size: courtSize,
                      painter: _BocciaCourtPainter(
                        whiteBall: _whiteBall,
                        colorBall: _colorBall,
                        launchPoint: _launchPoint,
                        teamBallColor: widget.teamBallColor,
                        courtSize: courtSize,
                        highlightBox: widget.launchBox,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        // ── Hint de zoom ─────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pinch, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              'Pellizca para hacer zoom',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Tarjetas de distancia ────────────────────────────────
        if (_whiteBall != null && _colorBall != null)
          _buildDistanceCard(
            icon: Icons.straighten,
            label: 'Distancia entre bolas (borde a borde)',
            meters: _edgeToEdgeDistance,
            color: const Color(0xFFEF4444),
          ),
        if (_whiteBall != null && _launchPoint != null) ...[
          const SizedBox(height: 8),
          _buildDistanceCard(
            icon: Icons.sports,
            label: 'Distancia lanzamiento → jack',
            meters: _launchToJackDistance,
            color: const Color(0xFF477D9E),
          ),
        ],
        const SizedBox(height: 8),

        // ── Reset ────────────────────────────────────────────────
        if (_whiteBall != null || _colorBall != null)
          TextButton.icon(
            onPressed: _resetAll,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reiniciar posiciones'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
          ),
      ],
    );
  }

  void _resetAll() {
    final colIdx = 6 - widget.launchBox; // numeración derecha→izquierda
    setState(() {
      _whiteBall = null;
      _colorBall = null;
      _launchPoint = Offset(
        colIdx * boxWidthM + boxWidthM / 2,
        boxesHeightM - 0.30,
      );
      _placingStep = 1;
      _transformController.value = Matrix4.identity();
    });
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(Colors.green[700]!, '▲ Lanzamiento'),
        const SizedBox(width: 14),
        _legendDot(Colors.white, 'J  Jack', border: Colors.grey[700]!),
        const SizedBox(width: 14),
        _legendDot(widget.teamBallColor, 'B  Bola color'),
      ],
    );
  }

  Widget _legendDot(Color color, String label, {Color? border}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: border ?? color, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6D7580))),
      ],
    );
  }

  Widget _buildStatusBar() {
    String text;
    IconData icon;
    Color color;

    if (_placingStep == 0) {
      text = 'Toca dentro del box ${widget.launchBox} para marcar el lanzamiento';
      icon = Icons.touch_app;
      color = Colors.green;
    } else if (_placingStep == 1) {
      text = 'Toca la cancha para colocar la bola blanca (Jack)';
      icon = Icons.touch_app;
      color = Colors.orange;
    } else if (_placingStep == 2) {
      text = 'Toca la cancha para colocar la bola de color';
      icon = Icons.touch_app;
      color = widget.teamBallColor;
    } else {
      text = 'Arrastra las bolas para ajustar · Pellizca para zoom';
      icon = Icons.open_with;
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withAlpha(229),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceCard({
    required IconData icon,
    required String label,
    required double meters,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6D7580))),
                const SizedBox(height: 2),
                Text(
                  '${meters.toStringAsFixed(2)} m',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color.withAlpha(220),
                  ),
                ),
                Text(
                  '${(meters * 100).toStringAsFixed(1)} cm',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF858C94)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PAINTER — Cancha de Boccia vertical con punto de lanzamiento
// ═══════════════════════════════════════════════════════════════════════════

class _BocciaCourtPainter extends CustomPainter {
  final Offset? whiteBall;
  final Offset? colorBall;
  final Offset? launchPoint;
  final Color teamBallColor;
  final Size courtSize;

  /// Box a resaltar (1-6).
  final int highlightBox;

  static const double courtWidthM = 6.00;
  static const double courtLengthM = 12.50;
  static const double boxesHeightM = 2.50;
  static const double boxWidthM = 1.00;
  static const int boxCount = 6;

  // V
  static const double vTipYM = 4.00;
  static const double vCornerYM = 5.50;

  // Cruz
  static const double crossXM = 3.00;
  static const double crossYM = 7.50;

  _BocciaCourtPainter({
    required this.whiteBall,
    required this.colorBall,
    required this.launchPoint,
    required this.teamBallColor,
    required this.courtSize,
    required this.highlightBox,
  });

  double _mToX(double m) => (m / courtWidthM) * courtSize.width;
  double _mToY(double m) => (m / courtLengthM) * courtSize.height;
  Offset _mToPixel(double mx, double my) => Offset(_mToX(mx), _mToY(my));

  /// Radio visual de una bola a escala real (8.6cm diámetro).
  double get _ballRadiusPx {
    final r = _mToX(kBocciaBallRadiusM);
    return r.clamp(6.0, 20.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ── Fondo ────────────────────────────────────────────────────
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFE8E8E8));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // ── Cajas ────────────────────────────────────────────────────
    final boxPaint = Paint()..color = const Color(0xFFD0D0D0);
    final boxBorderPaint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final highlightPaint = Paint()
      ..color = teamBallColor.withAlpha(40);

    for (int i = 0; i < boxCount; i++) {
      final x = _mToX(i * boxWidthM);
      final rect =
          Rect.fromLTWH(x, 0, _mToX(boxWidthM), _mToY(boxesHeightM));

      // Número de box: derecha=1, izquierda=6
      final boxNumber = boxCount - i;
      final isHighlighted = boxNumber == highlightBox;

      canvas.drawRect(rect, boxPaint);

      // Resaltar el box de lanzamiento
      if (isHighlighted) {
        canvas.drawRect(rect, highlightPaint);
      }

      canvas.drawRect(rect, boxBorderPaint);

      // Número
      final tp = TextPainter(
        text: TextSpan(
          text: '$boxNumber',
          style: TextStyle(
            color: isHighlighted
                ? teamBallColor
                : const Color(0xFF1A3A8A),
            fontSize: _mToY(0.45).clamp(12, 24).toDouble(),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          x + _mToX(boxWidthM) / 2 - tp.width / 2,
          _mToY(boxesHeightM) / 2 - tp.height / 2,
        ),
      );
    }

    // ── Línea V ──────────────────────────────────────────────────
    final vStrokePaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final vFillPaint = Paint()..color = const Color(0xFFCCCCCC).withAlpha(128);

    final vPath = Path()
      ..moveTo(_mToX(courtWidthM / 2), _mToY(vTipYM))
      ..lineTo(_mToX(0), _mToY(vCornerYM))
      ..lineTo(_mToX(0), _mToY(boxesHeightM))
      ..lineTo(_mToX(courtWidthM), _mToY(boxesHeightM))
      ..lineTo(_mToX(courtWidthM), _mToY(vCornerYM))
      ..close();

    canvas.drawPath(vPath, vFillPaint);
    canvas.drawLine(
        _mToPixel(courtWidthM / 2, vTipYM),
        _mToPixel(0, vCornerYM), vStrokePaint);
    canvas.drawLine(
        _mToPixel(courtWidthM / 2, vTipYM),
        _mToPixel(courtWidthM, vCornerYM), vStrokePaint);

    // ── Líneas horizontales ──────────────────────────────────────
    final hThinPaint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final refPaint = Paint()
      ..color = const Color(0xFF999999).withAlpha(102)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawLine(
        _mToPixel(0, 3.00), _mToPixel(courtWidthM, 3.00), hThinPaint);
    canvas.drawLine(
        _mToPixel(0, vCornerYM), _mToPixel(courtWidthM, vCornerYM), refPaint);
    canvas.drawLine(
        _mToPixel(0, 7.50), _mToPixel(courtWidthM, 7.50), refPaint);

    // ── Cruz central ─────────────────────────────────────────────
    final crossPaint = Paint()
      ..color = const Color(0xFF444444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final cax = _mToX(0.30);
    final cay = _mToY(0.30);
    final cx = _mToX(crossXM);
    final cy = _mToY(crossYM);
    canvas.drawLine(Offset(cx - cax, cy), Offset(cx + cax, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - cay), Offset(cx, cy + cay), crossPaint);

    // ── Dimensiones ──────────────────────────────────────────────
    _drawDimLabel(canvas, '1.0 m', _mToX(0.5), _mToY(-0.20));
    _drawDimLabel(canvas, '2.50 m', _mToX(-0.35), _mToY(1.25), rotate: true);
    _drawDimLabel(canvas, '3.00 m', _mToX(courtWidthM) + _mToX(0.35),
        _mToY((boxesHeightM + vCornerYM) / 2),
        rotate: true);
    _drawDimLabel(canvas, '7.00 m', _mToX(courtWidthM) + _mToX(0.35),
        _mToY((vCornerYM + courtLengthM) / 2),
        rotate: true);
    _drawDimLabel(canvas, '6.00 m', _mToX(3.00), _mToY(-0.20));
    _drawDimLabel(
        canvas, '12.50 m', _mToX(3.00), _mToY(courtLengthM) + _mToY(0.15));
    _drawDimLabel(
        canvas, '5.0 m', _mToX(4.80), _mToY(7.50) + _mToY(0.35));
    _drawDimLabel(canvas, '1.5 m', _mToX(courtWidthM / 2) + _mToX(0.6),
        _mToY((boxesHeightM + vTipYM) / 2));

    // ── Punto de lanzamiento (triángulo verde) ───────────────────
    if (launchPoint != null) {
      final lp = _mToPixel(launchPoint!.dx, launchPoint!.dy);
      final s = _ballRadiusPx * 1.2;
      final launchPath = Path()
        ..moveTo(lp.dx, lp.dy - s) // punta arriba
        ..lineTo(lp.dx - s * 0.85, lp.dy + s * 0.6)
        ..lineTo(lp.dx + s * 0.85, lp.dy + s * 0.6)
        ..close();

      canvas.drawPath(
          launchPath,
          Paint()
            ..color = const Color(0xFF2E7D32)
            ..style = PaintingStyle.fill);
      canvas.drawPath(
          launchPath,
          Paint()
            ..color = const Color(0xFF1B5E20)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }

    // ── Bolas (a escala real: 8.6cm diámetro) ────────────────────
    final br = _ballRadiusPx;

    if (whiteBall != null) {
      _drawBall(canvas, whiteBall!, br, Colors.white,
          const Color(0xFF444444), 'J', Colors.black);
    }
    if (colorBall != null) {
      _drawBall(canvas, colorBall!, br, teamBallColor,
          teamBallColor.withAlpha(178), 'B', Colors.white);
    }

    // ── Línea entre bolas ────────────────────────────────────────
    if (whiteBall != null && colorBall != null) {
      _drawDashedLine(
        canvas,
        _mToPixel(whiteBall!.dx, whiteBall!.dy),
        _mToPixel(colorBall!.dx, colorBall!.dy),
        Paint()
          ..color = const Color(0xFFEF4444)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // ── Línea launch → jack ──────────────────────────────────────
    if (launchPoint != null && whiteBall != null) {
      _drawDashedLine(
        canvas,
        _mToPixel(launchPoint!.dx, launchPoint!.dy),
        _mToPixel(whiteBall!.dx, whiteBall!.dy),
        Paint()
          ..color = const Color(0xFF477D9E).withAlpha(180)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
        dashWidth: 4,
        gapWidth: 4,
      );
    }
  }

  void _drawBall(Canvas canvas, Offset ballM, double radius, Color fillColor,
      Color strokeColor, String label, Color labelColor) {
    final p = _mToPixel(ballM.dx, ballM.dy);
    canvas.drawCircle(
        p + const Offset(1.5, 1.5), radius,
        Paint()..color = Colors.black.withAlpha(51));
    canvas.drawCircle(p, radius, Paint()..color = fillColor);
    canvas.drawCircle(
      p, radius,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: labelColor,
          fontSize: (radius * 1.1).clamp(8, 14).toDouble(),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
  }

  void _drawDimLabel(Canvas canvas, String text, double x, double y,
      {bool rotate = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF888888),
          fontSize: (courtSize.width * 0.035).clamp(8, 13).toDouble(),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    if (rotate) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(-math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    } else {
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint,
      {double dashWidth = 6, double gapWidth = 4}) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    final ux = dx / dist, uy = dy / dist;
    double d = 0;
    bool on = true;
    while (d < dist) {
      final seg = on
          ? math.min(dashWidth, dist - d)
          : math.min(gapWidth, dist - d);
      if (on) {
        canvas.drawLine(
          Offset(start.dx + ux * d, start.dy + uy * d),
          Offset(start.dx + ux * (d + seg), start.dy + uy * (d + seg)),
          paint,
        );
      }
      d += seg;
      on = !on;
    }
  }

  @override
  bool shouldRepaint(covariant _BocciaCourtPainter old) {
    return whiteBall != old.whiteBall ||
        colorBall != old.colorBall ||
        launchPoint != old.launchPoint ||
        teamBallColor != old.teamBallColor ||
        highlightBox != old.highlightBox;
  }
}
