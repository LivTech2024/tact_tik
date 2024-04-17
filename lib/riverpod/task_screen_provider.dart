import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskScreenState extends StateNotifier<TaskScreenStateModel> {
  TaskScreenState() : super(TaskScreenStateModel());

  void setClickedIn(bool value) {
    state = state.copyWith(clickedIn: value);
  }

  void setStopwatchSeconds(int value) {
    state = state.copyWith(stopwatchSeconds: value);
  }

  void setIsPaused(bool value) {
    state = state.copyWith(isPaused: value);
  }

  void setStopwatchTime(String value) {
    state = state.copyWith(stopwatchTime: value);
  }
}

class TaskScreenStateModel {
  TaskScreenStateModel({
    this.clickedIn = false,
    this.stopwatchSeconds = 0,
    this.isPaused = false,
    this.stopwatchTime = '',
  });

  final bool clickedIn;
  final int stopwatchSeconds;
  final bool isPaused;
  final String stopwatchTime;

  TaskScreenStateModel copyWith({
    bool? clickedIn,
    int? stopwatchSeconds,
    bool? isPaused,
    String? stopwatchTime,
  }) {
    return TaskScreenStateModel(
      clickedIn: clickedIn ?? this.clickedIn,
      stopwatchSeconds: stopwatchSeconds ?? this.stopwatchSeconds,
      isPaused: isPaused ?? this.isPaused,
      stopwatchTime: stopwatchTime ?? this.stopwatchTime,
    );
  }
}
