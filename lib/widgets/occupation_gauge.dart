import 'package:flutter/material.dart';

// Widget réutilisable pour afficher un pourcentage en cercle
class OccupationGauge extends StatelessWidget {
  final double percent;
  final Color color;
  final double size;
  final double strokeWidth;

  const OccupationGauge({
    super.key,
    required this.percent,
    required this.color,
    this.size = 58,
    this.strokeWidth = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: strokeWidth,
            strokeCap: StrokeCap.round,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
          Text(
            '${percent.toInt()}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size <= 60 ? 12 : 24,
            ),
          ),
        ],
      ),
    );
  }
}