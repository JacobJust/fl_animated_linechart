import 'package:example/fake_chart_series.dart';
import 'package:fl_animated_linechart/chart/area_line_chart.dart';
import 'package:fl_animated_linechart/fl_animated_linechart.dart';
import 'package:flutter/material.dart';

/**
 * TODO: fix chart not starting at x: 0
 */

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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

  bool _showLineChart = true;

  @override
  Widget build(BuildContext context) {
    Map<DateTime, double> line1 = createLine2();
    Map<DateTime, double> line2 = createLine2_2();

    LineChart chart;

    if (_showLineChart) {
      chart = LineChart.fromDateTimeMaps([line1, line2], [Colors.green, Colors.blue], ['C', 'C']);
    } else {
      chart = AreaLineChart.fromDateTimeMaps([line1], [Colors.green], ['C']);
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
                       shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black45), borderRadius: BorderRadius.all(Radius.circular(3))),
                       child: Text('LineChart', style: TextStyle(color: _showLineChart ? Colors.black : Colors.black12),),
                       onPressed: () {
                       setState(() {
                         _showLineChart = true;
                       });
                     },),
                     FlatButton(
                       shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black45), borderRadius: BorderRadius.all(Radius.circular(3))),
                       child: Text('AreaChart', style: TextStyle(color: !_showLineChart ? Colors.black : Colors.black12)),
                       onPressed: () {
                         setState(() {
                           _showLineChart = false;
                         });
                       },),
                   ],
                 ),
               ),
              Expanded(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedLineChart(chart, key: UniqueKey(),), //Unique key to force animations
              )),
              SizedBox(width: 200, height: 200, child: Text('')),
            ]
        ),
      ),
    );
  }
}
