import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/background_service.dart';
import '../widgets/floating_button.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isVoiceEnabled = false;
  bool _isCameraEnabled = false;
  final BackgroundService _backgroundService = BackgroundService();
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _command = "";
  CameraController? _cameraController;
  final FlutterTts _flutterTts = FlutterTts();  // Initialize Text-to-Speech

  @override
  void initState() {
    super.initState();
    _backgroundService.startBackgroundService();
    _speechToText = stt.SpeechToText();
  }

  @override
  void dispose() {
    _backgroundService.stopBackgroundService();
    _cameraController?.dispose();
    _flutterTts.stop();  // Stop TTS if active
    super.dispose();
  }

  // Function to start listening to voice commands
  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(onResult: (val) {
        setState(() {
          _command = val.recognizedWords;
          _processCommand(_command);
        });
      });
    }
  }

  // Function to stop listening
  void _stopListening() {
    setState(() => _isListening = false);
    _speechToText.stop();
  }

  // Function to process the voice command
  void _processCommand(String command) {
    command = command.toLowerCase();
    if (command.contains('open camera')) {
      setState(() => _isCameraEnabled = true);
      _openCamera();
    } else if (command.contains('voice recognition off')) {
      setState(() => _isVoiceEnabled = false);
    } else if (command.contains('voice recognition on')) {
      setState(() => _isVoiceEnabled = true);
    } else if (command.contains('copy text')) {
      _captureImageAndExtractText();
    }
  }

  // Function to open the camera
  void _openCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    await _cameraController!.initialize();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(controller: _cameraController!),
      ),
    );
  }

  // Function to capture image and extract text
  void _captureImageAndExtractText() async {
    if (_cameraController != null) {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';


      final XFile picture = await _cameraController!.takePicture();
      await picture.saveTo(filePath);

      final image = InputImage.fromFilePath(filePath);

      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(image);

      String extractedText = "";
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += line.text + '\n';
        }
      }

      textRecognizer.close();

      // Speak the extracted text using TTS
      _speak(extractedText);

      // Show dialog with extracted text
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Extracted Text'),
          content: Text(extractedText),
        ),
      );
    }
  }

  // Function to speak out the text using Text-to-Speech
  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My AI Assistant'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AI is running in the background...',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text(
                  _isListening ? 'Listening for commands...' : 'Tap to start listening',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                ),
              ],
            ),
          ),
          FloatingButton(
            onPressed: () {
              _showOptions(context);
            },
          ),
        ],
      ),
    );
  }

  // Function to display the options modal
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'AI Options',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: Text('Voice Recognition'),
                value: _isVoiceEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isVoiceEnabled = value;
                  });
                  if (_isVoiceEnabled) {
                    _startListening();
                  } else {
                    _stopListening();
                  }
                },
              ),
              SwitchListTile(
                title: Text('Open Camera'),
                value: _isCameraEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isCameraEnabled = value;
                    if (value) _openCamera();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
