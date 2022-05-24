import 'dart:ui';

import 'package:fl_animated_linechart/chart/chart_line.dart';
import 'package:fl_animated_linechart/chart/datetime_chart_point.dart';
import 'package:fl_animated_linechart/common/dates.dart';
import 'package:fl_animated_linechart/common/pair.dart';

class DateTimeSeriesConverter {
  static Pair<List<ChartLine>, Dates> convertFromDateMaps(
      List<Map<DateTime, double>> series,
      List<Color> colors,
      List<String> units) {
    Dates minMax = _findMinMax(series);

    int index = 0;
    List<ChartLine> lines = series
        .map((map) => _convert(map, minMax, colors[index], units[index++]))
        .toList();

    return Pair(lines, minMax);
  }

  static ChartLine _convert(
      Map<DateTime, double> input, Dates minMax, Color color, String unit) {
    DateTime? from = minMax.min;

    List<DateTimeChartPoint> result = [];

    input.forEach((dateTime, value) {
      double x = dateTime.difference(from!).inSeconds.toDouble();
      double y = value;
      result.add(DateTimeChartPoint(x, y, dateTime));
    });

    return ChartLine(result, color, unit);
  }

  static Dates _findMinMax(List<Map<DateTime, double>> list) {
    DateTime? min;
    DateTime? max;

    list.forEach((map) {
      map.keys.forEach((dateTime) {
        if (min == null) {
          min = dateTime;
          max = dateTime;
        } else {
          if (dateTime.isBefore(min!)) {
            min = dateTime;
          }
          if (dateTime.isAfter(max!)) {
            max = dateTime;
          }
        }
      });
    });

    return Dates(min, max);
  }
}
