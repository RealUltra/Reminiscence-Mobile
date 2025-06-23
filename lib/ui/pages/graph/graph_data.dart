import 'dart:math';
import 'dart:ui';

class GraphData {
  static final colors = List.generate(
    10,
    (_) => Color((Random().nextDouble() * 0xFFFFFF).toInt()).withAlpha(255),
  );

  final String x;
  final int y;

  const GraphData(this.x, this.y);
}
