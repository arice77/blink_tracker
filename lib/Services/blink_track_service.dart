import 'dart:ui';
import 'package:blink_tracker/Services/forefround_service.dart';
import 'package:camera_bg/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class BlinkTrack {
  final _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
    enableClassification: true,
  ));
  bool _isOpenend = true;

  InputImage getInputImage(CameraImage img) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in img.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(img.width.toDouble(), img.height.toDouble());
    final camera = cameras[1];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);

    final inputImageFormat = InputImageFormatValue.fromRawValue(img.format.raw);

    final planeData = img.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation!,
      inputImageFormat: inputImageFormat!,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    return inputImage;
  }

  void imageProcess(InputImage inputImage) async {
    final List<Face> faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      return;
    }
    Face face = faces.first;

    final double? leftEyeOpenProbability = face.leftEyeOpenProbability;
    final double? rightEyeOpenProbability = face.rightEyeOpenProbability;

    if (leftEyeOpenProbability != null &&
        rightEyeOpenProbability != null &&
        leftEyeOpenProbability > 0.3 &&
        rightEyeOpenProbability > 0.3) {
      _isOpenend = true;
    }

    if (leftEyeOpenProbability != null &&
        rightEyeOpenProbability != null &&
        leftEyeOpenProbability < 0.1 &&
        rightEyeOpenProbability < 0.1) {
      if (_isOpenend) {
        blinkCount++;

        _isOpenend = false;
      }
    }
  }
}
