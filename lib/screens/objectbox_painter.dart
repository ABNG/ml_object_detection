import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../utils/screen_util.dart';

class ObjectDetectorPainter extends CustomPainter {
  final DetectedObject object;
  final String targetObjectName;

  ObjectDetectorPainter(
    this.object,
    this.targetObjectName,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      backgroundColor: Colors.red.withValues(alpha: 0.3),
    );

    final rect = ScreenUtils.boundingBox(object);

    // Draw bounding box
    canvas.drawRect(rect, paint);

    // Draw label for each detected object
    for (final label in object.labels) {
      final textSpan = TextSpan(
        text: '${label.text} (${(label.confidence * 100).toStringAsFixed(1)}%)',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left, rect.top - textPainter.height),
      );
      break; // Only show the first label
    }
  }

  @override
  bool shouldRepaint(ObjectDetectorPainter oldDelegate) {
    return true;
  }
}
