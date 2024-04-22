import 'package:flutter/material.dart';
import 'package:tact_tik/pdf%20generation/countdown_test.dart';

void main() {
  runApp(MyApps());
}

class MyApps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CountdownScreen(),
    );
  }
}

class CountdownScreen extends StatefulWidget {
  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late CountdownService countdownService;
  Duration? remainingTime;

  @override
  void initState() {
    super.initState();
    countdownService = CountdownService();
    countdownService.initializeService();
    countdownService.startCountdown(Duration(minutes: 1));
    // Listen for changes in remaining time
    countdownService.onRemainingTimeChanged.listen((duration) {
      setState(() {
        remainingTime = duration;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayTime = remainingTime != null
        ? '${remainingTime!.inMinutes.remainder(60).toString().padLeft(2, '0')}:${remainingTime!.inSeconds.remainder(60).toString().padLeft(2, '0')}'
        : '00:00'; // Format the remaining time as MM:SS, pad with zeros if necessary

    return Scaffold(
      appBar: AppBar(
        title: Text('Countdown Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remaining Time:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              displayTime,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Restart the countdown when the button is clicked
                countdownService.startCountdown(Duration(minutes: 5));
              },
              child: Text('Restart Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}
