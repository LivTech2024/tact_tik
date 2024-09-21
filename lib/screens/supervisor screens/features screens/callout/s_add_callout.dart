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
import "package:omni_datetime_picker/omni_datetime_picker.dart";
import "package:searchfield/searchfield.dart";
import "package:tact_tik/common/widgets/button1.dart";
import "package:tact_tik/fonts/inter_bold.dart";
import "package:tact_tik/fonts/inter_medium.dart";
import "package:tact_tik/fonts/inter_regular.dart";
import "package:tact_tik/screens/home%20screens/calendar%20screen/utills/extensions.dart";
import "package:tact_tik/screens/home%20screens/widgets/home_screen_part1.dart";
import "package:tact_tik/screens/supervisor%20screens/home%20screens/widgets/set_details_widget.dart";
import "package:tact_tik/services/firebaseFunctions/firebase_function.dart";
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
  List _selectedEmployees = []; //Stores Selected employees
  List selectedEmployeeIds = [];
  List<String> results = [];
  List<Map<String, dynamic>> foundEmp = [];

  //Stores Selected Location
  String? LocDropDownvalue;
  String? CompanyId;

  List<String> dbLocation = [];
  String selectedLocation = '';
  String? selectedEmployeeID = '';
  String? selectedEmployeeName = '';
  List selectedEmployeeNames = [];

  late final Timestamp endTimeTimeStamp;
  Timestamp? calloutDateTimestamp; //Store Callout Time
  DateTime? dateTime;

  late GeoPoint calloutLocation;
  late String calloutLocationId;
  late String calloutLocationName;
  late String calloutLocationAddress;

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
      if (mounted) {
        setState(() {
          foundEmp.clear();
        });
      }
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

    Query<Map<String, dynamic>> queryRef = FirebaseFirestore.instance
        .collection('Employees')
        .where('EmployeeNameSearchIndex', arrayContains: query);

    // if (selectedPosition!.isNotEmpty) {
    //   queryRef = queryRef.where('EmployeeRole', isEqualTo: selectedPosition);
    // }

    try {
      final result = await queryRef.get();
      if (mounted) {
        setState(() {
          foundEmp = result.docs.map((doc) => doc.data()).toList();
        });
      }
      print(foundEmp); // Check if results are fetched
    } catch (e) {
      print('Error searching employees: $e');
    }
  }

  Future<List<String>> getAllLocation() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Locations').get();

      final List<String> location = snapshot.docs
          .map((doc) => doc.data()['LocationName'] as String)
          .toSet()
          .toList();

      if (mounted) {
        setState(() {
          dbLocation = location;
        });
      }
      return dbLocation;
    } catch (e) {
      print("Error fetching report titles: $e");
      return []; // Return empty list in case of error
    }
  }

  Future<QuerySnapshot<Object?>> getLocationDetail() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Locations')
          .where('LocationName', isEqualTo: LocDropDownvalue)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Loop through the documents and extract LocationName and LocationId
        for (var doc in querySnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          calloutLocationName = data['LocationName'];
          calloutLocationId = data['LocationId'];
          calloutLocation = data['LocationCoordinates'];
          calloutLocationAddress = data['LocationAddress'];

          print(
              "$calloutLocationName, $calloutLocationId, $calloutLocation, $calloutLocationAddress ");
        }

        return querySnapshot;
      } else {
        throw Exception('No document found with the specified location name.');
      }
    } catch (e) {
      print('Error getting location: $e');
      rethrow; // Rethrow the exception to handle it outside this function
    }
  }

  Future<void> addCallout() async {
    try {
      FireStoreService fireStoreService = FireStoreService();
      var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
      if (mounted) {
        if (userInfo != null) {
          CompanyId = userInfo['EmployeeCompanyId'];
        }
      }

      // Generate a new document reference with a unique ID
      DocumentReference calloutRef =
          FirebaseFirestore.instance.collection('Callouts').doc();
      String calloutId = calloutRef.id;

      // Convert the selectedEmployeeIds list to a map {0: id0, 1: id1, ...}
      // Map<String, String> assignedEmpsMap = {
      //   for (int i = 0; i < selectedEmployeeIds.length; i++)
      //     '$i': selectedEmployeeIds[i]
      // };

      List assignedEmpsList = selectedEmployeeIds;

      // Create the CalloutStatus array of maps, repeating for each employee
      List<Map<String, dynamic>> calloutStatusList = [
        for (int i = 0; i < selectedEmployeeIds.length; i++)
          {
            'Status': 'Pending',
            'StatusEmpId': selectedEmployeeIds[i],
            'StatusEmpName': selectedEmployeeNames[i],
          }
      ];

      if (_selectedEmployees != null &&
          _selectedEmployees.isNotEmpty &&
          LocDropDownvalue != null &&
          calloutDateTimestamp != null) {
        showDialog(
            context: context,
            builder: (context) {
              return Center(child: CircularProgressIndicator());
            });
        await calloutRef.set({
          'CalloutId': calloutId, // Store the same calloutId
          'CalloutLocation': calloutLocation,
          'CalloutLocationId': calloutLocationId,
          'CalloutLocationName': calloutLocationName,
          'CalloutLocationAddress': calloutLocationAddress,
          'CalloutDateTime': calloutDateTimestamp,
          'CalloutAssignedEmpsId': assignedEmpsList,
          'CalloutStatus': calloutStatusList,
          'CalloutCreatedAt': DateTime.now(),
          'CalloutModifiedAt': DateTime.now(),
          'CalloutStartTime': calloutDateTimestamp, //Added Now
          'CalloutCompanyId': CompanyId,
        });

        print('Callout added successfully with ID: $calloutId');
        Navigator.of(context).pop();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Callout Created',
          ),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Please ensure all fields are filled.',
          ),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Handle the error by printing it or taking other actions
      print('Error adding callout: $e');
    }
  }

  showDatePicker() async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    dateTime = await showOmniDateTimePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
        lastDate: DateTime.now().add(
          const Duration(days: 3652),
        ),
        is24HourMode: false,
        isShowSeconds: false,
        minutesInterval: 1,
        secondsInterval: 1,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        constraints: const BoxConstraints(
          maxWidth: 350,
          maxHeight: 650,
        ),
        transitionBuilder: (context, anim1, anim2, child) {
          return FadeTransition(
            opacity: anim1.drive(
              Tween(
                begin: 0,
                end: 1,
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        selectableDayPredicate: (dateTime) {
          // Disable 25th Feb 2023
          if (dateTime == DateTime(2023, 2, 25)) {
            return false;
          } else {
            return true;
          }
        },
        theme: ThemeData(
            colorScheme: ColorScheme(
          brightness: isDark ? Brightness.dark : Brightness.light,
          primary: isDark
              ? DarkColor.Primarycolor
              : LightColor.Primarycolor, //Selection and Button
          onPrimary: isDark
              ? Colors.black
              : Colors.white, //Text Color of Selected date
          secondary: Color.fromARGB(0, 255, 255, 255),
          onSecondary: Color.fromARGB(0, 255, 255, 255),
          error: Colors.red,
          onError: Colors.redAccent,
          surface: isDark
              ? DarkColor.AppBarcolor
              : LightColor.AppBarcolor, //Card Background
          onSurface:
              isDark ? Colors.white : Colors.black, //Text color of all date
        ) //Text colors
            ));
  }

  //Assigned Employee Card
  _AssignedEmp(isDark, index, name, employeeId) {
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
                        text: name.toString(),
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
                          if (mounted) {
                            setState(() {
                              _selectedEmployees.remove(name);
                              selectedEmployeeIds.remove(employeeId);
                              // _selectedEmployeesDetails.remove(name);
                              // _selectedEmployeesDetails.remove(employeeId);
                            });
                          }
                          print(selectedEmployeeIds);
                          // print(_selectedEmployeesDetails);
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
    // _selectedEmployeesDetails = [];
    selectedEmployeeIds = [];
    getAllLocation();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
        }
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
                if (mounted) {
                  setState(() {
                    if (_selectedEmployees.isNotEmpty) {
                      _selectedEmployees = [];
                    }
                  });
                }
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

                            //Location DropDown
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
                                  items: dbLocation.map((selectedLocation) {
                                    return DropdownMenuItem<String>(
                                      value: selectedLocation,
                                      child: Text(selectedLocation),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (mounted) {
                                      setState(() {
                                        LocDropDownvalue = newValue;
                                        getLocationDetail();
                                      });
                                    }
                                  },
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
                      //Select Employee
                      Container(
                        decoration: BoxDecoration(
                            // border: Border.all(color: Colors.white)
                            border: Border(
                                bottom: BorderSide(
                                    width: 1.2,
                                    color:
                                        isDark ? Colors.white : Colors.black))),
                        height: 64.h,
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              size: 24.sp,
                              color: isDark ? Colors.white : Colors.black,
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
                                    fontWeight: FontWeight.w400,
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
                          final Emp = foundEmp[index];
                          return ListTile(
                            title: InterLight(text: Emp['EmployeeName']),
                            onTap: () {
                              if (mounted) {
                                setState(
                                  () {
                                    // _searchController.text = guard;
                                    _selectedEmployees.add(Emp['EmployeeName']);
                                    selectedEmployeeID = Emp['EmployeeId'];
                                    selectedEmployeeName = Emp['EmployeeName'];
                                    print(_selectedEmployees);

                                    // _selectedEmployeesDetails.add({
                                    //   'CalloutAssignedEmpsId': selectedEmployeeID,
                                    //   'SelectedEmployeeName': selectedEmployeeName,
                                    // });
                                    selectedEmployeeNames
                                        .add(selectedEmployeeName);
                                    selectedEmployeeIds.add(selectedEmployeeID);
                                    print(
                                        "Selected Emp IDs: $selectedEmployeeIds");
                                    // print(
                                    //     "Selected Emp $_selectedEmployeesDetails");

                                    _searchController.clear();
                                    foundEmp.clear();
                                  },
                                );
                              }
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
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18.sp,
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
                              await showDatePicker();
                              // print(dateTime);
                              if (dateTime != null) {
                                calloutDateTimestamp =
                                    Timestamp.fromDate(dateTime!);
                                // Convert DateTime to Timestamp (Firestore)
                                String formattedDateTime =
                                    "${dateTime!.year}-${dateTime!.month.toString().padLeft(2, '0')}-${dateTime!.day.toString().padLeft(2, '0')} - "
                                    "${dateTime!.hour.toString().padLeft(2, '0')}:${dateTime!.minute.toString().padLeft(2, '0')}";

                                if (mounted) {
                                  setState(() {
                                    calloutTimeInput.text = formattedDateTime;
                                  });
                                }

                                print("Picked DateTime: $formattedDateTime");

                                // Print to see the result
                                print("Picked Time: $dateTime");
                              }
                            },
                          ),
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
                              isDark,
                              index,
                              _selectedEmployees[index],
                              selectedEmployeeID),
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
                                  addCallout();
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
