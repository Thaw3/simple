import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple/widgets/ai_model_predict_widget.dart';
import 'package:simple/states/ai_model_predict_provider.dart'; // Import your provider

class CameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        return CameraView(
          controller: cameraProvider.controller,
          initializeControllerFuture: cameraProvider.initializeControllerFuture,
          uploadedFileName: cameraProvider.uploadedFileName,
          uploadedFilePath: cameraProvider.uploadedFilePath,
          isCameraInitialized: cameraProvider.isCameraInitialized,
          onUploadModel: () => cameraProvider.uploadModel(context),
          onPredict: () => cameraProvider.setupCamera(context),
          onTakePicture: () => cameraProvider.takePicture(context),
        );
      },
    );
  }
}
