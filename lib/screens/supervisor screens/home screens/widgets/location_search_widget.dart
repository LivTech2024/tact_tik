import 'package:flutter/material.dart';

class LocationSearchWidget extends StatefulWidget {
  @override
  _LocationSearchWidgetState createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  TextEditingController _locationController = TextEditingController();
  List<String> locationSuggestions = ['Location 1', 'Location 2', 'Location 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Location:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Type to search location...',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Filter location suggestions based on user input
                List<String> filteredSuggestions = locationSuggestions
                    .where((location) =>
                        location.toLowerCase().contains(value.toLowerCase()))
                    .toList();
                // TODO: Show filteredSuggestions in dropdown
              },
            ),
            SizedBox(height: 16.0),
            // TODO: Show location suggestions dropdown
          ],
        ),
      ),
    );
  }
}
