
import 'package:flutter/services.dart';

class BackgroundService {
  static const platform = MethodChannel('my_ai_assistant/background');

  // This function will start the background service
  Future<void> startBackgroundService() async {
    try {
      await platform.invokeMethod('startBackgroundService');
    } on PlatformException catch (e) {
      print("Failed to start background service: ${e.message}");
    }
  }

  // This function will stop the background service
  Future<void> stopBackgroundService() async {
    try {
      await platform.invokeMethod('stopBackgroundService');
    } on PlatformException catch (e) {
      print("Failed to stop background service: ${e.message}");
    }
  }
}
