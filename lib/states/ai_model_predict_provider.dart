// lib/providers/camera_provider.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

late List<CameraDescription> cameras;

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCameraInitialized = false;
  String? _uploadedFileName;
  String? _uploadedFilePath;
  XFile? _capturedImage;

  CameraController? get controller => _controller;
  Future<void>? get initializeControllerFuture => _initializeControllerFuture;
  bool get isCameraInitialized => _isCameraInitialized;
  String? get uploadedFileName => _uploadedFileName;
  String? get uploadedFilePath => _uploadedFilePath;
  XFile? get capturedImage => _capturedImage;

  Future<void> setupCamera(BuildContext context) async {
    if (_isCameraInitialized) {
      print('Camera already initialized.');
      return;
    }

    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras[0], ResolutionPreset.medium);
        _initializeControllerFuture = _controller!.initialize();
        await _initializeControllerFuture;

        _isCameraInitialized = true;
        notifyListeners();
        print('Camera initialized successfully.');
      } else {
        print('No cameras found on this device.');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No cameras found.')));
      }
    } catch (e) {
      print('Error setting up camera: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error setting up camera: $e')));
      _isCameraInitialized = false;
      _controller = null;
      _initializeControllerFuture = null;
      notifyListeners();
    }
  }

  Future<void> uploadModel(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'tflite',
          'pt',
          'onnx',
          'zip',
          'txt',
          'csv',
          'onnx',
          'ipynb',
        ],
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        _uploadedFileName = file.name;
        _uploadedFilePath = file.path;
        notifyListeners();

        print('File picked: ${file.name}');
        print('File path: ${file.path}');
        print('File size: ${file.size} bytes');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Model "${file.name}" selected!')),
        );
      } else {
        print('File picking canceled by user.');
        _uploadedFileName = null;
        _uploadedFilePath = null;
        notifyListeners();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Model upload canceled.')));
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> takePicture(BuildContext context) async {
    if (!_isCameraInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera not initialized. Click Predict first.'),
        ),
      );
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      _capturedImage = image;
      notifyListeners();
      print('Picture taken: ${image.path}');
      if (kIsWeb) {
        final String fileName =
            'captured_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String mimeType = 'image/jpeg';

        final List<int> imageBytes = await image.readAsBytes();

        final html.Blob blob = html.Blob([imageBytes], mimeType);

        final String url = html.Url.createObjectUrlFromBlob(blob);
        final html.AnchorElement anchor =
            html.AnchorElement(href: url)
              ..setAttribute("download", fileName)
              ..click();

        html.Url.revokeObjectUrl(url);

        print('Picture download initiated for web: $fileName');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Picture download initiated: $fileName')),
        );
      } else {
        final Directory appDocumentsDir =
            await getApplicationDocumentsDirectory();
        final String picturesDir = '${appDocumentsDir.path}/CapturedPictures';
        await Directory(picturesDir).create(recursive: true);

        final String timestamp =
            DateTime.now().millisecondsSinceEpoch.toString();
        final String newPath = '$picturesDir/IMG_$timestamp.jpg';

        await image.saveTo(newPath);

        print('Picture saved to: $newPath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Picture saved to: ${image.path}')),
        );
      }
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking picture: $e')));
    }
  }

  void performPrediction(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera not active for prediction.')),
      );
      return;
    }
    print('Performing prediction on live camera feed...');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Prediction initiated!')));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
