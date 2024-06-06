import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:tact_tik/utils/colors.dart';

class DatePickerDemo extends StatefulWidget {
  @override
  _DatePickerDemoState createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  List<DateTime> _selectedDates = [];
  // Color primaryColor = ; // Define primary color here


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Date Picker Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _showDatePicker(context);
              },
              child: Text('Select Dates'),
            ),
            SizedBox(height: 20),
            Text('Selected Dates:'),
            SizedBox(height: 10),
            Text(_selectedDates.join(', ')),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width - 120,
            height: 400,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Select Dates', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Expanded(
                  child: SfDateRangePicker(
                    selectionTextStyle: TextStyle(color:DarkColor. Primarycolor), // Use primary color here
                    selectionShape: DateRangePickerSelectionShape.circle,
                    selectionColor: DarkColor.Primarycolor, // Use primary color here
                    selectionRadius: 4,
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.multiple,
                    initialSelectedDates: _selectedDates,
                    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                      setState(() {
                        _selectedDates = args.value.cast<DateTime>();
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
