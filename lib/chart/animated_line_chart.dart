import 'dart:math';

import 'package:fl_animated_linechart/chart/area_line_chart.dart';
import 'package:fl_animated_linechart/chart/datetime_chart_point.dart';
import 'package:fl_animated_linechart/chart/highlight_point.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:fl_animated_linechart/common/animated_path_util.dart';
import 'package:fl_animated_linechart/common/pair.dart';
import 'package:fl_animated_linechart/common/text_direction_helper.dart';
import 'package:fl_animated_linechart/common/tuple_3.dart';
import 'package:fl_animated_linechart/fl_animated_linechart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:path_drawing/path_drawing.dart';

typedef TapText = String Function(String prefix, double y, String unit);

enum MaxMin { MAX, MIN }

class AnimatedLineChart extends StatefulWidget {
  final LineChart chart;
  final TapText? tapText;
  final TextStyle? textStyle;
  final Color toolTipColor;
  final Color gridColor;
  final List<Legend>? legends;
  final bool? showMarkerLines;
  final List<DateTime> verticalMarker;
  final Color? verticalMarkerColor;
  final List<Icon>? verticalMarkerIcon;
  final Color? iconBackgroundColor;
  final bool? fillMarkerLines;
  final double? innerGridStrokeWidth;
  final List<MaxMin>? filledMarkerLinesValues;
  final bool? legendsRightLandscapeMode;

  const AnimatedLineChart(
    this.chart, {
    Key? key,
    this.tapText,
    this.textStyle,
    required this.gridColor,
    required this.toolTipColor,
    this.legends = const [],
    this.showMarkerLines = false,
    this.verticalMarker = const [],
    this.verticalMarkerColor,
    this.verticalMarkerIcon = const [],
    this.iconBackgroundColor,
    this.fillMarkerLines = false,
    this.innerGridStrokeWidth = 0.0,
    this.filledMarkerLinesValues = const [],
    this.legendsRightLandscapeMode = false,
  }) : super(key: key);

  @override
  _AnimatedLineChartState createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<AnimatedLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation? _animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));

    Animation curve = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _animation = Tween(begin: 0.0, end: 1.0).animate(curve as Animation<double>);

    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) => orientation == Orientation.landscape &&
              widget.legends != null &&
              widget.legends!.isNotEmpty &&
              widget.legendsRightLandscapeMode == true
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    widget.chart.initialize(constraints.maxWidth,
                        constraints.maxHeight, widget.textStyle);
                    return _GestureWrapper(
                      widget.chart,
                      _animation,
                      tapText: widget.tapText,
                      gridColor: widget.gridColor,
                      textStyle: widget.textStyle,
                      toolTipColor: widget.toolTipColor,
                      legends: widget.legends,
                      showMarkerLines: widget.showMarkerLines,
                      verticalMarker: widget.verticalMarker,
                      verticalMarkerColor: widget.verticalMarkerColor,
                      verticalMarkerIcon: widget.verticalMarkerIcon,
                      iconBackgroundColor: widget.iconBackgroundColor,
                      fillMarkerLines: widget.fillMarkerLines,
                      innerGridStrokeWidth: widget.innerGridStrokeWidth,
                      filledMarkerLinesValues: widget.filledMarkerLinesValues,
                      legendsRightLandscapeMode:
                          widget.legendsRightLandscapeMode,
                    );
                  }),
                ),
                Visibility(
                  visible: widget.legends != null && widget.legends!.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: Wrap(
                        direction: Axis.vertical,
                        children: widget.legends!.map((legend) {
                          assertLegends();
                          return Padding(
                            padding: const EdgeInsets.only(
                                right: 4.0, top: 5, left: 4.0),
                            child: legend,
                          );
                        }).toList()),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    widget.chart.initialize(constraints.maxWidth,
                        constraints.maxHeight, widget.textStyle);
                    return _GestureWrapper(
                      widget.chart,
                      _animation,
                      tapText: widget.tapText,
                      gridColor: widget.gridColor,
                      textStyle: widget.textStyle,
                      toolTipColor: widget.toolTipColor,
                      legends: widget.legends,
                      showMarkerLines: widget.showMarkerLines,
                      verticalMarker: widget.verticalMarker,
                      verticalMarkerColor: widget.verticalMarkerColor,
                      verticalMarkerIcon: widget.verticalMarkerIcon,
                      iconBackgroundColor: widget.iconBackgroundColor,
                      fillMarkerLines: widget.fillMarkerLines,
                      innerGridStrokeWidth: widget.innerGridStrokeWidth,
                      filledMarkerLinesValues: widget.filledMarkerLinesValues,
                      legendsRightLandscapeMode: false,
                    );
                  }),
                ),
                Visibility(
                  visible: widget.legends != null && widget.legends!.isNotEmpty,
                  child: Wrap(
                      direction: Axis.horizontal,
                      children: widget.legends!.map((legend) {
                        assertLegends();

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 4.0, top: 5, left: 4.0),
                              child: legend,
                            ),
                          ],
                        );
                      }).toList()),
                ),
              ],
            ),
    );
  }

  void assertLegends() {
    assert(widget.legends!.length ==
            widget.chart.lines.where((line) => line.isMarkerLine).length ||
        widget.legends!.length ==
            widget.chart.lines
                .where((line) => line.isMarkerLine == false)
                .length ||
        widget.legends!.length == widget.chart.lines.length);
  }
}

//Wrap gestures, to avoid reinitializing the chart model when doing gestures
class _GestureWrapper extends StatefulWidget {
  final LineChart _chart;
  final Animation? _animation;
  final TapText? tapText;
  final TextStyle? textStyle;
  final Color? toolTipColor;
  final Color? gridColor;
  final List<Legend>? legends;
  final bool? showMarkerLines;
  final List<DateTime>? verticalMarker;
  final Color? verticalMarkerColor;
  final List<Icon>? verticalMarkerIcon;
  final Color? iconBackgroundColor;
  final bool? fillMarkerLines;
  final double? innerGridStrokeWidth;
  final List<MaxMin>? filledMarkerLinesValues;
  final bool? legendsRightLandscapeMode;

  const _GestureWrapper(
    this._chart,
    this._animation, {
    Key? key,
    this.tapText,
    this.gridColor,
    this.toolTipColor,
    this.textStyle,
    this.legends = const [],
    this.showMarkerLines = false,
    this.verticalMarker = const [],
    this.verticalMarkerColor,
    this.verticalMarkerIcon = const [],
    this.iconBackgroundColor,
    this.fillMarkerLines = false,
    this.innerGridStrokeWidth = 0.0,
    this.filledMarkerLinesValues = const [],
    this.legendsRightLandscapeMode = false,
  }) : super(key: key);

  @override
  _GestureWrapperState createState() => _GestureWrapperState();
}

class _GestureWrapperState extends State<_GestureWrapper> {
  bool _horizontalDragActive = false;
  double _horizontalDragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _AnimatedChart(
        widget._chart,
        _horizontalDragActive,
        _horizontalDragPosition,
        animation: widget._animation!,
        tapText: widget.tapText,
        gridColor: widget.gridColor,
        style: widget.textStyle,
        toolTipColor: widget.toolTipColor,
        legends: widget.legends,
        showMarkerLines: widget.showMarkerLines,
        verticalMarker: widget.verticalMarker,
        verticalMarkerColor: widget.verticalMarkerColor,
        verticalMarkerIcon: widget.verticalMarkerIcon,
        iconBackgroundColor: widget.iconBackgroundColor,
        fillMarkerLines: widget.fillMarkerLines,
        innerGridStrokeWidth: widget.innerGridStrokeWidth,
        filledMarkerLinesValues: widget.filledMarkerLinesValues,
        legendsRightLandscapeMode: widget.legendsRightLandscapeMode,
      ),
      onTapDown: (tap) {
        _horizontalDragActive = true;
        _horizontalDragPosition = tap.globalPosition.dx;
        setState(() {});
      },
      onHorizontalDragStart: (dragStartDetails) {
        _horizontalDragActive = true;
        _horizontalDragPosition = dragStartDetails.globalPosition.dx;
        setState(() {});
      },
      onHorizontalDragUpdate: (dragUpdateDetails) {
        _horizontalDragPosition += dragUpdateDetails.primaryDelta!;
        setState(() {});
      },
      onHorizontalDragEnd: (dragEndDetails) {
        _horizontalDragActive = false;
        _horizontalDragPosition = 0.0;
        setState(() {});
      },
      onTapUp: (tap) {
        _horizontalDragActive = false;
        _horizontalDragPosition = 0.0;
        setState(() {});
      },
    );
  }
}

class _AnimatedChart extends AnimatedWidget {
  final LineChart _chart;
  final bool _horizontalDragActive;
  final double _horizontalDragPosition;
  final TapText? tapText;
  final TextStyle? style;
  final Color? gridColor;
  final Color? toolTipColor;
  final List<Legend>? legends;
  final bool? showMarkerLines;
  final List<DateTime>? verticalMarker;
  final Color? verticalMarkerColor;
  final List<Icon>? verticalMarkerIcon;
  final Color? iconBackgroundColor;
  final bool? fillMarkerLines;
  final double? innerGridStrokeWidth;
  final List<MaxMin>? filledMarkerLinesValues;
  final bool? legendsRightLandscapeMode;

  _AnimatedChart(
    this._chart,
    this._horizontalDragActive,
    this._horizontalDragPosition, {
    this.tapText,
    Key? key,
    required Animation animation,
    this.style,
    this.gridColor,
    this.toolTipColor,
    this.legends = const [],
    this.showMarkerLines = false,
    this.verticalMarker = const [],
    this.verticalMarkerColor,
    this.verticalMarkerIcon = const [],
    this.iconBackgroundColor,
    this.fillMarkerLines = false,
    this.innerGridStrokeWidth = 0.0,
    this.filledMarkerLinesValues = const [],
    this.legendsRightLandscapeMode = false,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation animation = listenable as Animation;

    return CustomPaint(
      painter: ChartPainter(
        animation.value,
        _chart,
        _horizontalDragActive,
        _horizontalDragPosition,
        style,
        tapText: tapText,
        gridColor: gridColor!,
        toolTipColor: toolTipColor!,
        legends: legends,
        showMarkerLines: showMarkerLines,
        verticalMarker: verticalMarker,
        verticalMarkerColor: verticalMarkerColor,
        verticalMarkerIcon: verticalMarkerIcon,
        iconBackgroundColor: iconBackgroundColor,
        fillMarkerLines: fillMarkerLines,
        innerGridStrokeWidth: innerGridStrokeWidth,
        filledMarkerLinesValues: filledMarkerLinesValues,
        legendsRightLandscapeMode: legendsRightLandscapeMode,
      ),
      child: Container(),
    );
  }
}

class ChartPainter extends CustomPainter {
  static final double _stepCount = 5;

  final DateFormat _formatMonthDayHoursMinutes = DateFormat('dd/MM kk:mm');

  final Paint _gridPainter = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  Paint _linePainter = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  Paint _fillPainter = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 2;

  Paint _tooltipPainter = Paint()..style = PaintingStyle.fill;

  final double _progress;
  final LineChart _chart;
  final bool _horizontalDragActive;
  final double _horizontalDragPosition;

  final List<Legend>? legends;
  final bool? showMarkerLines;
  final List<DateTime>? verticalMarker;
  final Color? verticalMarkerColor;
  final List<Icon>? verticalMarkerIcon;
  final Color? iconBackgroundColor;
  final bool? fillMarkerLines;
  final double? innerGridStrokeWidth;
  final List<MaxMin>? filledMarkerLinesValues;
  final bool? legendsRightLandscapeMode;

  TapText? tapText;
  final TextStyle? style;

  static final TapText _defaultTapText =
      (prefix, y, unit) => '$prefix: ${y.toStringAsFixed(1)} $unit';

  ChartPainter(
    this._progress,
    this._chart,
    this._horizontalDragActive,
    this._horizontalDragPosition,
    this.style, {
    this.tapText,
    required Color gridColor,
    required Color toolTipColor,
    this.legends = const [],
    this.showMarkerLines = false,
    this.verticalMarker = const [],
    this.verticalMarkerColor,
    this.verticalMarkerIcon = const [],
    this.iconBackgroundColor,
    this.fillMarkerLines = false,
    this.innerGridStrokeWidth = 0.0,
    this.filledMarkerLinesValues = const [],
    this.legendsRightLandscapeMode = false,
  }) {
    tapText = tapText ?? _defaultTapText;
    _tooltipPainter.color = toolTipColor;
    _gridPainter.color = gridColor;
    _linePainter.color = gridColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawUnits(canvas, size, style);
    _drawLines(size, canvas);
    _drawAxisValues(canvas, size);

    if (showMarkerLines! &&
        fillMarkerLines! &&
        filledMarkerLinesValues != null &&
        filledMarkerLinesValues!.isNotEmpty) {
      _drawShadedAreaBetweenLines(size, canvas);
    }

    if (_horizontalDragActive) {
      _drawHighlights(
        size,
        canvas,
        _chart.tapTextFontWeight,
        _tooltipPainter.color,
      );
    }

    if (verticalMarker != null && verticalMarker!.isNotEmpty) {
      _drawVerticalMarkers(size, canvas);
    }
  }

  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  void _drawHighlights(Size size, Canvas canvas, FontWeight? tapTextFontWeight,
      Color onTapLineColor) {
    _linePainter.color = onTapLineColor;

    if (_horizontalDragPosition > LineChart.axisOffsetPX &&
        _horizontalDragPosition < size.width) {
      canvas.drawLine(
          Offset(_horizontalDragPosition, 0),
          Offset(_horizontalDragPosition, size.height - LineChart.axisOffsetPX),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = brightness == Brightness.dark
                ? Colors.grey
                : _gridPainter.color);
    }

    List<HighlightPoint> highlights =
        _chart.getClosetHighlightPoints(_horizontalDragPosition);

    List<TextPainter> textPainters = [];
    int index = 0;
    double minHighlightX = highlights[0].chartPoint.x;
    double minHighlightY = highlights[0].chartPoint.y;
    double maxWidth = 0;

    highlights.forEach((highlight) {
      if (highlight.chartPoint.x < minHighlightX) {
        minHighlightX = highlight.chartPoint.x;
      }
      if (highlight.chartPoint.y < minHighlightY) {
        minHighlightY = highlight.chartPoint.y;
      }
    });

    highlights.forEach((highlight) {
      if (!_chart.lines[index].isMarkerLine) {
        canvas.drawCircle(Offset(highlight.chartPoint.x, highlight.chartPoint.y),
            5, _linePainter);
      }

      String prefix = '';

      if (highlight.chartPoint is DateTimeChartPoint) {
        DateTimeChartPoint dateTimeChartPoint =
            highlight.chartPoint as DateTimeChartPoint;
        prefix = _formatMonthDayHoursMinutes.format(dateTimeChartPoint.dateTime);
      }

      TextSpan span = TextSpan(
          style: style,
          text: tapText!(
            prefix,
            highlight.yValue,
            _chart.lines[index].unit,
          ));
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.right,
          textDirection: TextDirectionHelper.getDirection());

      tp.layout();

      if (tp.width > maxWidth) {
        maxWidth = tp.width;
      }

      if (!_chart.lines[index]
          .isMarkerLine) // do not show markerline values in highlight box
      {
        textPainters.add(tp);
      }

      index++;
    });

    minHighlightX += 12; //make room for the chart points
    double tooltipHeight = textPainters[0].height * textPainters.length + 16;

    if ((minHighlightX + maxWidth + 16) > size.width) {
      minHighlightX -= maxWidth;
      minHighlightX -= 34;
    }

    if (minHighlightY + tooltipHeight >
        size.height - _chart.axisOffSetWithPadding!) {
      minHighlightY =
          size.height - _chart.axisOffSetWithPadding! - tooltipHeight;
    }

    //Draw highlight bordered box:
    Rect tooltipRect = Rect.fromLTWH(
        minHighlightX - 5, minHighlightY - 5, maxWidth + 20, tooltipHeight);
    canvas.drawRect(tooltipRect, _tooltipPainter);
    canvas.drawRect(tooltipRect, _gridPainter);

    //Draw the actual highlights:
    textPainters.forEach((tp) {
      tp.paint(canvas, Offset(minHighlightX + 5, minHighlightY));
      minHighlightY += 17;
    });
  }

  void _drawAxisValues(Canvas canvas, Size size) {
    //TODO: calculate and cache

    //Draw main axis, should always be available:
    for (int c = 0; c <= (_stepCount + 1); c++) {
      TextPainter tp = _chart.yAxisTexts(0)![c];
      tp.paint(
          canvas,
          Offset(
              _chart.axisOffSetWithPadding! - tp.width,
              (size.height - 6) -
                  (c * _chart.heightStepSize!) -
                  LineChart.axisOffsetPX));
    }

    if (_chart.yAxisCount == 2) {
      for (int c = 0; c <= (_stepCount + 1); c++) {
        TextPainter tp = _chart.yAxisTexts(1)![c];
        tp.paint(
            canvas,
            Offset(
                LineChart.axisMargin + size.width - _chart.xAxisOffsetPXright,
                (size.height - 6) -
                    (c * _chart.heightStepSize!) -
                    LineChart.axisOffsetPX));
      }
    }

    //TODO: calculate and cache
    for (int c = 0; c <= (_stepCount + 1); c++) {
      _drawRotatedText(
          canvas,
          _chart.xAxisTexts![c],
          _chart.axisOffSetWithPadding! + (c * _chart.widthStepSize!),
          size.height - (LineChart.axisOffsetPX - 5),
          pi * 1.5);
    }
  }

  double firstVerticalMarkerX = 0.0;
  double firstVerticalMarkerY = 0.0;
  double lastVerticalMarkerX = 0.0;
  double lastVerticalMarkerY = 0.0;
  void _drawLines(Size size, Canvas canvas) {
    int index = 0;

    _chart.lines.forEach((chartLine) {
      _linePainter.color = chartLine.color;
      Path? path;

      List<HighlightPoint> points = _chart.seriesMap?[index] ?? [];

      bool drawCircles = points.length < 100;

      if (_progress < 1.0) {
        path = AnimatedPathUtil.createAnimatedPath(
            _chart.getPathCache(index)!, _progress);
      } else {
        path = _chart.getPathCache(index);
        if (!chartLine.isMarkerLine) {
          points.forEach((p) {
            if (p.chartPoint is DateTimeChartPoint) {
              DateTimeChartPoint dateTimeChartPoint =
                  p.chartPoint as DateTimeChartPoint;
              if (this.verticalMarker != null &&
                  this.verticalMarker!.isNotEmpty) {
                _setVerticalMarkerChartPoints(dateTimeChartPoint);
              }
            }

            if (drawCircles) {
              canvas.drawCircle(
                  Offset(p.chartPoint.x, p.chartPoint.y), 2, _linePainter);
            }
          });
        }
      }

      if (chartLine.isMarkerLine && showMarkerLines!) {
        canvas.drawPath(
            dashPath(
              path!,
              dashArray: CircularIntervalList<double>(<double>[15.0, 5.0]),
            ),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = _linePainter.color
              ..strokeWidth = 1);
      } else {
        canvas.drawPath(path!, _linePainter);
      }

      if (_chart is AreaLineChart) {
        AreaLineChart areaLineChart = _chart as AreaLineChart;

        if (areaLineChart.gradients != null) {
          Pair<Color, Color> gradient = areaLineChart.gradients![index];

          _fillPainter.shader = LinearGradient(stops: [
            0.0,
            0.6
          ], colors: [
            gradient.left.withAlpha((220 * _progress).round()),
            gradient.right.withAlpha((220 * _progress).round())
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter)
              .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        } else {
          _fillPainter.color =
              chartLine.color.withAlpha((200 * _progress).round());
        }

        Path areaPathCache = areaLineChart.getAreaPathCache(index)!;

        canvas.drawPath(areaPathCache, _fillPainter);
      }

      index++;
    });
  }

  void _setVerticalMarkerChartPoints(DateTimeChartPoint dateTimeChartPoint) {
    List<DateTime>? verticalMarkers = this.verticalMarker;
    if (verticalMarkers!.isNotEmpty &&
        dateTimeChartPoint.dateTime.difference(verticalMarkers.first) <
            Duration(minutes: 1)) {
      firstVerticalMarkerX = dateTimeChartPoint.x;
      firstVerticalMarkerY = dateTimeChartPoint.y;
    }

    if (verticalMarkers.length == 2 &&
        dateTimeChartPoint.dateTime.difference(verticalMarkers.last) <
            Duration(minutes: 1)) {
      lastVerticalMarkerX = dateTimeChartPoint.x;
      lastVerticalMarkerY = dateTimeChartPoint.y;
    }
  }

  void _drawShadedAreaBetweenLines(Size size, Canvas canvas) {
    assert(filledMarkerLinesValues!.length ==
        _chart.lines.where((line) => line.isMarkerLine).length);

    List values = [];

    if (_chart.seriesMap != null) {
      _chart.seriesMap!.forEach((key, value) {
        if (key == 0) {
        } else {
          value.forEach((highlightPoint) {
            values.add(highlightPoint.chartPoint.y);
          });
        }
      });
    }

    List distinctValues = values.toSet().toList();

    List<Tuple3> sortedList = [];

    for (int i = 0; i < distinctValues.length; i++) {
      sortedList.add(Tuple3(filledMarkerLinesValues![i], distinctValues[i],
          _chart.lines[i + 1].color));
    }

    sortedList.sort((a, b) => a.middle.compareTo(b.middle));

    for (int i = 0; i < sortedList.length; i++) {
      if (sortedList[i].left == MaxMin.MAX) {
        canvas.drawRect(
            Rect.fromPoints(
              Offset(_chart.xAxisOffsetPX, sortedList[i].middle),
              Offset(size.width, i >= 1 ? sortedList[i - 1].middle : 0),
            ),
            Paint()..color = sortedList[i].right.withOpacity(0.1));
      } else {
        canvas.drawRect(
            Rect.fromPoints(
              Offset(_chart.xAxisOffsetPX, sortedList[i].middle),
              Offset(
                  size.width,
                  sortedList[i].middle == distinctValues.last ||
                          sortedList[i] == sortedList.last
                      ? size.height - LineChart.axisOffsetPX
                      : sortedList[i + 1].middle),
            ),
            Paint()..color = sortedList[i].right.withOpacity(0.1));
      }
    }
  }

  void _drawVerticalMarkers(Size size, Canvas canvas) {
    assert(verticalMarker!.length <= 2);

    final firstVerticalMarker = firstVerticalMarkerX;

    // Set the paint style for the line
    final verticalMarkerPaint = Paint()
      ..color = verticalMarkerColor ?? Colors.blueAccent
      ..strokeWidth = 2;

    // Draw the line
    bool loaded = firstVerticalMarkerX > 0;
    if (loaded) {
      canvas.drawLine(
          Offset(firstVerticalMarker, 0),
          Offset(firstVerticalMarker, size.height - LineChart.axisOffsetPX),
          verticalMarkerPaint);

      if (verticalMarkerIcon != null && verticalMarkerIcon!.isNotEmpty) {
        assert(verticalMarkerIcon!.length == verticalMarker!.length);
        TextPainter firstIconTp = TextPainter(
          textDirection: TextDirectionHelper.getDirection(),
        );

        firstIconTp.text = TextSpan(
          text: String.fromCharCode(verticalMarkerIcon!.first.icon!.codePoint),
          style: TextStyle(
            fontSize: 17.0,
            fontFamily: verticalMarkerIcon?.first.icon!.fontFamily,
            color: verticalMarkerIcon?.first.color ?? _gridPainter.color,
          ),
        );

        firstIconTp.layout();

        if (iconBackgroundColor != null) {
          // Setting the background color of the icon
          canvas.drawCircle(
              Offset(
                firstVerticalMarkerX,
                firstVerticalMarkerY,
              ),
              4.5,
              Paint()..color = iconBackgroundColor ?? Colors.white);
        }

        firstIconTp.paint(
          canvas,
          Offset(
            firstVerticalMarkerX - 9,
            firstVerticalMarkerY - 9,
          ),
        );
      }

      // If there are two x values defined, draw a shaded area between the two vertical lines
      if (verticalMarker!.length == 2) {
        final lastVerticalMarker = lastVerticalMarkerX;

        canvas.drawLine(
            Offset(lastVerticalMarker - 2, 0),
            Offset(lastVerticalMarker - 2, size.height - LineChart.axisOffsetPX),
            Paint()
              ..color = Colors.grey
              ..strokeWidth = 1);

        Path filledPath = Path();

        filledPath.moveTo(firstVerticalMarker, 0);
        filledPath.lineTo(lastVerticalMarker, 0);
        filledPath.lineTo(
            lastVerticalMarker, size.height - LineChart.axisOffsetPX);
        filledPath.lineTo(
            firstVerticalMarker, size.height - LineChart.axisOffsetPX);

        canvas.drawPath(
          filledPath,
          Paint()..color = verticalMarkerPaint.color.withOpacity(0.3),
        );

        if (verticalMarkerIcon?.length == 2) {
          TextPainter lastIconTp = TextPainter(
            textDirection: TextDirectionHelper.getDirection(),
          );

          lastIconTp.text = TextSpan(
            text: String.fromCharCode(verticalMarkerIcon!.last.icon!.codePoint),
            style: TextStyle(
              fontSize: 17.0,
              fontFamily: verticalMarkerIcon?.last.icon!.fontFamily,
              color: verticalMarkerIcon?.last.color ?? _gridPainter.color,
            ),
          );

          lastIconTp.layout();

          if (iconBackgroundColor != null) {
            // Setting the background color of the icon
            canvas.drawCircle(
                Offset(
                  lastVerticalMarkerX,
                  lastVerticalMarkerY,
                ),
                4.5,
                Paint()..color = iconBackgroundColor ?? Colors.white);
          }

          lastIconTp.paint(
            canvas,
            Offset(
              lastVerticalMarkerX - 9,
              lastVerticalMarkerY - 9,
            ),
          );
        }
      }
    }
  }

  void _drawUnits(Canvas canvas, Size size, TextStyle? style) {
    if (_chart.indexToUnit.length > 0) {
      TextSpan span = TextSpan(
          style: style, text: _chart.yAxisName ?? _chart.indexToUnit[0]);
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.right,
          textDirection: TextDirectionHelper.getDirection());
      tp.layout();

      tp.paint(canvas, Offset(_chart.xAxisOffsetPX, -20)); //-16
    }

    if (_chart.indexToUnit.length == 2) {
      TextSpan span = TextSpan(style: style, text: _chart.indexToUnit[1]);
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.right,
          textDirection: TextDirectionHelper.getDirection());
      tp.layout();

      tp.paint(canvas,
          Offset(size.width - tp.width - _chart.xAxisOffsetPXright, -16));
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(
            _chart.xAxisOffsetPX,
            0,
            size.width - _chart.xAxisOffsetPX - _chart.xAxisOffsetPXright,
            size.height - LineChart.axisOffsetPX),
        _gridPainter..strokeWidth = 1);

    for (double c = 1; c <= _stepCount; c++) {
      canvas.drawLine(
          Offset(_chart.xAxisOffsetPX, c * _chart.heightStepSize!),
          Offset(size.width - _chart.xAxisOffsetPXright,
              c * _chart.heightStepSize!),
          _gridPainter..strokeWidth = innerGridStrokeWidth ?? 1);
      canvas.drawLine(
          Offset(c * _chart.widthStepSize! + _chart.xAxisOffsetPX, 0),
          Offset(c * _chart.widthStepSize! + _chart.xAxisOffsetPX,
              size.height - LineChart.axisOffsetPX),
          _gridPainter..strokeWidth = innerGridStrokeWidth ?? 1);
    }
  }

  void _drawRotatedText(Canvas canvas, TextPainter tp, double x, double y,
      double angleRotationInRadians) {
    canvas.save();
    canvas.translate(x, y + tp.width);

    canvas.rotate(angleRotationInRadians);
    tp.paint(canvas, Offset(0.0, 0.0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Legend extends StatelessWidget {
  final String? title;
  final Color? color;
  final Icon? icon;
  final TextStyle? style;
  final bool? showLeadingLine;

  const Legend({
    this.title,
    this.color,
    this.icon,
    this.style,
    this.showLeadingLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon != null
            ? icon!
            : Visibility(
                visible: showLeadingLine == true,
                child: Container(
                  height: 3,
                  width: 15,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
              ),
        Text(
          ' $title',
          style: style ??
              TextStyle(
                color: Colors.black,
                fontSize: 12,
                overflow: TextOverflow.clip,
              ),
        ),
      ],
    );
  }
}
