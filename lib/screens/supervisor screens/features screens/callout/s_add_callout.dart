import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/svg.dart";
import "package:flutter_tags_x/flutter_tags_x.dart";
import "package:get/get.dart";
import "package:hive/hive.dart";
import "package:intl/intl.dart";
import "package:tact_tik/fonts/inter_bold.dart";
import "package:tact_tik/fonts/inter_medium.dart";
import "package:tact_tik/screens/supervisor%20screens/features%20screens/callout/multi_select.dart";

import "../../../../fonts/inter_light.dart";
import "../../../../utils/colors.dart";

class SAddCallout extends StatefulWidget {
  const SAddCallout({super.key});

  @override
  State<SAddCallout> createState() => _SAddCalloutState();
}

//Assigned Employee Card
_AssignedEmp(isDark) {
  return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
      ),
      child: Row(
        children: [
          const Row(
            children: [
              SizedBox(
                width: 14,
              ),
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/default.png'),
              ),
              SizedBox(
                width: 14,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [InterBold(text: "Tahmeed")],
              ),
              SizedBox(
                width: 20,
              )
            ],
          ),
          Spacer(),
          Align(alignment: Alignment.topRight, child: Icon(Icons.close, color: isDark? Colors.white: Colors.black)),
        ],
      ));
}

class _SAddCalloutState extends State<SAddCallout> {
  TextEditingController calloutTimeInput = TextEditingController();
  TextEditingController endTimeInput = TextEditingController();

  @override
  void initState() {
    calloutTimeInput.text = ""; //set the initial value of text field
    endTimeInput.text = ""; //set the initial value of text field
    super.initState();
  }

  List<String> _selectedEmployees = [];

  void _showMultiSelect() async {
    final List<String> employees = [
      'Vaibhav Sutar',
      'Debayan',
      'Yash Singh',
      'Tahmeed Zamindar',
      'Vishhal Narkar',
    ];

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(employees: employees);
      },
    );

    if (results != null) {
      setState(() {
        _selectedEmployees = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Width of the User's Device
    double screenWidth = MediaQuery.sizeOf(context).width;
    String dropDownvalue = "Select Location";
    final List<String> dropDownItems = [
      "123, ABC Apartment",
      "456, DEF Apartment",
      "789, GHI Apartment",
    ];

    // Calculating the Safe Area and Height of the User's Device
    var padding = MediaQuery.paddingOf(context);
    double screenHeight =
        MediaQuery.sizeOf(context).height - padding.top - padding.bottom;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
          centerTitle: true,
          title: InterBold(
            text: "Call out",
            fontsize: 16.sp,
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_sharp)),
        ),
        // Parent Coloumn
        body: Column(
          children: [
            //Full Container
            Container(
                padding: EdgeInsets.all(screenHeight * 0.035),
                height: screenHeight - AppBar().preferredSize.height,
                // decoration: BoxDecoration(
                //     border: Border.all(color: Colors.blueAccent)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterBold(
                      text: "Create callout",
                      fontsize: 16.sp,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    SizedBox(width: (screenHeight * 0.035)),
                    SizedBox(
                      height: 20.h,
                    ),

                    //Select Location Card
                    Container(
                      width: double.maxFinite,
                      height: 64.sp,
                      decoration: BoxDecoration(
                        color:
                            isDark ? DarkColor.AppBarcolor : LightColor.color9,
                        borderRadius: BorderRadius.all(Radius.circular(13)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Location Icon Container
                          Container(
                            margin: EdgeInsets.all(screenWidth * 0.03),
                            width: screenWidth * 0.11,
                            height: screenWidth * 0.11,
                            decoration: BoxDecoration(
                                color: isDark
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9))),
                            child: SvgPicture.asset(
                              'assets/images/locationIcon.svg',
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          DropdownButton(
                            value: dropDownvalue,
                            icon: const Icon(Icons.menu),
                            style: const TextStyle(color: Colors.white),
                            underline: Container(
                              height: 0,
                              color: Colors.transparent,
                            ),
                            onChanged: (String? newValue){
                              setState(() {
                                dropDownvalue = newValue!;
                              });
                            },
                            items: const [
                              DropdownMenuItem<String>(
                                value: "Select Location",
                                child: Text("Select Location"),
                              ),
                              DropdownMenuItem<String>(
                                value: "One",
                                child: Text("One"),
                              ),
                              DropdownMenuItem<String>(
                                value: "Two",
                                child: Text("Two"),
                              ),
                              DropdownMenuItem<String>(
                                value: "Three",
                                child: Text("Three"),
                              ),
                            ],
                          ),

                          // Select Location Text

                          // const InterLight(
                          //   text: "Select Location",
                          //   letterSpacing: 0.5,
                          // )
                        ],
                      ),
                    ),
                    // Vertical Padding
                    SizedBox(
                      height: 30.h,
                    ),

                    //Select Employee
                    GestureDetector(
                      onTap: () {
                        _showMultiSelect();
                      },
                      // Container And Border
                      child: Container(
                        width: double.maxFinite,
                        height: 64.sp,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: isDark
                                        ? DarkColor.AppBarcolor
                                        : LightColor.AppBarcolor))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              // If Margin Required Replace Widget with Container
                              // margin: EdgeInsets.all(screenWidth * 0.03),
                              width: screenWidth * 0.11,
                              height: screenWidth * 0.11,
                              child: Icon(
                                Icons.account_circle_outlined,
                                color: isDark ? Colors.white : Colors.black,
                                // size: 30.h,
                              ),
                            ),
                            const InterMedium(
                              text: "Select Employee",
                              fontsize: 16,
                            )
                          ],
                        ),
                      ),
                    ),

                    //Callout Time
                    //TODO: Time not displaying after selection
                    Container(
                      width: double.maxFinite,
                      height: 64.sp,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: isDark
                                      ? DarkColor.AppBarcolor
                                      : LightColor.AppBarcolor))),
                      child: Center(
                        child: TextField(
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                          controller:
                              calloutTimeInput, //editing controller of this TextField
                          decoration: InputDecoration(
                              icon: Icon(
                                Icons.access_time,
                                size: 24.sp,
                                color: isDark ? Colors.white : Colors.black,
                              ), //icon of text field

                              labelText: "Callout Time",
                              labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black), //label text of field
                              enabledBorder: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent)),
                              focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent))),
                          readOnly:
                              true, //set it true, so that user will not able to edit text
                          onTap: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              initialTime: TimeOfDay.now(),
                              context: context,
                            );

                            if (pickedTime != null) {
                              String formattedPickTime =
                                  pickedTime.format(context).toString();
                              print(formattedPickTime);
                              setState(() {
                                calloutTimeInput.text =
                                    formattedPickTime; //set the value of text field.
                              });
                            } else {
                              print("Time is not selected");
                              setState(() {
                                endTimeInput.text =
                                    ""; //set the value of text field.
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    //End Time
                    Container(
                      width: double.maxFinite,
                      height: 64.sp,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: isDark
                                      ? DarkColor.AppBarcolor
                                      : LightColor.AppBarcolor))),
                      child: TextField(
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        controller:
                            endTimeInput, //editing controller of this TextField
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.access_time,
                              size: 24.sp,
                              color: isDark ? Colors.white : Colors.black,
                            ), //icon of text field

                            labelText: "End Time",
                            labelStyle: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black), //label text of field
                            enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent))),
                        readOnly:
                            true, //set it true, so that user will not able to edit text
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            initialTime: TimeOfDay.now(),
                            context: context,
                          );

                          if (pickedTime != null) {
                            String formattedPickTime =
                                pickedTime.format(context).toString();
                            print(formattedPickTime);
                            setState(() {
                              endTimeInput.text =
                                  formattedPickTime; //set the value of text field.
                            });
                          } else {
                            print("Time is not selected");
                            setState(() {
                              endTimeInput.text =
                                  ""; //set the value of text field.
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    InterBold(
                      text: "Assigned Employee",
                      fontsize: 18.sp,
                      letterSpacing: 0.5,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    _AssignedEmp(isDark),

                    Wrap(
                      children: _selectedEmployees
                          .map((e) => Chip(
                                label: Text(e),
                              ))
                          .toList(),
                    ),

                    const Spacer(),
                    SizedBox(
                        width: screenWidth,
                        height: 60.sp,
                        child: ElevatedButton(
                            onPressed: () {
                              print("Pressed On Done Button");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? DarkColor.Primarycolor
                                  : LightColor.Primarycolor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            child: InterMedium(
                              text: "Done",
                              color: isDark ? Colors.black : Colors.white,
                              fontsize: 18.sp,
                              letterSpacing: 0.5,
                            ))),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
