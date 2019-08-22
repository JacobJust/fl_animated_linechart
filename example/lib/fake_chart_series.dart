class FakeChartSeries {
  Map<DateTime, double> createLineData(double factor) {
    Map<DateTime, double> data = {};

    for (int c = 100; c > 0; c--) {
      data[DateTime.now().subtract(Duration(minutes: c))] = c.toDouble() * factor;
    }

    return data;
  }

  Map<DateTime, double> createLine1() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 40))] = 14.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 47.0;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 21.0;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 22.0;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 15.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 34.0;

    return data;
  }



  Map<DateTime, double> createLine2() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 40))] = 11.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 22.0;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 37.0;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 31.0;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 29.0;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 11.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 37.0;
    return data;
  }
}