import "package:flutter/material.dart";

class SAddCallout extends StatefulWidget {
  const SAddCallout({super.key});

  @override
  State<SAddCallout> createState() => _SAddCalloutState();
}

class _SAddCalloutState extends State<SAddCallout> {
  @override
  Widget build(BuildContext context) {
    // Width of the User's Device
    double screenWidth = MediaQuery.sizeOf(context).width;

    // Calculating the Safe Area and Height of the User's Device
    var padding = MediaQuery.paddingOf(context);
    double screenHeight =
        MediaQuery.sizeOf(context).height - padding.top - padding.bottom;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Call out"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_outlined)),
      ),
      body: Column(
        children: [
          Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(screenHeight * 0.035),
              child: Column(
                children: [
                  const Text("Create Callout"),
                  SizedBox(width: (screenHeight * 0.035)),
                  Container(
                    color: Colors.grey,
                    width: screenWidth,
                    child: Column(),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
