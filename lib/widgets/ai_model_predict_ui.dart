import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

late List<CameraDescription> cameras;

/// The main widget that encapsulates the entire UI of the camera screen.
/// It receives all necessary data and callbacks from the stateful parent.
class CameraView extends StatelessWidget {
  final CameraController? controller;
  final Future<void>? initializeControllerFuture;
  final String? uploadedFileName;
  final String? uploadedFilePath;
  final bool isCameraInitialized; // Renamed for clarity in this widget

  final VoidCallback onUploadModel;
  final VoidCallback onPredict;
  final VoidCallback onTakePicture;

  const CameraView({
    Key? key,
    required this.controller,
    required this.initializeControllerFuture,
    required this.uploadedFileName,
    required this.uploadedFilePath,
    required this.isCameraInitialized,
    required this.onUploadModel,
    required this.onPredict,
    required this.onTakePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Buttons section
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 255, 254, 254),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                //buttons place top center of pafe
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onUploadModel, // Using passed callback
                    child: const Text('Upload Model'),
                  ),
                  ElevatedButton(
                    onPressed: onPredict, // Using passed callback
                    child: const Text('Predict'),
                  ),
                ],
              ),
            ),
          ),
          // Display uploaded file information
          if (uploadedFileName != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Uploaded File:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('Name: $uploadedFileName'),
                  // Only show path if it's available (might be null on web)
                  // if (uploadedFilePath != null) Text('Path: $uploadedFilePath'),
                ],
              ),
            ),

          // Camera preview section
          Expanded(
            child: Center(
              child:
                  isCameraInitialized &&
                      controller != null &&
                      initializeControllerFuture != null
                  ? FutureBuilder<void>(
                      future: initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Center(
                            child: AspectRatio(
                              aspectRatio: controller!.value.aspectRatio,
                              child: CameraPreview(controller!),
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    )
                  : const Center(
                      child: Text(
                        'Click "Predict" to open camera.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
            ),
          ),

          // Capture button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton.icon(
              onPressed: onTakePicture, // Using passed callback
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture'), // Label is now 'Capture'
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: const Color.fromARGB(255, 135, 168, 196),
                foregroundColor: Colors.white,
                elevation: 5,
              ),
            ),
          ),
          const SizedBox(height: 320),
        ],
      ),
    );
  }
}
