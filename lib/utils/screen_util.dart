import 'dart:ui';

import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

/// Singleton to record size related data
class ScreenUtils {
  static late Size screenSize;
  static late Size previewSize;

  static Rect boundingBox(DetectedObject object) {
    final double scaleX = screenSize.width / previewSize.height;
    final double scaleY = screenSize.height / previewSize.width;
    return Rect.fromLTRB(
      object.boundingBox.left * scaleX,
      object.boundingBox.top * scaleY,
      object.boundingBox.right * scaleX,
      object.boundingBox.bottom * scaleY,
    );
  }
}
