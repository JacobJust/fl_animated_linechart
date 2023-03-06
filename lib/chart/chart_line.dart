import 'dart:ui';

import 'package:fl_animated_linechart/chart/chart_point.dart';

class ChartLine {
  final List<ChartPoint> points;
  final Color color;
  final String unit;
  bool isMarkerLine;

  double _minX = 0;
  double _minY = 0;
  double _maxX = 0;
  double _maxY = 0;

  ChartLine(this.points, this.color, this.unit, {this.isMarkerLine = false}) {
    if (points.length > 0) {
      _minX = points[0].x;
      _maxX = points[0].x;
      _minY = points[0].y;
      _maxY = points[0].y;
    }

    points.forEach((p) {
      if (p.x < _minX) {
        _minX = p.x;
      }
      if (p.x > _maxX) {
        _maxX = p.x;
      }
      if (p.y < _minY) {
        _minY = p.y;
      }
      if (p.y > _maxY) {
        _maxY = p.y;
      }
    });

    if (_minY == _maxY) {
      _minY--;
      _maxY++;
    }
  }

  double get minX => _minX;
  double get minY => _minY;
  double get maxX => _maxX;
  double get maxY => _maxY;
}
