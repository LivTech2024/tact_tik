import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownService {
  static final CountdownService _instance = CountdownService._internal();
  factory CountdownService() => _instance;
  CountdownService._internal();

  late SharedPreferences _prefs;
  Timer? _countdownTimer;
  DateTime? _countdownStartTime;
  Duration _countdownDuration = Duration.zero;

  final StreamController<Duration> _remainingTimeController =
      StreamController<Duration>.broadcast();

  Stream<Duration> get onRemainingTimeChanged =>
      _remainingTimeController.stream;

  Future<void> initializeService() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCountdownState();
    _initializeCountdownTimer();
  }

  void _loadCountdownState() {
    final startTimeMillis = _prefs.getInt('countdownStartTime') ?? 0;
    final durationMillis = _prefs.getInt('countdownDuration') ?? 0;

    if (startTimeMillis != 0 && durationMillis != 0) {
      _countdownStartTime =
          DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
      _countdownDuration = Duration(milliseconds: durationMillis);
      _initializeCountdownTimer();
    }
  }

  void _initializeCountdownTimer() {
    if (_countdownDuration.inMilliseconds > 0) {
      final remainingDuration = _countdownDuration -
          (DateTime.now().difference(_countdownStartTime!));

      _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (remainingDuration.inSeconds == 0) {
          _countdownTimer?.cancel();
          _scheduleNotification();
        } else {
          _remainingTimeController
              .add(remainingDuration); // Emit remaining time
        }
      });
    }
  }

  void startCountdown(Duration duration) {
    _countdownDuration = duration;
    _countdownStartTime = DateTime.now();
    _storeCountdownState();
    _initializeCountdownTimer();
  }

  void _storeCountdownState() {
    _prefs.setInt(
        'countdownStartTime', _countdownStartTime!.millisecondsSinceEpoch);
    _prefs.setInt('countdownDuration', _countdownDuration.inMilliseconds);
  }

  void _scheduleNotification() {
    // Use the flutter_local_notifications package to schedule a notification
  }

  void dispose() {
    _remainingTimeController.close();
  }
}
