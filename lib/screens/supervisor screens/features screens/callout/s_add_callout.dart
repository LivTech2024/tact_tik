import "dart:developer";

import "package:animated_custom_dropdown/custom_dropdown.dart";
import "package:bounce/bounce.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:dropdown_search/dropdown_search.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_searchable_dropdown/flutter_searchable_dropdown.dart";
import "package:flutter_svg/svg.dart";
import "package:flutter_tags_x/flutter_tags_x.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:hive/hive.dart";
import "package:intl/intl.dart";
import "package:multi_select_flutter/multi_select_flutter.dart";
import "package:searchfield/searchfield.dart";
import "package:tact_tik/common/widgets/button1.dart";
import "package:tact_tik/fonts/inter_bold.dart";
import "package:tact_tik/fonts/inter_medium.dart";
import "package:tact_tik/fonts/inter_regular.dart";
import "package:tact_tik/screens/home%20screens/widgets/home_screen_part1.dart";
import "package:tact_tik/test_screen.dart";

import "../../../../fonts/inter_light.dart";
import "../../../../utils/colors.dart";

class SAddCallout extends StatefulWidget {
  const SAddCallout({super.key});

  @override
  State<SAddCallout> createState() => _SAddCalloutState();
}

class _SAddCalloutState extends State<SAddCallout> {
  TextEditingController calloutTimeInput = TextEditingController();
  TextEditingController endTimeInput = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // Focus node for TextField
  bool _showSuggestions = false;
  List<String> _selectedEmployees = [];
  List<String> results = [];
  List<String> foundEmp = [];
  String? LocDropDownvalue; // Stores Drop Down Value
  List<String> locations = [
    'Select Location',
    'Floor 1',
    'Floor 2',
    'Floor 3',
    'Floor 4',
    'Floor 5'
  ]; // Location Names

  final List<String> employees = [
    'Vaibhav Sutar',
    'Debayan',
    'Yash Singh',
    'Tahmeed Zamindar',
    'Vishhal Narkar',
  ];

  Future<void> searchEmp(String query) async {
    if (query.isEmpty) {
      setState(() {
        foundEmp.clear();
      });
      return;
    }

    if (query.isEmpty) {
      results = employees;
    } else {
      results = employees
          .where((employee) =>
              employee.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // Query<Map<String, dynamic>> queryRef = FirebaseFirestore.instance
    //     .collection('Employees')
    //     .where('EmployeeCompanyId', isEqualTo: widget.CompanyId)
    //     .where('EmployeeNameSearchIndex', arrayContains: query);

    // if (selectedPosition!.isNotEmpty) {
    //   queryRef = queryRef.where('EmployeeRole', isEqualTo: selectedPosition);
    // }

    // final result = await queryRef.get();
    print(results);
    setState(() {
      foundEmp = results;
    });
  }

  //Assigned Employee Card
  _AssignedEmp(isDark, index, name) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.007.sh),
      child: Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: isDark ? DarkColor.AppBarcolor : LightColor.color9,
          ),
          child: Row(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 14,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? LightColor.color9
                            : DarkColor.AppBarcolor, // Border color
                        width: 1, // Border width
                      ),
                    ),
                    child: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/default.png'),
                    ),
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InterMedium(
                        text: name,
                        fontsize: 0.02.sh,
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  )
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 7),
                child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedEmployees.remove(name);
                          });
                        },
                        color: isDark ? Colors.white : Colors.black)),
              ),
            ],
          )),
    );
  }

  @override
  void initState() {
    calloutTimeInput.text = ""; //set the initial value of text field
    endTimeInput.text = "";
    _selectedEmployees = []; //set the initial value of text field
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // Width of the User's Device
    double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculating the Safe Area and Height of the User's Device
    var padding = MediaQuery.paddingOf(context);
    double screenHeight =
        MediaQuery.sizeOf(context).height - padding.top - padding.bottom;

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
                setState(() {
                  if (_selectedEmployees.isNotEmpty) {
                    _selectedEmployees = [];
                  }
                });
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_sharp)),
        ),
        // Parent Coloumn
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Safe Area Container
              Container(
                  padding: EdgeInsets.all(screenHeight * 0.035),
                  height: screenHeight - AppBar().preferredSize.height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Call Out Text
                      InterBold(
                        text: "Create callout",
                        fontsize: 16.sp,
                        color: isDark ? Colors.white : Colors.black,
                      ),

                      // Vertical Padding
                      SizedBox(
                        height: 20.h,
                      ),

                      //Select Location Card
                      Container(
                        width: double.maxFinite,
                        height: 64.sp,
                        decoration: BoxDecoration(
                          color: isDark
                              ? DarkColor.AppBarcolor
                              : LightColor.color9,
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

                            // Location DropDown
                            Expanded(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(right: screenWidth * 0.03),
                                child: DropdownButton<String>(
                                  elevation: 2,
                                  value: LocDropDownvalue,
                                  borderRadius: BorderRadius.circular(8),
                                  hint: InterLight(
                                    text: "Select Location",
                                    color: isDark
                                        ? LightColor.color9
                                        : DarkColor.AppBarcolor,
                                    fontsize: screenHeight * 0.022,
                                  ),
                                  underline: Container(),
                                  icon: const Icon(
                                      Icons.arrow_drop_down_outlined),
                                  style: TextStyle(
                                    color: isDark
                                        ? LightColor.color9
                                        : DarkColor.AppBarcolor,
                                    fontSize: screenHeight * 0.022,
                                  ),
                                  isExpanded: true,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      LocDropDownvalue = newValue;
                                    });
                                  },
                                  items: locations.map((String location) {
                                    return DropdownMenuItem<String>(
                                      value: location,
                                      child: Text(location),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      // Vertical Padding
                      SizedBox(
                        height: 30.h,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            // border: Border.all(color: Colors.white)
                            border: Border(
                                bottom: BorderSide(
                                  width: 1.2,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black))),
                        height: 64.h,
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              size: 24.sp,
                              color: const Color.fromARGB(255, 233, 233, 233),
                            ),
                            SizedBox(
                              width: 16.sp,
                            ),
                            Expanded(
                              child: TextField(
                                onTapOutside: (event) {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                },
                                controller: _searchController,
                                onChanged: (query) {
                                  searchEmp(query);
                                },
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.r),
                                    ),
                                  ),
                                  focusedBorder: InputBorder.none,
                                  hintStyle: GoogleFonts.inter(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 18.sp,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  hintText: 'Select Employee',
                                  contentPadding: EdgeInsets.zero,
                                ),
                                cursorColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: foundEmp.length,
                        itemBuilder: (context, index) {
                          final guard = foundEmp[index];
                          return ListTile(
                            title: InterLight(text: guard),
                            onTap: () {
                              setState(() {
                                // _searchController.text = guard;
                                _selectedEmployees.add(guard);
                                _searchController.clear();
                                foundEmp.clear();
                              });
                            },
                          );
                        },
                      ),

                      //Callout Time
                      Container(
                        width: double.maxFinite,
                        height: 64.sp,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: isDark
                                        ? LightColor.AppBarcolor
                                        : DarkColor.AppBarcolor))
                            // border: Border.all(color: Colors.white)
                            ),
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
                                        ? LightColor.AppBarcolor
                                        : DarkColor.AppBarcolor))),
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

                      // Vertical Padding
                      SizedBox(
                        height: 25.h,
                      ),

                      // Assigned Emp Txt
                      InterBold(
                        text: "Assigned Employee",
                        fontsize: 18.sp,
                        letterSpacing: screenWidth * 0.0005,
                      ),

                      // Vertical Padding
                      SizedBox(
                        height: 20.h,
                      ),

                      // Employee Card
                      Expanded(
                        child: ListView.builder(
                          itemCount: _selectedEmployees.length,
                          itemBuilder: (context, index) => _AssignedEmp(
                              isDark, index, _selectedEmployees[index]),
                        ),
                      ),

                      // Done Button
                      // Vertical Padding
                      SizedBox(height: screenHeight * 0.010),
                      SizedBox(
                          width: screenWidth,
                          height: 60.sp,
                          child: Bounce(
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
                                )),
                          )),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
