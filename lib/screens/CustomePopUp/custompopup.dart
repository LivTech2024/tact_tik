import 'package:flutter/material.dart';

class CustomPopup extends StatelessWidget {
  final String message;
  const CustomPopup({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Popup Alert'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
