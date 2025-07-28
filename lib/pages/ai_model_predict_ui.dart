import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
//import 'dart:html' as html;
import 'package:simple/widgets/ai_model_predict_widget.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  bool _isCameraInitialized = false;

  String? _uploadedFileName;
  String? _uploadedFilePath;

  XFile? _capturedImage; // New: To store the captured image
  bool _showCameraPreview =
      false; // New: Flag to control camera preview visibility

  @override
  void initState() {
    super.initState();
    // _setupCamera();
  }

  // This function sets up the camera and initializes the controller
  Future<void> _setupCamera() async {
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
        await _initializeControllerFuture; // Wait for initialization to complete

        setState(() {
          _isCameraInitialized = true; // Set flag to true
        });
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
      setState(() {
        _isCameraInitialized = false; // Reset flag on error
        _controller = null;
        _initializeControllerFuture = null;
      });
    }
  }

  // Modified _uploadModel function to store and display file info
  Future<void> _uploadModel() async {
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
      ); // Allow multiple file types

      if (result != null) {
        PlatformFile file = result.files.first;

        // Update the state with the file's name and path
        setState(() {
          _uploadedFileName = file.name;
          _uploadedFilePath = file.path; // file.path will be null for web
        });

        print('File picked: ${file.name}');
        print('File path: ${file.path}');
        print('File size: ${file.size} bytes'); // Display file size

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Model "${file.name}" selected!')),
        ); // Show a snackbar with the file name
      } else {
        // User canceled the picker
        print('File picking canceled by user.');
        setState(() {
          _uploadedFileName = null; // Clear previous selection if canceled
          _uploadedFilePath = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Model upload canceled.')),
        ); // Show a snackbar for cancellation
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    } // Reset the camera state after uploading a model
  }

  // New function for the "Capture" button
  Future<void> _takePicture() async {
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
      print('Picture taken: ${image.path}');
      //for web
      // if (kIsWeb) {
      //   // --- Web-specific saving (download) ---
      //   final String fileName =
      //       'captured_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      //   final String mimeType = 'image/jpeg';

      //   // Read the image bytes from the XFile
      //   final List<int> imageBytes = await image.readAsBytes();

      //   // Create a Blob from the bytes
      //   final html.Blob blob = html.Blob([imageBytes], mimeType);

      //   // Create a download link
      //   final String url = html.Url.createObjectUrlFromBlob(blob);
      //   final html.AnchorElement anchor =
      //       html.AnchorElement(href: url)
      //         ..setAttribute("download", fileName)
      //         ..click();

      //   html.Url.revokeObjectUrl(url); // Clean up the URL object

      //   print('Picture download initiated for web: $fileName');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Picture download initiated: $fileName')),
      //   );
      // } else {
      //   // --- Mobile/Desktop saving (to app's documents directory) ---
      //   final Directory appDocumentsDir =
      //       await getApplicationDocumentsDirectory();
      //   final String picturesDir = '${appDocumentsDir.path}/CapturedPictures';
      //   await Directory(picturesDir).create(recursive: true);

      //   final String timestamp =
      //       DateTime.now().millisecondsSinceEpoch.toString();
      //   final String newPath = '$picturesDir/IMG_$timestamp.jpg';

      //   await image.saveTo(newPath);

      //   print('Picture saved to: $newPath');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Picture saved to: ${image.path}')),
      //   );
      // You can now process the image, display it, or save it permanently.
      //}
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking picture: $e')));
    }
  }

  // New function to perform prediction on the live camera feed
  void _performPrediction() {
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

  // This widget builds the camera view with the controller and other parameters
  @override
  Widget build(BuildContext context) {
    // Pass all necessary state and callbacks to the CameraView widget
    return CameraView(
      controller: _controller,
      initializeControllerFuture: _initializeControllerFuture,
      uploadedFileName: _uploadedFileName,
      uploadedFilePath: _uploadedFilePath,
      isCameraInitialized: _isCameraInitialized,
      onUploadModel: _uploadModel,
      onPredict: _setupCamera, // The "Predict" button now calls _setupCamera
      onTakePicture: _takePicture,
    );
  }
}
