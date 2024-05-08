import 'package:flutter/material.dart';

class IntInputWidget extends StatelessWidget {
  const IntInputWidget({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  final String hintText;
  final TextEditingController controller;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          final intValue = int.tryParse(value);
          onChanged(intValue);
        } else {
          onChanged(null);
        }
      },
    );
  }
}
