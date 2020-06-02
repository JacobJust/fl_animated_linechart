import 'dart:math';

import 'package:fl_animated_linechart/chart/chart_line.dart';
import 'package:fl_animated_linechart/chart/chart_point.dart';
import 'package:fl_animated_linechart/chart/datetime_chart_point.dart';
import 'package:fl_animated_linechart/chart/datetime_series_converter.dart';
import 'package:fl_animated_linechart/chart/highlight_point.dart';
import 'package:fl_animated_linechart/common/dates.dart';
import 'package:fl_animated_linechart/common/pair.dart';
import 'package:fl_animated_linechart/common/text_direction_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class LineChart {
  final DateFormat formatHoursMinutes;
  final DateFormat formatDayMonth;
  static const String _defaultFormatHoursMinutes = 'kk:mm';
  static const String _defaultFormatDayMonth = 'dd/MM';
  final double _effectiveChartHeightRatio = 5 / 6;
  final FontWeight tapTextFontWeight;
  //The lines / points should only draw to 5/6 from the top of the chart area

  static final double axisMargin = 5.0;
  static final double axisOffsetPX = 50.0;
  static final double stepCount = 5;

  final List<ChartLine> lines;
  final Dates fromTo;
  double _minX = 0;
  double _maxX = 0;
  double _xAxisOffsetPX = 0;
  double _xAxisOffsetPXright = 0;

  Map<String, double> _minY;
  Map<String, double> _maxY;
  Map<String, double> _yScales;
  Map<String, double> _yTicks;

  double _widthStepSize;
  double _heightStepSize;
  double _xScale;
  double _xOffset;
  Map<int, List<HighlightPoint>> _seriesMap;
  Map<int, Path> _pathMap;
  double _axisOffSetWithPadding;
  Map<int, List<TextPainter>> _yAxisTexts;
  List<TextPainter> _xAxisTexts;
  Map<int, String> indexToUnit;

  LineChart(this.lines, this.fromTo,
      {this.tapTextFontWeight, String formatHoursMinutes = _defaultFormatHoursMinutes, String formatDayMonth = _defaultFormatDayMonth})
      : this.formatHoursMinutes = DateFormat(formatHoursMinutes),
        this.formatDayMonth = DateFormat(formatDayMonth);

  factory LineChart.fromDateTimeMaps(List<Map<DateTime, double>> series, List<Color> colors, List<String> units,
      {FontWeight tapTextFontWeight}) {
    assert(series.length == colors.length);
    assert(series.length == units.length);

    Pair<List<ChartLine>, Dates> convertFromDateMaps = DateTimeSeriesConverter.convertFromDateMaps(series, colors, units);
    return LineChart(convertFromDateMaps.left, convertFromDateMaps.right, tapTextFontWeight: tapTextFontWeight);
  }

  double get width => _maxX - _minX;
  double get minX => _minX;
  double get maxX => _maxX;
  double get xAxisOffsetPX => _xAxisOffsetPX;
  double get xAxisOffsetPXright => _xAxisOffsetPXright;

  double minY(String unit) => _minY[unit];
  double maxY(String unit) => _maxY[unit];
  double height(String unit) => _maxY[unit] - _minY[unit];
  double yScale(String unit) => _yScales[unit];

  void _calcScales(double heightPX) {
    Map<String, Pair> unitToMinMaxY = Map();

    lines.forEach((line) {
      if (unitToMinMaxY.containsKey(line.unit)) {
        double minY = min(unitToMinMaxY[line.unit].left, line.minY);
        double maxY = max(unitToMinMaxY[line.unit].right, line.maxY);

        unitToMinMaxY[line.unit] = Pair(minY, maxY);
      } else {
        unitToMinMaxY[line.unit] = Pair(line.minY, line.maxY);
      }

      if (line.minX < _minX) {
        _minX = line.minX;
      }
      if (line.maxX > _maxX) {
        _maxX = line.maxX;
      }
    });

    _minY = Map();
    _maxY = Map();
    _yScales = Map();
    indexToUnit = Map();

    int i = 0;
    unitToMinMaxY.forEach((key, value) {
      _minY[key] = value.left;
      _maxY[key] = value.right;
      _yScales[key] = ((heightPX - axisOffsetPX) / height(key)) * _effectiveChartHeightRatio;
      indexToUnit[i++] = key;
    });
  }

  //Calculate ui pixels values
  void initialize(double widthPX, double heightPX) {
    _calcScales(heightPX);

    //calc axis textpainters, before using
    _yTicks = Map();

    int index = 0;
    lines.forEach((chartLine) {
      _yTicks[chartLine.unit] = height(chartLine.unit) / 5;
      index++;
    });

    _yAxisTexts = Map();

    double maxLeft = 0;
    double maxRight = 1;

    for (int axisIndex = 0; axisIndex < indexToUnit.length; axisIndex++) {
      List<TextPainter> painters = List();
      _yAxisTexts[axisIndex] = painters;
      String unit = indexToUnit[axisIndex];

      for (int c = 0; c <= (stepCount + 1); c++) {
        double axisValue = (_minY[unit] + _yTicks[unit] * c);

        String axisValueString;

        if (_yTicks[unit] < 1) {
          axisValueString = axisValue.toStringAsFixed(2);

          if (axisValueString.endsWith('0')) {
            axisValueString = axisValueString.substring(0, axisValueString.length - 1);
          }
        } else if (_yTicks[unit] <= 10) {
          axisValueString = axisValue.toStringAsFixed(1);
        } else {
          axisValueString = axisValue.round().toString();
        }

        TextSpan span =
            new TextSpan(style: new TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w200, fontSize: 10), text: axisValueString);
        TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.right, textDirection: TextDirectionHelper.getDirection());
        tp.layout();

        if (axisIndex == 0) {
          maxLeft = max(tp.width + axisMargin, maxLeft);
        } else {
          maxRight = max(tp.width + axisMargin, maxRight);
        }

        painters.add(tp);
      }
    }
    _xAxisOffsetPX = maxLeft;
    _xAxisOffsetPXright = maxRight;

    _widthStepSize = (widthPX - maxLeft - maxRight) / (stepCount + 1);
    _heightStepSize = (heightPX - axisOffsetPX) / (stepCount + 1);

    _xScale = (widthPX - xAxisOffsetPX - maxRight) / width;
    _xOffset = minX * _xScale;

    _seriesMap = Map();
    _pathMap = Map();

    index = 0;
    lines.forEach((chartLine) {
      chartLine.points.forEach((p) {
        double x = (p.x * xScale) - xOffset;

        double adjustedY = (p.y * _yScales[chartLine.unit]) - (_minY[chartLine.unit] * _yScales[chartLine.unit]);

        double y = (heightPX - axisOffsetPX) - adjustedY;

        //adjust to make room for axis values:
        x += xAxisOffsetPX;
        if (_seriesMap[index] == null) {
          _seriesMap[index] = List();
        }

        if (p is DateTimeChartPoint) {
          _seriesMap[index].add(HighlightPoint(DateTimeChartPoint(x, y, p.dateTime), p.y));
        } else {
          _seriesMap[index].add(HighlightPoint(ChartPoint(x, y), p.y));
        }
      });

      index++;
    });

    _axisOffSetWithPadding = xAxisOffsetPX - axisMargin;
    _xAxisTexts = [];

    //Todo: make the axis part generic, to support both string, dates, and numbers
    Duration duration = fromTo.max.difference(fromTo.min);
    double stepInSeconds = duration.inSeconds.toDouble() / (stepCount + 1);

    for (int c = 0; c <= (stepCount + 1); c++) {
      DateTime tick = fromTo.min.add(Duration(seconds: (stepInSeconds * c).round()));

      TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.grey[800], fontSize: 11.0, fontWeight: FontWeight.w200),
          text: _formatDateTime(tick, duration));
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.right, textDirection: TextDirectionHelper.getDirection());
      tp.layout();

      _xAxisTexts.add(tp);
    }
  }

  String _formatDateTime(DateTime dateTime, Duration duration) {
    if (duration.inHours < 30) {
      return formatHoursMinutes.format(dateTime.toLocal());
    } else {
      return formatDayMonth.format(dateTime.toLocal());
    }
  }

  double get heightStepSize => _heightStepSize;
  double get widthStepSize => _widthStepSize;

  double get xOffset => _xOffset;
  double get xScale => _xScale;

  Map<int, List<HighlightPoint>> get seriesMap => _seriesMap;

  double get axisOffSetWithPadding => _axisOffSetWithPadding;

  List<TextPainter> yAxisTexts(int index) => _yAxisTexts[index];

  int get yAxisCount => _yAxisTexts.length;

  List<TextPainter> get xAxisTexts => _xAxisTexts;

  List<HighlightPoint> getClosetHighlightPoints(double horizontalDragPosition) {
    List<HighlightPoint> highlights = List();

    seriesMap.forEach((key, list) {
      HighlightPoint closest = _findClosest(list, horizontalDragPosition);
      highlights.add(closest);
    });

    return highlights;
  }

  HighlightPoint _findClosest(List<HighlightPoint> list, double horizontalDragPosition) {
    HighlightPoint candidate = list[0];

    double candidateDist = ((candidate.chartPoint.x) - horizontalDragPosition).abs();
    for (HighlightPoint alternative in list) {
      double alternativeDist = ((alternative.chartPoint.x) - horizontalDragPosition).abs();

      if (alternativeDist < candidateDist) {
        candidate = alternative;
        candidateDist = ((candidate.chartPoint.x) - horizontalDragPosition).abs();
      }
      if (alternativeDist > candidateDist) {
        break;
      }
    }

    return candidate;
  }

  Path getPathCache(int index) {
    if (_pathMap.containsKey(index)) {
      return _pathMap[index];
    } else {
      Path path = Path();

      bool init = true;

      this.seriesMap[index].forEach((p) {
        if (init) {
          init = false;
          path.moveTo(p.chartPoint.x, p.chartPoint.y);
        }

        path.lineTo(p.chartPoint.x, p.chartPoint.y);
      });

      _pathMap[index] = path;

      return path;
    }
  }
}
