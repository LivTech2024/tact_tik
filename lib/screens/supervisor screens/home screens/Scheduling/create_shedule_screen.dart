import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/Scheduling/select_guards_screen.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import '../widgets/set_details_widget.dart';

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
  TextEditingController _locationController = TextEditingController();
  List<String> locationSuggestions = ['Location 1', 'Location 2', 'Location 3'];

  void _selectDate(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
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
        selectedDate = datePicked;
      });
      print(selectedDate);
    }
  }

  Future<List<TimeOfDay>?> showCustomTimePicker(BuildContext context) async {
    List<TimeOfDay> selectedTimes = [];
    bool validTimesSelected = false;

    do {
      TimeOfDay? selectedTime = await showTimePicker(
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

      if (selectedTime != null) {
        selectedTimes.add(selectedTime);
        if (selectedTimes.length == 2) {
          validTimesSelected = true;
        }
      } else {
        // If user cancels, exit the loop
        validTimesSelected = true;
      }
    } while (!validTimesSelected);

    return selectedTimes.isNotEmpty ? selectedTimes : null;
  }

  void _selectTime(BuildContext context) async {
    final timePicked = await showCustomTimePicker(context);
    if (timePicked != null) {
      setState(() {
        selectedTime = timePicked;
      });
      print(selectedTime);
    }
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
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
                                    builder: (context) => SelectGuardsScreen(
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
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width10),
                      decoration: BoxDecoration(
                        color: WidgetColor,
                        borderRadius: BorderRadius.circular(width / width13),
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
                                  color: color2, // Change text color to white
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
                          String guardId = selectedGuards[index]['GuardId'];
                          String guardName = selectedGuards[index]['GuardName'];
                          String guardImg = selectedGuards[index]['GuardImg'];
                          return Padding(
                            padding: EdgeInsets.only(right: height / height20),
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
                                            selectedGuards.removeAt(index);
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
                      hintText: 'client Name',
                      icon: Icons.account_circle_outlined,
                      controller: _clientcontrller,
                      onTap: () {},
                    ),
                    Container(
                      height: height / height60,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        // color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(width / width10),
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
                            child: TextField(
                              onChanged: (value) {
                                List<String> filteredSuggestions =
                                    locationSuggestions
                                        .where((location) => location
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                              },
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300,
                                fontSize: width / width18,
                                color:
                                    Colors.white, // Change text color to white
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
                                  color: color2, // Change text color to white
                                ),
                                hintText: 'Location',
                                contentPadding:
                                    EdgeInsets.zero, // Remove padding
                              ),
                              cursorColor: Primarycolor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SetDetailsWidget(
                      hintText: selectedDate == null
                          ? 'Date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      icon: Icons.date_range,
                      onTap: () => _selectDate(context),
                  ),
                    SetDetailsWidget(
                      hintText: selectedTime == null
                          ? 'Time'
                          : '${selectedTime![0].hour}:${selectedTime![0].minute} To ${selectedTime![1].hour}:${selectedTime![1].minute}',
                      icon: Icons.access_time_rounded,
                      onTap: () => _selectTime(context),
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
