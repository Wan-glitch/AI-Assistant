import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import "package:path_provider/path_provider.dart";

class CameraScreen extends StatefulWidget {
  final CameraController controller;

  CameraScreen({required this.controller});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String _extractedText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: Stack(
        children: [
          CameraPreview(widget.controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _captureImageAndExtractText,
                  child: Text('Capture and Extract Text'),
                ),
                SizedBox(height: 10),
                _extractedText.isNotEmpty
                    ? Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.black54,
                        child: Text(
                          _extractedText,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to capture image and extract text
  void _captureImageAndExtractText() async {
    try {
      // Capture the image
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Update this line
      final XFile picture = await widget.controller.takePicture();
      await picture.saveTo(filePath);

      final image = InputImage.fromFilePath(filePath);

      // Initialize text recognizer
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(image);

      // Process recognized text
      String extractedText = "";
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += line.text + '\n';
        }
      }

      setState(() {
        _extractedText = extractedText;
      });

      // Dispose the text recognizer after use
      textRecognizer.close();
    } catch (e) {
      print('Error occurred while capturing image: $e');
    }
  }
}