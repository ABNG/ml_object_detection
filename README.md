# Object Detection App with Flutter

A real-time object detection application built with Flutter that uses ML Kit for object detection.

## Features

- Real-time object detection using ML Kit
- Object detection with visual guidance
- Live detection confidence scores
- auto Capture detected object image
- Cross-platform support (iOS and Android)

## Requirements

- Flutter 3.27
- Dart 3.6.0
- iOS 15.6 or higher
- Android (API 26 or higher)

## Dependencies

```yaml
dependencies:
  camera: ^0.11.0+2
  google_mlkit_object_detection: ^0.11.0
  path_provider: ^2.1.5
  path: ^1.9.0
  intl: ^0.20.1
```

## Installation

1. Clone the repository:
```bash
git clone [repository-url]
```

2. Navigate to project directory and install dependencies:
```bash
flutter clean && flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

1. Launch the app
2. Select an object type from the available options
3. Point your camera at the object
4. Follow the on-screen guidance to position the object correctly
5. The app will automatically capture the image when the object is properly positioned
6. View the captured image with detection details

## Implementation Challenges and Solutions

### Challenge: Model Selection and Integration
Initially attempted to use tflite-flutter plugin for custom model integration. However, faced compatibility issues with current model and other models which are compatible with tflite_flutter plugin was not good enough.

**Solution:** Switched to Google ML Kit's object detection, which provided:
- Better out-of-the-box performance
- Easier setup and integration
- support custom model integration
- More reliable detection results
- Firebase ML integration capabilities if needed


## Video Demo

[Link to video demonstration to be added]
