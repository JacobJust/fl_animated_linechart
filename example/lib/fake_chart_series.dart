class FakeChartSeries {
  Map<DateTime, double> createLineData(double factor) {
    Map<DateTime, double> data = {};

    for (int c = 50; c > 0; c--) {
      data[DateTime.now().subtract(Duration(minutes: c))] =
          c.toDouble() * factor;
    }

    return data;
  }

  Map<DateTime, double> createLineAlmostSaveValues() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 40))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 24.9;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 25.0;

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
    var date = DateTime.now().subtract(Duration(minutes: 40));
    data[date.subtract(Duration(minutes: 40))] = 13.0;
    data[date.subtract(Duration(minutes: 30))] = 24.0;
    data[date.subtract(Duration(minutes: 22))] = 39.0;
    data[date.subtract(Duration(minutes: 20))] = 29.0;
    data[date.subtract(Duration(minutes: 15))] = 27.0;
    data[date.subtract(Duration(minutes: 12))] = 9.0;
    data[date.subtract(Duration(minutes: 5))] = 35.0;
    return data;
  }

  Map<DateTime, double> createLine2_2() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 40))] = 30.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 48.0;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 67.0;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 99.0;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 23.0;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 47.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 10.0;
    return data;
  }

  Map<DateTime, double> createLine2_3() {
    Map<DateTime, double> data = {};

    data[DateTime.parse('2012-02-27 12:33:00')] = 215.0;
    data[DateTime.parse('2012-02-27 12:38:00')] = 212.0;
    data[DateTime.parse('2012-02-27 12:43:00')] = 201.0;
    data[DateTime.parse('2012-02-27 12:48:00')] = 204.0;
    data[DateTime.parse('2012-02-27 12:53:00')] = 200.0;
    data[DateTime.parse('2012-02-27 12:58:00')] = 200.0;
    data[DateTime.parse('2012-02-27 13:03:00')] = 214.0;
    data[DateTime.parse('2012-02-27 13:08:00')] = 215.0;
    data[DateTime.parse('2012-02-27 13:13:00')] = 204.0;
    data[DateTime.parse('2012-02-27 13:18:00')] = 199.0;
    data[DateTime.parse('2012-02-27 13:23:00')] = 217.0;
    data[DateTime.parse('2012-02-27 13:28:00')] = 200.0;
    data[DateTime.parse('2012-02-27 13:33:43.564')] = 210.0;
    data[DateTime.parse('2012-02-27 13:38:45.751')] = 202.0;
    data[DateTime.parse('2012-02-27 13:43:00')] = 214.0;
    data[DateTime.parse('2012-02-27 13:48:00')] = 216.0;
    data[DateTime.parse('2012-02-27 13:53:00')] = 217.0;
    data[DateTime.parse('2012-02-27 13:58:00')] = 207.0;
    data[DateTime.parse('2012-02-27 14:03:00')] = 216.0;
    data[DateTime.parse('2012-02-27 14:08:00')] = 214.0;
    data[DateTime.parse('2012-02-27 14:13:00')] = 199.0;
    data[DateTime.parse('2012-02-27 14:18:00')] = 212.0;
    data[DateTime.parse('2012-02-27 14:23:00')] = 206.0;
    data[DateTime.parse('2012-02-27 14:28:00')] = 199.0;
    data[DateTime.parse('2012-02-27 14:33:00')] = 217.0;
    data[DateTime.parse('2012-02-27 14:38:00')] = 201.0;
    return data;
  }

  Map<DateTime, double> yAxisUpperMaxMarkerLine() {
    Map<DateTime, double> data = {};
    data[DateTime.parse('2012-02-27 12:33:00')] = 210.0;
    data[DateTime.parse('2012-02-27 14:43:00')] = 210.0;
    return data;
  }

  Map<DateTime, double> yAxisLowerMaxMarkerLine() {
    Map<DateTime, double> data = {};
    data[DateTime.parse('2012-02-27 12:33:00')] = 151.1;
    data[DateTime.parse('2012-02-27 14:43:00')] = 151.1;
    return data;
  }

  Map<DateTime, double> yAxisUpperMinMarkerLine() {
    Map<DateTime, double> data = {};
    data[DateTime.parse('2012-02-27 12:33:00')] = 208.0;
    data[DateTime.parse('2012-02-27 14:43:00')] = 208.0;
    return data;
  }

  Map<DateTime, double> yAxisLowerMinMarkerLine() {
    Map<DateTime, double> data = {};
    data[DateTime.parse('2012-02-27 12:33:00')] = 180.12;
    data[DateTime.parse('2012-02-27 14:43:00')] = 180.12;
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
