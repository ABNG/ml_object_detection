import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:ml_object_detection/utils/screen_util.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DetectorService {
  late ObjectDetector _objectDetector;
  List<String> _labels = [];

  Future<void> initializeDetector() async {
    final modelPath =
        await _getModelPath('assets/ml/mobilenet_v1_1.0_224_quant.tflite');
    await _loadLabels();
    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,
      modelPath: modelPath,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<String> _getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(p.dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  Future<void> _loadLabels() async {
    _labels = (await rootBundle.loadString("assets/ml/labels.txt")).split('\n');
  }

  Future<(DetectedObject?, String)> processCameraImage(
      CameraImage image, String targetObjectName) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: InputImageRotation.rotation90deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
    final detectedObjects = await _objectDetector.processImage(inputImage);
    return _processDetectedObjects(detectedObjects, targetObjectName);
  }

  (DetectedObject?, String) _processDetectedObjects(
      List<DetectedObject> objects, String targetObjectName) {
    String _guidance = '';
    for (final object in objects) {
      if (_isTargetObject(object, targetObjectName)) {
        final boxSize = ScreenUtils.boundingBox(object).size;
        final screenSize = ScreenUtils.screenSize;
        if (boxSize.width < screenSize.width * 0.3) {
          _guidance = 'Move closer';
        } else if (boxSize.width > screenSize.width * 0.8) {
          _guidance = 'Move farther';
        } else {
          _guidance = 'Object in position';
        }
        return (object, _guidance);
      }
    }
    _guidance = 'Detecting $targetObjectName...';
    return (null, _guidance);
  }

  bool _isTargetObject(DetectedObject object, String targetObjectName) {
    return object.labels.any((label) => _labels[label.index]
        .toLowerCase()
        .contains(targetObjectName.toLowerCase()));
  }

  void dispose() {
    _objectDetector.close();
  }
}
