// import 'dart:io';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as image_lib;
// import 'package:tflite_flutter/tflite_flutter.dart';
//
// import '../model/recognition.dart';
// import '../utils/image_utils.dart';
//
// class Detector {
//   static const String _modelPath = 'assets/ml/ssd_mobilenet.tflite';
//   static const String _labelPath = 'assets/ml/ssd_mobilenet.txt';
//
//   /// Input size of image (height = width = 300)
//   static const int mlModelInputSize = 300;
//
//   /// Result confidence threshold
//   static const double confidence = 0.5;
//
//   final Interpreter _interpreter;
//   final List<String> _labels;
//   Detector._(this._interpreter, this._labels);
//
//   static Future<Detector> start() async {
//     return Detector._(
//       await _loadModel(),
//       await _loadLabels(),
//     );
//   }
//
//   static Future<Interpreter> _loadModel() async {
//     final interpreterOptions = InterpreterOptions();
//     if (Platform.isAndroid) {
//       interpreterOptions.addDelegate(XNNPackDelegate());
//     }
//
//     // Use Metal Delegate
//     if (Platform.isIOS) {
//       interpreterOptions.addDelegate(GpuDelegate());
//     }
//
//     return Interpreter.fromAsset(
//       _modelPath,
//       options: interpreterOptions..threads = 4,
//     );
//   }
//
//   static Future<List<String>> _loadLabels() async {
//     return (await rootBundle.loadString(_labelPath)).split('\n');
//   }
//
//   ///should be in background isolate
//   Future<List<Recognition>?> processFrame(
//       CameraImage cameraImage, List<String> targetsToDetect) async {
//     //TODO: STEP-1: Pre-process the image
//
//     image_lib.Image? image = await convertCameraImageToImage(cameraImage);
//
//     if (image != null) {
//       if (Platform.isAndroid) {
//         image = image_lib.copyRotate(image, angle: 90);
//       }
//
//       /// Pre-process the image
//       /// Resizing image for model [300, 300]
//       final imageInput = image_lib.copyResize(
//         image,
//         width: mlModelInputSize,
//         height: mlModelInputSize,
//       );
//
//       // Creating matrix representation, [300, 300, 3]
//       final imageMatrix = List.generate(
//         imageInput.height,
//         (y) => List.generate(
//           imageInput.width,
//           (x) {
//             final pixel = imageInput.getPixel(x, y);
//             return [pixel.r, pixel.g, pixel.b];
//           },
//         ),
//       );
//
//       //TODO: STEP-2: Run inference
//
//       final output = _runInference(imageMatrix);
//
//       //TODO: STEP-3: Post-process the output
//
//       // Classes
//       final classesRaw = output.elementAt(1).first as List<double>;
//       final classes = classesRaw.map((value) => value.toInt()).toList();
//
//       // Number of detections
//       final numberOfDetectionsRaw = output.last.first as double;
//       final numberOfDetections = numberOfDetectionsRaw.toInt();
//
//       final List<int> selectedTargetIndex = [];
//       if (targetsToDetect.isEmpty) {
//         /// target all objects
//         selectedTargetIndex
//             .addAll(List.generate(numberOfDetections, (index) => index));
//       } else {
//         /// target only selected objects
//         for (int i = 0; i < numberOfDetections; i++) {
//           if (targetsToDetect.contains(_labels[classes[i]])) {
//             selectedTargetIndex.add(i);
//           }
//         }
//       }
//
//       if (selectedTargetIndex.isEmpty) {
//         return null;
//       }
//
//       // Scores
//       final scores = output.elementAt(2).first as List<double>;
//       // Location
//       final locationsRaw = output.first.first as List<List<double>>;
//       final List<Rect> locations = locationsRaw
//           .map((list) =>
//               list.map((value) => (value * mlModelInputSize)).toList())
//           .map((rect) => Rect.fromLTRB(rect[1], rect[0], rect[3], rect[2]))
//           .toList();
//
//       /// Generate recognitions
//       List<Recognition> recognitions = [];
//       for (int i = 0; i < selectedTargetIndex.length; i++) {
//         // Prediction score
//         var score = scores[selectedTargetIndex[i]];
//         // Label string
//         var label = _labels[classes[selectedTargetIndex[i]]];
//
//         if (score > confidence) {
//           recognitions.add(
//             Recognition(selectedTargetIndex[i], label, score,
//                 locations[selectedTargetIndex[i]]),
//           );
//         }
//       }
//       return recognitions;
//     }
//     return null;
//   }
//
//   void dispose() {
//     _interpreter.close();
//   }
//
//   /// Object detection main function
//   List<List<Object>> _runInference(
//     List<List<List<num>>> imageMatrix,
//   ) {
//     // Set input tensor [1, 300, 300, 3]
//     final input = [imageMatrix];
//
//     // print("input tensor ${_interpreter.getInputTensors()}");
//     // final inputShape = _interpreter.getInputTensor(0).shape;
//     // final outputShape = _interpreter.getOutputTensor(0).shape;
//     //
//     // print('Input Shape: $inputShape');
//     // print('Output Shape: $outputShape');
//
//     // Set output tensor
//     // Locations: [1, 10, 4]
//     // Classes: [1, 10],
//     // Scores: [1, 10],
//     // Number of detections: [1]
//     final output = {
//       0: [List<List<num>>.filled(10, List<num>.filled(4, 0))],
//       1: [List<num>.filled(10, 0)],
//       2: [List<num>.filled(10, 0)],
//       3: [0.0],
//     };
//
//     _interpreter.runForMultipleInputs([input], output);
//     return output.values.toList();
//   }
// }
