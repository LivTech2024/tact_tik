import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tact_tik/pdf%20generation/countdown_service.dart';

void main() {
  runApp(CountdownScreen());
}

class CountdownScreen extends StatefulWidget {
  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _remainingTime = 0;

  @override
  void initState() {
    super.initState();
    const MethodChannel channel =
        MethodChannel('com.avocadotech.tacttik.tact_tik/countdown_service');
    channel.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    if (call.method == 'countdown_update') {
      setState(() {
        _remainingTime = call.arguments['remainingTime'];
      });
    }
  }

  String get _formattedRemainingTime {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Countdown'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Remaining Time: $_formattedRemainingTime',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  CountdownService.startCountdown();
                },
                child: Text('Start Countdown'),
              ),
              ElevatedButton(
                onPressed: () {
                  CountdownService.stopCountdown();
                },
                child: Text('Stop Countdown'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
