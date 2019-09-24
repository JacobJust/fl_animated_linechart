import 'dart:math';

import 'package:fl_animated_linechart/chart/datetime_chart_point.dart';
import 'package:fl_animated_linechart/chart/highlight_point.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:fl_animated_linechart/common/animated_path_util.dart';
import 'package:fl_animated_linechart/common/text_direction_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AnimatedLineChart extends StatefulWidget {

  final LineChart chart;

  const AnimatedLineChart(this.chart, {Key key, }) : super(key: key);

  @override
  _AnimatedLineChartState createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<AnimatedLineChart> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 700));

    Animation curve = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

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
          widget.chart.initialize(constraints.maxWidth, constraints.maxHeight);
          return _GestureWrapper(constraints.maxHeight, constraints.maxWidth, widget.chart, _animation);
        }
    );
  }
}

//Wrap gestures, to avoid reinitializing the chart model when doing gestures
class _GestureWrapper extends StatefulWidget {
  final double _height;
  final double width;
  final LineChart chart;
  final Animation animation;

  const _GestureWrapper(this._height, this.width, this.chart, this.animation, {Key key,}) : super(key: key);

  @override
  _GestureWrapperState createState() => _GestureWrapperState();
}

class _GestureWrapperState extends State<_GestureWrapper> {
  bool horizontalDragActive = false;
  double horizontalDragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _AnimatedChart(widget.chart, widget.width, widget._height, horizontalDragActive, horizontalDragPosition, animation: widget.animation,),
      onTapDown: (tap) {
        horizontalDragActive = true;
        horizontalDragPosition = tap.globalPosition.dx;
        setState(() {
        });
      },
      onHorizontalDragStart: (dragStartDetails) {
        horizontalDragActive = true;
        horizontalDragPosition = dragStartDetails.globalPosition.dx;
        setState(() {
        });
      },
      onHorizontalDragUpdate: (dragUpdateDetails) {
        horizontalDragPosition += dragUpdateDetails.primaryDelta;
        setState(() {
        });
      },
      onHorizontalDragEnd: (dragEndDetails) {
        horizontalDragActive = false;
        horizontalDragPosition = 0.0;
        setState(() {
        });
      },
      onTapUp: (tap) {
        horizontalDragActive = false;
        horizontalDragPosition = 0.0;
        setState(() {
        });
      },
    );
  }
}

class _AnimatedChart extends AnimatedWidget {
  final double height;
  final double width;
  final LineChart chart;
  final bool horizontalDragActive;
  final double horizontalDragPosition;

  _AnimatedChart(this.chart, this.width, this.height, this.horizontalDragActive, this.horizontalDragPosition, {Key key, Animation animation}) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation animation = listenable as Animation;

    return CustomPaint(
      painter: ChartPainter(animation?.value, chart, horizontalDragActive, horizontalDragPosition),
    );
  }
}

class ChartPainter extends CustomPainter {

  static final double stepCount = 5;

  final DateFormat _formatMonthDayHoursMinutes = DateFormat('dd/MM kk:mm');

  final Paint _gridPainter = Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1
                          ..color = Colors.black26;

  Paint linePainter = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.black26;

  Paint tooltipPainter = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white.withAlpha(230);

  final double progress;
  final LineChart chart;
  final bool horizontalDragActive;
  final double horizontalDragPosition;

  ChartPainter(this.progress, this.chart, this.horizontalDragActive, this.horizontalDragPosition);

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawUnits(canvas, size);
    _drawLines(size, canvas);
    _drawAxisValues(canvas, size);

    if (horizontalDragActive) {
      _drawHighlights(size, canvas);
    }
  }

  void _drawHighlights(Size size, Canvas canvas) {
    linePainter.color = Colors.black45;
    
    if (horizontalDragPosition > LineChart.axisOffsetPX && horizontalDragPosition < size.width) {
      canvas.drawLine(Offset(horizontalDragPosition, 0), Offset(horizontalDragPosition, size.height - LineChart.axisOffsetPX), linePainter);
    }
    
    List<HighlightPoint> highlights = chart.getClosetHighlightPoints(horizontalDragPosition);
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
      canvas.drawCircle(Offset(highlight.chartPoint.x, highlight.chartPoint.y), 5, linePainter);

      String prefix = "";
    
      if (highlight.chartPoint is DateTimeChartPoint) {
        DateTimeChartPoint dateTimeChartPoint = highlight.chartPoint;
        prefix = _formatMonthDayHoursMinutes.format(dateTimeChartPoint.dateTime);
      }

      TextSpan span = new TextSpan(style: new TextStyle(color: chart.lines[index].color, fontWeight: FontWeight.w200, fontSize: 12), text: '$prefix: ${highlight.yValue.toStringAsFixed(1)} ${chart.lines[index].unit}');
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.right, textDirection: TextDirectionHelper.getDirection());
    
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

    if (minHighlightY + tooltipHeight > size.height - chart.axisOffSetWithPadding) {
      minHighlightY = size.height - chart.axisOffSetWithPadding - tooltipHeight;
    }

    //Draw highlight bordered box:
    Rect tooltipRect = Rect.fromLTWH(minHighlightX-5, minHighlightY - 5, maxWidth+20, tooltipHeight);
    canvas.drawRect(tooltipRect, tooltipPainter);
    canvas.drawRect(tooltipRect, _gridPainter);

    //Draw the actual highlights:
    textPainters.forEach((tp) {
      tp.paint(canvas, Offset(minHighlightX+5, minHighlightY));
      minHighlightY += 17;
    });
  }

  void _drawAxisValues(Canvas canvas, Size size) {
    //TODO: calculate and cache

    //Draw main axis, should always be available:
    for (int c = 0; c <= (stepCount + 1); c++) {
      TextPainter tp = chart.yAxisTexts(0)[c];
      tp.paint(canvas, new Offset(chart.axisOffSetWithPadding - tp.width, (size.height - 6)- (c * chart.heightStepSize) - LineChart.axisOffsetPX));
    }

    if (chart.yAxisCount == 2) {
      for (int c = 0; c <= (stepCount + 1); c++) {
        TextPainter tp = chart.yAxisTexts(1)[c];
        tp.paint(canvas, new Offset(LineChart.axisMargin + size.width - chart.xAxisOffsetPXright, (size.height - 6)- (c * chart.heightStepSize) - LineChart.axisOffsetPX));
      }
    }

    //TODO: calculate and cache
    for (int c = 0; c <= (stepCount + 1); c++) {
      _drawRotatedText(canvas, chart.xAxisTexts[c], chart.axisOffSetWithPadding + (c * chart.widthStepSize), size.height - (LineChart.axisOffsetPX-5), pi * 1.5);
    }
  }

  void _drawLines(Size size, Canvas canvas) {
    int index = 0;

    chart.lines.forEach((chartLine) {
      linePainter.color = chartLine.color;
      Path path;

      List<HighlightPoint> points = chart.seriesMap[index];

      bool drawCircles = points.length < 100;

      if (progress < 1.0) {
        path = AnimatedPathUtil.createAnimatedPath(chart.getPathCache(index), progress);
      } else {
        path = chart.getPathCache(index);

        if (drawCircles) {
          points.forEach((p) => canvas.drawCircle(Offset(p.chartPoint.x, p.chartPoint.y), 2, linePainter));
        }
      }

      canvas.drawPath(path, linePainter);
      index++;
    });
  }

  void _drawUnits(Canvas canvas, Size size) {
      if (chart.indexToUnit.length > 0) {
        Color color;

        if (chart.lines.length == 2 && chart.indexToUnit.length == 2) {
          color = chart.lines[0].color;
        } else {
          color  = Colors.black54;
        }

        TextSpan span = new TextSpan(style: new TextStyle(color: color, fontWeight: FontWeight.w200, fontSize: 14), text: chart.indexToUnit[0]);
        TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.right, textDirection: TextDirectionHelper.getDirection());
        tp.layout();

        tp.paint(canvas, new Offset(chart.xAxisOffsetPX, -16));
      }

      if (chart.indexToUnit.length == 2) {
        Color color;

        if (chart.lines.length == 2) {
          color = chart.lines[1].color;
        } else {
          color  = Colors.black54;
        }


        TextSpan span = new TextSpan(style: new TextStyle(color: color, fontWeight: FontWeight.w200, fontSize: 14), text: chart.indexToUnit[1]);
        TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.right, textDirection: TextDirectionHelper.getDirection());
        tp.layout();

        tp.paint(canvas, new Offset(size.width - tp.width - chart.xAxisOffsetPXright, -16));
      }
  }

  void _drawGrid(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(chart.xAxisOffsetPX, 0, size.width - chart.xAxisOffsetPX - chart.xAxisOffsetPXright, size.height - LineChart.axisOffsetPX), _gridPainter);
    
    for(double c = 1; c <= stepCount; c ++) {
      canvas.drawLine(Offset(chart.xAxisOffsetPX, c*chart.heightStepSize), Offset(size.width - chart.xAxisOffsetPXright, c*chart.heightStepSize), _gridPainter);
      canvas.drawLine(Offset(c*chart.widthStepSize + chart.xAxisOffsetPX, 0), Offset(c*chart.widthStepSize + chart.xAxisOffsetPX, size.height-LineChart.axisOffsetPX), _gridPainter);
    }
  }

  void _drawRotatedText(Canvas canvas,TextPainter tp, double x, double y, double angleRotationInRadians) {
    canvas.save();
    canvas.translate(x, y + tp.width);
    canvas.rotate(angleRotationInRadians);
    tp.paint(canvas, new Offset(0.0,0.0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}