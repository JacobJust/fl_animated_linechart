import 'dart:math';

import 'package:fl_animated_linechart/chart/datetime_chart_point.dart';
import 'package:fl_animated_linechart/chart/highlight_point.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomChart extends StatefulWidget {

  final LineChart chart;

  const CustomChart(this.chart, {Key key, }) : super(key: key);

  @override
  _CustomChartState createState() => _CustomChartState();
}

class _CustomChartState extends State<CustomChart> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 600));

    Animation curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOutExpo);

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
    return Padding(
      padding: EdgeInsets.only(right: ChartPainter.axisOffsetPX),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            widget.chart.initialize(constraints.maxWidth, constraints.maxHeight);

            return _GestureWrapper(constraints.maxHeight, constraints.maxWidth, widget.chart, _animation);
          }
      ),
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

  static final double axisOffsetPX = 50.0;
  static final double stepCount = 5;

  final Paint _gridPainter = Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1
                          ..color = Colors.black26;

  Paint linePainter = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.black26;

  final double progress;
  final LineChart chart;
  final bool horizontalDragActive;
  final double horizontalDragPosition;

  ChartPainter(this.progress, this.chart, this.horizontalDragActive, this.horizontalDragPosition);// : horizontalDragPosition = horizontalDragActive ? horizontalDragPosition - axisOffsetPX  : 0;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    int index = 0;

    chart.lines.forEach((chartLine) {
      linePainter.color = chartLine.color;
      Path path;

      List<HighlightPoint> points = chart.seriesMap[index];

      bool drawCircles = points.length < 100;

      if (progress < 1.0) {
        path = Path(); // create new path, to make animation work
        bool init = true;

        chartLine.points.forEach((p) {
          double x = (p.x * chart.xScale) - chart.xOffset;
          double adjustedY = (p.y * chart.yScale) - (chart.minY * chart.yScale);
          double y = (size.height - LineChart.axisOffsetPX) - (adjustedY * progress);

          //adjust to make room for axis values:
          x += LineChart.axisOffsetPX;

          if (init) {
            init = false;
            path.moveTo(x, y);
          }

          path.lineTo(x, y);
          if (drawCircles) {
            canvas.drawCircle(Offset(x, y), 2, linePainter);
          }
        });
      } else {
        path = chart.getPathCache(index);

        if (drawCircles) {
          points.forEach((p) => canvas.drawCircle(Offset(p.chartPoint.x, p.chartPoint.y), 2, linePainter));
        }
      }

      canvas.drawPath(path, linePainter);
      index++;
    });

    //TODO: calculate and cache
    for (int c = 0; c <= (stepCount + 1); c++) {
      TextPainter tp = chart.axisTexts[c];
      tp.paint(canvas, new Offset(chart.axisOffSetWithPadding - tp.width, (size.height - 6)- (c * chart.heightStepSize) - axisOffsetPX));
    }

    //TODO: calculate and cache
    for (int c = 0; c <= (stepCount + 1); c++) {
      _drawRotatedText(canvas, chart.yAxisTexts[c], chart.axisOffSetWithPadding + (c * chart.widthStepSize), size.height - chart.axisOffSetWithPadding, pi * 1.5);
    }

    if (horizontalDragActive) {
      linePainter.color = Colors.teal.shade100;

      if (horizontalDragPosition > axisOffsetPX && horizontalDragPosition < size.width) {
        canvas.drawLine(Offset(horizontalDragPosition, 0), Offset(horizontalDragPosition, size.height - axisOffsetPX), linePainter);
      }

      List<HighlightPoint> highlights = chart.getClosetHighlightPoints(horizontalDragPosition);

      index = 0;
      highlights.forEach((highlight) {
        canvas.drawCircle(Offset(highlight.chartPoint.x, highlight.chartPoint.y), 5, linePainter);

        String prefix = "";

        //TODO: detect if range is <= 25h or >25h, and format accordently:
        if (highlight.chartPoint is DateTimeChartPoint) {
          DateTimeChartPoint dateTimeChartPoint = highlight.chartPoint;
          prefix = '${dateTimeChartPoint.dateTime.hour}:${dateTimeChartPoint.dateTime.minute}';
        }

        TextSpan span = new TextSpan(style: new TextStyle(color: chart.lines[index].color, fontWeight: FontWeight.w200, fontSize: 12), text: '${prefix}: ${highlight.yValue.toStringAsFixed(1)}');
        TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.right, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, new Offset(highlight.chartPoint.x + 7, highlight.YTextPosition-10));

        index++;
      });
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(axisOffsetPX, 0, size.width - axisOffsetPX, size.height - axisOffsetPX), _gridPainter);
    
    for(double c = 1; c <= stepCount; c ++) {
      canvas.drawLine(Offset(axisOffsetPX, c*chart.heightStepSize), Offset(size.width, c*chart.heightStepSize), _gridPainter);
      canvas.drawLine(Offset(c*chart.widthStepSize + axisOffsetPX, 0), Offset(c*chart.widthStepSize + axisOffsetPX, size.height-axisOffsetPX), _gridPainter);
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