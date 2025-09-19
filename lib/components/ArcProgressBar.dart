import 'dart:math' as Math;
import 'dart:ui' as UI;
import 'package:flutter/material.dart';
import '../config/constants.dart';

class ArcProgressBar extends StatefulWidget {
  final double width; // 宽
  final double height; // 高
  final double min; // 最小值
  final double max; // 最大值
  final double progress; // 进度值
  const ArcProgressBar(
      {Key? key,
      this.width = 0,
      this.height = 0,
      this.min = 0,
      this.max = 120,
      this.progress = 0})
      : super(key: key);
  @override
  ArcProgressBarState createState() => ArcProgressBarState();
}

class ArcProgressBarState extends State<ArcProgressBar> {
  @override
  Widget build(BuildContext context) => AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _ArcProgressBarPainter(8, widget.progress,
            min: widget.min, max: widget.max),
      ));
}

class _ArcProgressBarPainter extends CustomPainter {
  final Paint _paint = Paint();

  double _strokeSize = 1;

  double get _margin => _strokeSize / 2;

  double progress = 0;

  double min;

  double max;

  _ArcProgressBarPainter(double strokeSize, this.progress,
      {this.min = 0, this.max = 100}) {
    _strokeSize = strokeSize;
    if (progress == null || progress < min) progress = 0;
    if (progress > max) progress = max;
    if (min == null || min <= 0) min = 0;
    if (max == null || max <= min) max = 100;
  }

  @override
  void paint(Canvas canvas, Size size) {
    num radius = size.width / 2;
    num cx = radius;
    num cy = radius;
    _drawProgressArc(canvas, size);
    _drawArcProgressPoint(canvas, cx, cy, radius);
    _drawArcPointLine(canvas, cx, cy, radius);
  }

  void _drawProgressArc(Canvas canvas, Size size) {
    _paint
      ..isAntiAlias = true
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _strokeSize;
    canvas.drawArc(
        Rect.fromLTWH(_margin, _margin, size.width - _strokeSize,
            size.height - _strokeSize),
        _toRadius(120),
        _toRadius(300),
        false,
        _paint);

    _paint
      ..color = UI.Color.fromARGB(255, 245, 116, 30)
      ..strokeWidth = _strokeSize - 1;
    canvas.drawArc(
        Rect.fromLTWH(_margin + 1, _margin + 1, size.width - _strokeSize - 2,
            size.height - _strokeSize - 2),
        _toRadius(120),
        progress * _toRadius(300 / (max - min)),
        false,
        _paint);
  }

  void _drawArcProgressPoint(Canvas canvas, num cx, num cy, num radius) {
    _paint.strokeWidth = 1;
    canvas.save();
    canvas.translate(cx as double, cy as double);
    canvas.rotate(_toRadius(120));
    canvas.translate(-cx, -cy);
    for (int i = 0; i <= (max - min); i++) {
      double evaDegree = i * _toRadius(300 / (max - min));
      double b = i % 10 == 0 ? -5 : 0;
      double x = cx + (radius - 20 + b) * Math.cos(evaDegree);
      double y = cy + (radius - 20 + b) * Math.sin(evaDegree);
      double x1 = cx + (radius - 12) * Math.cos(evaDegree);
      double y1 = cx + (radius - 12) * Math.sin(evaDegree);
      canvas.drawLine(Offset(x, y), Offset(x1, y1), _paint);
    }
    canvas.translate(cx, cy);
    canvas.rotate(_toRadius(-120));
    canvas.translate(-cx, -cy);
    for (int i = min.toInt(); i <= max; i += 10) {
      var pb = UI.ParagraphBuilder(
          UI.ParagraphStyle(fontSize: 15, textAlign: TextAlign.start))
        ..pushStyle(UI.TextStyle(color: Colors.black))
        ..addText(i.toString());
      UI.Paragraph p = pb.build()
        ..layout(const UI.ParagraphConstraints(width: 30));
      num evaDegree = _toRadius(120) + i * _toRadius(300 / (max - min));
      num x = cx + (radius - 40) * Math.cos(evaDegree);
      num y = cy + (radius - 40) * Math.sin(evaDegree);
      canvas.drawParagraph(p, Offset(x - 8, y - 10));
    }
    canvas.restore();
  }

  void _drawArcPointLine(UI.Canvas canvas, num cx, num cy, num radius) {
    canvas.save();
    canvas.translate(cx as double, cy as double);
    canvas.rotate(_toRadius(120));
    canvas.translate(-cx, -cy);
    _paint
      ..color = UI.Color.fromARGB(255, 255, 114, 32)
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    num degree = _toRadius(300 / (max - min)) * progress;
    num x = cx + radius * 3 / 5 * Math.cos(degree);
    num y = cy + radius * 3 / 5 * Math.sin(degree);
    canvas.drawLine(Offset(cx, cy), Offset(x as double, y as double), _paint);
    _paint.color = UI.Color.fromARGB(255, 245, 104, 38);
    canvas.drawCircle(Offset(cx, cy), 12, _paint);
    canvas.restore();
  }

  double _toRadius(double degree) => degree * Math.pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
