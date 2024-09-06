import "package:flutter/material.dart";

class MultiSelect extends StatefulWidget {
  final List<String> employees;
  const MultiSelect({super.key, required this.employees});
  

  @override
  State<MultiSelect> createState() => _MultiSelectState();
}

final List<String> selectedEmployees = [];

class _MultiSelectState extends State<MultiSelect> {
  
  
  void _itemChange(String employeeValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedEmployees.add(employeeValue);
      } else {
        selectedEmployees.remove(employeeValue);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    Navigator.pop(context, selectedEmployees);
    print(selectedEmployees);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Employees"),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.employees
              .map((item) => CheckboxListTile(
                    value: selectedEmployees.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Submit"),
        )
      ],
    );
  }
}
