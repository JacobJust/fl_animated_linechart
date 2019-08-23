class FakeChartSeries {
  Map<DateTime, double> createLineData(double factor) {
    Map<DateTime, double> data = {};

    for (int c = 3000; c > 0; c--) {
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
    data[DateTime.now().subtract(Duration(minutes: 40))] = 13.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 24.0;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 39.0;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 29.0;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 27.0;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 9.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 35.0;
    return data;
  }

  Map<DateTime, double> createLine2_2() {
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

  Map<DateTime, double> createLine3() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(days: 6))] = 1100.0;
    data[DateTime.now().subtract(Duration(days: 5))] = 2233.0;
    data[DateTime.now().subtract(Duration(days: 4))] = 3744.0;
    data[DateTime.now().subtract(Duration(days: 3))] = 3100.0;
    data[DateTime.now().subtract(Duration(days: 2))] = 2900.0;
    data[DateTime.now().subtract(Duration(days: 1))] = 1100.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 3700.0;
    return data;
  }
}