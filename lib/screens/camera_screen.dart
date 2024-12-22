import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:ml_object_detection/service/detector_service.dart';
import 'package:ml_object_detection/utils/screen_util.dart';

import '../main.dart';
import 'objectbox_painter.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  final String objectName;

  const CameraScreen({
    super.key,
    required this.objectName,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late DetectorService _detectorService;
  bool _isProcessing = false;
  String _guidance = '';
  DetectedObject? _detectedObject;

  @override
  void initState() {
    super.initState();
    _detectorService = DetectorService()..initializeDetector();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    ScreenUtils.previewSize = _controller.value.previewSize!;
    _guidance = 'Detecting ${widget.objectName}';
    _startImageStream();
    if (mounted) {
      setState(() {});
    }
  }

  void _startImageStream() {
    _controller.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _isProcessing = true;
      final (detectedObject, guidance) =
          await _detectorService.processCameraImage(image, widget.objectName);
      _guidance = guidance;
      _detectedObject = detectedObject;
      setState(() {});
      if (_guidance == 'Object in position') {
        await _captureImage();
        _guidance = 'Detecting ${widget.objectName}';
      }
      _isProcessing = false;
    });
  }

  Future<void> _captureImage() async {
    if (_guidance != 'Object in position') return;

    final image = await _controller.takePicture();
    if (!mounted) return;
    await _controller.stopImageStream();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          imagePath: image.path,
          objectName: widget.objectName,
        ),
      ),
    ).then((_) async {
      _startImageStream();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _detectorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils.screenSize = MediaQuery.sizeOf(context);
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // appBar: AppBar(title: Text('Capture ${widget.objectName}')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller)),
          if (_detectedObject != null)
            CustomPaint(
              painter: ObjectDetectorPainter(
                _detectedObject!,
                widget.objectName,
              ),
            ),
          _buildGuidanceOverlay(),
        ],
      ),
    );
  }

  Widget _buildGuidanceOverlay() {
    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _guidance,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
