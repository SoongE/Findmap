import 'dart:math';
import 'dart:ui';

import 'package:findmap/src/my_colors.dart';
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  BackgroundPainter({
    required Animation<double> animation,
  })  : mountainPaint = Paint()
          ..color = MyColors.mountain
          ..style = PaintingStyle.fill,
        waterPaint = Paint()
          ..color = MyColors.water
          ..style = PaintingStyle.fill,
        icePaint = Paint()
          ..color = MyColors.ice
          ..style = PaintingStyle.fill,
        linePaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
        liquidAnim = CurvedAnimation(
          curve: Curves.easeOutBack,
          reverseCurve: Curves.elasticInOut,
          parent: animation,
        ),
        iceAnim = CurvedAnimation(
          parent: animation,
          curve: const Interval(
            0,
            0.7,
            curve: Interval(0, 0.8, curve: SpringCurve()),
          ),
          reverseCurve: Curves.linear,
        ),
        waterAnim = CurvedAnimation(
          parent: animation,
          curve: const Interval(
            0,
            0.8,
            curve: Interval(0, 0.9, curve: SpringCurve()),
          ),
          reverseCurve: Curves.easeInCirc,
        ),
        mountainAnim = CurvedAnimation(
          parent: animation,
          curve: const SpringCurve(),
          reverseCurve: Curves.easeInCirc,
        ),
        super(repaint: animation);

  final Animation<double> liquidAnim;
  final Animation<double> mountainAnim;
  final Animation<double> waterAnim;
  final Animation<double> iceAnim;

  final Paint linePaint;
  final Paint mountainPaint;
  final Paint waterPaint;
  final Paint icePaint;

  void _addPointsToPath(Path path, List<Point> points) {
    if (points.length < 3) {
      throw UnsupportedError('Need three or more points to create a path.');
    }

    for (var i = 0; i < points.length - 2; i++) {
      final xc = (points[i].x + points[i + 1].x) / 2;
      final yc = (points[i].y + points[i + 1].y) / 2;
      path.quadraticBezierTo(points[i].x, points[i].y, xc, yc);
    }

    // connect the last two points
    path.quadraticBezierTo(
        points[points.length - 2].x,
        points[points.length - 2].y,
        points[points.length - 1].x,
        points[points.length - 1].y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintMountain(size, canvas);
    paintWater(size, canvas);
    paintIce(size, canvas);
  }

  void paintMountain(Size size, Canvas canvas) {
    final path = Path();
    path.moveTo(size.width,
        lerpDouble2(size.height, size.height / 2, mountainAnim.value));
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(
      0,
      lerpDouble2(size.height, 0, mountainAnim.value),
    );
    _addPointsToPath(path, [
      Point(
        lerpDouble2(size.width / 3, 0, mountainAnim.value),
        lerpDouble2(size.height, 0, mountainAnim.value),
      ),
      Point(
        lerpDouble2(size.width / 4 * 3, size.width / 2, mountainAnim.value),
        lerpDouble2(size.height / 4 * 3, size.height / 2, liquidAnim.value),
      ),
      Point(
        size.width,
        lerpDouble2(size.height * 3 / 4, size.height / 2, liquidAnim.value),
      ),
    ]);
    canvas.drawPath(path, mountainPaint);
  }

  void paintWater(Size size, Canvas canvas) {
    final path = Path();
    path.moveTo(size.width, 500);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(
      0,
      lerpDouble2(
        size.height * 4 / 5,
        size.height / 4,
        waterAnim.value,
      ),
    );
    _addPointsToPath(
      path,
      [
        Point(
          size.width / 4,
          lerpDouble2(size.height * 4 / 5, size.height / 2, liquidAnim.value),
        ),
        Point(
          size.width * 3 / 5,
          lerpDouble2(size.height * 3 / 5, size.height / 4, waterAnim.value),
        ),
        Point(
          size.width * 4 / 5,
          lerpDouble2(size.height / 2, size.height / 6, waterAnim.value),
        ),
        Point(
          size.width,
          lerpDouble2(size.height * 0.55, size.height / 5, waterAnim.value),
        ),
      ],
    );

    canvas.drawPath(path, waterPaint);
  }

  void paintIce(Size size, Canvas canvas) {
    final path = Path();

    path.moveTo(size.width * 0.5, 0);
    path.lineTo(0, 0);
    path.lineTo(
      0,
      lerpDouble2(size.height * 0.3, size.height * 0.1, iceAnim.value),
    );
    _addPointsToPath(path, [
      Point(
        0,
        lerpDouble2(size.height * 0.3, size.height * 0.1, iceAnim.value),
      ),
      Point(
        size.width * 0.1,
        lerpDouble2(size.height * 0.31, size.height * 0.15, iceAnim.value),
      ),
      Point(
        size.width * 0.25,
        lerpDouble2(size.height * 0.32, size.height * 0.15, iceAnim.value),
      ),
      Point(
        size.width * 0.4,
        lerpDouble2(size.height * 0.3, size.height * 0.1, liquidAnim.value),
      ),
      Point(
        size.width * 0.6,
        lerpDouble2(size.height * 0.1, size.height * 0.05, liquidAnim.value),
      ),
      Point(
        size.width * 0.8,
        lerpDouble2(size.height * 0, size.height * -0.05, liquidAnim.value),
      ),
    ]);

    canvas.drawPath(path, icePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}

/// Custom curve to give gooey spring effect
class SpringCurve extends Curve {
  const SpringCurve({
    this.a = 0.15,
    this.w = 19.4,
  });

  final double a;
  final double w;

  @override
  double transformInternal(double t) {
    return (-(pow(e, -t / a) * cos(t * w)) + 1).toDouble();
  }
}

double lerpDouble2(num a, num b, double t) {
  if (a == b || (a.isNaN == true) && (b.isNaN == true)) return a.toDouble();
  assert(a.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(b.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(t.isFinite, 't must be finite when interpolating between values');
  return a * (1.0 - t) + b * t;
}
