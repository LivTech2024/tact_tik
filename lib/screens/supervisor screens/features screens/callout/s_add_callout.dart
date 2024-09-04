import "package:flutter/material.dart";

class SAddCallout extends StatefulWidget {
  const SAddCallout({super.key});

  @override
  State<SAddCallout> createState() => _SAddCalloutState();
}

class _SAddCalloutState extends State<SAddCallout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("callout"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_outlined)),
      ),
    );
  }
}
