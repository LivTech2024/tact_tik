import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/intl.dart';
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
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:http/http.dart' as http;
import '../widgets/set_details_widget.dart';
import 'select_guards_screen.dart';

class Guards {
  final String image;
  final String name;

  Guards(this.name, this.image);
}

class CreateSheduleScreen extends StatefulWidget {
  final String GuardId;
  final String GuardName;
  final String GuardImg;
  final String CompanyId;
  final String BranchId;
  final String supervisorEmail;
  final String shiftId;

  CreateSheduleScreen({
    super.key,
    required this.GuardId,
    required this.GuardName,
    required this.GuardImg,
    required this.CompanyId,
    required this.BranchId,
    required this.supervisorEmail,
    required this.shiftId,
  });

  @override
  State<CreateSheduleScreen> createState() => _CreateSheduleScreenState();
}

class _CreateSheduleScreenState extends State<CreateSheduleScreen> {
  FireStoreService fireStoreService = FireStoreService();

  List colors = [
    isDark ? DarkColor.Primarycolor : LightColor.color3,
    isDark ? DarkColor.color25 : LightColor.color2
  ];
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
  String? selectedGuardId;
  String? selectedGuardImage;
  String? selectedGuardName;

  List<String> ClintValues = ['Client'];
  List<String> LocationValues = ['Select Location'];
  List<String> PatrolValues = [];
  List<String> selectedPatrols = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> guards = [];
  String? selectedPatrol;
  List<ValueItem<String>> patrolItems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getEmployeeRoles();
    getAllClientNames();
    getAllPatrolNames();
    getAllLocationNames();
    initializeData();
  }

  void initializeData() async {
    await fetchShiftDataAndUpdateGuards();
  }

  Future<void> fetchShiftDataAndUpdateGuards() async {
    final shiftData = await fetchShiftData();

    if (shiftData != null) {
      if (shiftData.containsKey('ShiftAssignedUserId')) {
        List<String> assignedUserIds = List<String>.from(shiftData['ShiftAssignedUserId']);

        for (String guardId in assignedUserIds) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('Employees')
              .where('EmployeeId', isEqualTo: guardId)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            final employeeData = querySnapshot.docs.first.data();
            setState(() {
              selectedGuards.add({
                'GuardId': guardId,
                'GuardName': employeeData['EmployeeName'] ?? '',
                'GuardImg': employeeData['EmployeeImg'] ?? '',
              });
            });
          }
        }
      }

      // Set default values based on shift data
      setDefaultValuesFromShiftData(shiftData);
    }
  }

  Future<Map<String, dynamic>?> fetchShiftData() async {
    if (widget.shiftId.isNotEmpty) {
      final shiftDoc = await FirebaseFirestore.instance
          .collection('Shifts')
          .doc(widget.shiftId)
          .get();

      if (shiftDoc.exists) {
        return shiftDoc.data();
      }
    }
    return null;
  }

  void setDefaultValuesFromShiftData(Map<String, dynamic> shiftData) async {
    // Fetch and set default position
    String? shiftPosition = shiftData['ShiftPosition'];
    if (shiftPosition != null && shiftPosition.isNotEmpty) {
      setState(() {
        selectedPosition = shiftPosition;
      });
    }

    // Fetch and set default client
    String? shiftClientId = shiftData['ShiftClientId'];
    if (shiftClientId != null && shiftClientId.isNotEmpty) {
      final clientSnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .doc(shiftClientId)
          .get();

      if (clientSnapshot.exists) {
        setState(() {
          selectedClint = clientSnapshot.data()?['ClientName'] ?? 'Client';
        });
      }
    }

    // Fetch and set default location
    String? shiftLocationId = shiftData['ShiftLocationId'];
    if (shiftLocationId != null && shiftLocationId.isNotEmpty) {
      final locationSnapshot = await FirebaseFirestore.instance
          .collection('Locations')
          .doc(shiftLocationId)
          .get();

      if (locationSnapshot.exists) {
        setState(() {
          selectedLocatin = locationSnapshot.data()?['LocationName'] ?? 'Select Location';
        });
      }
    }

    _ShiftName.text = shiftData['ShiftName'] ?? '';
    requiredEmpcontroller.value = shiftData['ShiftRequiredEmp'] ?? '';
    _Description.text = shiftData['ShiftDescription'] ?? 0;
    requiredRadius.value = shiftData['ShiftRestrictedRadius'] ?? 0;
    _PhotoUploadIntervalInMinutes.value = shiftData['ShiftPhotoUploadIntervalInMinutes'] ?? 0;
    _isRestrictedChecked = shiftData['ShiftEnableRestrictedRadius'] ?? false;
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
    List<String> patrolNames =
        await fireStoreService.getAllPatrolName(widget.CompanyId);
    if (patrolNames.isNotEmpty) {
      setState(() {
        patrolItems = patrolNames
            .map((name) => ValueItem<String>(label: name, value: name))
            .toList();
        isLoading = false;
      });

    } else {
      setState(() {
        isLoading = false;
      });
    }
    print(patrolItems);
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
  List<DateTime> selectedDates = [];

  List<Map<String, dynamic>> tasks = [
    {'name': '', 'isQrRequired': false, 'isReturnQrRequired': false}
  ];
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
                    selectionTextStyle: TextStyle(
                        color: isDark
                            ? DarkColor.Primarycolor
                            : LightColor.color3), // Use primary color here
                    selectionShape: DateRangePickerSelectionShape.circle,
                    selectionColor:
                       isDark
                        ? DarkColor.Primarycolor
                        : LightColor.color3, // Use primary color here
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
                    print(_selectedDates);
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
              primary: isDark
                  ? DarkColor.Primarycolor
                  : LightColor.Primarycolor, // Change primary color to red
              secondary: DarkColor.Primarycolor,
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
            color: isDark
                ? DarkColor.color2
                : LightColor.color3, // Change text color to white
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

  Future<void> searchGuards(String query) async {
    if (query.isEmpty) {
      setState(() {
        guards.clear();
      });
      return;
    }

    final result = await FirebaseFirestore.instance
        .collection('Employees')
        .where('EmployeeRole', isEqualTo: 'GUARD')
        .where('EmployeeCompanyId', isEqualTo: widget.CompanyId)
        .where('EmployeeNameSearchIndex', arrayContains: query)
        .get();

    setState(() {
      guards = result.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> callPdfApi(String base64Image) async {
    final url = Uri.parse('https://backend-sceurity-app.onrender.com/api/html_to_pdf');

    final headers = {
      'Content-Type': 'application/json',
    };

    final htmlContent = '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
      <h1>TASK QR CODE!</h1>
      <img src="data:image/png;base64,$base64Image"/>
    </body>
    </html>
  ''';

    final body = jsonEncode({
      'html': htmlContent,
      'file_name': 'TaskQR.pdf',
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final pdfBase64 = base64Encode(response.bodyBytes);
      await sendEmail({
        'to_email': widget.supervisorEmail,
        'subject': 'Task QR Code',
        'from_name': 'Company',
        'html': '',
        'pdfFile': pdfBase64,
      });
    } else {
      print('Failed to call API: ${response.statusCode}, ${response.reasonPhrase}');
    }
  }

  Future<String> _savePdfFile(Uint8List pdfBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/security_report.pdf';
    final file = File(path);
    await file.writeAsBytes(pdfBytes);
    return path;
  }

  Future<bool> sendEmail(dynamic templateParams) async {
    try {
      final toEmail = templateParams['to_email'];
      final subject = templateParams['subject'];
      final fromName = templateParams['from_name'];
      final htmlContent = templateParams['html'];
      final pdfFile = templateParams['pdfFile'];

      final response = await http.post(
        Uri.parse('https://backend-sceurity-app.onrender.com/api/send_email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'to_email': toEmail,
          'subject': subject,
          'from_name': fromName,
          'html': htmlContent,
          'attachments': [
            {
              'filename': 'taskQR.pdf',
              'content': pdfFile,
              'contentType': 'application/pdf',
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        print('SUCCESS!');
        return true;
      } else {
        print('ERROR... ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  void _saveQrCode(String id) async {
    final qrImageData = await _generateQrImage(id);
    if (qrImageData == null) {
      print("Failed to generate QR code");
      return;
    }
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/qr_code.png';
    await File(path).writeAsBytes(qrImageData);
    print("Path : $path");
    OpenFile.open(path);

    final base64Image = base64Encode(qrImageData);
    await callPdfApi(base64Image);
  }

  Future<Uint8List?> _generateQrImage(String data) async {
    final qr = QrCode(4, QrErrorCorrectLevel.L);
    qr.addData(data);
    final painter = QrPainter(
        data: data,
        version: QrVersions.auto,
        color: Colors.black,
        emptyColor: Colors.white);
    final img = await painter.toImageData(2048, format: ImageByteFormat.png);
    return img?.buffer.asUint8List();
  }

  final TextEditingController _controller = TextEditingController();

  final List<Guards> _screens = [
    Guards('Site Tours', 'Image URL'),
    Guards('DAR Screen', 'Image URL'),
    Guards('Reports Screen', 'Image URL'),
    Guards('Post Screen', 'Image URL'),
    Guards('Task Screen', 'Image URL'),
    Guards('LogBook Screen', 'Image URL'),
    Guards('Visitors Screen', 'Image URL'),
    Guards('Assets Screen', 'Image URL'),
    Guards('Key Screen', 'Image URL'),
  ];

  Future<List<Guards>> suggestionsCallback(String pattern) async =>
      Future<List<Guards>>.delayed(
        Duration(milliseconds: 300),
        () => _screens.where((product) {
          // print(product.name);
          final nameLower = product.name.toLowerCase().split(' ').join('');
          final patternLower = pattern.toLowerCase().split(' ').join('');
          return nameLower.contains(patternLower);
        }).toList(),
      );

  Widget gridLayoutBuilder(
    BuildContext context,
    List<Widget> items,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 58,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      reverse: SuggestionsController.of<Guards>(context).effectiveDirection ==
          VerticalDirection.up,
      itemBuilder: (context, index) => items[index],
    );
  }

  @override
  Widget build(BuildContext context) {
 
    int requiredEmp = 0;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color:  isDark ? DarkColor.color1 : LightColor.color3,
              size: 24.w,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Create Schedule',
            fontsize: 18.sp,
            color:  isDark ? DarkColor.color1 : LightColor.color3,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        backgroundColor: isDark?DarkColor.Secondarycolor:LightColor.Secondarycolor,
        body: SingleChildScrollView(
          // physics: PageScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: 65.h,
                width: double.maxFinite,
                // color: isDark ? DarkColor.color24 : LightColor.WidgetColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: isDark ? DarkColor.color24 : LightColor.WidgetColor,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.transparent
                          : LightColor.color3.withOpacity(.05),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
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
                              fontsize: 18.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Patrol',
                              color: colors[1],
                              fontsize: 18.w,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              !nextScreen
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InterBold(
                                text: 'Select Guards',
                                fontsize: 16.sp,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
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
                                              bool guardExists = selectedGuards.any((guard) => guard['GuardId'] == value['id']);

                                              if (guardExists) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Guard already added'),
                                                  ),
                                                );
                                              } else {
                                                // Add the guard if it does not exist
                                                selectedGuards.add({
                                                  'GuardId': value['id'],
                                                  'GuardName': value['name'],
                                                  'GuardImg': value['url']
                                                });
                                              }
                                            }),
                                }
                                      });
                                },
                                child: InterBold(
                                  text: 'view all',
                                  fontsize: 14.sp,
                                  color: isDark
                                      ? DarkColor.color1
                                      : LightColor.color3,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Container(
                            height: 64.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.transparent
                                      : LightColor.color3.withOpacity(.05),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: Offset(0, 3),
                                )
                              ],
                              color:  isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                              borderRadius:
                                  BorderRadius.circular(13.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TypeAheadField<Guards>(
                                    autoFlipDirection: true,
                                    controller: _searchController,
                                    direction: VerticalDirection.down,
                                    builder:
                                        (context, _controller, focusNode) =>
                                            TextField(
                                      controller: _controller,
                                      focusNode: focusNode,
                                      autofocus: false,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 18.w,
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.r),
                                          ),
                                        ),
                                        focusedBorder: InputBorder.none,
                                        hintStyle: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 18.w,
                                          color: isDark
                                              ? DarkColor.color2
                                              : LightColor.color2,
                                        ),
                                        hintText: 'Search Guards',
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      cursorColor: isDark
                                          ? DarkColor.Primarycolor
                                          : LightColor.Primarycolor,
                                    ),
                                    suggestionsCallback: suggestionsCallback,
                                    itemBuilder: (context, Guards guards) {
                                      return ListTile(
                                        leading: Container(
                                          height: 30.h,
                                          width: 30.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isDark
                                                ? DarkColor.Primarycolor
                                                : LightColor.Primarycolor ,
                                          ),
                                        ),
                                        title: InterRegular(
                                          text: guards.name,
                                          color: isDark
                                              ? DarkColor.color2
                                              : LightColor.color2,
                                        ),
                                      );
                                    },
                                    emptyBuilder: (context) => Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10.h,
                                        horizontal: 10.w,
                                      ),
                                      child: InterRegular(
                                        text: 'No Such Screen found',
                                        color: isDark
                                            ? DarkColor.color2
                                            : LightColor.color2,
                                        fontsize: 18.sp,
                                      ),
                                    ),
                                    decorationBuilder: (context, child) =>
                                        Material(
                                      type: MaterialType.card,
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(
                                        10.r,
                                      ),
                                      child: child,
                                    ),
                                    debounceDuration:
                                        const Duration(milliseconds: 300),
                                    onSelected: (Guards guard) {
                                      print(
                                          'home screen search bar############################################');

                                      print(guard.name);
                                    },
                                    listBuilder: gridLayoutBuilder,
                                  ),
                                ),
                                Container(
                                  height: 44.h,
                                  width: 44.w,
                                  decoration: BoxDecoration(
                                    color:  isDark
                                        ? DarkColor.Primarycolor
                                        : LightColor.Primarycolor,
                                    borderRadius:
                                        BorderRadius.circular(10.r),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.search,
                                      size: 20.w,
                                      color:  isDark
                                          ? DarkColor.Secondarycolor
                                          : LightColor.color1,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: guards.length,
                            itemBuilder: (context, index) {
                              final guard = guards[index];
                              return ListTile(
                                title: Text(guard['EmployeeName']),
                                onTap: () {
                                  setState(() {
                                    _searchController.text =
                                        guard['EmployeeName'];
                                    selectedGuardId = guard['EmployeeId'];
                                    selectedGuardName = guard['EmployeeName'];
                                    selectedGuardImage = guard['EmployeeImg'];
                                    selectedGuards.add({
                                      'GuardId': selectedGuardId,
                                      'GuardName': selectedGuardName,
                                      'GuardImg': selectedGuardImage,
                                    });
                                    guards.clear();
                                  });
                                },
                              );
                            },
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            margin: EdgeInsets.only(top: 20.h),
                            height: 80.h,
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
                                      EdgeInsets.only(right: 20.h),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: 50.h,
                                            width: 50.w,
                                            decoration: guardImg != ""
                                                ? BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          guardImg ?? ""),
                                                      filterQuality:
                                                          FilterQuality.high,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isDark
                                                        ? DarkColor.Primarycolor
                                                        : LightColor.Primarycolor,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/default.png'),
                                                      filterQuality:
                                                          FilterQuality.high,
                                                      fit: BoxFit.cover,
                                                    ),
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
                                                height: 20.h,
                                                width: 20.w,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: DarkColor.color1),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 8,
                                                    color: DarkColor
                                                        .Secondarycolor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      InterBold(
                                        text: guardName,
                                        fontsize: 14.sp,
                                        color:  isDark
                                            ? DarkColor.color26
                                            : LightColor.color3,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          InterBold(
                            text: 'Set Details',
                            fontsize: 16.sp,
                            color:  isDark ? DarkColor.color1 : LightColor.color3,
                          ),
                          SizedBox(height: 10.h),
                          // Select Guard
                          // SetDetailsWidget(
                          //   useTextField: true,
                          //   hintText: 'Shift Position',
                          //   icon: Icons.control_camera,
                          //   controller: _ShiftPosition,
                          //   onTap: () {},
                          // ),
                          Container(
                            height: 60.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w),
                            decoration: BoxDecoration(
                              // color: Colors.redAccent,
                              borderRadius:
                                  BorderRadius.circular(10.r),
                              border: Border(
                                bottom: BorderSide(
                                  color:  isDark
                                      ? DarkColor.color19
                                      : LightColor.color3,
                                ),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                iconSize: 24.w,
                                icon: Icon(Icons.arrow_drop_down),
                                iconEnabledColor:  isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                                // Set icon color for enabled state
                                dropdownColor:  isDark
                                    ? DarkColor.WidgetColor
                                    : LightColor.WidgetColor,
                                style: TextStyle(color:  isDark
                                        ? DarkColor.color1
                                        : LightColor.color3),
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
                                                color:  isDark
                                                    ? DarkColor.color1
                                                    : LightColor.color3)
                                            : Icon(Icons.control_camera,
                                                color:  isDark
                                                    ? DarkColor.color3
                                                    : LightColor.color2),
                                        // Conditional icon color based on selection
                                        SizedBox(width: 10.w),
                                        InterRegular(
                                            text: value,
                                            color: selectedPosition == value
                                                ?  isDark
                                                    ? DarkColor.color1
                                                    : LightColor.color3
                                                :  isDark
                                                    ? DarkColor.color3
                                                    : LightColor.color2),
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
                            hintText: 'Date',
                            icon: Icons.date_range,
                            onTap: () => _showDatePicker(context),
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              InterMedium(text: 'Selected dates: ' , color: isDark
                                    ? DarkColor.Primarycolor
                                    : LightColor.color3,fontsize: 14.sp,),
                              if (_selectedDates != null)
                                for (var date in _selectedDates)
                                  Flexible(
                                    child: InterMedium(
                                      text: '${DateFormat('d').format(date)},',
                                      color: isDark
                                          ? DarkColor.color2
                                          : LightColor.color2,
                                      fontsize: 14.sp,
                                    ),
                                  ),
                            ],
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
                            height: 60.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w),
                            decoration: BoxDecoration(

                              // color: Colors.redAccent,
                              borderRadius:
                                  BorderRadius.circular(10.r),
                              border: Border(
                                bottom: BorderSide(
                                  color:  isDark
                                      ? DarkColor.color19
                                      : LightColor.color3,
                                ),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                iconSize: 24.w,
                                icon: Icon(Icons.arrow_drop_down,
                                    size: 24.w),
                                iconEnabledColor:  isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                                // Set icon color for enabled state
                                dropdownColor:  isDark
                                    ? DarkColor.WidgetColor
                                    : LightColor.WidgetColor,
                                style: TextStyle(color:  isDark
                                        ? DarkColor.color1
                                        : LightColor.color3),
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
                                                color:  isDark
                                                    ? DarkColor.color1
                                                    : LightColor.color3)
                                            : Icon(Icons.location_on,
                                                color:  isDark
                                                    ? DarkColor.color3
                                                    : LightColor.color2),
                                        // Conditional icon color based on selection
                                        SizedBox(width: 10.w),
                                        InterRegular(
                                            text: value,
                                            color: selectedLocatin == value
                                                ?  isDark
                                                    ? DarkColor.color1
                                                    : LightColor.color3
                                                :  isDark
                                                    ? DarkColor.color3
                                                    : LightColor.color2),
                                        // Conditional text color based on selection
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          // Clint DropDown
                          Container(
                            height: 60.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w),
                            decoration: BoxDecoration(
                              // color: Colors.redAccent,
                              borderRadius:
                                  BorderRadius.circular(10.w),
                              border: Border(
                                bottom: BorderSide(
                                  color:  isDark
                                      ? DarkColor.color19
                                      : LightColor.color3,
                                ),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                iconSize: 24.w,
                                icon: Icon(Icons.arrow_drop_down),
                                iconEnabledColor:  isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                                // Set icon color for enabled state
                                dropdownColor:  isDark
                                    ? DarkColor.WidgetColor
                                    : LightColor.WidgetColor,
                                style: TextStyle(color: isDark
                                        ? DarkColor.color1
                                        : LightColor.color3),
                                value: selectedClint,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedClint = newValue!;
                                    print('$selectedClint selected');
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
                                                color:  isDark
                                                    ? DarkColor.color1
                                                    : LightColor.color3)
                                            : Icon(
                                                Icons.account_circle_outlined,
                                                color:  isDark
                                                    ? DarkColor.color3
                                                    : LightColor.color2),
                                        // Conditional icon color based on selection
                                        SizedBox(width: 10.w),
                                        InterRegular(
                                            text: value,
                                            color: selectedClint == value
                                                ?  isDark
                                                    ? DarkColor.color1
                                                    : LightColor.color3
                                                :  isDark
                                                    ? DarkColor.color2
                                                    : LightColor.color2),
                                        // Conditional text color based on selection
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          // Select Guards
                          Container(
                            // height: ,
                            constraints:
                                BoxConstraints(minHeight: 60.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                            ),
                            decoration: BoxDecoration(
                              // color: Colors.redAccent,
                              borderRadius:
                                  BorderRadius.circular(10.r),
                              border: Border(
                                bottom: BorderSide(
                                  color:  isDark
                                      ? DarkColor.color19
                                      : LightColor.color3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.checklist,
                                  color: DarkColor.color1,
                                  size: 24.w,
                                ),
                                Expanded(
                                  child: isLoading
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : MultiSelectDropDown(
                                          selectedOptionBackgroundColor:
                                              isDark
                                              ? DarkColor.Primarycolor
                                              : LightColor.Primarycolor,
                                          dropdownBackgroundColor: isDark
                                              ? DarkColor.WidgetColor
                                              : LightColor.WidgetColor,
                                          fieldBackgroundColor:
                                              Colors.transparent,
                                          optionsBackgroundColor: isDark
                                              ? DarkColor.WidgetColor
                                              : LightColor.WidgetColor,
                                          borderColor: Colors.transparent,
                                          controller: _Patrollcontroller,
                                          onOptionSelected: (options) {
                                            setState(() {
                                              _selectedOptions = options;
                                            });
                                            print(_selectedOptions);
                                            print('length is');
                                            print(_selectedOptions.length);
                                          },
                                          options: patrolItems,
                                          selectionType: SelectionType.multi,
                                          chipConfig: const ChipConfig(
                                            wrapType: WrapType.wrap,
                                          ),
                                          dropdownHeight: 300.h,
                                          optionTextStyle: TextStyle(
                                              fontSize: 16.sp),
                                          selectedOptionIcon:
                                          Icon(Icons.check_circle , size: 24.sp,),
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
                                margin: EdgeInsets.only(top: 10.w),
                                padding: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  // color: Colors.redAccent,
                                  borderRadius:
                                      BorderRadius.circular(10.w),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: DarkColor. color19,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.checklist,
                                      color: DarkColor. color1,
                                      size: 24.w,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Expanded(
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 18.w,
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.r),
                                            ),
                                          ),
                                          focusedBorder: InputBorder.none,
                                          hintStyle: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 18.sp,
                                            color: DarkColor. color2,
                                          ),
                                          hintText:
                                              '${_selectedOptions[index].label} Hit Count',
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        cursorColor: DarkColor. Primarycolor,

                                        onSubmitted: (value) {
                                          setState(() {
                                            PatrolList[index][0] = value;
                                            PatrolList[index][1] =
                                                _selectedOptions[index].label;
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
                            keyboardType: TextInputType.number,
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
                                activeColor:  isDark
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor,
                                checkColor:  isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                                value: _isRestrictedChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isRestrictedChecked = value ?? false;
                                  });
                                },
                              ),
                              InterMedium(
                                text: 'Enable Restricted Radius',
                                fontsize: 16.w,
                                color:  isDark
                                      ? DarkColor.color2
                                      : LightColor.color2,
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

                          SizedBox(height: 40.h),
                          Button1(
                            text: 'Next',
                            height: 50.h,
                            onPressed: () async {
                              if (selectedClint != null &&
                                  selectedLocatin != null &&
                                  requiredEmpcontroller.text.isNotEmpty &&
                                  _ShiftName.text.isNotEmpty) {
                                setState(() {
                                  nextScreen = !nextScreen;
                                });
                              } else {
                                String errorMessage = "Please fill in the following required fields:";
                                if (selectedClint == null) {
                                  errorMessage += "\n- Client";
                                }
                                if (selectedLocatin == null) {
                                  errorMessage += "\n- Location";
                                }
                                if (requiredEmpcontroller.text.isEmpty) {
                                  errorMessage += "\n- Required Number of Employees";
                                }
                                if (_ShiftName.text.isEmpty) {
                                  errorMessage += "\n- Shift Name";
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
                                print(errorMessage);
                              }
                            },
                            backgroundcolor:  isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
                            color:  isDark ? DarkColor.color22 : LightColor.color1,
                            borderRadius: 10.r,
                            fontsize: 14.sp,
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
              )
                  : Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        String taskName = tasks[index]['name'];
                        bool isChecked = tasks[index]['isQrRequired'] ?? false;
                        bool isReturnChecked = tasks[index]['isReturnQrRequired'] ?? false;

                        return Column(
                          children: [
                            ListTile(
                              title: Container(
                                padding: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  color:  isDark
                                            ? DarkColor.WidgetColor
                                            : LightColor.WidgetColor, // WidgetColor,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: TextField(
                                  controller: taskControllers[index],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.r),
                                      ),
                                    ),
                                    focusedBorder: InputBorder.none,
                                    hintStyle: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18.sp,
                                      color: Colors.grey, // color2,
                                    ),
                                    hintText: 'Task ${index + 1}',
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  cursorColor: Colors.red,
                                  // Primarycolor,
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
                                  size: 24.w,
                                ),
                                onPressed: () {
                                  setState(() {
                                    tasks.removeAt(index);
                                    taskControllers.removeAt(index);
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.red, // Primarycolor,
                                  checkColor: Colors.black, // color1,
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      tasks[index]['isQrRequired'] = value ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  'QR Code Required',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    color: Colors.grey, // color2,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.red, // Primarycolor,
                                  checkColor: Colors.black, // color1,
                                  value: isReturnChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      tasks[index]['isReturnQrRequired'] = value ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  'Return QR Code Required',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.w,
                                    color: Colors.grey, // color2,
                                  ),
                                ),
                              ],
                            ),
                            Button1(
                              height: 50.h,
                              borderRadius: 10.w,
                              backgroundcolor:  isDark
                                        ? DarkColor.color33
                                        : LightColor.WidgetColor,
                              color:  isDark
                                        ? DarkColor.color1
                                        : LightColor.color3,
                              text: "Generate Qr",
                              onPressed: () async {
                                final name = taskControllers[index].text;
                                _saveQrCode(name);
                                print('Generate QR Button Pressed');
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: 120.w,
                      child: Button1(
                        borderRadius: 10.r,
                        onPressed: () {
                          // if (nextScreen == false) {
                          //   setState(() {
                          //     nextScreen = true;
                          //   });
                          // }  else
                          print(tasks);
                          _addNewTask();
                        },
                        height: 50.h,
                        backgroundcolor:  isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                        text: nextScreen == false ? 'Create Shift Task' : 'Create Task',
                        color:  isDark ? DarkColor.color1 : LightColor.color3,
                      ),
                    ),
                    SizedBox(height: 90.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Button1(
                            height: 50.h,
                            text: 'Done',
                            onPressed: () async {
                              if (nextScreen!) {
                                String address = "";
                                GeoPoint coordinates = GeoPoint(0, 0);
                                String name = "";
                                String locationId = "";

                                // Fetching the patrols ids using patrol name
                                List<String> patrolids =
                                await fireStoreService.getPatrolIdsFromNames(selectedPatrols);

                                // Fetching client id
                                String clientId =
                                await fireStoreService.getClientIdfromName(selectedClint!);
                                print('ClientName: $selectedClint');
                                print('ClientId: $clientId');

                                // Fetching location details from location name
                                var locationData = await fireStoreService
                                    .getLocationByName(selectedLocatin!, widget.CompanyId);
                                if (locationData.exists) {
                                  var data = locationData.data() as Map<String, dynamic>?;
                                  if (data != null) {
                                    address = data['LocationAddress'];
                                    coordinates = data['LocationCoordinates'] as GeoPoint;
                                    name = data['LocationName'];
                                    locationId = data['LocationId'];

                                    print("Address ${address}");
                                    print("Coordinates ${coordinates}");
                                    print("Latitude: ${coordinates.latitude}");
                                    print("Longitude: ${coordinates.longitude}");
                                  }
                                }

                                print("LocationData ids ${locationData}");
                                var requiredEmp = requiredEmpcontroller.text;
                                print("Number Editing Controller ${requiredEmpcontroller.number}");
                                print("ShiftName ${_ShiftName.text}");
                                print("ShiftDesc ${_Description.text}");

                                if (widget.shiftId.isNotEmpty) {
                                  // Update the existing document
                                  await fireStoreService.updateShift(
                                    widget.shiftId,
                                    selectedGuards,
                                    selectedPosition,
                                    address,
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
                                    _ShiftName.text,
                                    tasks, // Pass the tasks list
                                  );
                                } else {
                                  // Create a new document
                                  String id = await fireStoreService.ScheduleShift(
                                    selectedGuards,
                                    selectedPosition,
                                    address,
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
                                    _ShiftName.text,
                                    tasks, // Pass the tasks list
                                  );
                                  setState(() {
                                    CreatedshiftId = id;
                                  });
                                }

                                setState(() {
                                  Navigator.pop(context);
                                  _addNewTask();
                                });
                                print("Shift Created/Updated");
                              }
                            },
                            backgroundcolor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            borderRadius: 10.r,
                            fontsize: 14.sp,
                          ),
                        ),
                      ],
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
