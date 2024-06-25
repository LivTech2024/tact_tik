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
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:number_editing_controller/number_editing_controller.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/common/widgets/customToast.dart';
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

class CreateScheduleScreen extends StatefulWidget {
  final String GuardId;
  final String GuardName;
  final String GuardImg;
  final String CompanyId;
  final String BranchId;
  final String supervisorEmail;
  final String shiftId;

  CreateScheduleScreen({
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
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  FireStoreService fireStoreService = FireStoreService();

  List selectedGuards = [];
  String compId = "";
  List<TextEditingController> taskControllers = [];
  List<String> PositionValues = [];
  List<String> locationSuggestions = ['Location 1', 'Location 2', 'Location 3'];
  String dropdownValue = 'Other';
  List<String> tittles = [];
  String? selectedClint = 'Client';
  String? selectedBranch = 'Select branch';
  String? selectedLocatin = 'Select Location';
  String? selectedGuard = 'Guard 1';
  List<DateTime> _selectedDates = [];
  String? selectedPosition;
  String? selectedGuardId;
  String? selectedGuardImage;
  String? selectedGuardName;

  List<String> ClintValues = ['Client'];
  List<String> BranchValues = ['Select branch'];
  List<String> LocationValues = ['Select Location'];
  List<String> PatrolValues = [];
  List<String> selectedPatrols = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> guards = [];
  String? selectedPatrol;
  PageController _pageController = PageController(
    initialPage: 0,
  );

  // ValueItem<String>(label: 'Patrol 1', value: 'Patrol 1'),
  // ValueItem<String>(label: 'Patrol 2', value: 'Patrol 2'),
  // ValueItem<String>(label: 'Patrol 3', value: 'Patrol 3'),
  List<String> patrolItems = [];
  List<String> options = [];

  // print(patrol);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getEmployeeRoles();
    getAllClientNames();
    getAllPatrolNames();
    getAllLocationNames();
    initializeData();
    // _addNewTask();
    if (widget.GuardId.isNotEmpty || widget.GuardName.isNotEmpty) {
      setState(() {
        selectedGuards.add({
          'GuardId': widget.GuardId,
          'GuardName': widget.GuardName ?? '',
          'GuardImg': widget.GuardImg ?? '',
        });
      });
    }
  }

  void initializeData() async {
    await fetchShiftDataAndUpdateGuards();
  }

  Future<void> fetchShiftDataAndUpdateGuards() async {
    final shiftData = await fetchShiftData();

    if (shiftData != null) {
      if (shiftData.containsKey('ShiftAssignedUserId')) {
        List<String> assignedUserIds =
            List<String>.from(shiftData['ShiftAssignedUserId']);

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
          selectedLocatin =
              locationSnapshot.data()?['LocationName'] ?? 'Select Location';
        });
      }
    }

    _ShiftName.text = shiftData['ShiftName'] ?? '';
    requiredEmpcontroller.value = shiftData['ShiftRequiredEmp'] ?? '';
    _Description.text = shiftData['ShiftDescription'] ?? 0;
    requiredRadius.value = shiftData['ShiftRestrictedRadius'] ?? 0;
    _PhotoUploadIntervalInMinutes.value =
        shiftData['ShiftPhotoUploadIntervalInMinutes'] ?? 0;
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
    try {
      print("Fetching patrol items...");
      List<String> patrolNames =
          await fireStoreService.getAllPatrolName(widget.CompanyId);
      print("Fetched Patrol Names: $patrolNames");

      if (patrolNames.isNotEmpty) {
        setState(() {
          options = patrolNames;

          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching patrol names: $e");

      setState(() {
        isLoading = false;
      });
    }

    // patrolItems.forEach((item) => print("Patrol Item: ${item.label}"));
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
  List<String> _selectedOptions = [];
  bool _isRestrictedChecked = false;
  List<DateTime> selectedDates = [];

  List<Map<String, dynamic>> tasks = [
    // {'name': '', 'isQrRequired': false, 'isReturnQrRequired': false}
  ];
  List<Map<int, String>> PatrolList = [];
  MultiSelectController _Patrollcontroller = MultiSelectController();

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
                        color: Theme.of(context).textTheme.bodySmall!.color),
                    // Use primary color here
                    selectionShape: DateRangePickerSelectionShape.circle,
                    selectionColor:
                        Theme.of(context).textTheme.bodySmall!.color,
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
              primary:
                  Theme.of(context).primaryColor, // Change primary color to red
              secondary: Theme.of(context).primaryColor,
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
            color: Theme.of(context)
                .textTheme
                .bodyLarge!
                .color, // Change text color to white
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
      taskControllers.add(TextEditingController());
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
        // .where('EmployeeRole', isEqualTo: 'GUARD')
        .where('EmployeeCompanyId', isEqualTo: widget.CompanyId)
        .where('EmployeeNameSearchIndex', arrayContains: query)
        .get();

    setState(() {
      guards = result.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> callPdfApi(String base64Image) async {
    final url =
        Uri.parse('https://backend-sceurity-app.onrender.com/api/html_to_pdf');

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
      print(
          'Failed to call API: ${response.statusCode}, ${response.reasonPhrase}');
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

  void CreateShiftFunction() async {
    try {
      String address = "";
      GeoPoint coordinates = GeoPoint(0, 0);
      String name = "";
      String locationId = "";

      List<String> patrolids =
          await fireStoreService.getPatrolIdsFromNames(selectedPatrols);

      String clientId =
          await fireStoreService.getClientIdfromName(selectedClint!);
      print('ClientName: $selectedClint');
      print('ClientId: $clientId');

      var locationData = await fireStoreService.getLocationByName(
          selectedLocatin!, widget.CompanyId);
      if (locationData.exists) {
        var data = locationData.data() as Map<String, dynamic>?;
        if (data != null) {
          address = data['LocationAddress'];
          coordinates = data['LocationCoordinates'] as GeoPoint;
          name = data['LocationName'];
          locationId = data['LocationId'];

          print("Address $address");
          print("Coordinates $coordinates");
          print("Latitude: ${coordinates.latitude}");
          print("Longitude: ${coordinates.longitude}");
        }
      }
      String id = await fireStoreService.ScheduleShift(
        selectedGuards,
        selectedPosition,
        address,
        "CompanyBranchId",
        widget.CompanyId,
        _selectedDates,
        startTime,
        endTime,
        AsignedPatrol,
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
        tasks,
      );
      if (id.isNotEmpty) {
        setState(() {
          // Navigator.pop(context);
          // _addNewTask();
          CreatedshiftId = id;
        });
        showSuccessToast(context, "Shift created successfully");
      }
    } catch (e) {
      showErrorToast(context, "Error creating shift");
    }
  }

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

  List<Color> colors = [
    themeManager.themeMode == ThemeMode.dark
        ? DarkColor.color1
        : LightColor.color3,
    themeManager.themeMode == ThemeMode.dark
        ? DarkColor.color25
        : LightColor.color2,
  ];

  final NumberEditingTextController _textController =
      NumberEditingTextController.integer();
  String? _selectedOption;

  // List<String> options = [];

  //
  List<Map<dynamic, dynamic>> AsignedPatrol = [];

  void _showInputDialog(BuildContext context, List<String> options) {
    // final TextEditingController _textController = TextEditingController();
    // String _selectedOption;
    // List<String> options = ['Option 1', 'Option 2', 'Option 3'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: InterBold(
            text: 'Assign new patrol',
            fontsize: 16.sp,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60.h,
                width: double.maxFinite,
                // padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  // color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? DarkColor.color12
                          : LightColor.color3,
                    ),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: InterMedium(
                      text: 'Select an option',
                      color: Theme.of(context).highlightColor,
                      fontsize: 14.sp,
                    ),
                    value: _selectedOption,
                    onChanged: (newValue) {
                      _selectedOption = newValue!;
                      (context as Element).markNeedsBuild();
                    },
                    items: options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: InterMedium(
                          text: option,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                          fontsize: 14.sp,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SetDetailsWidget(
                keyboardType: TextInputType.number,
                useTextField: true,
                hintText: 'Enter count',
                icon: Icons.numbers,
                controller: _textController,
                onTap: () {},
              ),
              /*TextField(
                controller: _textController,
                decoration: InputDecoration(
                    labelText: 'Enter text',
                    labelStyle: TextStyle(
                      color: Theme.of(context).highlightColor,
                      fontSize: 16.sp,
                    )),
              ),*/
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: InterMedium(
                text: 'Cancel',
                color: Theme.of(context).highlightColor,
                fontsize: 14.sp,
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_selectedOption != null &&
                    _textController.text.isNotEmpty) {
                  final patrolId =
                      await fireStoreService.fetchPatrolId(_selectedOption!);
                  if (patrolId != null) {
                    setState(() {
                      AsignedPatrol.add({
                        "LinkedPatrolId": patrolId,
                        "LinkedPatrolName": _selectedOption,
                        "LinkedPatrolReqHitCount":
                            int.tryParse(_textController.text) ?? 0,
                      });
                    });
                    // Navigator.of(context).pop();
                  } else {
                    // Handle case where PatrolId is not found
                    print('Patrol ID not found');
                  }
                }
                // Handle save action
                // AsignedPatrol.add({
                //   "patrol": _selectedOption,
                //   "count": _textController.number
                // });
                // setState(() {});
                // print('Selected option: $_selectedOption');
                // print('Entered text: ${_textController.text}');
                Navigator.of(context).pop();
              },
              child: InterMedium(
                text: 'Save',
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontsize: 14.sp,
              ),
            ),
          ],
        );
      },
    );
  }

  int currentPage = 0;

  void NextPage() {
    setState(() {
      _pageController.animateToPage(1,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  void PreviousPage() {
    setState(() {
      _pageController.animateToPage(0,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    int requiredEmp = 0;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              if (currentPage != 1) {
                Navigator.of(context).pop();
              } else {
                PreviousPage();
              }
            },
          ),
          title: InterMedium(
            text: 'Create Schedule',
          ),
          centerTitle: true,
        ),
        body: PageView(
          controller: _pageController,
          children: [
            Scaffold(
              body: SingleChildScrollView(
                // physics: PageScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InterBold(
                            text: 'Select Guards',
                            fontsize: 16.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                                          bool guardExists = selectedGuards.any(
                                              (guard) =>
                                                  guard['GuardId'] ==
                                                  value['id']);

                                          if (guardExists) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text('Guard already added'),
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
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        height: 64.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              blurRadius: 5,
                              spreadRadius: 2,
                              offset: Offset(0, 3),
                            )
                          ],
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (query) {
                                  searchGuards(query);
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
                                  hintStyle: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 18.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                  hintText: 'Search Guard',
                                  contentPadding: EdgeInsets.zero,
                                ),
                                cursorColor: Theme.of(context).primaryColor,
                              ),
                            ),
                            Container(
                              height: 44.h,
                              width: 44.w,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.search,
                                  size: 20.w,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
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
                                _searchController.text = guard['EmployeeName'];
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
                      selectedGuards.isNotEmpty
                          ? Container(
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
                                    padding: EdgeInsets.only(right: 20.h),
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
                                                      color: Theme.of(context)
                                                          .primaryColor,
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
                                          color: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .color,
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 30.h,
                      ),
                      InterBold(
                        text: 'Set Details',
                        fontsize: 16.sp,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
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
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          // color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? DarkColor.color12
                                  : LightColor.color3,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            iconSize: 24.w,
                            icon: Icon(Icons.arrow_drop_down),
                            iconEnabledColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            // Set icon color for enabled state
                            dropdownColor: Theme.of(context).cardColor,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                            value: selectedPosition,
                            hint: Text("Select Roles",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color)),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPosition = newValue;
                                // print('$selectedValue selected');
                              });
                            },
                            items: PositionValues.map<DropdownMenuItem<String>>(
                                (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    selectedPosition == value
                                        ? Icon(Icons.control_camera,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color)
                                        : Icon(Icons.control_camera,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
                                    // Conditional icon color based on selection
                                    SizedBox(width: 10.w),
                                    InterRegular(
                                        text: value,
                                        color: selectedPosition == value
                                            ? Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
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
                          InterMedium(
                            text: 'Selected dates: ',
                            color: Theme.of(context).textTheme.bodySmall!.color,
                            fontsize: 14.sp,
                          ),
                          if (_selectedDates != null)
                            for (var date in _selectedDates)
                              Flexible(
                                child: InterMedium(
                                  text: '${DateFormat('d').format(date)},',
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                  fontsize: 14.sp,
                                ),
                              ),
                        ],
                      ),

                      // Seperate Time
                      SetDetailsWidget(
                        hintText: startTime != null
                            ? '${startTime!.format(context)}'
                            : 'Start Time',
                        icon: Icons.access_time_rounded,
                        onTap: () => _selectTime(context, true),
                      ),
                      SetDetailsWidget(
                        hintText: endTime != null
                            ? '${endTime!.format(context)}'
                            : 'End Time',
                        icon: Icons.access_time_rounded,
                        onTap: () => _selectTime(context, false),
                      ),

                      // Location DropDown
                      Container(
                        height: 60.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          // color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? DarkColor.color12
                                  : LightColor.color3,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            iconSize: 24.w,
                            icon: Icon(Icons.arrow_drop_down, size: 24.w),
                            iconEnabledColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            // Set icon color for enabled state
                            dropdownColor: Theme.of(context).cardColor,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                            value: selectedLocatin,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedLocatin = newValue!;
                                // print('$selectedValue selected');
                              });
                            },
                            items: LocationValues.map<DropdownMenuItem<String>>(
                                (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    selectedLocatin == value
                                        ? Icon(Icons.location_on,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color)
                                        : Icon(Icons.location_on,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
                                    // Conditional icon color based on selection
                                    SizedBox(width: 10.w),
                                    InterRegular(
                                        text: value,
                                        color: selectedLocatin == value
                                            ? Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
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
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          // color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10.w),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? DarkColor.color12
                                  : LightColor.color3,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            iconSize: 24.w,
                            icon: Icon(Icons.arrow_drop_down),
                            iconEnabledColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            // Set icon color for enabled state
                            dropdownColor: Theme.of(context).cardColor,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                            value: selectedClint,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedClint = newValue!;
                                print('$selectedClint selected');
                              });
                            },
                            items: ClintValues.map<DropdownMenuItem<String>>(
                                (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    selectedClint == value
                                        ? Icon(Icons.account_circle_outlined,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color)
                                        : Icon(Icons.account_circle_outlined,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
                                    // Conditional icon color based on selection
                                    SizedBox(width: 10.w),
                                    InterRegular(
                                        text: value,
                                        color: selectedClint == value
                                            ? Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
                                    // Conditional text color based on selection
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: 100.w,
                        child: Button1(
                          borderRadius: 10.r,
                          backgroundcolor: Theme.of(context).primaryColor,
                          height: 40.h,
                          color: Colors.white,
                          onPressed: () {
                            _showInputDialog(context, options);
                          },
                          text: 'patrol asign',
                          fontsize: 14.sp,
                        ),
                      ),

                      AsignedPatrol.length != null
                          ? Container(
                              margin: EdgeInsets.only(top: 10.h),
                              height: 40.h,
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: AsignedPatrol.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) => Container(
                                  margin: EdgeInsets.only(right: 10.w),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius:
                                          BorderRadius.circular(10.r)),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  height: 20.h,
                                  // width: 100,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InterMedium(
                                          text:
                                              '${AsignedPatrol[index]['LinkedPatrolName']},${AsignedPatrol[index]['LinkedPatrolReqHitCount']}'),
                                      IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            print("delete Patrol clicked");
                                            setState(() {
                                              AsignedPatrol.remove(index);
                                            });
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),

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
                              borderRadius: BorderRadius.circular(10.w),
                              border: Border(
                                bottom: BorderSide(
                                  color: DarkColor.color19,
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
                                        color: DarkColor.color2,
                                      ),
                                      hintText:
                                          '${_selectedOptions[index]} Hit Count',
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    cursorColor: DarkColor.Primarycolor,
                                    onSubmitted: (value) {
                                      setState(() {
                                        PatrolList[index][0] = value;
                                        PatrolList[index][1] =
                                            _selectedOptions[index]!;
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
                            activeColor: Theme.of(context).primaryColor,
                            checkColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ],
                      ),

                      /* SetDetailsWidget(
                        useTextField: true,
                        hintText: 'Branch(Optional)',
                        icon: Icons.apartment,
                        controller: _Branch,
                        onTap: () {},
                      ),*/
                      Container(
                        height: 60.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          // color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10.w),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? DarkColor.color12
                                  : LightColor.color3,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            iconSize: 24.w,
                            icon: Icon(Icons.arrow_drop_down),
                            iconEnabledColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            // Set icon color for enabled state
                            dropdownColor: Theme.of(context).cardColor,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                            value: selectedBranch,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedBranch = newValue!;
                                print('$selectedClint selected');
                              });
                            },
                            items: BranchValues.map<DropdownMenuItem<String>>(
                                (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    selectedBranch == value
                                        ? Icon(Icons.apartment,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color)
                                        : Icon(Icons.apartment,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
                                    // Conditional icon color based on selection
                                    SizedBox(width: 10.w),
                                    InterRegular(
                                      text: value,
                                      color: selectedBranch == value
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color,
                                    ),
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
                            // CreateShiftFunction();
                            setState(() {
                              NextPage();
                              nextScreen = !nextScreen;
                            });
                          } else {
                            String errorMessage =
                                "Please fill in the following required fields:";
                            if (selectedClint == null) {
                              errorMessage += "\n- Client";
                            }
                            if (selectedLocatin == null) {
                              errorMessage += "\n- Location";
                            }
                            if (requiredEmpcontroller.text.isEmpty) {
                              errorMessage +=
                                  "\n- Required Number of Employees";
                            }
                            if (_ShiftName.text.isEmpty) {
                              errorMessage += "\n- Shift Name";
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorMessage)));
                            print(errorMessage);
                          }
                        },
                        backgroundcolor: Theme.of(context).primaryColor,
                        color: Colors.white,
                        borderRadius: 10.r,
                        fontsize: 14.sp,
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tasks.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            String taskName = tasks[index]['name'];
                            bool isChecked =
                                tasks[index]['isQrRequired'] ?? false;
                            bool isReturnChecked =
                                tasks[index]['isReturnQrRequired'] ?? false;

                            return Column(
                              children: [
                                ListTile(
                                  title: Container(
                                    height: 50.h,
                                    padding: EdgeInsets.only(left: 10.w),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).shadowColor,
                                          blurRadius: 5,
                                          spreadRadius: 2,
                                          offset: Offset(0, 3),
                                        )
                                      ],
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: taskControllers.isNotEmpty
                                        ? TextField(
                                            controller: taskControllers[index],
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
                                              hintStyle: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 18.sp,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color,
                                              ),
                                              hintText: 'Task ${index + 1}',
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            cursorColor: Colors.red,
                                            onChanged: (value) {
                                              setState(() {
                                                tasks[index]['name'] = value;
                                              });
                                              print("textfield value $value");
                                            },
                                          )
                                        : SizedBox(),
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
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      checkColor: Colors.white,
                                      value: isChecked,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          tasks[index]['isQrRequired'] =
                                              value ?? false;
                                        });
                                      },
                                    ),
                                    Text(
                                      'QR Code Required',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Checkbox(
                                      activeColor: Colors.red,
                                      checkColor: Colors.black,
                                      value: isReturnChecked,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          tasks[index]['isReturnQrRequired'] =
                                              value ?? false;
                                        });
                                      },
                                    ),
                                    Text(
                                      'Return Required',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                // Button1(
                                //   height: 50.h,
                                //   borderRadius: 10.w,
                                //   backgroundcolor:
                                //       Theme.of(context).brightness ==
                                //               Brightness.dark
                                //           ? DarkColor.color33
                                //           : LightColor.WidgetColor,
                                //   color: Theme.of(context)
                                //       .textTheme
                                //       .headlineMedium!
                                //       .color,
                                //   text: "Generate Qr",
                                //   onPressed: () async {
                                //     final name =
                                //         taskControllers[index].text;
                                //     _saveQrCode(name);
                                //     print('Generate QR Button Pressed');
                                //   },
                                // ),
                              ],
                            );
                          },
                        )
                      else
                        Text('No tasks available.'),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: 120.w,
                        child: Button1(
                          borderRadius: 10.r,
                          onPressed: () {
                            print("Tasks ${tasks}");
                            _addNewTask();
                          },
                          height: 50.h,
                          backgroundcolor: Theme.of(context).cardColor,
                          text: nextScreen == false
                              ? 'Create Shift Task'
                              : 'Create Task',
                          color:
                              Theme.of(context).textTheme.headlineMedium!.color,
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

                                  List<String> patrolids =
                                      await fireStoreService
                                          .getPatrolIdsFromNames(
                                              selectedPatrols);

                                  String clientId = await fireStoreService
                                      .getClientIdfromName(selectedClint!);
                                  print('ClientName: $selectedClint');
                                  print('ClientId: $clientId');

                                  var locationData =
                                      await fireStoreService.getLocationByName(
                                          selectedLocatin!, widget.CompanyId);
                                  if (locationData.exists) {
                                    var data = locationData.data()
                                        as Map<String, dynamic>?;
                                    if (data != null) {
                                      address = data['LocationAddress'];
                                      coordinates = data['LocationCoordinates']
                                          as GeoPoint;
                                      name = data['LocationName'];
                                      locationId = data['LocationId'];

                                      print("Address $address");
                                      print("Coordinates $coordinates");
                                      print(
                                          "Latitude: ${coordinates.latitude}");
                                      print(
                                          "Longitude: ${coordinates.longitude}");
                                    }
                                  }

                                  print("LocationData ids $locationData");
                                  var requiredEmp = requiredEmpcontroller.text;
                                  print(
                                      "Number Editing Controller ${requiredEmpcontroller.number}");
                                  print("ShiftName ${_ShiftName.text}");
                                  print("ShiftDesc ${_Description.text}");
                                  print("Patrol ${AsignedPatrol}");

                                  if (widget.shiftId.isNotEmpty) {
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
                                      AsignedPatrol,
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
                                      tasks,
                                    );
                                  } else {
                                    String id =
                                        await fireStoreService.ScheduleShift(
                                      selectedGuards,
                                      selectedPosition,
                                      address,
                                      "CompanyBranchId",
                                      widget.CompanyId,
                                      _selectedDates,
                                      startTime,
                                      endTime,
                                      AsignedPatrol,
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
                                      tasks,
                                    );
                                    setState(() {
                                      CreatedshiftId = id;
                                    });
                                  }

                                  // setState(() {
                                  //   _addNewTask();
                                  // });
                                  // Navigator.pop
                                  Navigator.pop(context);
                                  print("Shift Created/Updated");
                                }
                              },
                              backgroundcolor: Theme.of(context).primaryColor,
                              color: Colors.white,
                              borderRadius: 10.r,
                              fontsize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
          onPageChanged: (int page) {
            currentPage = page;
            print("Current Page: " + page.toString());
          },
        ),
      ),
    );
  }
}

class ChipItem {
  final String label;
  final int value;

  ChipItem(this.label, this.value);

  @override
  String toString() {
    return '$label ($value)';
  }
}

final List<ChipItem> mockResults = [
  ChipItem('Alice', 1),
  ChipItem('Bob', 2),
  ChipItem('Charlie', 3),
  ChipItem('David', 4),
  ChipItem('Eve', 5),
];
