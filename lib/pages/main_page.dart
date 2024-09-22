import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/background_service.dart';
import '../widgets/floating_button.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
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
  final FlutterTts _flutterTts = FlutterTts();
  String _recognizedText = "";  // Holds recognized text

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
    _flutterTts.stop();
    super.dispose();
  }
// Function to process voice commands
  void _processCommand(String command) {
    command = command.toLowerCase();

    if (command.contains('open camera')) {
      setState(() => _isCameraEnabled = true);
      _openCamera();  // Open the camera when the user says "open camera"
    } else if (command.contains('voice recognition off')) {
      setState(() => _isVoiceEnabled = false);
      _stopListening();  // Turn off voice recognition when the user says "voice recognition off"
    } else if (command.contains('voice recognition on')) {
      setState(() => _isVoiceEnabled = true);
      _startListening();  // Turn on voice recognition when the user says "voice recognition on"
    } else if (command.contains('copy text')) {
      _captureImageAndExtractText();  // Extract text when the user says "copy text"
    } else {
      setState(() {
        _recognizedText = "Unknown command: $command";
      });
    }
  }
  // Method to start voice recognition
  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(onResult: (val) {
        setState(() {
          _command = val.recognizedWords;
          _recognizedText = val.recognizedWords;  // Update recognized text
          _processCommand(_command);
        });
      });
    }
  }

  // Method to stop voice recognition
  void _stopListening() {
    setState(() => _isListening = false);
    _speechToText.stop();
  }

  // Method to open the camera
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

  // Function to capture image and extract text using ML Kit
  void _captureImageAndExtractText() async {
    if (_cameraController != null) {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);
      final XFile picture = await _cameraController!.takePicture();
      final String filePath = picture.path;

      final image = InputImage.fromFilePath(filePath);

      // Initialize text recognizer
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(image);

      String extractedText = "";
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += line.text + '\n';
        }
      }

      textRecognizer.close();

      // Display the extracted text in the UI or process it
      setState(() {
        _recognizedText = extractedText;
      });

      // Optionally, use TTS to read the extracted text
      _speak(_recognizedText);
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
          Column(
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
              SizedBox(height: 20),
              // Add the recognized text section
              Text(
                _recognizedText.isNotEmpty ? _recognizedText : 'No speech detected yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ],
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
