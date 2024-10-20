import 'dart:convert';
import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/login_screen.dart';
import 'package:tact_tik/screens/client%20screens/DAR/client_dar.dart';
import 'package:tact_tik/screens/client%20screens/patrol/client_check_patrol_screen.dart';
import 'package:tact_tik/screens/client%20screens/patrol/client_open_patrol_screen.dart';
import 'package:tact_tik/screens/client%20screens/select_client_guards_screen.dart';
import 'package:tact_tik/screens/client%20screens/select_location_schift.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/message%20screens/super_inbox.dart';
import '../../fonts/inter_bold.dart';
import '../../fonts/inter_medium.dart';
import '../../fonts/inter_regular.dart';
import '../../fonts/inter_semibold.dart';
import '../../fonts/poppins_bold.dart';
import '../../fonts/poppins_regular.dart';
import '../../fonts/poppis_semibold.dart';
import '../../services/auth/auth.dart';
import '../../services/firebaseFunctions/firebase_function.dart';
import '../../utils/colors.dart';
import '../SideBar Screens/employment_letter.dart';
import '../SideBar Screens/history_screen.dart';
import '../SideBar Screens/profile_screen.dart';
import '../home screens/widgets/grid_widget.dart';
import '../home screens/widgets/home_screen_part1.dart';
import '../home screens/widgets/homescreen_custom_navigation.dart';
import '../message screen/message_screen.dart';
import 'DAR/select_location_dar.dart';
import 'Reports/client_oprn_report.dart';
import 'Reports/client_report_screen.dart';
import 'package:http/http.dart' as http;

import 'client_profile_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final Auth auth = Auth();
  String _userName = "";
  String employeeImg = "";
  String _ShiftDate = "";
  String _ShiftLocation = "";
  String _ShiftLocationName = "";

  String _ShiftName = "";
  String _ShiftEndTime = "";
  String _ShiftStartTime = "";
  String? _ShiftCompanyId = "";
  String _ShiftBranchId = "";
  String _shiftCLientId = "";
  double _shiftLatitude = 0;
  double _shiftLongitude = 0;
  String _employeeId = "";
  String _shiftLocationId = "";
  String _shiftId = "";
  String _empEmail = "";
  String _branchId = "";
  String _cmpId = "";
  String _patrolArea = "";
  String? _currentUserUid;
  String? _employeeName = "";
  String? _employeeEmail = "";
  String? _employeeImageUrl = "";
  String _patrolCompanyId = "";
  bool _patrolKeepGuardInRadiusOfLocation = true;
  bool _shiftKeepGuardInRadiusOfLocation = true;

  String _patrolLocationName = "";
  String _patrolName = "";
  int _patrolRestrictedRadius = 0;
  String _patrolTime = "";
  String _patrolDate = "";
  bool isWithinRadius = true;
  bool issShift = false;
  int _shiftRestrictedRadius = 0;
  int scheduleCount = 0;
  String selectedGuardId = '';
  List<String> selectedLocationAddress = [];
  int ScreenIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKeyClient = GlobalKey();
  List<Map<String, dynamic>> patrolsList = [];
  bool _showWish = true;
  bool NewMessage = false;
  List<Map<String, dynamic>> messages = [];

  Future<void> fetchMessages() async {
    try {
      QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
          .collection('Messages')
          .where('MessageReceiversId',
              arrayContains: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('MessageCreatedAt', descending: true)
          .get();

      Map<String, Map<String, dynamic>> latestMessages = {};

      for (var doc in messageSnapshot.docs) {
        Map<String, dynamic> message = doc.data() as Map<String, dynamic>;

        if (message['MessageType'] != 'message') continue;

        String senderId = message['MessageCreatedById'];

        if (!latestMessages.containsKey(senderId) ||
            (message['MessageCreatedAt'] as Timestamp).toDate().isAfter(
                (latestMessages[senderId]!['MessageCreatedAt'] as Timestamp)
                    .toDate())) {
          DocumentSnapshot employeeSnapshot = await FirebaseFirestore.instance
              .collection('Employees')
              .doc(senderId)
              .get();

          Map<String, dynamic>? employeeData =
              employeeSnapshot.data() as Map<String, dynamic>?;

          latestMessages[senderId] = {
            ...message,
            'EmployeeName': employeeData?['EmployeeName'] ?? 'Unknown',
            'EmployeeImg': employeeData?['EmployeeImg'] ??
                'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
          };
        }
      }

      setState(() {
        messages = latestMessages.values.toList();
      });
      print("MESSAGES: $messages");
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream() {
    return FirebaseFirestore.instance
        .collection('Messages')
        .where('MessageReceiversId',
            arrayContains: FirebaseAuth.instance.currentUser?.uid)
        .orderBy('MessageCreatedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      Map<String, Map<String, dynamic>> latestMessages = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> message = doc.data();

        if (message['MessageType'] != 'message') continue;

        String senderId = message['MessageCreatedById'];

        if (!latestMessages.containsKey(senderId) ||
            (message['MessageCreatedAt'] as Timestamp).toDate().isAfter(
                (latestMessages[senderId]!['MessageCreatedAt'] as Timestamp)
                    .toDate())) {
          DocumentSnapshot employeeSnapshot = await FirebaseFirestore.instance
              .collection('Employees')
              .doc(senderId)
              .get();

          Map<String, dynamic>? employeeData =
              employeeSnapshot.data() as Map<String, dynamic>?;

          latestMessages[senderId] = {
            ...message,
            'EmployeeName': employeeData?['EmployeeName'] ?? 'Unknown',
            'EmployeeImg': employeeData?['EmployeeImg'] ??
                'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
          };
        }
      }

      return latestMessages.values.toList();
    });
  }

  void NavigateScreen(Widget screen, BuildContext context) {
    void NavigateScreen(Widget screen, BuildContext context) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    }
  }

  FireStoreService fireStoreService = FireStoreService();
  final List<DateTime?> selectedDates = [];

  Future<void> _refresh() {
    return Future.delayed(Duration(seconds: 2));
  }

  Future<void> _refreshScreen() async {
    _getUserInfo();
    // _getCurrentUserUid();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    fetchMessages();
  }

  Future<void> _initializeData() async {
    await _getUserInfo();
    fetchShifts();
    fetchReports();
  }

  //TODO IMPLEMENT THIS WITH BUTTON
  //TODO PASTE THIS: generateShiftReportPdf(_userName, fetchedPatrols, shifts[index]['ShiftName'], shifts[index]['ShiftStartTime'], shifts[index]['ShiftEndTime']);
  Future<String> generateShiftReportPdf(
    String? ClientName,
    List<Map<String, dynamic>> Data,
    String GuardName,
    String shiftinTime,
    String shiftOutTime,
  ) async {
    final dateFormat = DateFormat('HH:mm'); // Define the format for time
    String patrolInfoHTML = '';
    for (var item in Data) {
      String checkpointImagesHTML = '';
      for (var checkpoint in item['PatrolLogCheckPoints']) {
        String checkpointImages = '';
        if (checkpoint['CheckPointImage'] != null) {
          for (var image in checkpoint['CheckPointImage']) {
            checkpointImages +=
                '<img src="$image">'; // Set max-width to ensure responsiveness
            // checkpointImages +=
            //     '<p>$image</p>'; // Set max-width to ensure responsiveness
          }
        }
        checkpointImagesHTML += '''
        <div>
          <p>Checkpoint Name: ${checkpoint['CheckPointName']}</p>
          $checkpointImages
          <p>Comment: ${checkpoint['CheckPointComment']}</p>
          <p>Reported At: ${dateFormat.format(checkpoint['CheckPointReportedAt'].toDate())}</p>
          <p>Status: ${checkpoint['CheckPointStatus']}</p>
        </div>
      ''';
      }

      patrolInfoHTML += '''
      <tr>
        <td>${item['PatrolLogPatrolCount']}</td>
        <td>${dateFormat.format(item['PatrolLogStartedAt'].toDate())}</td>
        <td>${dateFormat.format(item['PatrolLogEndedAt'].toDate())}</td>
        <td>${checkpointImagesHTML}</td>
      </tr>
    ''';
    }

    final htmlcontent = """
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        header {
            background-color: #333;
            color: white;
            padding: 20px;
            text-align: center;
        }

        .logo-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .logo-container img {
            max-height: 50px; /* Set the max-height for the logos */
        }

        h1 {
            margin: 0;
            font-size: 24px;
            flex-grow: 1; /* Allow the <h1> to grow and fill the space */
        }

        section {
            padding: 20px;
            background-color: #fff;
            margin-bottom: 20px;
            border-radius: 5px;
        }

        /* Other styles for tables, images, and footer */
        table {
            border-collapse: collapse;
            width: 100%;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }

        th {
            background-color: #f2f2f2;
        }

        img {
            max-width: 100%;
            height: auto;
            display: block;
            margin-bottom: 10px;
            max-height: 200px; /* Define a max-height for the images */
        }

        footer {
            background-color: #333;
            color: white;
            text-align: center;
            padding: 10px 0;
            margin-top: auto; /* Push the footer to the bottom of the page */
        }
    </style>
</head>
<body>
    <header>
        <h1>Security Report</h1>
    </header>

    <section>
        <h2>Dear ${ClientName},</h2>
        <p>I hope this email finds you well. I wanted to provide you with an update on the recent patrol activities carried out by our assigned security guard during their shift. Below is a detailed breakdown of the patrols conducted.</p>
    </section>

    <section>
        <h3>Shift Information</h3>
        <table>
            <tr>
                <th>Guard Name</th>
                <th>Shift Time In</th>
                <th>Shift Time Out</th>
            </tr>
            <tr>
                <td>${GuardName}</td>
                <td>${shiftinTime}</td>
                <td>${shiftOutTime}</td>
            </tr>
        </table>
    </section>

    <section>
        <h3>Patrol Information</h3>
        <table>
            <tr>
                <th>Patrol Count</th>
                <th>Patrol Time In</th>
                <th>Patrol Time Out</th>
                <th>Checkpoint Details</th>
            </tr>
            ${patrolInfoHTML}
        </table>
    </section>

    <section>
        <h3>Comments</h3>
        <table>
            <tr>
                <th>Incident</th>
                <th>Important Note</th>
                <th>Feedback Note</th>
            </tr>
        </table>
    </section>

    <footer>
        <p>&copy; 2024 TEAM TACTTIK. All rights reserved.</p>
    </footer>
</body>
</html>
  """;

    // Generate the PDF
    final pdfResponse = await http.post(
      Uri.parse('https://backend-sceurity-app.onrender.com/api/html_to_pdf'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'html': htmlcontent,
        'file_name': 'security_report.pdf',
      }),
    );

    if (pdfResponse.statusCode == 200) {
      print('PDF generated successfully');
      final pdfBase64 = await base64Encode(pdfResponse.bodyBytes);
      savePdfLocally(pdfBase64, 'security_report.pdf');
      return pdfBase64;
    } else {
      print('Failed to generate PDF. Status code: ${pdfResponse.statusCode}');
      throw Exception('Failed to generate PDF');
    }
  }

  Future<File> savePdfLocally(String pdfBase64, String fileName) async {
    final pdfBytes = base64Decode(pdfBase64);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  void onGuardSelected(String guardId) {
    setState(() {
      selectedGuardId = guardId;
    });
    print('Selected Guard ID: $selectedGuardId');
    fetchShifts();
  }

  void onLocationSelected(List<dynamic> locationAddresses) {
    setState(() {
      selectedLocationAddress = List<String>.from(locationAddresses);
    });
    print('Selected Location Address: $selectedLocationAddress');
    fetchShifts();
  }

  List<Map<String, dynamic>> shifts = [];
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  Future<void> _getUserInfo() async {
    print("Fetching user info");
    var userInfo = await fireStoreService.getClientInfoByCurrentUserEmail();
    if (mounted) {
      if (userInfo != null) {
        String userName = userInfo['ClientName'];
        String EmployeeId = userInfo['ClientId'];
        String empEmail = userInfo['ClientEmail'];
        String empImage = userInfo['ClientHomePageBgImg'] ?? "";
        String companyId = userInfo['ClientCompanyId'];
        print("Employee Id ${EmployeeId}");
        var shiftInfo =
            await fireStoreService.getShiftByEmployeeIdFromUserInfo(EmployeeId);
        var patrolInfo =
            await fireStoreService.getPatrolsByClientId(EmployeeId);
        print("User Info ${userName}");
        print("Patrol Info ${patrolInfo}");

        setState(() {
          _userName = userName;
          _employeeId = EmployeeId;
          _empEmail = empEmail;
          employeeImg = empImage;
          _cmpId = companyId;
        });
        print('User Info: ${userInfo.data()}');
        if (patrolInfo != null) {
          setState(() {
            patrolsList = patrolInfo;
          });
          //   String PatrolArea = patrolInfo['PatrolArea'];
          //   String PatrolCompanyId = patrolInfo['PatrolCompanyId'];
          //   bool PatrolKeepGuardInRadiusOfLocation =
          //       patrolInfo['PatrolKeepGuardInRadiusOfLocation'];
          //   String PatrolLocationName = patrolInfo['PatrolLocationName'];
          //   String PatrolName = patrolInfo['PatrolName'];
          //   int PatrolRestrictedRadius = patrolInfo['PatrolRestrictedRadius'];
          //   Timestamp PatrolTime = patrolInfo['PatrolTime'];
          //   DateTime patrolDateTime = PatrolTime.toDate();

          //   // Format DateTime as String
          //   String patrolTimeString =
          //       DateFormat('hh:mm a').format(patrolDateTime);
          //   String patrolDateString =
          //       DateFormat('yyyy-MM-dd').format(patrolDateTime);
          //   print('Patrol Info: ${patrolInfo.data()}');

          //   setState(() {
          //     _patrolArea = PatrolArea;
          //     _patrolCompanyId = PatrolCompanyId;
          //     _patrolKeepGuardInRadiusOfLocation =
          //         PatrolKeepGuardInRadiusOfLocation;
          //     _patrolLocationName = PatrolLocationName;
          //     _patrolRestrictedRadius = PatrolRestrictedRadius;
          //     // _patrolTime = patrolTimeString;
          //     _patrolDate = patrolDateString;

          //     // issShift = false;
          //   });
        }

        // if (shiftInfo != null) {
        //   String shiftDateStr =
        //       DateFormat.yMMMMd().format(shiftInfo['ShiftDate'].toDate());
        //   String shiftEndTimeStr = shiftInfo['ShiftEndTime'] ?? " ";
        //   String shiftStartTimeStr = shiftInfo['ShiftStartTime'] ?? " ";
        //   String shiftLocation = shiftInfo['ShiftLocationAddress'] ?? " ";
        //   String shiftLocationId = shiftInfo['ShiftLocationId'] ?? " ";
        //   String shiftLocationName = shiftInfo['ShiftLocationName'] ?? " ";

        //   String shiftName = shiftInfo['ShiftName'] ?? " ";
        //   String shiftId = shiftInfo['ShiftId'] ?? " ";
        //   GeoPoint shiftGeolocation = shiftInfo['ShiftLocation'] ?? 0;
        //   double shiftLocationLatitude = shiftGeolocation.latitude;
        //   double shiftLocationLongitude = shiftGeolocation.longitude;
        //   String companyBranchId = shiftInfo["ShiftCompanyBranchId"] ?? " ";
        //   String shiftCompanyId = shiftInfo["ShiftCompanyId"] ?? " ";
        //   String shiftClientId = shiftInfo["ShiftClientId"] ?? " ";

        //   int ShiftRestrictedRadius = shiftInfo["ShiftRestrictedRadius"] ?? 0;
        //   bool shiftKeepUserInRadius = shiftInfo["ShiftEnableRestrictedRadius"];
        //   // String ShiftClientId = shiftInfo['ShiftClientId'];
        //   // EmpEmail: _empEmail,
        //   //                     Branchid: _branchId,
        //   //                     cmpId: _cmpId,
        //   // String employeeImg = shiftInfo['EmployeeImg'];
        //   setState(() {
        //     _ShiftDate = shiftDateStr;
        //     _ShiftEndTime = shiftEndTimeStr;
        //     _ShiftStartTime = shiftStartTimeStr;
        //     _ShiftLocation = shiftLocation;
        //     _ShiftLocationName = shiftLocationName;
        //     _ShiftName = shiftName;
        //     _shiftLatitude = shiftLocationLatitude;
        //     _shiftLongitude = shiftLocationLongitude;
        //     _shiftId = shiftId;
        //     _shiftRestrictedRadius = ShiftRestrictedRadius;
        //     _ShiftCompanyId = shiftCompanyId;
        //     _ShiftBranchId = companyBranchId;
        //     _shiftKeepGuardInRadiusOfLocation = shiftKeepUserInRadius;
        //     _shiftLocationId = shiftLocationId;
        //     _shiftCLientId = shiftClientId;
        //     // _shiftCLientId = ShiftClientId;
        //     // print("Date time parse: ${DateTime.parse(shiftDateStr)}");
        //     DateTime shiftDateTime = DateFormat.yMMMMd().parse(shiftDateStr);
        //     if (!selectedDates
        //         .contains(DateFormat.yMMMMd().parse(shiftDateStr))) {
        //       setState(() {
        //         selectedDates.add(DateFormat.yMMMMd().parse(shiftDateStr));
        //       });
        //     }
        //     if (!selectedDates.any((date) =>
        //         date!.year == shiftDateTime.year &&
        //         date.month == shiftDateTime.month &&
        //         date.day == shiftDateTime.day)) {
        //       setState(() {
        //         selectedDates.add(shiftDateTime);
        //       });
        //     }
        //     // storage.setItem("shiftId", shiftId);
        //     // storage.setItem("EmpId", EmployeeId);

        //     // _employeeImg = employeeImg;
        //   });
        //   print('Shift Info: ${shiftInfo.data()}');

        //   Future<void> printAllSchedules(String empId) async {
        //     var getAllSchedules = await fireStoreService.getAllSchedules(empId);
        //     if (getAllSchedules.isNotEmpty) {
        //       getAllSchedules.forEach((doc) {
        //         var data = doc.data() as Map<String, dynamic>?;
        //         if (data != null && data['ShiftDate'] != null) {
        //           var shiftDate = data['ShiftDate'] as Timestamp;
        //           var date = DateTime.fromMillisecondsSinceEpoch(
        //               shiftDate.seconds * 1000);
        //           var formattedDate = DateFormat('yyyy-MM-dd').format(date);
        //           if (!selectedDates.contains(DateTime.parse(formattedDate))) {
        //             setState(() {
        //               selectedDates.add(DateTime.parse(formattedDate));
        //             });
        //           }
        //           // Format the date
        //           print("ShiftDate: $formattedDate");
        //         }

        //         print(
        //             "All Schedule date : ${doc.data()}"); // Print data of each document
        //       });
        //     } else {
        //       print("No schedules found.");
        //     }
        //   }

        //   printAllSchedules(EmployeeId);
        // } else {
        //   setState(() {
        //     issShift = true; //To validate that shift exists for the user.
        //   });
        //   print('Shift info not found');
        // }
        // getAndPrintAllSchedules();
      } else {
        print('User info not found');
      }
    }
  }

  List<Map<String, dynamic>> fetchedPatrols = [];

  Future<void> fetchShifts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Shifts')
          .where('ShiftClientId', isEqualTo: _employeeId)
          .get();

      List<Map<String, dynamic>> fetchedShifts = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (selectedGuardId.isNotEmpty) {
          List<dynamic> shiftAssignedUserIds = data['ShiftAssignedUserId'];
          if (shiftAssignedUserIds == null ||
              !shiftAssignedUserIds.contains(selectedGuardId)) {
            continue;
          }
        }

        if (selectedLocationAddress.isNotEmpty) {
          var shiftLocationAddress = data['ShiftLocationAddress'] as String?;
          if (!selectedLocationAddress.contains(shiftLocationAddress)) {
            continue;
          }
        }

        List<dynamic> patrols = data['ShiftLinkedPatrols'];
        for (var patrol in patrols) {
          QuerySnapshot patrolSnapshot = await FirebaseFirestore.instance
              .collection('Patrols')
              .where('PatrolId', isEqualTo: patrol['LinkedPatrolId'])
              .get();
          for (var patrolDoc in patrolSnapshot.docs) {
            fetchedPatrols.add(patrolDoc.data() as Map<String, dynamic>);
          }
        }

        fetchedShifts.add({
          'ShiftDate': data['ShiftDate'].toDate(),
          'ShiftName': data['ShiftName'],
          'ShiftLocationAddress': data['ShiftLocationAddress'],
          'ShiftStartTime': data['ShiftStartTime'],
          'ShiftEndTime': data['ShiftEndTime'],
          'members': data['ShiftAssignedUserId'],
          'patrols': fetchedPatrols,
        });
      }

      print("SHIFTS: ${fetchedShifts}");
      print("EMPLOYEE ID: ${_employeeId}");

      setState(() {
        shifts = fetchedShifts;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching shifts: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchReports() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Reports')
          .orderBy('ReportCreatedAt', descending: true)
          .where('ReportClientId', isEqualTo: _employeeId)
          .get();
      List<Map<String, dynamic>> fetchedReports = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'ReportDate': (data['ReportCreatedAt'] != null)
              ? data['ReportCreatedAt'].toDate()
              : DateTime.now(), // default to now if missing or null
          'ReportName': (data['ReportName'] != null &&
                  data['ReportName'].toString().isNotEmpty)
              ? data['ReportName']
              : 'Not Found',
          'ReportGuardName': (data['ReportEmployeeName'] != null &&
                  data['ReportEmployeeName'].toString().isNotEmpty)
              ? data['ReportEmployeeName']
              : 'Not Found',
          'ReportEmployeeName': (data['ReportEmployeeName'] != null &&
                  data['ReportEmployeeName'].toString().isNotEmpty)
              ? data['ReportEmployeeName']
              : 'Not Found',
          'ReportStatus': (data['ReportStatus'] != null &&
                  data['ReportStatus'].toString().isNotEmpty)
              ? data['ReportStatus']
              : 'Not Found',
          'ReportCategory': (data['ReportCategoryName'] != null &&
                  data['ReportCategoryName'].toString().isNotEmpty)
              ? data['ReportCategoryName']
              : 'Not Found',
          'ReportFollowUpRequire': data['ReportIsFollowUpRequired'] ?? false,
          'ReportData': (data['ReportData'] != null &&
                  data['ReportData'].toString().isNotEmpty)
              ? data['ReportData']
              : 'Not Found',
          'ReportLocation': (data['ReportLocationName'] != null &&
                  data['ReportLocationName'].toString().isNotEmpty)
              ? data['ReportLocationName']
              : 'Not Found',
        };
      }).toList();

      setState(() {
        reports = fetchedReports;
        isLoading = false;
      });
      print("REPORT DATA HERE IT'S  :$reports");
    } catch (e) {
      print("Error fetching reports: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  List IconColors = [
    ThemeMode.dark == themeManager.themeMode
        ? DarkColor.color1
        : LightColor.Primarycolor,
    ThemeMode.dark == themeManager.themeMode
        ? DarkColor.color3
        : LightColor.color2,
    ThemeMode.dark == themeManager.themeMode
        ? DarkColor.color3
        : LightColor.color2,
    ThemeMode.dark == themeManager.themeMode
        ? DarkColor.color3
        : LightColor.color2,
  ];

  // 12 datani mall shift start id A local stoarage
  // 2 capital mall

/*  void getAndPrintAllSchedules() async {
    List<DocumentSnapshot> schedules =
    await fireStoreService.getAllSchedules(_employeeId);
    print("All Schedules:");
    schedules.forEach((schedule) {
      if (!schedules_list.any((element) => element.id == schedule.id)) {
        setState(() {
          schedules_list.add(schedule);
        });
      }
      print(
          "Schedule docs ${schedule
              .data()}"); // Print the data of each document
    });
  }*/

  Future<void> _refreshData() async {
    // Fetch patrol data from Firestore (assuming your logic exists)
    _getUserInfo();
    // getAndPrintAllSchedules();
    fetchMessages();
  }

  final List<String> members = [
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
  ];

  int _selectedIndex = 0; // Index of the selected screen

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    setState(() {
      if (picked != null) {
        selectedDate = picked;
        // fetchDARData();  // Fetch data for the selected date
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    void ChangeIconColor(int index) {
      setState(() {
        switch (index) {
          case 0:
            IconColors[0] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color1
                : LightColor.Primarycolor;
            IconColors[1] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            IconColors[2] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            IconColors[3] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            break;
          case 1:
            IconColors[0] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            IconColors[1] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color1
                : LightColor.Primarycolor;
            IconColors[2] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            IconColors[3] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            break;
          case 2:
            IconColors[0] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            IconColors[1] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            IconColors[2] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color1
                : LightColor.Primarycolor;
            IconColors[3] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            break;
          case 3:
            IconColors[0] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            IconColors[1] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            IconColors[2] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color3
                : LightColor.color2;
            IconColors[3] = ThemeMode.dark == themeManager.themeMode
                ? DarkColor.color1
                : LightColor.Primarycolor;
            break;
        }
      });
    }

    void ChangeScreenIndex(int index) {
      setState(() {
        ScreenIndex = index;
        ChangeIconColor(index);
        print(ScreenIndex);
        // if (index == 1) {
        //   _showWish = false;
        // } else
        //   _showWish = true;
      });
    }

    ListTile buildListTile(
        IconData icon, String title, int index, VoidCallback onPressed,
        {bool isLogout = false}) {
      final bool isSelected = _selectedIndex == index;

      return ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .color, // Change color based on selection
          size: 24.w,
        ),
        title: PoppinsBold(
          text: title,
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.headlineSmall!.color,
          fontsize: 14.sp,
        ),
        onTap: onPressed,
      );
    }

    final List<List<String>> data = [
      ['assets/images/dar.png', 'DAR'],
      ['assets/images/reports.png', 'Reports'],
      // ['assets/images/default.png', 'Patrol'],
    ];

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKeyClient, // Assign the GlobalKey to the Scaffold
        endDrawer: Drawer(
          backgroundColor: Theme.of(context).canvasColor,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (_employeeId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          isClient: true,
                          empId: _employeeId,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  height: 180.h,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    color: Theme.of(context)
                        .primaryColor, // Background color for the drawer header
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: SizedBox.fromSize(
                                size: Size.fromRadius(
                                    Platform.isIOS ? 40.r : 50.r),
                                child: Image.network(
                                  employeeImg!,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        PoppinsSemibold(
                          text: _userName,
                          color: Theme.of(context).cardColor,
                          fontsize: 16.sp,
                          letterSpacing: -.3,
                        ),
                        SizedBox(height: 5.h),
                        PoppinsRegular(
                          text: _empEmail,
                          color: Theme.of(context).cardColor,
                          fontsize: 16.sp,
                          letterSpacing: -.3,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    buildListTile(
                      Icons.account_circle_outlined,
                      'Profile',
                      1,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              empId: _employeeId,
                              isClient: true,
                            ),
                          ),
                        );
                      },
                    ),
                    buildListTile(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.light_mode_outlined
                            : Icons.light_mode,
                        Theme.of(context).brightness == Brightness.dark
                            ? 'Switch To Light Mode'
                            : 'Switch to dark mode',
                        5, () {
                      setState(() {
                        themeManager.toggleTheme();
                        // await prefs.setBool('Theme', isDark);
                        // SystemChannels.platform.invokeMethod(
                        //     'SystemNavigator.pop');
                      });
                    }),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 24.sp,
                ),
                title: PoppinsBold(
                  text: 'Logout',
                  color: Colors.red,
                  fontsize: 14.sp,
                ),
                onTap: () {
                  auth.signOut(context, LoginScreen(), _employeeId);
                },
              ),
              SizedBox(height: 20.h)
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: 30.h,
          ),
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: HomeScreenPart1(
                    userName: _userName,
                    employeeImg: employeeImg,
                    empId: _employeeId,
                    branchId: _branchId,
                    empEmail: _employeeEmail,
                    shiftClientId: _shiftCLientId,
                    shiftCompanyId: '',
                    shiftId: _shiftId,
                    shiftLocationId: _shiftLocationId,
                    shiftLocationName: '',
                    showWish: _showWish,
                    drawerOnClicked: () {
                      _scaffoldKeyClient.currentState?.openEndDrawer();
                    },
                    isClient: true,
                    isEmployee: false,
                    Role: '',
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 30.w,
                      right: 30.w,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Bounce(
                              onTap: () => ChangeScreenIndex(0),
                              child: HomeScreenCustomNavigation(
                                text: 'Patrol',
                                icon: Icons.map,
                                color: ScreenIndex == 0
                                    ? ThemeMode.dark == themeManager.themeMode
                                        ? DarkColor.color1
                                        : LightColor.Primarycolor
                                    : Theme.of(context).focusColor,
                                textcolor: ScreenIndex == 0
                                    ? ThemeMode.dark == themeManager.themeMode
                                        ? DarkColor.color1
                                        : LightColor.Primarycolor
                                    : Theme.of(context).focusColor,
                              ),
                            ),
                            Bounce(
                              onTap: () => ChangeScreenIndex(1),
                              child: HomeScreenCustomNavigation(
                                text: 'Shifts',
                                icon: Icons.add_task,
                                color: ScreenIndex == 1
                                    ? ThemeMode.dark == themeManager.themeMode
                                        ? DarkColor.color1
                                        : LightColor.Primarycolor
                                    : Theme.of(context).focusColor,
                                textcolor: ScreenIndex == 1
                                    ? ThemeMode.dark == themeManager.themeMode
                                        ? DarkColor.color1
                                        : LightColor.Primarycolor
                                    : Theme.of(context).focusColor,
                              ),
                            ),
                            Bounce(
                              onTap: () => ChangeScreenIndex(2),
                              child: HomeScreenCustomNavigation(
                                text: 'Explore',
                                icon: Icons.grid_view_rounded,
                                color: ScreenIndex == 2
                                    ? ThemeMode.dark == themeManager.themeMode
                                        ? DarkColor.color1
                                        : LightColor.Primarycolor
                                    : Theme.of(context).focusColor,
                                textcolor: ScreenIndex == 2
                                    ? ThemeMode.dark == themeManager.themeMode
                                        ? DarkColor.color1
                                        : LightColor.Primarycolor
                                    : Theme.of(context).focusColor,
                              ),
                            ),
                            Bounce(
                              onTap: () => ChangeScreenIndex(3),
                              child: HomeScreenCustomNavigation(
                                useSVG: true,
                                SVG: NewMessage
                                    ? ScreenIndex == 3
                                        ? 'assets/images/message_dot.svg'
                                        : 'assets/images/no_message_dot.svg'
                                    : ScreenIndex == 3
                                        ? 'assets/images/message.svg'
                                        : 'assets/images/no_message.svg',
                                text: 'Message',
                                icon: Icons.chat_bubble_outline,
                                color: ScreenIndex == 3
                                    ? ThemeMode.dark == themeManager.themeMode
                                        ? DarkColor.color1
                                        : LightColor.Primarycolor
                                    : Theme.of(context).focusColor,
                                textcolor: ScreenIndex == 3
                                    ? ThemeMode.dark == themeManager.themeMode
                                        ? DarkColor.color1
                                        : LightColor.Primarycolor
                                    : Theme.of(context).focusColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h)
                      ],
                    ),
                  ),
                ),
                ScreenIndex == 0
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            var Patrol = patrolsList[index];
                            String PatrolName = Patrol['PatrolName'];
                            String PatrolId = Patrol['PatrolId'];
                            String PatrolLocation =
                                Patrol['PatrolLocationName'];
                            List<dynamic> PatrolCheckpoint =
                                Patrol['PatrolCheckPoints'];
                            int CheckpointCount = PatrolCheckpoint.length;
                            String guardStatus = "";
                            // String reqCount = Patrol['PatrolRequiredCount'];

                            return Padding(
                              padding: EdgeInsets.only(
                                left: 30.w,
                                right: 30.w,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  print("Clicked");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ClientCheckPatrolScreen(
                                                companyId: _cmpId,
                                                PatrolIdl: PatrolId,
                                                ScreenName: PatrolName,
                                              )));
                                },
                                child: Container(
                                  height: 100.h,
                                  margin: EdgeInsets.only(top: 10.h),
                                  width: double.maxFinite,
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
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  padding: EdgeInsets.only(
                                      top: 20.h, bottom: 20.h, right: 20.w),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 30.h,
                                                width: 4.w,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight: Radius.circular(
                                                      10.r,
                                                    ),
                                                    bottomRight:
                                                        Radius.circular(
                                                      10.r,
                                                    ),
                                                  ),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              SizedBox(width: 14.w),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  InterSemibold(
                                                    text: PatrolName ?? "",
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color,
                                                    fontsize: 14.sp,
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  SizedBox(
                                                    width: 200.w,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // TODO : Add location svg
                                                        SvgPicture.asset(
                                                          'assets/images/location_icon.svg',
                                                          height: 20.h,
                                                        ),
                                                        SizedBox(width: 5.w),
                                                        Flexible(
                                                          child: InterRegular(
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .color,
                                                            text:
                                                                PatrolLocation,
                                                            maxLines: 2,
                                                            fontsize: 14.sp,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InterRegular(
                                                  text: 'CheckPoints',
                                                  fontsize: 14.sp,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color,
                                                ),
                                                SizedBox(height: 10.h),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.qr_code,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: 24.sp,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    InterMedium(
                                                      text: CheckpointCount
                                                          .toString(),
                                                      fontsize: 13.sp,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .color,
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: patrolsList.length,
                        ),
                      )
                    : ScreenIndex == 1
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _selectDate(context),
                                        child: SizedBox(
                                          width: 140.w,
                                          child: IconTextWidget(
                                            icon: Icons.calendar_today,
                                            text: selectedDate != null
                                                ? "${selectedDate!.toLocal()}"
                                                    .split(' ')[0]
                                                : 'Select Date',
                                            fontsize: 14.sp,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color as Color,
                                            Iconcolor: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color as Color,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              SelectLocationShift
                                                  .showLocationDialog(
                                                context,
                                                _cmpId,
                                                onLocationSelected,
                                              );
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 80.w,
                                                  child: IconTextWidget(
                                                    space: 6.w,
                                                    icon: Icons.add,
                                                    iconSize: 20.sp,
                                                    text: 'Select',
                                                    useBold: true,
                                                    fontsize: 14.sp,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .color as Color,
                                                    Iconcolor: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color as Color,
                                                  ),
                                                ),
                                                InterBold(
                                                  text: 'Location',
                                                  fontsize: 16.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: Platform.isIOS ? 30.w : 10.w,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SelectClientGuardsScreen(
                                                    companyId: _cmpId,
                                                    onGuardSelected:
                                                        onGuardSelected,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: 80.w,
                                                  child: IconTextWidget(
                                                    space: 6.w,
                                                    icon: Icons.add,
                                                    iconSize: 20.sp,
                                                    text: 'Select',
                                                    useBold: true,
                                                    fontsize: 14.sp,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .color as Color,
                                                    Iconcolor: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color as Color,
                                                  ),
                                                ),
                                                InterBold(
                                                  text: 'Employee',
                                                  fontsize: 16.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  TextButton(
                                    onPressed: () {},
                                    child: InterMedium(
                                      text: 'clear',
                                      color: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .color,
                                      fontsize: 20.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  )
                                ],
                              ),
                            ),
                          )
                        : ScreenIndex == 2
                            ? SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200.0,
                                  // mainAxisSpacing: 10.0,
                                  // crossAxisSpacing: 10.0,
                                  // childAspectRatio: 4.0,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return Bounce(
                                      onTap: () {
                                        switch (index) {
                                          case 0:
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ClientDarScreen(
                                                          clientId: _employeeId,
                                                          companyId: _cmpId),
                                                ));
                                            break;
                                          case 1:
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ClientReportScreen(
                                                    companyId: _cmpId,
                                                    employeeId: _employeeId,
                                                  ),
                                                ));
                                            break;
                                          // case 2:
                                          //   Navigator.push(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             ClientDarScreen(
                                          //                 clientId: _employeeId,
                                          //                 companyId: _cmpId),
                                          //       ));
                                          //   break;
                                        }
                                      },
                                      child: gridWidget(
                                        img: data[index][0],
                                        tittle: data[index][1],
                                      ),
                                    );
                                  },
                                  childCount: data.length,
                                ),
                              )
                            : ScreenIndex == 3
                                ? SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30.w,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InterBold(
                                            text: 'Received Message ',
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontsize: 14.sp,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          SuperInboxScreen(
                                                            companyId: _cmpId,
                                                            userName: _userName,
                                                            isClient: true,
                                                            isGuard: false,
                                                          )));
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: 20.sp,
                                                ),
                                                SizedBox(width: 4.w),
                                                InterBold(
                                                  text: 'Create Message',
                                                  fontsize: 14.sp,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  maxLine: 2,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SliverToBoxAdapter(),
                ScreenIndex == 1
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            DateTime shiftDate = shifts[index]['ShiftDate'];
                            String dateString = (isSameDate(
                                    shiftDate, DateTime.now()))
                                ? 'Today'
                                : "${shiftDate.day} / ${shiftDate.month} / ${shiftDate.year}";
                            return Padding(
                              padding: EdgeInsets.only(
                                left: 30.w,
                                right: 30.w,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  NavigateScreen(
                                    ClientCheckPatrolScreen(
                                      companyId: _cmpId,
                                      PatrolIdl: '',
                                      ScreenName: '',
                                    ),
                                    context,
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10.h),
                                    InterBold(
                                      text: dateString,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .color,
                                      fontsize: 14.sp,
                                    ),
                                    SizedBox(
                                      height: 10.sp,
                                    ),
                                    Container(
                                      height: 160.h,
                                      margin: EdgeInsets.only(top: 10.h),
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Theme.of(context).shadowColor,
                                            blurRadius: 5,
                                            spreadRadius: 2,
                                            offset: Offset(0, 3),
                                          )
                                        ],
                                        color: Theme.of(context).cardColor,
                                        borderRadius:
                                            BorderRadius.circular(14.sp),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20.h),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 30.h,
                                                width: 4.w,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10.r),
                                                    bottomRight:
                                                        Radius.circular(10.r),
                                                  ),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              SizedBox(width: 14.w),
                                              SizedBox(
                                                width: 190.w,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    InterSemibold(
                                                      text: shifts[index]
                                                          ['ShiftName'],
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .color,
                                                      fontsize: 14.sp,
                                                    ),
                                                    SizedBox(height: 5.h),
                                                    InterRegular(
                                                      text: shifts[index][
                                                          'ShiftLocationAddress'],
                                                      maxLines: 1,
                                                      fontsize: 14.sp,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10.h),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: 18.w,
                                              right: 24.w,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: 100.w,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      InterRegular(
                                                        text: 'Guards',
                                                        fontsize: 14.sp,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .color!,
                                                      ),
                                                      SizedBox(height: 12.h),
                                                      Wrap(
                                                        spacing: -5.0,
                                                        children: [
                                                          if (shifts[index]
                                                                  ['members'] !=
                                                              null)
                                                            for (int i = 0;
                                                                i <
                                                                    (shifts[index]['members'].length >
                                                                            3
                                                                        ? 3
                                                                        : shifts[index]['members']
                                                                            .length);
                                                                i++)
                                                              CircleAvatar(
                                                                radius: 10.r,
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                  shifts[index][
                                                                      'members'][i],
                                                                ),
                                                                backgroundColor:
                                                                    Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                              ),
                                                          if (shifts[index][
                                                                      'members'] !=
                                                                  null &&
                                                              shifts[index][
                                                                          'members']
                                                                      .length >
                                                                  3)
                                                            CircleAvatar(
                                                              radius: 12.r,
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                              child:
                                                                  InterMedium(
                                                                text:
                                                                    '+${shifts[index]['members'].length - 3}',
                                                                fontsize: 12.sp,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 100.w,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      InterRegular(
                                                        text: 'Started At',
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .color!,
                                                        fontsize: 14.sp,
                                                      ),
                                                      SizedBox(height: 5.h),
                                                      InterMedium(
                                                        text: shifts[index]
                                                            ['ShiftStartTime'],
                                                        fontsize: 14.sp,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 100.w,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      InterRegular(
                                                        text: 'Ended At',
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .color!,
                                                        fontsize: 14.sp,
                                                      ),
                                                      SizedBox(height: 5.h),
                                                      Row(
                                                        children: [
                                                          SizedBox(width: 6.w),
                                                          InterMedium(
                                                            text: shifts[index][
                                                                'ShiftEndTime'],
                                                            fontsize: 14.sp,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: shifts.length,
                        ),
                      )
                    : SliverToBoxAdapter(),
                ScreenIndex == 3
                    ? StreamBuilder<List<Map<String, dynamic>>>(
                        stream: getMessagesStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SliverToBoxAdapter(
                                child:
                                    Center(child: CircularProgressIndicator()));
                          }
                          if (snapshot.hasError) {
                            return SliverToBoxAdapter(
                                child: Center(
                                    child: Text('Error: ${snapshot.error}')));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return SliverToBoxAdapter(
                                child: Center(child: Text('No messages')));
                          }

                          List<Map<String, dynamic>> messages = snapshot.data!;

                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                var message = messages[index];
                                var messageTime =
                                    (message['MessageCreatedAt'] as Timestamp)
                                        .toDate();
                                var formattedTime =
                                    '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
                                var receiverId = message['MessageCreatedById'];

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                MobileChatScreen(
                                                    receiverId: receiverId,
                                                    receiverName: '',
                                                    companyId: _cmpId,
                                                    userName: _userName)));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 20.h,
                                      left: 30.w,
                                      right: 30.w,
                                    ),
                                    height: 76.h,
                                    width: double.maxFinite,
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: double.maxFinite,
                                            height: 76.h,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).cardColor,
                                              border: Border(
                                                bottom: BorderSide(
                                                  width: 1,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .shadowColor,
                                                  blurRadius: 5,
                                                  spreadRadius: 2,
                                                  offset: Offset(0, 3),
                                                )
                                              ],
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 9.w),
                                                  height: 45.h,
                                                  width: 45.w,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          message[
                                                              'EmployeeImg']),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                SizedBox(
                                                  width: 300.w,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          InterRegular(
                                                            text: message[
                                                                'EmployeeName'],
                                                            fontsize: 17.sp,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .color!,
                                                          ),
                                                          Row(
                                                            children: [
                                                              PoppinsRegular(
                                                                text:
                                                                    formattedTime,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge!
                                                                    .color!,
                                                                fontsize: 15.sp,
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .arrow_forward_ios,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium!
                                                                    .color!,
                                                                size: 15.sp,
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4.h),
                                                      Flexible(
                                                        child: InterRegular(
                                                          text: message[
                                                              'MessageData'],
                                                          fontsize: 15.sp,
                                                          color: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headlineSmall!
                                                              .color!,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: messages.length,
                            ),
                          );
                        },
                      )
                    : SliverToBoxAdapter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
