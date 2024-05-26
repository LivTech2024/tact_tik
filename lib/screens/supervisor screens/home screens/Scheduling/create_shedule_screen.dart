import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:number_editing_controller/number_editing_controller.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/widgets/inputwidget.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../widgets/set_details_widget.dart';
import 'select_guards_screen.dart';

class CreateSheduleScreen extends StatefulWidget {
  final String GuardId;
  final String GuardName;
  final String GuardImg;
  final String CompanyId;

  CreateSheduleScreen({
    super.key,
    required this.GuardId,
    required this.GuardName,
    required this.GuardImg,
    required this.CompanyId,
  });

  @override
  State<CreateSheduleScreen> createState() => _CreateSheduleScreenState();
}

class _CreateSheduleScreenState extends State<CreateSheduleScreen> {
  FireStoreService fireStoreService = FireStoreService();

  List colors = [Primarycolor, color25];
  List selectedGuards = [];
  String compId = "";
  List<TextEditingController> taskControllers = [];
  List<String> PositionValues = [];
  List<String> locationSuggestions = ['Location 1', 'Location 2', 'Location 3'];
  String dropdownValue = 'Other';
  List<String> tittles = [];
  String? selectedClint = 'Client';
  String? selectedLocatin = 'Select Location';
  String? selectedGuard = 'Guard 1';
  List<DateTime> _selectedDates = [];
  String? selectedPosition;

  // selectedPosition = PositionValues.isNotEmpty ? PositionValues[0] : null;
  List<String> ClintValues = ['Client'];
  List<String> LocationValues = ['Select Location'];
  List<String> PatrolValues = [];
  List<String> selectedPatrols = [];
  String? selectedPatrol;

  @override
  void initState() {
    super.initState();
    getEmployeeRoles();
    getAllClientNames();
    getAllPatrolNames();
    getAllLocationNames();
    selectedPosition = PositionValues.isNotEmpty ? PositionValues[0] : null;
    selectedClint = ClintValues.isNotEmpty ? ClintValues[0] : null;
    selectedLocatin = LocationValues.isNotEmpty ? LocationValues[0] : null;
    selectedPatrol = selectedPatrols.isNotEmpty ? selectedPatrols[0] : null;

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
    for (int i = 0; i < tasks.length; i++) {
      taskControllers.add(TextEditingController());
    }
  }

  void getEmployeeRoles() async {
    List<String> roles =
        await fireStoreService.getEmployeeRoles(widget.CompanyId);
    if (roles.isNotEmpty) {
      setState(() {
        PositionValues.addAll(roles);
      });
    }
  }

  void getAllClientNames() async {
    List<String> clientNames =
        await fireStoreService.getAllClientsName(widget.CompanyId);
    if (clientNames.isNotEmpty) {
      setState(() {
        ClintValues.addAll(clientNames);
      });
    }
  }

  void getAllLocationNames() async {
    List<String> LocatioName =
        await fireStoreService.getAllLocation(widget.CompanyId);
    if (LocatioName.isNotEmpty) {
      setState(() {
        LocationValues.addAll(LocatioName);
      });
    }
  }

  void getAllPatrolNames() async {
    List<String> PatrolNames =
        await fireStoreService.getAllPatrolName(widget.CompanyId);
    if (PatrolNames.isNotEmpty) {
      setState(() {
        PatrolValues.addAll(PatrolNames);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in taskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _clientcontrller = TextEditingController();

  DateTime? selectedDate;

  // List<TimeOfDay>? selectedTime;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TextEditingController _locationController = TextEditingController();
  TextEditingController _ShiftPosition = TextEditingController();
  final TextEditingController _ShiftName = TextEditingController();
  TextEditingController _RequirednoofEmployees = TextEditingController();
  TextEditingController _RestrictedRadius = TextEditingController();
  TextEditingController _Description = TextEditingController();
  TextEditingController _PhotoUploadIntervalInMinutes = TextEditingController();
  TextEditingController _Branch = TextEditingController();
  final requiredEmpcontroller = NumberEditingTextController.integer();
  final requiredPhotocontroller = NumberEditingTextController.integer();
  final requiredRadius = NumberEditingTextController.integer();
  List<ValueItem> _selectedOptions = [];
  bool _isRestrictedChecked = false;
  List<DateTime> selectedDates = []; // Define and initialize selectedDates list

  List<Map<String, dynamic>> tasks = [];
  List<Map<int, String>> PatrolList = [];
  final MultiSelectController _Patrollcontroller = MultiSelectController();

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
                Text('Select Dates',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Expanded(
                  child: SfDateRangePicker(
                    selectionTextStyle: TextStyle(color: Primarycolor),
                    // Use primary color here
                    selectionShape: DateRangePickerSelectionShape.circle,
                    selectionColor: Primarycolor,
                    // Use primary color here
                    selectionRadius: 4,
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.multiple,
                    initialSelectedDates: _selectedDates,
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                      setState(() {
                        _selectedDates = args.value.cast<DateTime>();

                        print("selected Date:- $_selectedDates ");
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
      setState(() {});
    }
  }

  placesAutoCompleteTextField(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    String qrData = "https://github.com/ChinmayMunje";
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

  bool nextScreen = false;
  String CreatedshiftId = "";

  void _addNewTask() {
    setState(() {
      tasks.add(
          {'name': '', 'isQrRequired': false, 'isReturnQrRequired': false});
    });
  }

  void _saveQrCode(String id) async {
    final qrImageData = await _generateQrImage(id);
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/qr_code.png';
    await File(path).writeAsBytes(qrImageData!);
    print("Path : $path");
    OpenFile.open(path);
  }

  Future<Uint8List?> _generateQrImage(String data) async {
    final qr = QrCode(4, QrErrorCorrectLevel.L);
    qr.addData(data);
    final painter =
        QrPainter(data: data, version: QrVersions.auto, color: Colors.white);
    final img = await painter.toImageData(2048, format: ImageByteFormat.png);
    return img?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    int requiredEmp = 0;
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
              !nextScreen
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
                          // Select Guard
                          // SetDetailsWidget(
                          //   useTextField: true,
                          //   hintText: 'Shift Position',
                          //   icon: Icons.control_camera,
                          //   controller: _ShiftPosition,
                          //   onTap: () {},
                          // ),
                          Container(
                            height: height / height60,
                            padding: EdgeInsets.symmetric(
                                horizontal: width / width10),
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
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                iconSize: width / width24,
                                icon: Icon(Icons.arrow_drop_down),
                                iconEnabledColor: color1,
                                // Set icon color for enabled state
                                dropdownColor: WidgetColor,
                                style: TextStyle(color: color1),
                                value: selectedPosition,
                                hint: Text("Select Roles"),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedPosition = newValue;
                                    // print('$selectedValue selected');
                                  });
                                },
                                items: PositionValues.map<
                                    DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        selectedPosition == value
                                            ? Icon(Icons.control_camera,
                                                color: color1)
                                            : Icon(Icons.control_camera,
                                                color: color3),
                                        // Conditional icon color based on selection
                                        SizedBox(width: width / width10),
                                        InterRegular(
                                            text: value,
                                            color: selectedPosition == value
                                                ? color1
                                                : color3),
                                        // Conditional text color based on selection
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
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
                            onTap: () => _showDatePicker(context),
                          ),
                          // Seperate Time
                          SetDetailsWidget(
                            hintText: startTime != null
                                ? startTime.toString()
                                : 'Start Time',
                            icon: Icons.access_time_rounded,
                            onTap: () => _selectTime(context, true),
                          ),
                          SetDetailsWidget(
                            hintText: endTime != null
                                ? endTime.toString()
                                : 'End Time',
                            icon: Icons.access_time_rounded,
                            onTap: () => _selectTime(context, false),
                          ),

                          // Location DropDown
                          Container(
                            height: height / height60,
                            padding: EdgeInsets.symmetric(
                                horizontal: width / width10),
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
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                iconSize: width / width24,
                                icon: Icon(Icons.arrow_drop_down,
                                    size: width / width24),
                                iconEnabledColor: color1,
                                // Set icon color for enabled state
                                dropdownColor: WidgetColor,
                                style: TextStyle(color: color1),
                                value: selectedLocatin,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedLocatin = newValue!;
                                    // print('$selectedValue selected');
                                  });
                                },
                                items: LocationValues.map<
                                    DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        selectedLocatin == value
                                            ? Icon(Icons.location_on,
                                                color: color1)
                                            : Icon(Icons.location_on,
                                                color: color3),
                                        // Conditional icon color based on selection
                                        SizedBox(width: width / width10),
                                        InterRegular(
                                            text: value,
                                            color: selectedLocatin == value
                                                ? color2
                                                : color3),
                                        // Conditional text color based on selection
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: height / height10),
                          // Clint DropDown
                          Container(
                            height: height / height60,
                            padding: EdgeInsets.symmetric(
                                horizontal: width / width10),
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
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                iconSize: width / width24,
                                icon: Icon(Icons.arrow_drop_down),
                                iconEnabledColor: color1,
                                // Set icon color for enabled state
                                dropdownColor: WidgetColor,
                                style: TextStyle(color: color1),
                                value: selectedClint,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedClint = newValue!;
                                    // print('$selectedValue selected');
                                  });
                                },
                                items:
                                    ClintValues.map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        selectedClint == value
                                            ? Icon(
                                                Icons.account_circle_outlined,
                                                color: color1)
                                            : Icon(
                                                Icons.account_circle_outlined,
                                                color: color3),
                                        // Conditional icon color based on selection
                                        SizedBox(width: width / width10),
                                        InterRegular(
                                            text: value,
                                            color: selectedClint == value
                                                ? color2
                                                : color3),
                                        // Conditional text color based on selection
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: height / height10),
                          // Select Guards
                          Container(
                            // height: ,
                            constraints:
                                BoxConstraints(minHeight: height / height60),
                            padding: EdgeInsets.symmetric(
                              horizontal: width / width10,
                            ),
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
                            child: Row(
                              children: [
                                Icon(
                                  Icons.checklist,
                                  color: color1,
                                  size: width / width24,
                                ),
                                Expanded(
                                  child: MultiSelectDropDown(
                                    selectedOptionBackgroundColor: Primarycolor,
                                    dropdownBackgroundColor: WidgetColor,
                                    // showClearIcon: true,
                                    fieldBackgroundColor: Colors.transparent,
                                    optionsBackgroundColor: WidgetColor,
                                    borderColor: Colors.transparent,
                                    controller: _Patrollcontroller,
                                    onOptionSelected: (options) {
                                      _selectedOptions = options;
                                      print(_selectedOptions);
                                      print('length is');
                                      print(_selectedOptions.length);
                                      setState(() {

                                      });
                                      // debugPrint(options.toString());
                                    },
                                    options: const <ValueItem>[
                                      ValueItem(label: 'Option 1', value: '1'),
                                      ValueItem(label: 'Option 2', value: '2'),
                                      ValueItem(label: 'Option 3', value: '3'),
                                      ValueItem(label: 'Option 4', value: '4'),
                                      ValueItem(label: 'Option 5', value: '5'),
                                      ValueItem(label: 'Option 6', value: '6'),
                                    ],
                                    disabledOptions: const [
                                      ValueItem(label: 'Option 1', value: '1')
                                    ],
                                    selectionType: SelectionType.multi,
                                    chipConfig: const ChipConfig(
                                        wrapType: WrapType.wrap),
                                    dropdownHeight: 300,
                                    optionTextStyle:
                                        const TextStyle(fontSize: 16),
                                    selectedOptionIcon:
                                        const Icon(Icons.check_circle),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // TODO ${_selectedOptions[index].label} Hit Count
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _selectedOptions.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(top: height / height10),
                                padding: EdgeInsets.only(
                                    left: width / width10),
                                decoration: BoxDecoration(
                                  // color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(width / width10),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: color19,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.checklist,
                                      color: color1,
                                      size: width / width24,
                                    ),
                                    SizedBox(
                                      width: width / width10,
                                    ),
                                    Expanded(
                                      child: TextField(
                                        keyboardType: TextInputType.number,
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

                                          hintText: '${_selectedOptions[index].label} Hit Count',
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        cursorColor: Primarycolor,

                                        onSubmitted: (value) {
                                          setState(() {
                                            PatrolList[index][0] = value;
                                            PatrolList[index][1] = _selectedOptions[index].label;
                                          });
                                          print(PatrolList);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          /**/

                          SetDetailsWidget(
                            keyboardType: TextInputType.number,
                            useTextField: true,
                            hintText: 'Required no. of Employees ',
                            icon: Icons.onetwothree,
                            controller: requiredEmpcontroller,
                            onTap: () {},
                          ),
                          // IntInputWidget(
                          //     hintText: "Required no. of Employees",
                          //     controller: requiredEmpcontroller,
                          //     onChanged: (text) {
                          //       print("Photo Interval minutes ${text}");
                          //       // setState(() {
                          //       //   requiredEmp = text!;
                          //       // });
                          //     }),
                          SetDetailsWidget(
                            useTextField: true,
                            hintText: 'Restricted Radius(in meter)',
                            icon: Icons.attribution,
                            controller: requiredRadius,
                            onTap: () {},
                          ),
                          // IntInputWidget(
                          //     hintText: "Restricted Radius(in meter)",
                          //     controller: requiredRadius,
                          //     onChanged: (text) {
                          //       print("Photo Interval minutes ${text}");
                          //       // setState(() {
                          //       //   requiredEmp = text!;
                          //       // });
                          //     }),
                          Row(
                            children: [
                              Checkbox(
                                activeColor: Primarycolor,
                                checkColor: color1,
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
                            keyboardType: TextInputType.number,
                            hintText: 'Photo Upload interval in minutes ',
                            icon: Icons.backup_outlined,
                            controller: requiredPhotocontroller,
                            onTap: () {},
                          ),
                          // IntInputWidget(
                          //     hintText: "Photo Upload interval in minutes",
                          //     controller: requiredPhotocontroller,
                          //     onChanged: (text) {
                          //       print("Photo Interval minutes ${text}");
                          //       // setState(() {
                          //       //   requiredEmp = text!;
                          //       // });
                          //     }),
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
                            onPressed: () async {
                              String address = "";
                              GeoPoint coordinates = GeoPoint(0, 0);
                              String name = "";
                              String locationId = "";
                              //fetching the patrols ids using patrol name
                              List<String> patrolids = await fireStoreService
                                  .getPatrolIdsFromNames(selectedPatrols);
                              // fetching clientid

                              String clientId = await fireStoreService
                                  .getClientIdfromName(selectedClint!);
                              print('CLientName: $selectedClint');
                              print('clientId: $clientId');

                              // //fetching location details from locationame
                              var locationData =
                                  await fireStoreService.getLocationByName(
                                      selectedLocatin!, widget.CompanyId);
                              if (locationData.exists) {
                                var data = locationData.data()
                                    as Map<String, dynamic>?;
                                ;
                                if (data != null) {
                                  address = data['LocationAddress'];
                                  coordinates =
                                      data['LocationCoordinates'] as GeoPoint;
                                  name = data['LocationName'];
                                  locationId = data['LocationId'];

                                  print("Address ${address}");
                                  print("coordinates ${coordinates}");
                                  print("Latitude: ${coordinates.latitude}");
                                  print("Longitude: ${coordinates.longitude}");
                                }
                              }
                              print("locationData  ids ${locationData}");
                              var requiredEmp = _RequirednoofEmployees.text;
                              // int? requiredEmpNUmber = int.parse(requiredEmp);
                              print(
                                  "Number Editing Controller ${requiredEmpcontroller.number}");
                              print("ShiftName ${_ShiftName.text}");
                              print("ShiftDesc ${_Description.text}");

                              String id = await fireStoreService.ScheduleShift(
                                  selectedGuards,
                                  selectedPosition,
                                  "Address",
                                  "CompanyBranchId",
                                  widget.CompanyId,
                                  _selectedDates,
                                  startTime,
                                  endTime,
                                  patrolids,
                                  clientId,
                                  requiredEmpcontroller.text,
                                  requiredPhotocontroller.text,
                                  requiredRadius.text,
                                  _isRestrictedChecked,
                                  coordinates,
                                  name,
                                  locationId,
                                  address,
                                  _Branch.text,
                                  _Description.text,
                                  _ShiftName.text);
                              setState(() {
                                nextScreen = !nextScreen;
                                _addNewTask();
                              });
                              print("Shift Created");
                              print("Shift ID : ${id}");
                              setState(() {
                                CreatedshiftId = id;
                              });
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
                              bool isChecked =
                                  tasks[index]['isQrRequired'] ?? false;
                              bool isReturnChecked = tasks[index]
                                      ['isReturnQrRequired'] ??
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
                                        onChanged: (value) {
                                          setState(() {
                                            tasks[index]['name'] = value;
                                          });
                                          print("textfield value $value");
                                        },
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
                                        activeColor: Primarycolor,
                                        checkColor: color1,
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            tasks[index]['isQrRequired'] =
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
                                    // {'name': '', 'isQrRequired': false, 'isReturnQrRequired': false});
                                  ),
                                  SizedBox(height: height / height10),
                                  Row(
                                    children: [
                                      Checkbox(
                                        activeColor: Primarycolor,
                                        checkColor: color1,
                                        value: isReturnChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            tasks[index]['isReturnQrRequired'] =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                      InterMedium(
                                        text: 'Return QR Code Required',
                                        fontsize: width / width16,
                                        color: color2,
                                      ),
                                    ],
                                  ),
                                  // Button1(
                                  //     text: "Generate Qr",
                                  //     onPressed: () async {
                                  //       // if (taskText != null) {
                                  //       //   final name = taskText.text;
                                  //       //   _saveQrCode(name.toString());
                                  //       // }
                                  //       print("Generate qr buttoin");
                                  //     })
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
                                print(tasks);
                                _addNewTask();
                              },
                              height: height / height50,
                              backgroundcolor: Primarycolor,
                              text: nextScreen == false
                                  ? 'Create Shift Task'
                                  : 'Create Task',
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: height / height90),
                          Button1(
                            text: 'Done',
                            onPressed: () {
                              if (nextScreen!) {
                                // print(tasks);
                                print('clicked on done');
                                print(PatrolList);
                              }
                            },
                            backgroundcolor: Primarycolor,
                            color: color22,
                            borderRadius: width / width10,
                            fontsize: width / width18,
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
