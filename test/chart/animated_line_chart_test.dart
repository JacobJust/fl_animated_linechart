

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

        LineChart lineChart = LineChart.fromDateTimeMaps(series, [Colors.pink], 'E');
        lineChart.initialize(200, 100);

        await tester.pumpWidget(buildTestableWidget(
            AnimatedLineChart(lineChart)
        ));

        await tester.pump(Duration(milliseconds: 50));

        expect(tester.hasRunningAnimations, true);

        await expectLater(find.byType(AnimatedLineChart),
            matchesGoldenFile('animatedLineChartWhileAnimating.png'));

        await tester.pump(Duration(seconds: 1));

        expect(tester.hasRunningAnimations, false);

        await expectLater(find.byType(AnimatedLineChart),
            matchesGoldenFile('animatedLineChartAfterAnimation.png'));
    });

  testWidgets('Test horizontal drag',
          (WidgetTester tester) async {
            DateTime start = DateTime.now();

            List<Map<DateTime, double>> series = List();
            Map<DateTime, double> line = Map();
            line[start] = 1.2;
            line[start.add(Duration(minutes: 5))] = 0.5;
            line[start.add(Duration(minutes: 10))] = 1.7;
            series.add(line);

            LineChart lineChart = LineChart.fromDateTimeMaps(series, [Colors.amber], 'E');
            lineChart.initialize(200, 100);

            await tester.pumpWidget(buildTestableWidget(
                SizedBox(child: AnimatedLineChart(lineChart),
                width: 500,
                    height: 500,)
            ));

            await tester.pump(Duration(seconds: 1));

            await tester.startGesture(Offset(250, 250), pointer: 7);
            await tester.pump(Duration(milliseconds: 50));

            await expectLater(find.byType(AnimatedLineChart),
                matchesGoldenFile('animatedLineChartDuringDrag.png'));
      });
}