import 'dart:math';
import 'dart:ui';
import 'package:app/view/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// To use it, just wrap it in a container of the required size
// 使用するには、必要なサイズの容器に包むだけです

// This container is just an example and not the correct syntax
Container(
  height: 52.0,
  width: 52.0,
  child: AnimatedCheck(
    color: Color(0xff47f2e5),
    controller: controller1, // I defined this controller in my main class.
  ),
),


class AnimatedCheck extends AnimatedWidget {
  const AnimatedCheck({
    Key? key,
    required this.controller,
    required this.color,
  }) : super(key: key, listenable: controller);
  final AnimationController controller;
  final Color color;

  // I just passed my controller here, just pass your controller here and color of the check
  // ここにコントローラーを渡しました。ここにコントローラーを渡し、小切手の色を渡します
  Widget build(BuildContext context) {
    final Animation<double> progress =
        Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.87, 0.95, curve: Curves.linear),
      ),
    );
    final Animation<double> opacity =
        Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.95, 1.00, curve: Curves.linear),
      ),
    );

    // Above mentioned are animation values. I used opacity also but the progress tween is necessary to animate the check.
    // 上記はアニメーション値です。不透明度も使用しましたが、チェックをアニメーション化するにはプログレストゥイーンが必要です
    return Opacity(
      opacity: opacity.value,
      child: CustomPaint(
        painter: AnimatedPathPainter(
          animation: progress,
          color: color,
        ),
      ),
    );
  }
}

class AnimatedPathPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final double? strokeWidth;
  AnimatedPathPainter(
      {required this.animation, required this.color, this.strokeWidth});
  Path _createAnyPath(Size size) {
    return Path()
      ..moveTo(size.width / 2 - 0.5 * size.width / 2,
          size.height / 2 - 0.125 * size.height / 2)
      ..lineTo(size.width / 2 + 0.0 * size.width / 2,
          size.height / 2 + 0.40 * size.height / 2)
      ..lineTo(size.width / 2 + 0.85 * size.width / 2,
          size.height / 2 - 0.45 * size.height / 2);
  } 

  Path createAnimatedPath(Path originalPath, double animationPercent) {
    final totalLength = originalPath
        .computeMetrics()
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

    final currentLength = totalLength * animationPercent;

    return extractPathUntilLength(originalPath, currentLength);
  }

  Path extractPathUntilLength(Path originalPath, double length) {
    var currentLength = 0.0;
    final path = new Path();
    var metricsIterator = originalPath.computeMetrics().iterator;
    while (metricsIterator.moveNext()) {
      var metric = metricsIterator.current;
      var nextLength = currentLength + metric.length;
      final isLastSegment = nextLength > length;
      if (isLastSegment) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0.0, remainingLength);
        path.addPath(pathSegment, Offset.zero);
        break;
      } else {
        final pathSegment = metric.extractPath(0.0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }

      currentLength = nextLength;
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final animationPercent = this.animation.value;

    var center = Offset(size.width / 2, size.height / 2);
    var radius = size.width / 2;
    var circleBrush = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12; // このストローク幅は、その外側の円用です // this strokewidth is for circle outside it 
    if (animationPercent > 0.0) {
      canvas.drawCircle(center, radius - 5.0, circleBrush); //In this if function, I just drew the whole circle in one go
    } // このif関数では、円全体を一度に描画しました

    final path = createAnimatedPath(_createAnyPath(size), animationPercent);

    final Paint paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;
    paint.strokeWidth = strokeWidth ?? size.width * 0.14; //このストローク幅はチェックマーク用です // this strokewidth is for check
    if (animationPercent > 0) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
