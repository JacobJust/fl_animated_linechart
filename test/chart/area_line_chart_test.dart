import 'package:fl_animated_linechart/chart/area_line_chart.dart';
import 'package:fl_animated_linechart/common/dates.dart';
import 'package:fl_animated_linechart/fl_animated_linechart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../testHelpers/chart_data_helper.dart';

void main() {
  test('path calculate', () async {
    double chartHeight = 100.0;

    AreaLineChart lineChart = AreaLineChart(
        [ChartLineHelper.createLine(10, 2, Colors.cyan, 'W')],
        Dates(DateTime.now(), DateTime.now()),
        null);
    lineChart.initialize(
      200,
      chartHeight,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    expectPathCacheToMatch(
        lineChart.getAreaPathCache(0)!,
        10,
        2,
        lineChart,
        chartHeight,
        'W',
        lineChart.xAxisOffsetPX,
        lineChart.getPathCache(0)!.getBounds());
  });

  test('path cache', () async {
    double chartHeight = 100.0;

    AreaLineChart lineChart = AreaLineChart(
        [ChartLineHelper.createLine(10, 2, Colors.cyan, 'W')],
        Dates(DateTime.now(), DateTime.now()),
        null);
    lineChart.initialize(
      200,
      chartHeight,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    Path? path = lineChart.getAreaPathCache(0);
    Path? pathCached = lineChart.getAreaPathCache(0);

    expect(path, pathCached,
        reason: 'The two part should reference the same object reference');
  });
}

void expectPathCacheToMatch(
    Path pathCache,
    int pointCount,
    double pointFactor,
    LineChart lineChart,
    double chartHeight,
    String unit,
    double xAxisOffsetPX,
    Rect bounds) {
  for (double c = 0; c < pointCount; c++) {
    double adjustedY = (c * pointFactor * lineChart.yScale(unit)!);
    double y = (chartHeight - LineChart.axisOffsetPX) - adjustedY;

    Offset offset = Offset((c * lineChart.xScale!) + xAxisOffsetPX, y);
    expect(pathCache.contains(offset), true,
        reason: 'Expect path to contain $c,${c * pointFactor}');
  }

  expect(pathCache.contains(Offset(bounds.left, bounds.bottom)), true);
  expect(pathCache.contains(Offset(bounds.right, bounds.bottom)), true);
  expect(pathCache.contains(Offset(bounds.left, bounds.bottom)), true);
}
