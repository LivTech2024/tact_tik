import 'dart:async';
import 'dart:isolate';

void countdownIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      final countdownDuration = message['countdownDuration'] as int;
      final callback = message['callback'] as SendPort;

      int remainingTime = countdownDuration;
      final timer = Timer.periodic(Duration(seconds: 1), (timer) {
        remainingTime--;
        callback.send(remainingTime);
        if (remainingTime == 0) {
          timer.cancel();
          Isolate.exit(sendPort);
        }
      });
    }
  });
}
