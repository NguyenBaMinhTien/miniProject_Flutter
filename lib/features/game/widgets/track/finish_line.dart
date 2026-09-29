import 'package:flutter/material.dart';
import 'package:flutter_horse_racing/features/game/widgets/track/race_track_system.dart';

class FinishLine extends StatelessWidget {
  const FinishLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Finish line',
      child: const CustomPaint(
        key: Key('finish-line'),
        size: Size(RaceTrackSystem.finishLineWidth, double.infinity),
        painter: _FinishLinePainter(),
      ),
    );
  }
}

class _FinishLinePainter extends CustomPainter {
  const _FinishLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const square = 9.0;
    final light = Paint()..color = Colors.white;
    final dark = Paint()..color = Colors.black87;
    for (double y = 0; y < size.height; y += square) {
      for (double x = 0; x < size.width; x += square) {
        final column = (x / square).floor();
        final row = (y / square).floor();
        canvas.drawRect(
          Rect.fromLTWH(x, y, square, square),
          (column + row).isEven ? light : dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
