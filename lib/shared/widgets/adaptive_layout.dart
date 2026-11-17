import 'package:flutter/material.dart';

/// Rejilla de tarjetas (estadisticas, indicadores) que elige el numero de
/// columnas segun el ancho REAL disponible, no el ancho de la pantalla.
///
/// - Solo usa un numero de columnas que divida exactamente el numero de
///   tarjetas (4 tarjetas -> 4, 2 o 1 columnas), para no dejar huerfanas.
/// - Cada tarjeta tiene alto fijo [itemHeight], asi el contenido no se
///   desborda en pantallas angostas ni queda con huecos en las anchas.
///
/// Acepta los mismos parametros que `GridView.count` usados en la app para
/// que el cambio sea directo; [crossAxisCount] y [childAspectRatio] se
/// ignoran porque el calculo se hace a partir del ancho.
class AdaptiveStatGrid extends StatelessWidget {
  final List<Widget> children;
  final double itemHeight;
  final double minItemWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const AdaptiveStatGrid({
    super.key,
    required this.children,
    this.itemHeight = 124,
    this.minItemWidth = 140,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    // Compatibilidad con la firma de GridView.count (no se usan).
    int? crossAxisCount,
    double? childAspectRatio,
    bool? shrinkWrap,
    ScrollPhysics? physics,
  });

  /// Columnas a usar para [count] tarjetas en [width] px.
  static int columnsFor({
    required int count,
    required double width,
    required double minItemWidth,
    required double spacing,
  }) {
    if (count <= 1) return 1;
    for (var cols = count; cols > 1; cols--) {
      if (count % cols != 0) continue;
      final cell = (width - spacing * (cols - 1)) / cols;
      if (cell >= minItemWidth) return cols;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = columnsFor(
          count: children.length,
          width: width,
          minItemWidth: minItemWidth,
          spacing: crossAxisSpacing,
        );
        final cellWidth = (width - crossAxisSpacing * (cols - 1)) / cols;

        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: cellWidth / itemHeight,
          children: children,
        );
      },
    );
  }
}

/// Muestra dos secciones lado a lado cuando hay espacio suficiente
/// ([breakpoint], medido sobre el ancho disponible) y una debajo de la otra
/// en pantallas angostas.
class TwoColumnSection extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double breakpoint;
  final double spacing;

  const TwoColumnSection({
    super.key,
    required this.left,
    required this.right,
    this.breakpoint = 840,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [left, SizedBox(height: spacing), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: spacing),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
