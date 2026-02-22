import 'dart:math';
import 'package:flutter/material.dart';

class ForceTargetWidget extends StatefulWidget {
  final void Function(double x, double y, int score)? onTargetTap;
  final Offset? selection;
  final double size;

  const ForceTargetWidget({
    Key? key,
    this.onTargetTap,
    this.selection,
    this.size = 300.0,
  }) : super(key: key);

  @override
  State<ForceTargetWidget> createState() => ForceTargetWidgetState();
}

class ForceTargetWidgetState extends State<ForceTargetWidget> {
  Offset? _internalSelection;

  Offset? get selection => widget.selection ?? _internalSelection;

  int _calculateScore(double relativeX, double relativeY) {
    // Distancia desde el centro (50, 50)
    final dx = relativeX - 50;
    final dy = relativeY - 50;
    final distance = sqrt(dx * dx + dy * dy);

    // Lógica según FLUTTER_FORCE_TEST_IMPLEMENTATION.md
    if (distance < 5.5) return 5;
    if (distance < 13.5) return 4;
    
    // Zona 3: Cuadrado 50x50 (relativo 0-100) -> de 25 a 75
    // El prompt dice "distance.abs() < 20.5 && distance.abs() < 20.5" 
    // pero usualmente se refiere a las coordenadas relativas al centro
    if (dx.abs() <= 25 && dy.abs() <= 25) return 3;
    
    // Zona 2 y 1: Basado en el cuadrado de 60x60 (relativo de 20 a 80)
    if (dx.abs() <= 30 && dy.abs() <= 30) {
      if (distance <= 29.5) return 2;
      return 1;
    }
    
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
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: ForceTargetPainter(
                selection: selection,
              ),
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
    
    // Fondo crema/amarillo claro
    final bgPaint = Paint()..color = const Color(0xFFFFFBE6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Zona 1 Punto (60% del tamaño) - Cuadrado azul claro
    final zone1Paint = Paint()..color = const Color(0xFFf0f9ff);
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.6,
        height: size.height * 0.6,
      ),
      zone1Paint,
    );
    
    // Zona 3 Puntos (50% del tamaño) - Cuadrado con borde azul
    final zone3Rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.5,
      height: size.height * 0.5,
    );
    final zone3Paint = Paint()
      ..color = const Color(0xFFFFFBE6)
      ..style = PaintingStyle.fill;
    canvas.drawRect(zone3Rect, zone3Paint);
    
    final blueBorderPaint = Paint()
      ..color = const Color(0xFF00BFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(zone3Rect, blueBorderPaint);
    
    // Círculo Medio (4 Puntos) - Radio 18%
    final circle4Paint = Paint()..color = Colors.white;
    canvas.drawCircle(center, size.width * 0.18, circle4Paint);
    
    final circle4Border = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, size.width * 0.18, circle4Border);
    
    // Círculo Interior (5 Puntos) - Radio 10%
    final circle5Paint = Paint()..color = const Color(0xFFFF8080);
    canvas.drawCircle(center, size.width * 0.1, circle5Paint);
    
    final circle5Border = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, size.width * 0.1, circle5Border);
    
    // Ejes cruzados (líneas punteadas rojas)
    final axisPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    _drawDashedLine(canvas, Offset(size.width * 0.05, center.dy), Offset(size.width * 0.95, center.dy), axisPaint);
    _drawDashedLine(canvas, Offset(center.dx, size.height * 0.05), Offset(center.dx, size.height * 0.95), axisPaint);
    
    _drawLabels(canvas, size);

    if (selection != null) {
      _drawBocciaBall(canvas, size, selection!);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 3, dashSpace = 3;
    double distance = sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;
    double currentDist = 0;
    while (currentDist < distance) {
      canvas.drawLine(
        Offset(p1.dx + dx * currentDist, p1.dy + dy * currentDist),
        Offset(p1.dx + dx * min(currentDist + dashWidth, distance), p1.dy + dy * min(currentDist + dashWidth, distance)),
        paint,
      );
      currentDist += dashWidth + dashSpace;
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    void drawText(String text, Offset offset, double fontSize, Color color) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    drawText('5 pts', Offset(size.width * 0.5, size.height * 0.5), size.width * 0.035, const Color(0xFF333333));
    drawText('4 pts', Offset(size.width * 0.64, size.height * 0.5), size.width * 0.03, const Color(0xFF333333));
    drawText('3 pts', Offset(size.width * 0.72, size.height * 0.28), size.width * 0.03, const Color(0xFF333333));
  }

  void _drawBocciaBall(Canvas canvas, Size size, Offset position) {
    final ballX = (position.dx / 100) * size.width;
    final ballY = (position.dy / 100) * size.height;
    final ballRadius = size.width * 0.035;
    
    // Sombra
    canvas.drawCircle(
      Offset(ballX + 2, ballY + 2), 
      ballRadius, 
      Paint()..color = Colors.black.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
    );

    // Cuerpo de la bola
    final ballPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(Offset(ballX, ballY), ballRadius, ballPaint);
    
    // Costuras
    final seamPaint = Paint()
      ..color = const Color(0xFF7F1D1D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.003;
    
    // Costura superior
    canvas.drawPath(
      Path()
        ..moveTo(ballX - ballRadius * 0.7, ballY - ballRadius * 0.5)
        ..quadraticBezierTo(ballX, ballY - ballRadius * 0.8, ballX + ballRadius * 0.7, ballY - ballRadius * 0.5),
      seamPaint
    );
    
    // Costura inferior
    canvas.drawPath(
      Path()
        ..moveTo(ballX - ballRadius * 0.7, ballY + ballRadius * 0.5)
        ..quadraticBezierTo(ballX, ballY + ballRadius * 0.8, ballX + ballRadius * 0.7, ballY + ballRadius * 0.5),
      seamPaint
    );

    // Logo (círculo blanco)
    canvas.drawCircle(Offset(ballX, ballY), ballRadius * 0.4, Paint()..color = Colors.white);
    
    // Borde final
    canvas.drawCircle(
      Offset(ballX, ballY), 
      ballRadius, 
      Paint()..color = const Color(0xFF991B1B)..style = PaintingStyle.stroke..strokeWidth = 1
    );
  }

  @override
  bool shouldRepaint(ForceTargetPainter oldDelegate) {
    return oldDelegate.selection != selection;
  }
}
