import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart'; // Import for file_picker
// Removed archive imports as zipping is no longer needed

class ClassWidget extends StatefulWidget {
  String className;
  bool classEnabled;
  final Function(String) onDelete;

  ClassWidget({
    super.key,
    required this.className,
    this.classEnabled = true,
    required this.onDelete, // Default to enabled
  });

  @override
  State<ClassWidget> createState() => _ClassWidgetState();
}

class _ClassWidgetState extends State<ClassWidget> {
  int sampleCount = 0;
  List<XFile> _selectedImages = []; // List to store selected images

  // Function to pick an image from the camera
  void onCameraPressed() async {
    ImagePicker imagePicker = ImagePicker();
    try {
      final image = await imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(image); // Add the image to the list
          sampleCount = _selectedImages.length; // Update the sample count
        });
      }
    } catch (error) {
      print('Error picking image from camera: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image from camera: $error')),
      );
    }
  }

  // Function to pick an image from the gallery
  void onUploadPressed() async {
    ImagePicker imagePicker = ImagePicker();
    try {
      final image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(image); // Add the image to the list
          sampleCount = _selectedImages.length; // Update the sample count
        });
      }
    } catch (error) {
      print('Error picking image from gallery: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image from gallery: $error')),
      );
    }
  }

  // Function to handle editing the class name
  void onEditPressed() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController classNameController = TextEditingController(
          text: widget.className,
        );
        return AlertDialog(
          title: const Text('Edit Class Name'),
          content: TextField(
            controller: classNameController,
            decoration: const InputDecoration(hintText: 'Enter new class name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.className =
                      classNameController.text; // Update the class name
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      debugPrint('Initial Permission.storage status: $status');

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Storage permission permanently denied. Please enable it in app settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () async {
                await openAppSettings();
              },
            ),
          ),
        );
        return false;
      } else {
        status = await Permission.storage.request();
        debugPrint('After request Permission.storage status: $status');
        if (status.isGranted) {
          return true;
        } else if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission denied. Please grant permission to save files.',
              ),
            ),
          );
          return false;
        }
      }
      return false;
    }
    return true;
  }

  // Function to select a directory for saving files
  Future<String?> _selectDirectory() async {
    // if (!await _requestPermissions()) {
    //   return null;
    // }

    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      return selectedDirectory;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting directory: $e')));
      print('Error selecting directory: $e');
      return null;
    }
  }

  // Function to save individual images to a class-named directory
  Future<void> _saveImagesToClassDirectory(
    List<XFile> images,
    String className,
    String? parentDirectoryPath,
  ) async {
    // if (!await _requestPermissions()) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Storage permission denied. Cannot save images.')),
    //   );
    //   return;
    // }

    if (images.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No images to save.')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving images to class directory...')),
    );

    try {
      final String baseDirectory;
      if (parentDirectoryPath != null && parentDirectoryPath.isNotEmpty) {
        baseDirectory = parentDirectoryPath;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        baseDirectory = directory.path;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No custom directory selected. Saving to app documents.',
            ),
          ),
        );
      }

      // Create a new directory named after the class
      final classDirectoryPath = '$baseDirectory/$className';
      final classDir = Directory(classDirectoryPath);
      if (!await classDir.exists()) {
        await classDir.create(recursive: true);
        print('Created directory: $classDirectoryPath');
      }

      int savedCount = 0;
      for (int i = 0; i < images.length; i++) {
        // Use a loop with index
        final image = images[i];
        try {
          final file = File(image.path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            // Construct the new file path in the class directory with .jpeg extension
            // Naming convention: className_simple[index+1].jpeg
            final newFileName = '${className}_simple${i + 1}.jpeg';
            final newFilePath = '$classDirectoryPath/$newFileName';
            final newFile = File(newFilePath);
            await newFile.writeAsBytes(bytes);
            savedCount++;
            print('Saved image: $newFilePath');
          } else {
            print('Warning: Source image file not found at ${image.path}');
          }
        } catch (e) {
          print('Error saving individual image ${image.name}: $e');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved $savedCount images to: $classDirectoryPath'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save images to directory: $e')),
      );
      print('Error saving images to directory: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.className,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        onEditPressed();
                      },
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'delete') {
                          widget.onDelete(widget.className);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${widget.className} deleted'),
                            ),
                          );
                        } else if (value == 'disable') {
                          setState(() {
                            widget.classEnabled = false;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.className} disabled'),
                              ),
                            );
                          });
                        } else if (value == 'enable') {
                          setState(() {
                            widget.classEnabled = true;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.className} enabled'),
                              ),
                            );
                          });
                        } else if (value == 'remove') {
                          setState(() {
                            _selectedImages.clear();
                            sampleCount = 0;
                          });
                        } else if (value == 'download') {
                          if (_selectedImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No images to download.'),
                              ),
                            );
                            return;
                          }

                          String? selectedDir = await _selectDirectory();
                          if (selectedDir != null) {
                            await _saveImagesToClassDirectory(
                              _selectedImages,
                              widget.className,
                              selectedDir,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Download cancelled: No directory selected.',
                                ),
                              ),
                            );
                          }
                        } else if (value == 'share') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Share functionality not yet implemented.',
                              ),
                            ),
                          );
                        }
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Class'),
                            ),
                            const PopupMenuItem(
                              value: 'disable',
                              child: Text('Disable Class'),
                            ),
                            const PopupMenuItem(
                              value: 'enable',
                              child: Text('Enable Class'),
                            ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text('Remove All Samples'),
                            ),
                            const PopupMenuItem(
                              value: 'download',
                              child: Text('Download Samples'),
                            ),
                            const PopupMenuItem(
                              value: 'share',
                              child: Text('Share Samples'),
                            ),
                          ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add Image Samples: $sampleCount samples',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Display selected images in a GridView
            if (_selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of images per row
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Image.file(
                    File(_selectedImages[index].path),
                    fit: BoxFit.cover,
                  );
                },
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onCameraPressed,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text(
                    'Camera',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onUploadPressed,
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text(
                    'Upload',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
