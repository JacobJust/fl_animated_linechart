

import 'package:fl_animated_linechart/chart/area_line_chart.dart';
import 'package:fl_animated_linechart/fl_animated_linechart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../testHelpers/widget_test_helper.dart';

void main() {
  testWidgets('Test animations runs and disposes',
          (WidgetTester tester) async {
        DateTime start = DateTime.now();

        List<Map<DateTime, double>> series = List();
        Map<DateTime, double> line = Map();
        line[start] = 1.2;
        line[start.add(Duration(minutes: 5))] = 0.5;
        line[start.add(Duration(minutes: 10))] = 1.7;
        series.add(line);

        LineChart lineChart = LineChart.fromDateTimeMaps(series, [Colors.pink], ['P']);
        lineChart.initialize(200, 100);

        await tester.pumpWidget(buildTestableWidget(
            AnimatedLineChart(lineChart)
        ));

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
            DateTime start = DateTime.now();

            List<Map<DateTime, double>> series = List();
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

            LineChart lineChart = LineChart.fromDateTimeMaps(series.reversed.toList(), [Colors.amber, Colors.pink], ['P', 'P']);
            lineChart.initialize(200, 100);

            await tester.pumpWidget(buildTestableWidget(
                SizedBox(child: AnimatedLineChart(lineChart),
                width: 500,
                    height: 500,)
            ));

            await tester.pump(Duration(seconds: 1));

            TestGesture testGesture = await tester.startGesture(Offset(0, 250), pointer: 7);

            await tester.pump(Duration(milliseconds: 50));

            await expectLater(find.byType(AnimatedLineChart),
                matchesGoldenFile('animatedLineChartDuringDrag.png'));

            for (double c = 1; c < 100; c++) {
              await testGesture.moveBy(Offset(5 * c,0));
              await tester.pump(Duration(milliseconds: 50));
            }

            await testGesture.up();

            await tester.pump(Duration(milliseconds: 50));

            await expectLater(find.byType(AnimatedLineChart),
                matchesGoldenFile('animatedLineChartAfterDrag.png'));

          });

  testWidgets('Test horizontal drag multiple series different unit',
          (WidgetTester tester) async {
        DateTime start = DateTime.now();

        List<Map<DateTime, double>> series = List();
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

        LineChart lineChart = LineChart.fromDateTimeMaps(series.reversed.toList(), [Colors.amber, Colors.pink], ['C', 'F']);
        lineChart.initialize(200, 100);

        await tester.pumpWidget(buildTestableWidget(
            SizedBox(child: AnimatedLineChart(lineChart),
              width: 500,
              height: 500,)
        ));

        await tester.pump(Duration(seconds: 1));

        TestGesture testGesture = await tester.startGesture(Offset(0, 250), pointer: 7);

        await tester.pump(Duration(milliseconds: 50));

        await expectLater(find.byType(AnimatedLineChart),
            matchesGoldenFile('animatedLineChartDuringDragMultiUnit.png'));

        for (double c = 1; c < 100; c++) {
          await testGesture.moveBy(Offset(5 * c,0));
          await tester.pump(Duration(milliseconds: 50));
        }

        await testGesture.up();

        await tester.pump(Duration(milliseconds: 50));

        await expectLater(find.byType(AnimatedLineChart),
            matchesGoldenFile('animatedLineChartAfterDragMultiUnit.png'));

      });


  testWidgets('Test horizontal drag single serie',
          (WidgetTester tester) async {
        DateTime start = DateTime.now();

        List<Map<DateTime, double>> series = List();
        Map<DateTime, double> line = Map();
        line[start] = 1.2;
        line[start.add(Duration(minutes: 5))] = 0.5;
        line[start.add(Duration(minutes: 10))] = 1.7;
        line[start.add(Duration(minutes: 15))] = 1.7;
        line[start.add(Duration(minutes: 20))] = 1.7;
        line[start.add(Duration(minutes: 25))] = 1.7;
        line[start.add(Duration(minutes: 30))] = 1.7;
        series.add(line);

        LineChart lineChart = LineChart.fromDateTimeMaps(series, [Colors.amber], ['W']);
        lineChart.initialize(200, 100);

        await tester.pumpWidget(buildTestableWidget(
            SizedBox(child: AnimatedLineChart(lineChart),
              width: 500,
              height: 500,)
        ));

        await tester.pump(Duration(seconds: 1));

        TestGesture testGesture = await tester.startGesture(Offset(250, 250), pointer: 7);

        await tester.pump(Duration(milliseconds: 50));

        await expectLater(find.byType(AnimatedLineChart),
            matchesGoldenFile('animatedLineChartDuringDragSingle.png'));

        await testGesture.moveBy(Offset(20,0));

        await tester.pump(Duration(milliseconds: 50));

        await testGesture.moveBy(Offset(-200,0));

        await testGesture.up();

        await tester.pump(Duration(milliseconds: 50));

        await expectLater(find.byType(AnimatedLineChart),
            matchesGoldenFile('animatedLineChartAfterDragSingle.png'));

      });

  testWidgets('Test tooltip triggered by tap',
          (WidgetTester tester) async {
        DateTime start = DateTime.now();

        List<Map<DateTime, double>> series = List();
        Map<DateTime, double> line = Map();
        line[start] = 1.2;
        line[start.add(Duration(minutes: 5))] = 0.5;
        line[start.add(Duration(minutes: 10))] = 1.7;
        line[start.add(Duration(minutes: 15))] = 1.7;
        line[start.add(Duration(minutes: 20))] = 1.7;
        line[start.add(Duration(minutes: 25))] = 1.7;
        line[start.add(Duration(minutes: 30))] = 1.7;
        series.add(line);

        LineChart lineChart = LineChart.fromDateTimeMaps(series, [Colors.amber], ['W']);
        lineChart.initialize(200, 100);

        await tester.pumpWidget(buildTestableWidget(
            SizedBox(child: AnimatedLineChart(lineChart),
              width: 500,
              height: 500,)
        ));

        await tester.pump(Duration(seconds: 1));

        await tester.tapAt(Offset(250, 250));

        await expectLater(find.byType(AnimatedLineChart),
            matchesGoldenFile('animatedLineChartAfterDragSingle.png'));

      });

  testWidgets('serie with same values', (WidgetTester tester) async {
    DateTime start = DateTime.now();

    List<Map<DateTime, double>> series = List();
    Map<DateTime, double> line = Map();
    line[start] = 100.0;
    line[start.add(Duration(minutes: 5))] = 100.0;
    line[start.add(Duration(minutes: 10))] = 100.0;
    line[start.add(Duration(minutes: 15))] = 100.0;
    line[start.add(Duration(minutes: 20))] = 100.0;
    line[start.add(Duration(minutes: 25))] = 100.0;
    line[start.add(Duration(minutes: 30))] = 100.0;
    series.add(line);

    LineChart lineChart = LineChart.fromDateTimeMaps(series, [Colors.amber], ['W']);
    lineChart.initialize(200, 100);

    await tester.pumpWidget(buildTestableWidget(
        SizedBox(child: AnimatedLineChart(lineChart),
          width: 500,
          height: 500,)
    ));

    await tester.pump(Duration(seconds: 1));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('animatedLineChartSerieWithSameValues.png'));
  });

  testWidgets('area chart', (WidgetTester tester) async {
    DateTime start = DateTime.now();

    List<Map<DateTime, double>> series = List();
    Map<DateTime, double> line = Map();
    line[start] = 100.0;
    line[start.add(Duration(minutes: 5))] = 100.0;
    line[start.add(Duration(minutes: 10))] = 50.0;
    line[start.add(Duration(minutes: 15))] = 80.0;
    line[start.add(Duration(minutes: 20))] = 30.0;
    line[start.add(Duration(minutes: 25))] = 60.0;
    line[start.add(Duration(minutes: 30))] = 90.0;
    series.add(line);

    AreaLineChart lineChart = AreaLineChart.fromDateTimeMaps(series, [Colors.amber], ['W']);
    lineChart.initialize(200, 100);

    await tester.pumpWidget(buildTestableWidget(
        SizedBox(child: AnimatedLineChart(lineChart),
          width: 500,
          height: 500,)
    ));

    await tester.pump(Duration(seconds: 1));

    await expectLater(find.byType(AnimatedLineChart),
        matchesGoldenFile('areaChart.png'));
  });
}