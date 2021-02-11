import 'dart:math';

import 'package:fl_animated_linechart/chart/area_line_chart.dart';
import 'package:fl_animated_linechart/chart/datetime_chart_point.dart';
import 'package:fl_animated_linechart/chart/highlight_point.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:fl_animated_linechart/common/animated_path_util.dart';
import 'package:fl_animated_linechart/common/pair.dart';
import 'package:fl_animated_linechart/common/text_direction_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

typedef TapText = String Function(String prefix, double y, String unit);

class AnimatedLineChart extends StatefulWidget {
  final LineChart chart;
  final TapText tapText;
  final TextStyle style;

  const AnimatedLineChart(
    this.chart, {
    Key key,
    this.tapText,
    this.style
  }) : super(key: key);

  @override
  _AnimatedLineChartState createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<AnimatedLineChart>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));

    Animation curve =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _animation = Tween(begin: 0.0, end: 1.0).animate(curve);

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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      widget.chart.initialize(constraints.maxWidth, constraints.maxHeight, widget.style);
      return _GestureWrapper(
        widget.chart,
        _animation,
        tapText: widget.tapText,
      );
    });
  }
}

//Wrap gestures, to avoid reinitializing the chart model when doing gestures
class _GestureWrapper extends StatefulWidget {
  final LineChart _chart;
  final Animation _animation;
  final TapText tapText;

  const _GestureWrapper(
    this._chart,
    this._animation, {
    Key key,
    this.tapText,
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
        animation: widget._animation,
        tapText: widget.tapText,
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
        _horizontalDragPosition += dragUpdateDetails.primaryDelta;
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
  final TapText tapText;
  final TextStyle style;

  _AnimatedChart(
      this._chart, this._horizontalDragActive, this._horizontalDragPosition,
      {this.tapText, Key key, Animation animation, this.style})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation animation = listenable as Animation;

    return CustomPaint(
      painter: ChartPainter(animation?.value, _chart, _horizontalDragActive,
          _horizontalDragPosition, style,
          tapText: tapText),
    );
  }
}

class ChartPainter extends CustomPainter {
  static final double _stepCount = 5;

  final DateFormat _formatMonthDayHoursMinutes = DateFormat('dd/MM kk:mm');

  final Paint _gridPainter = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = Colors.red;

  Paint _linePainter = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.red;

  Paint _fillPainter = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 2;

  Paint _tooltipPainter = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.blue;

  final double _progress;
  final LineChart _chart;
  final bool _horizontalDragActive;
  final double _horizontalDragPosition;

  final TapText tapText;
  final TextStyle style;

  static final TapText _defaultTapText =
      (prefix, y, unit) => '$prefix: ${y.toStringAsFixed(1)} $unit';

  ChartPainter(this._progress, this._chart, this._horizontalDragActive,
      this._horizontalDragPosition, this.style,
      {TapText tapText})
      : tapText = tapText ?? _defaultTapText;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawUnits(canvas, size, style);
    _drawLines(size, canvas);
    _drawAxisValues(canvas, size);

    if (_horizontalDragActive) {
      _drawHighlights(size, canvas, _chart.tapTextFontWeight, style);
    }
  }

  void _drawHighlights(Size size, Canvas canvas, FontWeight tapTextFontWeight, TextStyle style) {
    _linePainter.color = Colors.yellow;

    if (_horizontalDragPosition > LineChart.axisOffsetPX &&
        _horizontalDragPosition < size.width) {
      canvas.drawLine(
          Offset(_horizontalDragPosition, 0),
          Offset(_horizontalDragPosition, size.height - LineChart.axisOffsetPX),
          _linePainter);
    }

    List<HighlightPoint> highlights =
        _chart.getClosetHighlightPoints(_horizontalDragPosition);
    List<TextPainter> textPainters = List();
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
      canvas.drawCircle(Offset(highlight.chartPoint.x, highlight.chartPoint.y),
          5, _linePainter);

      String prefix = '';

      if (highlight.chartPoint is DateTimeChartPoint) {
        DateTimeChartPoint dateTimeChartPoint = highlight.chartPoint;
        prefix =
            _formatMonthDayHoursMinutes.format(dateTimeChartPoint.dateTime);
      }

      TextSpan span = TextSpan(
          style: style,
          text: tapText(
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

      textPainters.add(tp);
      index++;
    });

    minHighlightX += 12; //make room for the chart points
    double tooltipHeight = textPainters[0].height * textPainters.length + 16;

    if ((minHighlightX + maxWidth + 16) > size.width) {
      minHighlightX -= maxWidth;
      minHighlightX -= 34;
    }

    if (minHighlightY + tooltipHeight >
        size.height - _chart.axisOffSetWithPadding) {
      minHighlightY =
          size.height - _chart.axisOffSetWithPadding - tooltipHeight;
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
      TextPainter tp = _chart.yAxisTexts(0)[c];
      tp.paint(
          canvas,
          Offset(
              _chart.axisOffSetWithPadding - tp.width,
              (size.height - 6) -
                  (c * _chart.heightStepSize) -
                  LineChart.axisOffsetPX));
    }

    if (_chart.yAxisCount == 2) {
      for (int c = 0; c <= (_stepCount + 1); c++) {
        TextPainter tp = _chart.yAxisTexts(1)[c];
        tp.paint(
            canvas,
            Offset(
                LineChart.axisMargin + size.width - _chart.xAxisOffsetPXright,
                (size.height - 6) -
                    (c * _chart.heightStepSize) -
                    LineChart.axisOffsetPX));
      }
    }

    //TODO: calculate and cache
    for (int c = 0; c <= (_stepCount + 1); c++) {
      _drawRotatedText(
          canvas,
          _chart.xAxisTexts[c],
          _chart.axisOffSetWithPadding + (c * _chart.widthStepSize),
          size.height - (LineChart.axisOffsetPX - 5),
          pi * 1.5);
    }
  }

  void _drawLines(Size size, Canvas canvas) {
    int index = 0;

    _chart.lines.forEach((chartLine) {
      _linePainter.color = chartLine.color;
      Path path;

      List<HighlightPoint> points = _chart.seriesMap[index];

      bool drawCircles = points.length < 100;

      if (_progress < 1.0) {
        path = AnimatedPathUtil.createAnimatedPath(
            _chart.getPathCache(index), _progress);
      } else {
        path = _chart.getPathCache(index);

        if (drawCircles) {
          points.forEach((p) => canvas.drawCircle(
              Offset(p.chartPoint.x, p.chartPoint.y), 2, _linePainter));
        }
      }

      canvas.drawPath(path, _linePainter);

      if (_chart is AreaLineChart) {
        AreaLineChart areaLineChart = _chart;

        if (areaLineChart.gradients != null) {
          Pair<Color, Color> gradient = areaLineChart.gradients[index];

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

        Path areaPathCache = areaLineChart.getAreaPathCache(index);
        canvas.drawPath(areaPathCache, _fillPainter);
      }

      index++;
    });
  }

  void _drawUnits(Canvas canvas, Size size, TextStyle style) {
    if (_chart.indexToUnit.length > 0) {

      TextSpan span = TextSpan(
          style: style,
          text: _chart.indexToUnit[0]);
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.right,
          textDirection: TextDirectionHelper.getDirection());
      tp.layout();

      tp.paint(canvas, Offset(_chart.xAxisOffsetPX, -16));
    }

    if (_chart.indexToUnit.length == 2) {
      TextSpan span = TextSpan(
          style: style,
          text: _chart.indexToUnit[1]);
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
        _gridPainter);

    for (double c = 1; c <= _stepCount; c++) {
      canvas.drawLine(
          Offset(_chart.xAxisOffsetPX, c * _chart.heightStepSize),
          Offset(size.width - _chart.xAxisOffsetPXright,
              c * _chart.heightStepSize),
          _gridPainter);
      canvas.drawLine(
          Offset(c * _chart.widthStepSize + _chart.xAxisOffsetPX, 0),
          Offset(c * _chart.widthStepSize + _chart.xAxisOffsetPX,
              size.height - LineChart.axisOffsetPX),
          _gridPainter);
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
