import 'package:fl_animated_linechart/chart/chart_line.dart';
import 'package:fl_animated_linechart/chart/chart_point.dart';
import 'dart:ui';

class ChartLineHelper {
  static ChartLine createLine(int count, double yFactor, Color color, String unit) {
    List<ChartPoint> points = List();

    for (double c = 0; c < count; c++) {
      points.add(ChartPoint(c, c * yFactor));
    }

    return ChartLine(points, color, unit);
  }
}

