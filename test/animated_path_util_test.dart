import 'dart:ui';

import 'package:fl_animated_linechart/common/animated_path_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('animated path', () async {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(1, 1);
    path.lineTo(49, 49);
    path.lineTo(51, 51);
    path.lineTo(100, 100);

    Path animatedPath0 = AnimatedPathUtil.createAnimatedPath(path, 0.0);
    Path animatedPath50 = AnimatedPathUtil.createAnimatedPath(path, 0.5);
    Path animatedPath100 = AnimatedPathUtil.createAnimatedPath(path, 1.0);

    expect(animatedPath0.contains(Offset(1, 1)), false);
    expect(animatedPath50.contains(Offset(1, 1)), true);
    expect(animatedPath50.contains(Offset(49, 49)), true);
    expect(animatedPath50.contains(Offset(51, 51)), false);
    expect(animatedPath100.contains(Offset(51, 51)), true);
    expect(animatedPath100.contains(Offset(100, 100)), true);
  });
}
