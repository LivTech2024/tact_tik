import 'package:flutter/material.dart';
import 'package:flutter_filter_dialog/flutter_filter_dialog.dart';

class ReusableSmartSelect extends StatefulWidget {
  final String title;
  final String initialValue;
  final List<S2Choice<String>> options;
  final Function(String) onChange;

  ReusableSmartSelect({
    required this.title,
    required this.initialValue,
    required this.options,
    required this.onChange,
  });

  @override
  _ReusableSmartSelectState createState() => _ReusableSmartSelectState();
}

class _ReusableSmartSelectState extends State<ReusableSmartSelect> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SmartSelect<String>.single(
      title: widget.title,
      selectedValue: value,
      choiceItems: widget.options,
      onChange: (state) {
        if (state.value != null) {
          setState(() {
            value = state.value!;
          });
          widget.onChange(state.value!);
        }
      },
    );
  }
}
