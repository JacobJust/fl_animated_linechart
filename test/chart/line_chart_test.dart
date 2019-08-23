import 'dart:ui';

import 'package:fl_animated_linechart/chart/chart_line.dart';
import 'package:fl_animated_linechart/chart/chart_point.dart';
import 'package:fl_animated_linechart/chart/highlight_point.dart';
import 'package:fl_animated_linechart/common/dates.dart';
import 'package:fl_animated_linechart/fl_animated_linechart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../testHelpers/chart_data_helper.dart';

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
    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W')], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.seriesMap.length, 1);
    expect(lineChart.seriesMap[0].length, 10);

    expect(lineChart.minX, 0.0);
    expect(lineChart.maxX, 9.0);

    expect(lineChart.minY, 0.0);
    expect(lineChart.maxY, 18.0);
  });

  test('init with multiple lines', () async {
    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W'),
                                     ChartLineHelper.createLine(15, 1, Colors.cyan, 'W')],
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
    DateTime start = DateTime.now();

    List<Map<DateTime, double>> series = List();
    Map<DateTime, double> line = Map();
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 0.5;
    line[start.add(Duration(minutes: 10))] = 1.7;
    series.add(line);

    LineChart lineChart = LineChart.fromDateTimeMaps(series, [Colors.amber], 'E');
    lineChart.initialize(200, 100);

    List<HighlightPoint> list = lineChart.seriesMap[0];

    expect(list[0].chartPoint.x, 50);
    expect(list[1].chartPoint.x, 125);
    expect(list[2].chartPoint.x, 200);
  });

  test('test xScale', () async {
    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W'),
    ChartLineHelper.createLine(15, 1, Colors.cyan, 'W')],
        Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.xScale, 10.714285714285714);
  });

  test('test yScale', () async {
    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W'),
    ChartLineHelper.createLine(15, 1, Colors.cyan, 'W')],
        Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.yScale, 1.6666666666666667);
  });

  test('test heightStepSize', () async {
    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W'),
    ChartLineHelper.createLine(15, 1, Colors.cyan, 'W')],
        Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.heightStepSize, 8.333333333333334);
  });

  test('test widthStepSize', () async {
    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W'),
    ChartLineHelper.createLine(15, 1, Colors.cyan, 'W')],
        Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.widthStepSize, 25.0);
  });

  test('test axisOffSetWithPadding', () async {
    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W'),
    ChartLineHelper.createLine(15, 1, Colors.cyan, 'W')],
        Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.axisOffSetWithPadding, 45.0);
  });

  test('test min max values', () async {
    double minX = -2;
    double maxX = 87;
    double minY = -6;
    double maxY = 67;

    ChartLine line = ChartLine([
      ChartPoint(1,1),
      ChartPoint(57, 57),
      ChartPoint(0, 0),
      ChartPoint(maxX, maxY),
      ChartPoint(minX, minY),
    ], Colors.pink, 'C');

    LineChart lineChart = LineChart([ChartLine([], Colors.amber, 'W'), line], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.minX, minX);
    expect(lineChart.maxX, maxX);
    expect(lineChart.minY, minY);
    expect(lineChart.maxY, maxY);
  });

  test('width and height calculated based on min and max values', () async {
    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W')], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    expect(lineChart.width, 9);
    expect(lineChart.height, 18.0);
  });

  test('path calculate', () async {
    double chartHeight = 100.0;

    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W'), ChartLineHelper.createLine(10, 4, Colors.cyan, 'W')], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, chartHeight);

    expectPathCacheToMatch(lineChart.getPathCache(0), 10, 2, lineChart, chartHeight);
    expectPathCacheToMatch(lineChart.getPathCache(1), 10, 4, lineChart, chartHeight);
  });

  test('path cache', () async {
    double chartHeight = 100.0;

    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W')], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, chartHeight);

    Path path = lineChart.getPathCache(0);
    Path pathCached = lineChart.getPathCache(0);

    expect(path, pathCached, reason: 'The two part should reference the same object reference');
  });


  test('find the highlight closest', () async {
    LineChart lineChart = LineChart([ChartLineHelper.createLine(10, 2, Colors.cyan, 'W')], Dates(DateTime.now(), DateTime.now()), 'W');
    lineChart.initialize(200, 100);

    List<HighlightPoint> closetHighlightPoints = lineChart.getClosetHighlightPoints(101);

    expect(closetHighlightPoints.length, 1);
    expect(closetHighlightPoints[0].chartPoint.x, 100);
    expect(closetHighlightPoints[0].chartPoint.y, 40);
  });

  test('y axis calculations', () async {
    DateTime start = DateTime.now();

    List<Map<DateTime, double>> series = List();
    Map<DateTime, double> line = Map();
    line[start] = 1;
    line[start.add(Duration(minutes: 5))] = 5;
    line[start.add(Duration(minutes: 10))] = 5;
    line[start.add(Duration(minutes: 15))] = 13;
    line[start.add(Duration(minutes: 20))] = 3;
    line[start.add(Duration(minutes: 25))] = 18;
    line[start.add(Duration(minutes: 30))] = 20;
    series.add(line);

    LineChart lineChart = LineChart.fromDateTimeMaps(series, [Colors.amber], 'E');
    lineChart.initialize(200, 100);

    List<TextPainter> axisTexts = lineChart.yAxisTexts;

    expect(axisTexts[0].text.toPlainText(), '1');
    expect(axisTexts[1].text.toPlainText(), '5');
    expect(axisTexts[2].text.toPlainText(), '9');
    expect(axisTexts[3].text.toPlainText(), '12');
    expect(axisTexts[4].text.toPlainText(), '16');
    expect(axisTexts[5].text.toPlainText(), '20');
    expect(axisTexts[6].text.toPlainText(), '24');
  });

  test('x axis format hours minutes', () async {
    DateTime start = DateTime.now();

    List<Map<DateTime, double>> series = List();
    Map<DateTime, double> line = Map();
    line[start] = 1;
    line[start.add(Duration(minutes: 5))] = 5;
    line[start.add(Duration(minutes: 10))] = 5;
    line[start.add(Duration(minutes: 15))] = 13;
    line[start.add(Duration(minutes: 20))] = 3;
    line[start.add(Duration(minutes: 25))] = 18;
    line[start.add(Duration(minutes: 30))] = 20;
    series.add(line);

    LineChart lineChart = LineChart.fromDateTimeMaps(series, [Colors.amber], 'E');
    lineChart.initialize(200, 100);

    List<TextPainter> axisTexts = lineChart.xAxisTexts;

    expect(axisTexts[0].text.toPlainText().contains(':'), true);
  });

  test('x axis format hours minutes day month', () async {
    DateTime start = DateTime.now();

    List<Map<DateTime, double>> series = List();
    Map<DateTime, double> line = Map();
    line[start] = 1;
    line[start.add(Duration(days: 1))] = 5;
    line[start.add(Duration(days: 2))] = 5;
    line[start.add(Duration(days: 3))] = 13;
    line[start.add(Duration(days: 4))] = 3;
    line[start.add(Duration(days: 5))] = 18;
    line[start.add(Duration(days: 6))] = 20;
    series.add(line);

    LineChart lineChart = LineChart.fromDateTimeMaps(series, [Colors.amber], 'E');
    lineChart.initialize(200, 100);

    List<TextPainter> axisTexts = lineChart.xAxisTexts;

    expect(axisTexts[0].text.toPlainText().contains('/'), true);
  });
}

void expectPathCacheToMatch(Path pathCache, int pointCount, double pointFactor, LineChart lineChart, double chartHeight) {
  for (double c = 0; c < pointCount; c++) {

    double adjustedY = (c * pointFactor * lineChart.yScale);
    double y = (chartHeight - LineChart.axisOffsetPX) - adjustedY;

    Offset offset = Offset((c * lineChart.xScale) + LineChart.axisOffsetPX, y);
    expect(pathCache.contains(offset), true, reason: 'Expect path to contain $c,${c * pointFactor}');
  }
}
