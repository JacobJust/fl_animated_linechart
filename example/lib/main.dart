import 'package:example/fake_chart_series.dart';
import 'package:fl_animated_linechart/chart/area_line_chart.dart';
import 'package:fl_animated_linechart/common/pair.dart';
import 'package:fl_animated_linechart/fl_animated_linechart.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'fl_animated_chart demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with FakeChartSeries {
  int chartIndex = 0;

  @override
  Widget build(BuildContext context) {
    Map<DateTime, double> line1 = createLine2();
    Map<DateTime, double> line2 = createLine2_2();

    LineChart chart;

    if (chartIndex == 0) {
      chart = LineChart.fromDateTimeMaps([line1, line2], [Colors.green, Colors.blue], ['C', 'C'], tapTextFontWeight: FontWeight.w400);
    } else if (chartIndex == 1) {
      chart = LineChart.fromDateTimeMaps([createLineAlmostSaveValues()], [Colors.green], ['C'], tapTextFontWeight: FontWeight.w400);
    } else {
      chart = AreaLineChart.fromDateTimeMaps([line1], [Colors.red.shade900], ['C'],
          gradients: [Pair(Colors.yellow.shade400, Colors.red.shade700)]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black45), borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: Text(
                        'LineChart',
                        style: TextStyle(color: chartIndex == 0 ? Colors.black : Colors.black12),
                      ),
                      onPressed: () {
                        setState(() {
                          chartIndex = 0;
                        });
                      },
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black45), borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: Text('LineChart2', style: TextStyle(color: chartIndex == 1 ? Colors.black : Colors.black12)),
                      onPressed: () {
                        setState(() {
                          chartIndex = 1;
                        });
                      },
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black45), borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: Text('AreaChart', style: TextStyle(color: chartIndex == 2 ? Colors.black : Colors.black12)),
                      onPressed: () {
                        setState(() {
                          chartIndex = 2;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedLineChart(
                  chart,
                  key: UniqueKey(),
                  gridColor: Colors.black54,
                  textStyle: TextStyle(fontSize: 10, color: Colors.black54),
                  toolTipColor: Colors.white,
                ), //Unique key to force animations
              )),
              SizedBox(width: 200, height: 50, child: Text('')),
            ]),
      ),
    );
  }
}
