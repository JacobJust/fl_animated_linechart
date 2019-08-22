import 'dart:ui';

import 'package:fl_animated_linechart/chart/chart_line.dart';
import 'package:fl_animated_linechart/chart/chart_point.dart';
import 'package:fl_animated_linechart/common/dates.dart';
import 'package:fl_animated_linechart/fl_animated_linechart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('init with empty dataset', () async {
    LineChart lineChart = LineChart([], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.seriesMap.isEmpty, true);

    lineChart = LineChart([ChartLine([], Colors.black, 'C')], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.seriesMap.isEmpty, true);
  });

  test('init with 1 line', () async {
    LineChart lineChart = LineChart([_createLine(10, 2, Colors.cyan, 'W')], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.seriesMap.length, 1);
    expect(lineChart.seriesMap[0].length, 10);

    expect(lineChart.minX, 0.0);
    expect(lineChart.maxX, 9.0);

    expect(lineChart.minY, 0.0);
    expect(lineChart.maxY, 18.0);
  });

  test('init with multiple lines', () async {
    LineChart lineChart = LineChart([_createLine(10, 2, Colors.cyan, 'W'),
                                     _createLine(15, 1, Colors.cyan, 'W')],
                                      Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.seriesMap.length, 2);
    expect(lineChart.seriesMap[0].length, 10);
    expect(lineChart.seriesMap[1].length, 15);

    expect(lineChart.minX, 0.0);
    expect(lineChart.maxX, 14.0);

    expect(lineChart.minY, 0.0);
    expect(lineChart.maxY, 18.0);
  });

  test('init with datetime chart points', () async {

  });

  test('width and height calculated based on min and max values', () async {
    LineChart lineChart = LineChart([_createLine(10, 2, Colors.cyan, 'W')], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.width, 9);
    expect(lineChart.height, 18.0);
  });

  test('path cache', () async {
    LineChart lineChart = LineChart([_createLine(10, 2, Colors.cyan, 'W')], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.width, 9);
    expect(lineChart.height, 18.0);
  });

  test('find the highlight closest', () async {
    LineChart lineChart = LineChart([_createLine(10, 2, Colors.cyan, 'W')], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.width, 9);
    expect(lineChart.height, 18.0);
  });
}

ChartLine _createLine(int count, double yFactor, Color color, String unit) {
  List<ChartPoint> points = List();

  for (double c = 0; c < count; c++) {
    points.add(ChartPoint(c, c * yFactor));
  }

  return ChartLine(points, color, unit);
}