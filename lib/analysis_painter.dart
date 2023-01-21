import 'package:aws_rekognition_api/rekognition-2016-06-27.dart';
import 'package:flutter/material.dart';

class AnalysisPainter extends CustomPainter {
  AnalysisPainter(this.customLabels);

  List<CustomLabel>? customLabels;

  // Paint Bounding boxes as rectangles
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    // Initialize with dummy values. They will never be displayed, as if
    // a bounding box with 0-values will be returned, an exception is thrown
    // and caught in the paint-method.
    double dx = 1.0;
    double dy = 2.0;
    double dWidth = 3.0;
    double dHeight = 4.0;

    for (CustomLabel label in customLabels!) {
      try {
        double? left = label.geometry?.boundingBox?.left;
        if (left != null) {
          dx = left * size.width;
        } else {
          throw Exception();
        }
        double? top = label.geometry?.boundingBox?.top;
        if (top != null) {
          dy = top * size.height;
        } else {
          throw Exception();
        }

        double? width = label.geometry?.boundingBox?.width;
        if (width != null) {
          dWidth = width * size.width;
        } else {
          throw Exception();
        }

        double? height = label.geometry?.boundingBox?.height;
        if (height != null) {
          dHeight = height * size.height;
        } else {
          throw Exception();
        }

        Rect rect = Offset(dx, dy) & Size(dWidth, dHeight);
        canvas.drawRect(rect, paint);
      } on Exception catch (e) {
        print(
            "Likely Reason for Error: Returned Bounding Box from AWS had 0 values!");
        print(e);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
