import 'package:flutter/material.dart';

class HeatmapChart extends StatelessWidget {
  final List<Map<String, double>> coordinates;

  const HeatmapChart({Key? key, required this.coordinates}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
        ),
        child: Stack(
          children: [
            // Simplified Heatmap: Points with varying opacity/size or a custom painter
            ...coordinates.map((coord) => Positioned(
                  left: (coord['x']! / 100) * MediaQuery.of(context).size.width * 0.4, // Approximation
                  top: (coord['y']! / 100) * MediaQuery.of(context).size.width * 0.4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                )),
            Center(
              child: Text(
                "Mapa de Calor",
                style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
