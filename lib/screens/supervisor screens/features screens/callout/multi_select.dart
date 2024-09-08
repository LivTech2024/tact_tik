import "package:flutter/material.dart";
import "package:tact_tik/fonts/inter_light.dart";
import "package:tact_tik/fonts/inter_medium.dart";
import "package:tact_tik/utils/colors.dart";

class MultiSelect extends StatefulWidget {
  final List<String> employees;
  const MultiSelect({super.key, required this.employees});
  

  @override
  State<MultiSelect> createState() => _MultiSelectState();
}

List<String> selectedEmployees = [];

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      scrollable: true,
      title:InterMedium(text: "Select Employees", color: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,),
      content: SingleChildScrollView(
        
        child: ListBody(
          children: widget.employees
              .map((item) => CheckboxListTile(
                    activeColor: isDark? DarkColor.Primarycolor : LightColor.Primarycolor ,
                    value: selectedEmployees.contains(item),
                    title: InterLight(text: item,),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: InterMedium(text: 'Cancel', color: isDark? DarkColor.color2: LightColor.color4,),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: InterMedium(text: 'Submit',color: isDark? DarkColor.Primarycolor: LightColor.Primarycolor),
        )
      ],
    );
  }
}
