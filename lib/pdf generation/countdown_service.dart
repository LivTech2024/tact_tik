import 'package:flutter/services.dart';

class CountdownService {
  static const MethodChannel _channel =
      MethodChannel('com.example/countdown_service');

  static Future<void> startCountdown() async {
    try {
      await _channel.invokeMethod('startCountdown');
    } on PlatformException catch (e) {
      print("Failed to start countdown service: '${e.message}'.");
    }
  }

  static Future<void> stopCountdown() async {
    try {
      await _channel.invokeMethod('stopCountdown');
    } on PlatformException catch (e) {
      print("Failed to stop countdown service: '${e.message}'.");
    }
  }
}
