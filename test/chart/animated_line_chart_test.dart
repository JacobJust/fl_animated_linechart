import 'package:fl_animated_linechart/chart/area_line_chart.dart';
import 'package:fl_animated_linechart/common/pair.dart';
import 'package:fl_animated_linechart/fl_animated_linechart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:ui' as ui;

import '../testHelpers/widget_test_helper.dart';

void main() {
  testWidgets('Test animations runs and disposes', (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = {};
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 0.5;
    line[start.add(Duration(minutes: 10))] = 1.7;
    series.add(line);

    LineChart lineChart =
        LineChart.fromDateTimeMaps(series, [Colors.pink], ['P']);
    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    await tester.pumpWidget(
      buildTestableWidget(
        AnimatedLineChart(
          lineChart,
          gridColor: Colors.black54,
          textStyle: TextStyle(fontSize: 10, color: Colors.black54),
          toolTipColor: Colors.white,
        ),
      ),
    );

    int count = 0;

    expect(tester.hasRunningAnimations, true);
    await tester.pump(Duration(milliseconds: 50));
    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartWhileAnimating.png'));

    while (count < 20) {
      await tester.pump(Duration(milliseconds: 50));
      count++;
    }

    expect(tester.hasRunningAnimations, false);

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartAfterAnimation.png'));
  });

  testWidgets('Test horizontal drag multiple series',
      (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = Map();
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 50;
    line[start.add(Duration(minutes: 10))] = 180.7;
    line[start.add(Duration(minutes: 15))] = 280.7;
    line[start.add(Duration(minutes: 20))] = 380.7;
    line[start.add(Duration(minutes: 25))] = 480.7;
    line[start.add(Duration(minutes: 30))] = 580.7;
    series.add(line);

    Map<DateTime, double> line2 = Map();
    line2[start] = 1.2;
    line2[start.add(Duration(minutes: 4))] = 0.1;
    line2[start.add(Duration(minutes: 14))] = 1.1;
    line2[start.add(Duration(minutes: 19))] = 1.1;
    line2[start.add(Duration(minutes: 24))] = 1.1;
    line2[start.add(Duration(minutes: 29))] = 500;
    line2[start.add(Duration(minutes: 34))] = 1.1;
    series.add(line2);

    LineChart lineChart = LineChart.fromDateTimeMaps(
        series.reversed.toList(), [Colors.amber, Colors.pink], ['P', 'P']);
    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    await tester.pumpWidget(buildTestableWidget(SizedBox(
      child: AnimatedLineChart(
        lineChart,
        gridColor: Colors.black54,
        textStyle: TextStyle(fontSize: 10, color: Colors.black54),
        toolTipColor: Colors.white,
      ),
      width: 500,
      height: 500,
    )));

    await tester.pump(Duration(seconds: 1));

    TestGesture testGesture =
        await tester.startGesture(Offset(0, 250), pointer: 7);

    await tester.pump(Duration(milliseconds: 50));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartDuringDrag.png'));

    for (double c = 1; c < 100; c++) {
      await testGesture.moveBy(Offset(5 * c, 0));
      await tester.pump(Duration(milliseconds: 50));
    }

    await testGesture.up();

    await tester.pump(Duration(milliseconds: 50));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartAfterDrag.png'));
  });

  testWidgets('Test horizontal drag multiple series different unit',
      (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = Map();
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 50;
    line[start.add(Duration(minutes: 10))] = 180.7;
    line[start.add(Duration(minutes: 15))] = 280.7;
    line[start.add(Duration(minutes: 20))] = 380.7;
    line[start.add(Duration(minutes: 25))] = 480.7;
    line[start.add(Duration(minutes: 30))] = 580.7;
    series.add(line);

    Map<DateTime, double> line2 = Map();
    line2[start] = 1.2;
    line2[start.add(Duration(minutes: 4))] = 0.1;
    line2[start.add(Duration(minutes: 14))] = 1.1;
    line2[start.add(Duration(minutes: 19))] = 1.1;
    line2[start.add(Duration(minutes: 24))] = 1.1;
    line2[start.add(Duration(minutes: 29))] = 500;
    line2[start.add(Duration(minutes: 34))] = 1.1;
    series.add(line2);

    LineChart lineChart = LineChart.fromDateTimeMaps(
        series.reversed.toList(), [Colors.amber, Colors.pink], ['C', 'F']);
    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    await tester.pumpWidget(buildTestableWidget(SizedBox(
      child: AnimatedLineChart(
        lineChart,
        gridColor: Colors.black54,
        textStyle: TextStyle(fontSize: 10, color: Colors.black54),
        toolTipColor: Colors.white,
      ),
      width: 500,
      height: 500,
    )));

    await tester.pump(Duration(seconds: 1));

    TestGesture testGesture =
        await tester.startGesture(Offset(0, 250), pointer: 7);

    await tester.pump(Duration(milliseconds: 50));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartDuringDragMultiUnit.png'));

    for (double c = 1; c < 100; c++) {
      await testGesture.moveBy(Offset(5 * c, 0));
      await tester.pump(Duration(milliseconds: 50));
    }

    await testGesture.up();

    await tester.pump(Duration(milliseconds: 50));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartAfterDragMultiUnit.png'));
  });

  testWidgets('Test horizontal drag single serie', (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = Map();
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 0.5;
    line[start.add(Duration(minutes: 10))] = 1.7;
    line[start.add(Duration(minutes: 15))] = 1.7;
    line[start.add(Duration(minutes: 20))] = 1.7;
    line[start.add(Duration(minutes: 25))] = 1.7;
    line[start.add(Duration(minutes: 30))] = 1.7;
    series.add(line);

    LineChart lineChart =
        LineChart.fromDateTimeMaps(series, [Colors.amber], ['W']);
    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    await tester.pumpWidget(buildTestableWidget(SizedBox(
      child: AnimatedLineChart(
        lineChart,
        gridColor: Colors.black54,
        textStyle: TextStyle(fontSize: 10, color: Colors.black54),
        toolTipColor: Colors.white,
      ),
      width: 500,
      height: 500,
    )));

    await tester.pump(Duration(seconds: 1));

    TestGesture testGesture =
        await tester.startGesture(Offset(250, 250), pointer: 7);

    await tester.pump(Duration(milliseconds: 50));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartDuringDragSingle.png'));

    await testGesture.moveBy(Offset(20, 0));

    await tester.pump(Duration(milliseconds: 50));

    await testGesture.moveBy(Offset(-200, 0));

    await testGesture.up();

    await tester.pump(Duration(milliseconds: 50));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartAfterDragSingle.png'));
  });

  testWidgets('Test tooltip triggered by tap', (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = Map();
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 0.5;
    line[start.add(Duration(minutes: 10))] = 1.7;
    line[start.add(Duration(minutes: 15))] = 1.7;
    line[start.add(Duration(minutes: 20))] = 1.7;
    line[start.add(Duration(minutes: 25))] = 1.7;
    line[start.add(Duration(minutes: 30))] = 1.7;
    series.add(line);

    LineChart lineChart =
        LineChart.fromDateTimeMaps(series, [Colors.amber], ['W']);
    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    await tester.pumpWidget(buildTestableWidget(SizedBox(
      child: AnimatedLineChart(
        lineChart,
        gridColor: Colors.black54,
        textStyle: TextStyle(fontSize: 10, color: Colors.black54),
        toolTipColor: Colors.white,
      ),
      width: 500,
      height: 500,
    )));

    await tester.pump(Duration(seconds: 1));

    await tester.tapAt(Offset(250, 250));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartAfterDragSingle.png'));
  });

  testWidgets('serie with same values', (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = Map();
    line[start] = 100.0;
    line[start.add(Duration(minutes: 5))] = 100.0;
    line[start.add(Duration(minutes: 10))] = 100.0;
    line[start.add(Duration(minutes: 15))] = 100.0;
    line[start.add(Duration(minutes: 20))] = 100.0;
    line[start.add(Duration(minutes: 25))] = 100.0;
    line[start.add(Duration(minutes: 30))] = 100.0;
    series.add(line);

    LineChart lineChart =
        LineChart.fromDateTimeMaps(series, [Colors.amber], ['W']);
    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    await tester.pumpWidget(buildTestableWidget(SizedBox(
      child: AnimatedLineChart(
        lineChart,
        gridColor: Colors.black54,
        textStyle: TextStyle(fontSize: 10, color: Colors.black54),
        toolTipColor: Colors.white,
      ),
      width: 500,
      height: 500,
    )));

    await tester.pump(Duration(seconds: 1));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartSerieWithSameValues.png'));
  });

  testWidgets('area chart', (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = Map();
    line[start] = 100.0;
    line[start.add(Duration(minutes: 5))] = 100.0;
    line[start.add(Duration(minutes: 10))] = 50.0;
    line[start.add(Duration(minutes: 15))] = 80.0;
    line[start.add(Duration(minutes: 20))] = 30.0;
    line[start.add(Duration(minutes: 25))] = 60.0;
    line[start.add(Duration(minutes: 30))] = 90.0;
    series.add(line);

    AreaLineChart lineChart =
        AreaLineChart.fromDateTimeMaps(series, [Colors.amber], ['W']);
    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    await tester.pumpWidget(buildTestableWidget(SizedBox(
      child: AnimatedLineChart(
        lineChart,
        gridColor: Colors.black54,
        textStyle: TextStyle(fontSize: 10, color: Colors.black54),
        toolTipColor: Colors.white,
      ),
      width: 500,
      height: 500,
    )));

    await tester.pump(Duration(seconds: 1));

    await expectLater(
        find.byType(AnimatedLineChart), matchesGoldenFile('areaChart.png'));
  });

  testWidgets('area chart with gradient', (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = Map();
    line[start] = 100.0;
    line[start.add(Duration(minutes: 5))] = 100.0;
    line[start.add(Duration(minutes: 10))] = 50.0;
    line[start.add(Duration(minutes: 15))] = 80.0;
    line[start.add(Duration(minutes: 20))] = 30.0;
    line[start.add(Duration(minutes: 25))] = 60.0;
    line[start.add(Duration(minutes: 30))] = 90.0;
    series.add(line);

    AreaLineChart lineChart = AreaLineChart.fromDateTimeMaps(
        series, [Colors.red.shade900], ['C'],
        gradients: [Pair(Colors.yellow.shade400, Colors.red.shade700)]);
    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    await tester.pumpWidget(buildTestableWidget(SizedBox(
      child: AnimatedLineChart(
        lineChart,
        gridColor: Colors.black54,
        textStyle: TextStyle(fontSize: 10, color: Colors.black54),
        toolTipColor: Colors.white,
      ),
      width: 500,
      height: 500,
    )));

    await tester.pump(Duration(seconds: 1));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('areaChartGradient.png'));
  });

  testWidgets('Test with upper and lower level dashed lines',
      (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = {};
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 0.5;
    line[start.add(Duration(minutes: 10))] = 1.7;

    Map<DateTime, double> upperCritical = {};
    upperCritical[start] = 2;
    upperCritical[start.add(Duration(minutes: 10))] = 2;

    Map<DateTime, double> lowerCritical = {};
    lowerCritical[start] = 0;
    lowerCritical[start.add(Duration(minutes: 10))] = 0;

    Map<DateTime, double> upperWarning = {};
    upperWarning[start] = 1.7;
    upperWarning[start.add(Duration(minutes: 10))] = 1.7;

    Map<DateTime, double> lowerWarning = {};
    lowerWarning[start] = 0.4;
    lowerWarning[start.add(Duration(minutes: 10))] = 0.4;

    series.add(line);
    series.add(upperCritical);
    series.add(upperWarning);
    series.add(lowerWarning);
    series.add(lowerCritical);

    LineChart lineChart = LineChart.fromDateTimeMaps(
        series,
        [Colors.pink, Colors.red, Colors.yellow, Colors.yellow, Colors.red],
        ['P', 'P', 'P', 'P', 'P']);

    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );
    lineChart.lines[1].isMarkerLine = true;
    lineChart.lines[2].isMarkerLine = true;
    lineChart.lines[3].isMarkerLine = true;
    lineChart.lines[4].isMarkerLine = true;

    await tester.pumpWidget(
      buildTestableWidget(
        AnimatedLineChart(
          lineChart,
          gridColor: Colors.black54,
          textStyle: TextStyle(fontSize: 10, color: Colors.black54),
          toolTipColor: Colors.white,
          showMarkerLines: true,
        ),
      ),
    );

    await tester.pump(Duration(seconds: 1));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartWithMarkerLines.png'));
  });

  testWidgets('Test with horizontal and vertical marker lines',
      (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = {};
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 0.5;
    line[start.add(Duration(minutes: 7))] = 1.7;
    line[start.add(Duration(minutes: 10))] = 1;

    Map<DateTime, double> upperCritical = {};
    upperCritical[start] = 2;
    upperCritical[start.add(Duration(minutes: 10))] = 2;

    Map<DateTime, double> lowerCritical = {};
    lowerCritical[start] = 0;
    lowerCritical[start.add(Duration(minutes: 10))] = 0;

    Map<DateTime, double> upperWarning = {};
    upperWarning[start] = 1.7;
    upperWarning[start.add(Duration(minutes: 7))] = 1.7;

    Map<DateTime, double> lowerWarning = {};
    lowerWarning[start] = 0.4;
    lowerWarning[start.add(Duration(minutes: 10))] = 0.4;

    series.add(line);
    series.add(upperCritical);
    series.add(upperWarning);
    series.add(lowerWarning);
    series.add(lowerCritical);

    LineChart lineChart = LineChart.fromDateTimeMaps(
        series,
        [Colors.pink, Colors.red, Colors.yellow, Colors.yellow, Colors.red],
        ['P', 'P', 'P', 'P', 'P']);

    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );
    lineChart.lines[1].isMarkerLine = true;
    lineChart.lines[2].isMarkerLine = true;
    lineChart.lines[3].isMarkerLine = true;
    lineChart.lines[4].isMarkerLine = true;

    await tester.pumpWidget(
      buildTestableWidget(
        AnimatedLineChart(
          lineChart,
          gridColor: Colors.black54,
          textStyle: TextStyle(fontSize: 10, color: Colors.black54),
          toolTipColor: Colors.white,
          showMarkerLines: true,
          verticalMarker: [
            start.add(Duration(minutes: 7)),
            start.add(Duration(minutes: 10))
          ],
          verticalMarkerColor: Colors.yellow,
          verticalMarkerIcon: [
            Icon(
              Icons.report_problem_rounded,
              color: Colors.yellow,
            ),
            Icon(
              Icons.clear,
              color: Colors.green,
            )
          ],
          iconBackgroundColor: Colors.white,
        ),
      ),
    );

    await tester.pumpAndSettle(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));

    await expectLater(
        find.byType(AnimatedLineChart),
        matchesGoldenFile(
            'animatedLineChartWithHorizontalAndVerticalMarkerLines.png'));
  });

  testWidgets('Test legends showing', (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();

    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = {};
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 0.5;
    line[start.add(Duration(minutes: 7))] = 1.7;
    line[start.add(Duration(minutes: 10))] = 1;

    series.add(line);

    LineChart lineChart =
        LineChart.fromDateTimeMaps(series, [Colors.pink], ['P']);

    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );

    binding.window.physicalSizeTestValue = Size(400, 800);
    binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      buildTestableWidget(
        AnimatedLineChart(
          lineChart,
          gridColor: Colors.black54,
          textStyle: TextStyle(fontSize: 10, color: Colors.black54),
          toolTipColor: Colors.white,
          legends: [
            Legend(
              title: 'Total',
              color: Colors.pink,
              showLeadingLine: true,
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartWithLegends.png'));

    binding.window.physicalSizeTestValue =
        Size(800, 600); //restting size of device screen back to default value
  });

  testWidgets('Test shaded area between marker lines',
      (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = {};
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 0.5;
    line[start.add(Duration(minutes: 7))] = 1.7;
    line[start.add(Duration(minutes: 10))] = 1;

    Map<DateTime, double> upperCritical = {};
    upperCritical[start] = 2;
    upperCritical[start.add(Duration(minutes: 10))] = 2;

    Map<DateTime, double> lowerCritical = {};
    lowerCritical[start] = 0;
    lowerCritical[start.add(Duration(minutes: 10))] = 0;

    Map<DateTime, double> upperWarning = {};
    upperWarning[start] = 1.7;
    upperWarning[start.add(Duration(minutes: 7))] = 1.7;

    Map<DateTime, double> lowerWarning = {};
    lowerWarning[start] = 0.4;
    lowerWarning[start.add(Duration(minutes: 10))] = 0.4;

    series.add(line);
    series.add(upperCritical);
    series.add(upperWarning);
    series.add(lowerWarning);
    series.add(lowerCritical);

    LineChart lineChart = LineChart.fromDateTimeMaps(
        series,
        [Colors.pink, Colors.red, Colors.yellow, Colors.yellow, Colors.red],
        ['P', 'P', 'P', 'P', 'P']);

    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );
    lineChart.lines[1].isMarkerLine = true;
    lineChart.lines[2].isMarkerLine = true;
    lineChart.lines[3].isMarkerLine = true;
    lineChart.lines[4].isMarkerLine = true;

    await tester.pumpWidget(
      buildTestableWidget(
        AnimatedLineChart(
          lineChart,
          gridColor: Colors.black54,
          textStyle: TextStyle(fontSize: 10, color: Colors.black54),
          toolTipColor: Colors.white,
          showMarkerLines: true,
          fillMarkerLines: true,
          filledMarkerLinesValues: [
            MaxMin.MAX,
            MaxMin.MAX,
            MaxMin.MIN,
            MaxMin.MIN,
          ],
        ),
      ),
    );

    await tester.pumpAndSettle(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartShadedAreaBetweenMarkerLines.png'));
  });

  testWidgets('Test legends on right hand side when landscape mode',
      (WidgetTester tester) async {
    DateTime start = DateTime.parse('2012-02-27 13:27:00');

    List<Map<DateTime, double>> series = [];
    Map<DateTime, double> line = {};
    line[start] = 1.2;
    line[start.add(Duration(minutes: 5))] = 0.5;
    line[start.add(Duration(minutes: 7))] = 1.7;
    line[start.add(Duration(minutes: 10))] = 1;

    Map<DateTime, double> upperCritical = {};
    upperCritical[start] = 10;
    upperCritical[start.add(Duration(minutes: 10))] = 10;

    Map<DateTime, double> lowerCritical = {};
    lowerCritical[start] = 0;
    lowerCritical[start.add(Duration(minutes: 10))] = 0;

    Map<DateTime, double> upperWarning = {};
    upperWarning[start] = 9.9;
    upperWarning[start.add(Duration(minutes: 7))] = 9.9;

    Map<DateTime, double> lowerWarning = {};
    lowerWarning[start] = 0.4;
    lowerWarning[start.add(Duration(minutes: 10))] = 0.4;

    series.add(line);
    series.add(upperCritical);
    series.add(upperWarning);
    series.add(lowerWarning);
    series.add(lowerCritical);

    LineChart lineChart = LineChart.fromDateTimeMaps(
        series,
        [Colors.pink, Colors.red, Colors.yellow, Colors.yellow, Colors.red],
        ['P', 'P', 'P', 'P', 'P']);

    lineChart.initialize(
      200,
      100,
      TextStyle(
          color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
    );
    lineChart.lines[1].isMarkerLine = true;
    lineChart.lines[2].isMarkerLine = true;
    lineChart.lines[3].isMarkerLine = true;
    lineChart.lines[4].isMarkerLine = true;

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData.fromWindow(ui.window)
            .copyWith(size: const Size(600.0, 800.0)),
        child: buildTestableWidget(
          AnimatedLineChart(
            lineChart,
            gridColor: Colors.black54,
            textStyle: TextStyle(fontSize: 10, color: Colors.black54),
            toolTipColor: Colors.white,
            showMarkerLines: true,
            legends: [
              Legend(
                title: 'Max: 10',
                color: Colors.red,
                showLeadingLine: true,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              Legend(
                title: 'High: 9.9',
                color: Colors.yellow,
                icon: Icon(Icons.report_problem_rounded),
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              Legend(
                title: 'Low',
                color: Colors.yellow,
                icon: Icon(Icons.report_problem_rounded),
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              Legend(
                title: 'Min',
                color: Colors.red,
                showLeadingLine: true,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
            legendsRightLandscapeMode: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartLandscapeModeLegends.png'));
  });
}
