import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PieChartData {
  const PieChartData(this.color, this.percent);

  final Color color;
  final double percent;
}

// our pie chart widget
class PieChart extends StatelessWidget {
  PieChart({
    required this.data,
    required this.radius,

    this.strokeWidth = 3,
    this.child,
    super.key,
    required this.oneStory,
  }) : // make sure sum of data is never ovr 100 percent
       assert(data.fold<double>(0, (sum, data) => sum + data.percent) <= 100);
  final bool oneStory;
  final List<PieChartData> data;
  // radius of chart
  final double radius;
  // width of stroke
  final double strokeWidth;
  // optional child; can be used for text for example
  final Widget? child;

  @override
  Widget build(context) {
    return SizedBox(
      height: 8.h,
      width: 8.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _Painter(strokeWidth, data, oneStory),
            size: Size.square(radius),
            child: SizedBox.square(
              // calc diameter
              dimension: radius * 2,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Center(child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// responsible for painting our chart
class _PainterData {
  const _PainterData(this.paint, this.radians);

  final Paint paint;
  final double radians;
}

class _Painter extends CustomPainter {
  _Painter(double strokeWidth, List<PieChartData> data, bool oneStory) {
    // convert chart data to painter data
    dataList =
        data
            .map(
              (e) => _PainterData(
                Paint()
                  ..color = e.color
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..strokeCap = StrokeCap.round,
                // remove padding from stroke
                oneStory
                    ? (e.percent * _percentInRadians)
                    : (e.percent - _padding) * _percentInRadians,
              ),
            )
            .toList();
  }

  static const _percentInRadians = 0.062831853071796;
  // this is the gap between strokes in percent
  static const _padding = 4;
  static const _paddingInRadians = _percentInRadians * _padding;
  // 0 radians is to the right, but since we want to start from the top
  // we'll use -90 degrees in radians
  static const _startAngle = -1.570796 + _paddingInRadians / 2;

  late final List<_PainterData> dataList;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // keep track of start angle for next stroke
    double startAngle = _startAngle;

    for (final data in dataList) {
      final path = Path()..addArc(rect, startAngle, data.radians);

      startAngle += data.radians + _paddingInRadians;

      canvas.drawPath(path, data.paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
