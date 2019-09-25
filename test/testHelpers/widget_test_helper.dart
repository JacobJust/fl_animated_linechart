import 'package:flutter/material.dart';

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(
        home: Scaffold(body: widget),
      ));
}
