
import 'package:fl_animated_linechart/chart/chart_point.dart';

class HighlightPoint {
  final ChartPoint chartPoint;
  final double yValue;
  double _deltaY = 0;

  HighlightPoint(this.chartPoint, this.yValue);

  void adjustTextY(double delta) {
    _deltaY = delta;
  }

  double get yTextPosition => chartPoint.y + _deltaY;
}