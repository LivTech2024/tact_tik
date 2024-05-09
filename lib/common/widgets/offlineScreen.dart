import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline'),
      ),
      body: Center(
        child: Text('You are offline'),
      ),
    );
  }
}
