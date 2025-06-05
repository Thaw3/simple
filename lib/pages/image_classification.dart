import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple/widgets/camera_screen.dart';

class ImageClassification extends StatefulWidget {
  const ImageClassification({super.key});

  @override
  State<ImageClassification> createState() => _ImageClassificationState();
}

class _ImageClassificationState extends State<ImageClassification> {
  File? _imageFile;
  final picker = ImagePicker();
  List<Map<String, dynamic>> _results = [];

  Future<void> _getImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _results = [
          {"label": "Room", "score": 0.84},
          {"label": "Shelf", "score": 0.77},
          {"label": "Tile", "score": 0.72},
          {"label": "Space", "score": 0.69},
        ];
      });
    }
  }
  Future<void> _openCamera() async {

    final result = await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );

    if (result != null) {
      setState(() {
        //imagePaths.add(result.path); // Or store for upload
      });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Capture features'),
        content: Image.file(result),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.grey[200],
                width: double.infinity,
                height: 250,
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : const Center(child: Text("No image selected")),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: () => _getImage(ImageSource.gallery),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () => _openCamera(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _results.map((result) {
                  return Text(
                    "${result['label']}  ${result['score']}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
