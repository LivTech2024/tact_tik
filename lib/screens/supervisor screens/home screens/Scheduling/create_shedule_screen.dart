import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../widgets/set_details_widget.dart';
import 'select_guards_screen.dart';

class MultiDateSelectionDialog extends StatefulWidget {
  @override
  _MultiDateSelectionDialogState createState() =>
      _MultiDateSelectionDialogState();
}

class _MultiDateSelectionDialogState extends State<MultiDateSelectionDialog> {
  List<DateTime> selectedDates = [];

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: InterMedium(
        text: 'Select Dates',
        color: color2,
        fontsize: width / width20,
      ),
      content: Container(
        width: double.minPositive,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display selected dates
              if (selectedDates.isNotEmpty)
                Column(
                  children: selectedDates
                      .map((date) => ListTile(
                            title: Text(date.toString()),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  selectedDates.remove(date);
                                });
                              },
                            ),
                          ))
                      .toList(),
                ),
              // Date picker for selecting new dates
              ElevatedButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: InterMedium(
                  text: 'Select Date',
                  color: Primarycolor,
                  fontsize: width / width16,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(selectedDates);
          },
          child: InterMedium(
            text: 'OK',
            color: Primarycolor,
            fontsize: width / width18,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(3000),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Primarycolor, // Change primary color to red
            ),
          ),
          child: child!,
        );
      },
    );
    if (datePicked != null) {
      setState(() {
        selectedDates.add(datePicked);
      });
    }
  }
}

class CreateSheduleScreen extends StatefulWidget {
  final String GuardId;
  final String GuardName;
  final String GuardImg;
  final String CompanyId;

  CreateSheduleScreen(
      {super.key,
      required this.GuardId,
      required this.GuardName,
      required this.GuardImg,
      required this.CompanyId});

  @override
  State<CreateSheduleScreen> createState() => _CreateSheduleScreenState();
}

class _CreateSheduleScreenState extends State<CreateSheduleScreen> {
  List colors = [Primarycolor, color25];
  List selectedGuards = [];
  String compId = "";

  @override
  void initState() {
    super.initState();
    // Add the initial guard data to selectedGuards if not already present
    if (!selectedGuards.any((guard) => guard['GuardId'] == widget.GuardId)) {
      setState(() {
        selectedGuards.add({
          'GuardId': widget.GuardId,
          'GuardName': widget.GuardName,
          'GuardImg': widget.GuardImg
        });
        compId = widget.CompanyId;
      });
    }
  }

  TextEditingController _clientcontrller = TextEditingController();

  DateTime? selectedDate;
  List<TimeOfDay>? selectedTime;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TextEditingController _locationController = TextEditingController();
  TextEditingController _ShiftPosition = TextEditingController();
  TextEditingController _ShiftName = TextEditingController();
  TextEditingController _RequirednoofEmployees = TextEditingController();
  TextEditingController _RestrictedRadius = TextEditingController();
  TextEditingController _Description = TextEditingController();
  TextEditingController _PhotoUploadIntervalInMinutes = TextEditingController();
  TextEditingController _Branch = TextEditingController();
  bool _isRestrictedChecked = false;
  List<DateTime> selectedDates = []; // Define and initialize selectedDates list

  List<Map<String, dynamic>> tasks = [];
  List<String> locationSuggestions = ['Location 1', 'Location 2', 'Location 3'];

  void _selectDate(BuildContext context) async {
    final List<DateTime>? selectedDates = await showDialog<List<DateTime>>(
      context: context,
      builder: (context) => MultiDateSelectionDialog(),
    );

    if (selectedDates != null) {
      print('Selected Dates: $selectedDates');
    }
  }

/*
  void _selectDate(BuildContext context) async {
    List<DateTime> selectedDates = [];

    final List<DateTime>? pickedDates = await showCalendarDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(3000),
      selectableDayPredicate: (DateTime date) {
        // Customize the predicate to allow or disallow specific dates to be selectable
        return true; // Allow all dates to be selectable
      },
      initialSelectionMode: SelectionMode.multi,
      headerTextStyle: TextStyle(color: Colors.white),
      selectedDecoration: BoxDecoration(
        color: Color(0xFF704600),
        shape: BoxShape.circle,
      ),
      todayDecoration: BoxDecoration(
        color: Color(0xFFCBA76B),
        shape: BoxShape.circle,
      ),
    );

    if (pickedDates != null) {
      // User selected one or more dates
      setState(() {
        selectedDates.addAll(pickedDates);
      });
    }

    print('Selected Dates: $selectedDates');
  }
*/

  Future<TimeOfDay?> showCustomTimePicker(BuildContext context) async {
    TimeOfDay? selectedTime;

    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Primarycolor, // Change primary color to red
              secondary: Primarycolor,
            ),
          ),
          child: child!,
        );
      },
    );

    return selectedTime;
  }

  void _selectTime(BuildContext context, bool isStartTime) async {
    final selectedTime = await showCustomTimePicker(context);
    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          startTime = selectedTime;
        } else {
          endTime = selectedTime;
        }
      });
      print('Start Time: $startTime');
      print('End Time: $endTime');
    }
  }

  placesAutoCompleteTextField(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: _locationController,
        googleAPIKey: "AIzaSyDd_MBd7IV8MRQKpyrhW9O1BGLlp-mlOSc",
        inputDecoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(
              Radius.circular(width / width10),
            ),
          ),
          focusedBorder: InputBorder.none,
          hintStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w300,
            fontSize: width / width18,
            color: color2, // Change text color to white
          ),
          hintText: 'Search your location',
          contentPadding: EdgeInsets.zero, // Remove padding
        ),
        debounceTime: 400,
        countries: ["in", "fr"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          print("placeDetails" + prediction.lat.toString());
        },

        itemClick: (Prediction prediction) {
          _locationController.text = prediction.description ?? "";
          _locationController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: Divider(),
        containerHorizontalPadding: 10,

        // OPTIONAL// If you want to customize list view item builder
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(
                  width: 7,
                ),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },

        isCrossBtnShown: true,

        // default 600 ms ,
      ),
    );
  }

  bool nextScreen = true;

  void _addNewTask() {
    setState(() {
      tasks.add({'name': '', 'isChecked': false});
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: width / width24,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Create Schedule',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        backgroundColor: Secondarycolor,
        body: SingleChildScrollView(
          // physics: PageScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: height / height65,
                width: double.maxFinite,
                color: color24,
                padding: EdgeInsets.symmetric(vertical: height / height16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Shift',
                              color: colors[0],
                              fontsize: width / width18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Primarycolor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Patrol',
                              color: colors[1],
                              fontsize: width / width18,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: height / height30),
              nextScreen
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InterBold(
                                text: 'Select Guards',
                                fontsize: width / width16,
                                color: color1,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SelectGuardsScreen(
                                                companyId: widget.CompanyId,
                                              ))).then((value) => {
                                        if (value != null)
                                          {
                                            print("Value: ${value}"),
                                            setState(() {
                                              selectedGuards.add({
                                                'GuardId': value['id'],
                                                'GuardName': value['name'],
                                                'GuardImg': value['url']
                                              });
                                            }),
                                          }
                                      });
                                },
                                child: InterBold(
                                  text: 'view all',
                                  fontsize: width / width14,
                                  color: color1,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: height / height24),
                          Container(
                            height: height / height64,
                            padding: EdgeInsets.symmetric(
                                horizontal: width / width10),
                            decoration: BoxDecoration(
                              color: WidgetColor,
                              borderRadius:
                                  BorderRadius.circular(width / width13),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextField(
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      fontSize: width / width18,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(width / width10),
                                        ),
                                      ),
                                      focusedBorder: InputBorder.none,
                                      hintStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: width / width18,
                                        color:
                                            color2, // Change text color to white
                                      ),
                                      hintText: 'Search Guard',
                                      contentPadding:
                                          EdgeInsets.zero, // Remove padding
                                    ),
                                    cursorColor: Primarycolor,
                                  ),
                                ),
                                Container(
                                  height: height / height44,
                                  width: width / width44,
                                  decoration: BoxDecoration(
                                    color: Primarycolor,
                                    borderRadius:
                                        BorderRadius.circular(width / width10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.search,
                                      size: width / width20,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: height / height20),
                            height: height / height80,
                            width: double.maxFinite,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: selectedGuards.length,
                              itemBuilder: (context, index) {
                                String guardId =
                                    selectedGuards[index]['GuardId'];
                                String guardName =
                                    selectedGuards[index]['GuardName'];
                                String guardImg =
                                    selectedGuards[index]['GuardImg'];
                                return Padding(
                                  padding:
                                      EdgeInsets.only(right: height / height20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: height / height50,
                                            width: width / width50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: NetworkImage(guardImg),
                                                  fit: BoxFit.fitWidth),
                                            ),
                                          ),
                                          Positioned(
                                            top: -4,
                                            right: -5,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedGuards
                                                      .removeAt(index);
                                                });
                                              },
                                              child: Container(
                                                height: height / height20,
                                                width: width / width20,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: color1),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 8,
                                                    color: Secondarycolor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: height / height8),
                                      InterBold(
                                        text: guardName,
                                        fontsize: width / width14,
                                        color: color26,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: height / height30,
                          ),
                          InterBold(
                            text: 'Set Details',
                            fontsize: width / width16,
                            color: color1,
                          ),
                          SizedBox(height: height / height10),
                          SetDetailsWidget(
                            useTextField: true,
                            hintText: 'Shift Position',
                            icon: Icons.control_camera,
                            controller: _ShiftPosition,
                            onTap: () {},
                          ),
                          SetDetailsWidget(
                            useTextField: true,
                            hintText: 'Shift Name',
                            icon: Icons.map_outlined,
                            controller: _ShiftName,
                            onTap: () {},
                          ),

                          // Multiple Date To Do
                          SetDetailsWidget(
                            hintText: selectedDate == null
                                ? 'Date'
                                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                            icon: Icons.date_range,
                            onTap: () => _selectDate(context),
                          ),
                          // Seperate Time
                          SetDetailsWidget(
                            hintText: selectedTime == null
                                ? 'Start Time'
                                : '${selectedTime![0].hour}:${selectedTime![0].minute} To ${selectedTime![1].hour}:${selectedTime![1].minute}',
                            icon: Icons.access_time_rounded,
                            onTap: () => _selectTime(context, true),
                          ),
                          SetDetailsWidget(
                            hintText: selectedTime == null
                                ? 'End Time'
                                : '${selectedTime![0].hour}:${selectedTime![0].minute} To ${selectedTime![1].hour}:${selectedTime![1].minute}',
                            icon: Icons.access_time_rounded,
                            onTap: () => _selectTime(context, false),
                          ),

                          Container(
                            height: height / height60,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              // color: Colors.redAccent,
                              borderRadius:
                                  BorderRadius.circular(width / width10),
                              border: Border(
                                bottom: BorderSide(
                                  color: color19,
                                ),
                              ),
                            ),
                            margin: EdgeInsets.only(top: height / height10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: width / width10),
                                Icon(
                                  Icons.location_on,
                                  size: width / width24,
                                  color: color1,
                                ),
                                SizedBox(width: width / width10),
                                Expanded(
                                  child: GooglePlaceAutoCompleteTextField(
                                    textEditingController: _locationController,
                                    googleAPIKey:
                                        "AIzaSyDd_MBd7IV8MRQKpyrhW9O1BGLlp-mlOSc",
                                    boxDecoration:
                                        BoxDecoration(border: Border()),
                                    inputDecoration: InputDecoration(
                                      border: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      hintStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: width / width18,
                                        color:
                                            color2, // Change text color to white
                                      ),
                                      hintText: 'Search your location',
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    debounceTime: 400,
                                    countries: ["in", "fr"],
                                    isLatLngRequired: true,
                                    getPlaceDetailWithLatLng:
                                        (Prediction prediction) {
                                      print("placeDetails" +
                                          prediction.lat.toString());
                                    },

                                    itemClick: (Prediction prediction) {
                                      _locationController.text =
                                          prediction.description ?? "";
                                      _locationController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: prediction.description
                                                          ?.length ??
                                                      0));
                                    },
                                    seperatedBuilder: Divider(),
                                    // containerHorizontalPadding: 10,

                                    // OPTIONAL// If you want to customize list view item builder
                                    itemBuilder: (context, index,
                                        Prediction prediction) {
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on),
                                            SizedBox(
                                              width: 6,
                                            ),
                                            Expanded(
                                              child: InterMedium(
                                                text:
                                                    '${prediction.description ?? ""}',
                                                color: color2,
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },

                                    isCrossBtnShown: true,
                                    textStyle: TextStyle(color: Colors.white),

                                    // default 600 ms ,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SetDetailsWidget(
                            useTextField: true,
                            hintText: 'client Name',
                            icon: Icons.account_circle_outlined,
                            controller: _clientcontrller,
                            onTap: () {},
                          ),
                          SetDetailsWidget(
                            useTextField: true,
                            hintText: 'Required no. of Employees ',
                            icon: Icons.onetwothree,
                            controller: _RequirednoofEmployees,
                            onTap: () {},
                          ),
                          SetDetailsWidget(
                            useTextField: true,
                            hintText: 'Restricted Radius(in meter)',
                            icon: Icons.attribution,
                            controller: _RestrictedRadius,
                            onTap: () {},
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _isRestrictedChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isRestrictedChecked = value ?? false;
                                  });
                                },
                              ),
                              InterMedium(
                                text: 'Enable Restricted Radius',
                                fontsize: width / width16,
                                color: color2,
                              ),
                            ],
                          ),

                          SetDetailsWidget(
                            useTextField: true,
                            hintText: 'Branch(Optional)',
                            icon: Icons.apartment,
                            controller: _Branch,
                            onTap: () {},
                          ),
                          SetDetailsWidget(
                            useTextField: true,
                            hintText: 'Photo Upload interval in minutes ',
                            icon: Icons.backup_outlined,
                            controller: _PhotoUploadIntervalInMinutes,
                            onTap: () {},
                          ),
                          SetDetailsWidget(
                            useTextField: true,
                            hintText: 'Description(Optional)',
                            icon: Icons.draw_outlined,
                            controller: _Description,
                            onTap: () {},
                          ),
                          // placesAutoCompleteTextField(),

                          SizedBox(height: height / height90),
                          Button1(
                            text: 'Done',
                            onPressed: () {
                              print(selectedGuards);
                            },
                            backgroundcolor: Primarycolor,
                            color: color22,
                            borderRadius: width / width10,
                            fontsize: width / width18,
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              String taskName = tasks[index]['name'];
                              bool isChecked = tasks[index]['isChecked'] ??
                                  false; // Default value is false

                              return Column(
                                children: [
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.only(
                                          left: width / width10),
                                      decoration: BoxDecoration(
                                        color: WidgetColor,
                                        borderRadius: BorderRadius.circular(
                                            width / width10),
                                      ),
                                      child: TextField(
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w300,
                                          fontSize: width / width18,
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(width / width10),
                                            ),
                                          ),
                                          focusedBorder: InputBorder.none,
                                          hintStyle: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                            fontSize: width / width18,
                                            color: color2,
                                          ),
                                          hintText: 'Task ${index + 1}',
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        cursorColor: Primarycolor,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                        size: width / width24,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          tasks.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: height / height10),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            tasks[index]['isChecked'] =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                      InterMedium(
                                        text: 'QR Code Required',
                                        fontsize: width / width16,
                                        color: color2,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: height / height20),
                          SizedBox(
                            width: width / width120,
                            child: Button1(
                              borderRadius: width / width10,
                              onPressed: () {
                                // if (nextScreen == false) {
                                //   setState(() {
                                //     nextScreen = true;
                                //   });
                                // }  else
                                _addNewTask();
                              },
                              height: height / height50,
                              backgroundcolor: Primarycolor,
                              text: nextScreen == false
                                  ? 'Fist screen'
                                  : 'Second Screen',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
