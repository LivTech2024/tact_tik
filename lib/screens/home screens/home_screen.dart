import 'dart:async';
import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'package:tact_tik/fonts/poppis_semibold.dart';
import 'package:tact_tik/login_screen.dart';
import 'package:tact_tik/screens/feature%20screens/Log%20Book/logbook_screen.dart';
import 'package:tact_tik/screens/feature%20screens/Report/report_screen.dart';
import 'package:tact_tik/screens/feature%20screens/dar/dar_screen.dart';
import 'package:tact_tik/screens/feature%20screens/site_tours/site_tour_screen.dart';
import 'package:tact_tik/screens/get%20started/getstarted_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/custom_calendar.dart';
import 'package:tact_tik/screens/home%20screens/widgets/grid_widget.dart';
import 'package:tact_tik/screens/home%20screens/widgets/home_screen_part1.dart';
import 'package:tact_tik/screens/home%20screens/widgets/homescreen_custom_navigation.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import 'package:tact_tik/screens/home%20screens/widgets/start_task_screen.dart';

// import 'package:tact_tik/screens/home%20screens/widgets/start_task_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/task_screen.dart';
import 'package:tact_tik/services/auth/auth.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import '../../common/sizes.dart';
import '../../fonts/roboto_bold.dart';
import '../../fonts/roboto_medium.dart';
import '../../utils/utils.dart';
import '../SideBar Screens/employment_letter.dart';
import '../SideBar Screens/history_screen.dart';
import '../SideBar Screens/profile_screen.dart';
import '../feature screens/assets/assets_screen.dart';
import '../feature screens/keys/keys_screen.dart';
import '../feature screens/pani button/panic_button.dart';
import '../feature screens/post_order.dart/post_order_screen.dart';
import '../feature screens/task/task_feature_screen.dart';
import '../feature screens/visitors/visitors.dart';
import 'calendar_screen.dart';
import 'controller/home_screen_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final LocalStorage storage = LocalStorage('ShiftDetails');
final LocalStorage userStorage = LocalStorage('currentUserEmail');

class _HomeScreenState extends State<HomeScreen> {
  //Get the current User
  final Auth auth = Auth();
  String _userName = "";
  String employeeImg = "";
  String _ShiftDate = "";
  String _ShiftStatus = "";

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
  String _employeeCompanyID = "";
  bool ShiftStarted = false;
  bool ShiftExist = false;
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
  List IconColors = [Primarycolor, color21, color21, color21];
  int ScreenIndex = 0;
  late GoogleMapController mapController;
  List<DocumentSnapshot> schedules_list = [];
  final LatLng _center =
      const LatLng(19.3505737, 72.9158990); // San Francisco coordinates
  final double _zoom = 12.0;
  GlobalKey<ScaffoldState> _scaffoldKey1 = GlobalKey();
  bool _showWish = true;
  bool NewMessage = false;

  @override
  void refreshHomeScreen() {
    _getUserInfo();
    getAndPrintAllSchedules();

    // Implement the refresh logic here
    // For example, you can call setState() to update the UI
  }

  void initState() {
    // selectedEvent = events[selectedDay] ?? [];
    _getUserInfo();
    getAndPrintAllSchedules();
    _requestPermissions();
    // _getCurrentUserUid();

    // checkLocation();
    // Timer.periodic(Duration(seconds: 1), (Timer timer) {
    //   // checkLocation();
    // });
    super.initState();
  }

  void _requestPermissions() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      var statusAlways = await Permission.locationAlways.request();
      if (statusAlways.isGranted) {
      } else {}
    } else if (status.isDenied) {
    } else if (status.isPermanentlyDenied) {}
  }

  // Future<void> _getCurrentUserUid() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     setState(() {
  //       _currentUserUid = user.uid;
  //     });
  //     _fetchEmployeeData();
  //   }
  // }

  // Future<void> _fetchEmployeeData() async {
  //   if (_currentUserUid != null) {
  //     final employeeDoc = await FirebaseFirestore.instance
  //         .collection('Employees')
  //         .doc(_currentUserUid)
  //         .get();
  //     if (employeeDoc.exists) {
  //       final employeeData = employeeDoc.data();
  //       setState(() {
  //         _employeeName = employeeData?['EmployeeName'];
  //         _employeeEmail = employeeData?['EmployeeEmail'];
  //         _employeeImageUrl = employeeData?['EmployeeImg'];
  //       });
  //     }
  //   }
  // }

  void ChangeScreenIndex(int index) {
    setState(() {
      ScreenIndex = index;
      ChangeIconColor(index);
      print(ScreenIndex);
      if (index == 1) {
        _showWish = false;
      } else
        _showWish = true;
    });
  }

  void ChangeIconColor(int index) {
    setState(() {
      switch (index) {
        case 0:
          IconColors[0] = Primarycolor;
          IconColors[1] = color21;
          IconColors[2] = color21;
          IconColors[3] = color21;
          break;
        case 1:
          IconColors[0] = color21;
          IconColors[1] = Primarycolor;
          IconColors[2] = color21;
          IconColors[3] = color21;
          break;
        case 2:
          IconColors[0] = Primarycolor;
          IconColors[1] = color21;
          IconColors[2] = color21;
          IconColors[3] = color21;
          ScreenIndex = 0;
          // CalendarScreen
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => CalendarScreen(
          //             companyId: _employeeCompanyID, employeeId: _employeeId)));

          break;
        case 3:
          IconColors[0] = color21;
          IconColors[1] = color21;
          IconColors[2] = color21;
          IconColors[3] = Primarycolor;
          break;
      }
    });
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

  // 12 datani mall shift start id A local stoarage
  // 2 capital mall
  void _getUserInfo() async {
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
    if (mounted) {
      if (userInfo != null) {
        String userName = userInfo['EmployeeName'];
        String EmployeeId = userInfo['EmployeeId'];
        String empEmail = userInfo['EmployeeEmail'];
        String empImage = userInfo['EmployeeImg'] ?? "";
        String empCompanyId = userInfo['EmployeeCompanyId'] ?? "";
        String empBranchId = userInfo['EmployeeCompanyBranchId'] ?? "";
        var shiftInfo =
            await fireStoreService.getShiftByEmployeeIdFromUserInfo(EmployeeId);
        var patrolInfo = await fireStoreService
            .getPatrolsByEmployeeIdFromUserInfo(EmployeeId);
        setState(() {
          _userName = userName;
          _employeeId = EmployeeId;
          _empEmail = empEmail;
          employeeImg = empImage;
          _employeeCompanyID = empCompanyId;
        });
        print('User Info: ${userInfo.data()}');
        if (patrolInfo != null) {
          String PatrolArea = patrolInfo['PatrolArea'];
          String PatrolCompanyId = patrolInfo['PatrolCompanyId'];
          bool PatrolKeepGuardInRadiusOfLocation =
              patrolInfo['PatrolKeepGuardInRadiusOfLocation'];
          String PatrolLocationName = patrolInfo['PatrolLocationName'];
          String PatrolName = patrolInfo['PatrolName'];
          int PatrolRestrictedRadius = patrolInfo['PatrolRestrictedRadius'];
          Timestamp PatrolTime = patrolInfo['PatrolTime'];
          DateTime patrolDateTime = PatrolTime.toDate();

          // Format DateTime as String
          // String patrolTimeString =
          //     DateFormat('hh:mm a').format(patrolDateTime);
          String patrolDateString =
              DateFormat('yyyy-MM-dd').format(patrolDateTime);
          print('Patrol Info: ${patrolInfo.data()}');

          setState(() {
            _patrolArea = PatrolArea;
            _patrolCompanyId = PatrolCompanyId;
            _patrolKeepGuardInRadiusOfLocation =
                PatrolKeepGuardInRadiusOfLocation;
            _patrolLocationName = PatrolLocationName;
            _patrolRestrictedRadius = PatrolRestrictedRadius;
            // _patrolTime = patrolTimeString;
            _patrolDate = patrolDateString;

            // issShift = false;
          });
        }

        if (shiftInfo != null) {
          String shiftDateStr =
              DateFormat.yMMMMd().format(shiftInfo['ShiftDate'].toDate());
          String shiftEndTimeStr = shiftInfo['ShiftEndTime'] ?? " ";
          String shiftStartTimeStr = shiftInfo['ShiftStartTime'] ?? " ";
          String shiftLocation = shiftInfo['ShiftLocationAddress'] ?? " ";
          String shiftLocationId = shiftInfo['ShiftLocationId'] ?? " ";
          String shiftLocationName = shiftInfo['ShiftLocationName'] ?? " ";
          String shiftName = shiftInfo['ShiftName'] ?? " ";
          String shiftId = shiftInfo['ShiftId'] ?? " ";
          GeoPoint shiftGeolocation =
              shiftInfo['ShiftLocation'] as GeoPoint? ?? GeoPoint(0.0, 0.0);
          double shiftLocationLatitude = shiftGeolocation.latitude;
          double shiftLocationLongitude = shiftGeolocation.longitude;
          String companyBranchId = shiftInfo["ShiftCompanyBranchId"] ?? " ";
          String shiftCompanyId = shiftInfo["ShiftCompanyId"] ?? " ";
          String shiftClientId = shiftInfo["ShiftClientId"] ?? " ";
          List<Map<String, dynamic>> shiftCurrentStatus =
              List<Map<String, dynamic>>.from(shiftInfo['ShiftCurrentStatus']);

          List<Map<String, dynamic>> filteredStatus = shiftCurrentStatus
              .where((status) => status['StatusReportedById'] == _employeeId)
              .toList();

          String statusString = filteredStatus
                  .map((status) => status['Status'] as String)
                  .join(', ') ??
              "";

          print("Shift CUrrent Status ${statusString}");
          if (statusString == "started") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('ShiftStarted', true);
            setState(() {
              ShiftStarted = true;
            });
            prefs.setBool('clickedIn', true);
          } else {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('ShiftStarted', false);
            prefs.setBool('clickedIn', false);
            setState(() {
              ShiftStarted = false;
            });
          }
          int ShiftRestrictedRadius = shiftInfo["ShiftRestrictedRadius"] ?? 0;
          bool shiftKeepUserInRadius = shiftInfo["ShiftEnableRestrictedRadius"];
          // String ShiftClientId = shiftInfo['ShiftClientId'];
          // EmpEmail: _empEmail,
          //                     Branchid: _branchId,
          //                     cmpId: _cmpId,
          // String employeeImg = shiftInfo['EmployeeImg'];
          print("Shift Id at the HomeScreen ${shiftId}");
          setState(() {
            _ShiftDate = shiftDateStr;
            _ShiftEndTime = shiftEndTimeStr;
            _ShiftStartTime = shiftStartTimeStr;
            _ShiftLocation = shiftLocation;
            _ShiftLocationName = shiftLocationName;
            _ShiftName = shiftName;
            _shiftLatitude = shiftLocationLatitude;
            _shiftLongitude = shiftLocationLongitude;
            _shiftId = shiftId;
            _shiftRestrictedRadius = ShiftRestrictedRadius;
            _ShiftCompanyId = shiftCompanyId;
            _ShiftBranchId = companyBranchId;
            _shiftKeepGuardInRadiusOfLocation = shiftKeepUserInRadius;
            _shiftLocationId = shiftLocationId;
            _shiftCLientId = shiftClientId;
            _ShiftStatus = statusString;
            ShiftExist = true;
            // _shiftCLientId = ShiftClientId;
            // print("Date time parse: ${DateTime.parse(shiftDateStr)}");
            DateTime shiftDateTime = DateFormat.yMMMMd().parse(shiftDateStr);
            if (!selectedDates
                .contains(DateFormat.yMMMMd().parse(shiftDateStr))) {
              setState(() {
                selectedDates.add(DateFormat.yMMMMd().parse(shiftDateStr));
              });
            }
            if (!selectedDates.any((date) =>
                date!.year == shiftDateTime.year &&
                date.month == shiftDateTime.month &&
                date.day == shiftDateTime.day)) {
              setState(() {
                selectedDates.add(shiftDateTime);
              });
            }
            storage.setItem("shiftId", shiftId);
            storage.setItem("EmpId", EmployeeId);

            // _employeeImg = employeeImg;
          });
          print('Shift Info: ${shiftInfo.data()}');

          Future<void> printAllSchedules(String empId) async {
            var getAllSchedules = await fireStoreService.getAllSchedules(empId);
            if (getAllSchedules.isNotEmpty) {
              getAllSchedules.forEach((doc) {
                var data = doc.data() as Map<String, dynamic>?;
                if (data != null && data['ShiftDate'] != null) {
                  var shiftDate = data['ShiftDate'] as Timestamp;
                  var date = DateTime.fromMillisecondsSinceEpoch(
                      shiftDate.seconds * 1000);
                  var formattedDate = DateFormat('yyyy-MM-dd').format(date);
                  if (!selectedDates.contains(DateTime.parse(formattedDate))) {
                    setState(() {
                      selectedDates.add(DateTime.parse(formattedDate));
                    });
                  }
                  // Format the date
                  print("ShiftDate: $formattedDate");
                }

                print(
                    "All Schedule date : ${doc.data()}"); // Print data of each document
              });
            } else {
              print("No schedules found.");
            }
          }

          printAllSchedules(EmployeeId);
        } else {
          setState(() {
            issShift = true; //To validate that shift exists for the user.
          });
          print('Shift info not found');
        }
        getAndPrintAllSchedules();
      } else {
        print('User info not found');
      }
    }
  }

  void getAndPrintAllSchedules() async {
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
          "Schedule docs ${schedule.data()}"); // Print the data of each document
    });
  }

  Future<void> _refreshData() async {
    // Fetch patrol data from Firestore (assuming your logic exists)
    _getUserInfo();
    getAndPrintAllSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenController(), permanent: true);
    final List<List<String>> data = [
      ['assets/images/panic_mode.png', 'Panic Mode'],
      ['assets/images/site_tour.png', 'Site Tours'],
      ['assets/images/dar.png', 'DAR'],
      ['assets/images/reports.png', 'Reports'],
      ['assets/images/post_order.png', 'Post Orders'],
      ['assets/images/task.png', 'Task'],
      ['assets/images/log_book.png', 'Log Book'],
      ['assets/images/visitors.png', 'Visitors'],
      ['assets/images/assets.png', 'Assets'],
      ['assets/images/keys.png', 'Key'],
    ];

    // final double height = MediaQuery.of(context).size.height;
    // final double width = MediaQuery.of(context).size.width;

    int _selectedIndex = 0; // Index of the selected screen

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
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
              ? Primarycolor
              : color3, // Change color based on selection
          size: 24.sp,
        ),
        title: PoppinsBold(
          text: title,
          color: isSelected ? Primarycolor : color3,
          fontsize: 16.sp,
        ),
        onTap: onPressed,
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        key: _scaffoldKey1, // Assign the GlobalKey to the Scaffold
        endDrawer: Drawer(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10.sp),
                height: 178.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: Primarycolor, // Background color for the drawer header
                ),
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/default.png'),
                            foregroundImage: NetworkImage(employeeImg!),
                            radius: 50.r,
                            backgroundColor: Primarycolor,
                            // maxRadius: width / width50,
                            // minRadius: width / width50,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        PoppinsSemibold(
                          text: _userName,
                          color: WidgetColor,
                          fontsize: 16.sp,
                          letterSpacing: -.3,
                        ),
                        SizedBox(height: 5.h),
                        PoppinsRegular(
                          text: _empEmail,
                          color: WidgetColor,
                          fontsize: 16.sp,
                          letterSpacing: -.3,
                        )
                      ]),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    buildListTile(
                      Icons.door_back_door_outlined,
                      'Home',
                      0,
                      () {},
                    ),
                    buildListTile(
                      Icons.account_circle_outlined,
                      'Profile',
                      1,
                      () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen()));
                      },
                    ),
                    buildListTile(
                      Icons.add_card,
                      'Wages',
                      2,
                      () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EmploymentLetterScreen()));
                      },
                    ),
                    buildListTile(
                      Icons.article,
                      'Employment Letter',
                      3,
                      () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EmploymentLetterScreen()));
                      },
                    ),
                    buildListTile(
                      Icons.restart_alt,
                      'History',
                      4,
                      () {
                        // customEmail();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryScreen(
                              empID: _employeeId,
                            ),
                          ),
                        );
                      },
                    ),
                    buildListTile(
                      Icons.switch_left,
                      'Theme',
                      5,
                      () async {
                        // List<String> emails = [];
                        // emails.add("sutarvaibhav37@gmail.com");
                        // emails.add("pankaj.kumar1312@yahoo.com");
                        // emails.add("alerts.tactik@gmail.com");ƒ
                        // emails.add("security@lestonholdings.com");
                        // emails.add("dan@tpssolution.com");
                        // // "security@lestonholdings.com"
                        // // List<String> patrolLogIds = [];
                        // // patrolLogIds.add("87WnD0GicwKSGunKnHpD");
                        // // patrolLogIds.add("sDFfQDSLM9oVxkJxuQ1D");
                        // // patrolLogIds.add("BrRI6OO1GRiwkuiXhLgitQZ");
                        // // //Sending Shift end report
                        // var data =
                        //     await fireStoreService.fetchTemplateDataForPdf(
                        //   "Hijql0nkNjA1tOhSf8wW",
                        //   "qRtZHPi8a4JOUUwmG1Wj",
                        // );

                        // await sendShiftTemplateEmail(
                        //   "Leston holdings ",
                        //   emails,
                        //   'Tacttik Shift Report',
                        //   "Tacttik Shift Report",
                        //   data,
                        //   "Shift",
                        //   "10 May",
                        //   "Dan Martin",
                        //   "01:20:27",
                        //   "06:00:00",
                        //   "High level place",
                        //   "completed",
                        //   "formattedDateTime",
                        //   "formattedEndTime",
                        // );
                        // await fireStoreService.copyAndCreateDocument(
                        //     "PatrolLogs", "htqtVzVzdb4ejCl7VvBf");
                      },
                    ),
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
                  fontsize: 16.sp,
                ),
                onTap: () {
                  auth.signOut(context, LoginScreen(), _employeeId);
                },
              ),
              SizedBox(height: 10.h)
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            physics: PageScrollPhysics(),
            slivers: [
              HomeScreenPart1(
                userName: _userName,
                employeeImg: employeeImg,
                shiftLocationName: '',
                shiftLocationId: _shiftLocationId,
                shiftId: _shiftId,
                shiftCompanyId: '',
                shiftClientId: _shiftCLientId,
                empEmail: _employeeEmail,
                branchId: _branchId,
                empId: _employeeId,
                // employeeImg: _employeeImg,
                showWish: _showWish,
                drawerOnClicked: () {
                  _scaffoldKey1.currentState?.openEndDrawer();
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Bounce(
                            onTap: () => ChangeScreenIndex(0),
                            child: HomeScreenCustomNavigation(
                              text: 'Shifts',
                              icon: Icons.add_task,
                              color: IconColors[0],
                              textcolor:
                                  ScreenIndex == 0 ? Primarycolor : color21,
                            ),
                          ),
                          Bounce(
                            onTap: () => ChangeScreenIndex(1),
                            child: HomeScreenCustomNavigation(
                              text: 'Explore',
                              icon: Icons.grid_view_rounded,
                              color: IconColors[1],
                              textcolor:
                                  ScreenIndex == 1 ? Primarycolor : color21,
                            ),
                          ),
                          Bounce(
                            onTap: () => ChangeScreenIndex(2),
                            child: HomeScreenCustomNavigation(
                              text: 'Calendar',
                              icon: Icons.calendar_today,
                              color: IconColors[2],
                              textcolor:
                                  ScreenIndex == 2 ? Primarycolor : color21,
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
                              color: IconColors[3],
                              textcolor:
                                  ScreenIndex == 3 ? Primarycolor : color21,
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
                  ? SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: ShiftExist
                              ? FutureBuilder(
                                  future: Future.delayed(Duration(seconds: 2)),
                                  builder: (c, s) => s.connectionState ==
                                          ConnectionState.done
                                      ? StartTaskScreen(
                                          ShiftDate: _ShiftDate,
                                          ShiftClientID: _shiftCLientId,
                                          ShiftEndTime: _ShiftEndTime,
                                          ShiftStartTime: _ShiftStartTime,
                                          EmployeId: _employeeId,
                                          ShiftId: _shiftId,
                                          ShiftAddressName: _ShiftLocationName,
                                          ShiftCompanyId: _ShiftCompanyId ?? "",
                                          ShiftBranchId: _ShiftBranchId,
                                          EmployeeName: _userName ?? "",
                                          ShiftLocationId: _shiftLocationId,
                                          resetShiftStarted: () {},
                                          ShiftIN: true,
                                          onRefresh: refreshHomeScreen,
                                          ShiftName: _ShiftName,
                                          ShiftStatus: _ShiftStatus,
                                        )
                                      : Center(
                                          child: InterMedium(
                                            text: 'Loading...',
                                            color: Primarycolor,
                                            fontsize: 14.sp,
                                          ),
                                        ),
                                )
                              : SizedBox()),
                    )
                  : ScreenIndex == 1
                      ? SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Number of columns
                            // mainAxisSpacing: 12, // Spacing between rows
                            // crossAxisSpacing: 25,
                            childAspectRatio:
                                1.0, // Aspect ratio of each grid item (width / height)
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Bounce(
                                onTap: () {
                                  switch (index) {
                                    case 0:
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return PanicAlertDialog(
                                            EmpId: _employeeId,
                                            CompanyId: _employeeCompanyID,
                                            Username: _userName,
                                          );
                                        },
                                      );
                                      break;
                                    case 1:
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SiteTourScreen(
                                            schedulesList: schedules_list,
                                          );
                                        },
                                      );
                                      break;
                                    case 2:
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>

                                                  // CreateDarScreen(
                                                  //   EmpEmail: _empEmail,
                                                  //   Username: _userName,
                                                  //   EmpId: _employeeId,
                                                  // )
                                                  DarDisplayScreen(
                                                    EmpEmail: _empEmail,
                                                    EmpID: _employeeId,
                                                    EmpDarCompanyId:
                                                        _ShiftCompanyId ?? "",
                                                    EmpDarCompanyBranchId:
                                                        _branchId,
                                                    EmpDarShiftID: _shiftId,
                                                    EmpDarClientID:
                                                        _shiftCLientId,
                                                    Username: _userName,
                                                  )));
                                      break;
                                    case 3:
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ReportScreen(
                                                    locationId:
                                                        _shiftLocationId,
                                                    locationName:
                                                        _ShiftLocationName,
                                                    companyId:
                                                        _ShiftCompanyId ?? "",
                                                    empId: _employeeId,
                                                    empName: _userName,
                                                    clientId: _shiftCLientId,
                                                    ShiftId: _shiftId,
                                                  )));
                                      break;
                                    case 4:
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PostOrder(
                                                    locationId:
                                                        _shiftLocationId,
                                                  )));
                                      break;
                                    case 5:
                                      /*TaskScreen*/
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TaskFeatureScreen()));
                                      break;
                                    case 6:
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LogBookScreen(
                                                    EmpId: _employeeId,
                                                  )));
                                      break;
                                    case 7:
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  VisiTorsScreen(
                                                    locationId:
                                                        _shiftLocationId,
                                                  )));
                                      break;
                                    case 8:
                                      // AssetsScreen
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  // KeysScreen(
                                                  //     keyId: _employeeId)
                                                  AssetsScreen(
                                                      assetEmpId:
                                                          _employeeId)));
                                      break;
                                    case 9:
                                      // AssetsScreen
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  KeysScreen(keyId: _employeeId, companyId: _employeeCompanyID,)
                                              // AssetsScreen(
                                              //     assetEmpId:
                                              //         _employeeId)

                                              ));
                                      break;
                                    default:
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
                      : /*ScreenIndex == 2
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: width / width30,
                                  right: width / width30,
                                ),
                                child: CustomCalendar(
                                  selectedDates: selectedDates,
                                ),
                              ),
                            )
                          :*/
                      ScreenIndex == 3
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30.w),
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        height: 76.h,
                                        margin: EdgeInsets.only(
                                          bottom: 23.h,
                                        ),
                                        width: double.maxFinite,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              width: 1,
                                              color: Primarycolor,
                                            ),
                                          ),
                                          // color: WidgetColor,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 7.h,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment
                                          //         .spaceBetween,
                                          children: [
                                            NewMessage
                                                ? Container(
                                                    height: 11.h,
                                                    width: 11.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  )
                                                : SizedBox(),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(left: 9.w),
                                              height: 45.h,
                                              width: 45.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 12.w,
                                            ),
                                            SizedBox(
                                              width: 300.w,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                        text: 'Supervisor',
                                                        fontsize: 17.sp,
                                                        color: color1,
                                                      ),
                                                      Row(
                                                        // mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          PoppinsRegular(
                                                            text: '9:36 AM',
                                                            color: color3,
                                                            fontsize: 15.sp,
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            color: color1,
                                                            size: 15.sp,
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 4.h,
                                                  ),
                                                  Flexible(
                                                    child: InterRegular(
                                                      text:
                                                          'Nice. I don\'t know why people get all worked up about hawaiian pizza. I ...',
                                                      fontsize: 15.sp,
                                                      color: color3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: 8,
                              ),
                            )
                          : const SizedBox(),
              /*ScreenIndex == 2
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          var schedules = schedules_list[index];
                          Timestamp shifttimestamp = schedules['ShiftDate'];
                          DateTime dateTime = shifttimestamp.toDate();
                          String shiftDate =
                              DateFormat('dd-MM-yyy').format(dateTime);

                          print('Shift Date: $shiftDate');
                          print("Schedule COunt ${schedules_list.length}");
                          String dayOfWeek =
                              DateFormat('EEEE').format(dateTime);
                          // if (dateTime.year == DateTime.now().year &&
                          //     dateTime.month == DateTime.now().month &&
                          //     dateTime.day == DateTime.now().day) {
                          //   if (!shiftDate.endsWith('*')) {
                          //     shiftDate = '$shiftDate*';
                          //     print(shiftDate);
                          //   }
                          // }
                          return Container(
                            margin: EdgeInsets.only(
                              top: height / height20,
                              left: width / width30,
                              right: width / width30,
                            ),
                            height: height / height180,
                            width: double.maxFinite,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    width: width / width200,
                                    height: height / height50,
                                    padding: EdgeInsets.only(
                                        top: height / height3,
                                        left: width / width10,
                                        right: width / width10,
                                        bottom: height / height20),
                                    decoration: BoxDecoration(
                                      color: color31,
                                      borderRadius: BorderRadius.circular(
                                        width / width10,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        InterBold(
                                          text: shiftDate,
                                          color: color30,
                                          fontsize: width / width16,
                                        ),
                                        InterBold(
                                          text: dayOfWeek,
                                          color: color30,
                                          fontsize: width / width12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: double.maxFinite,
                                    height: height / height150,
                                    padding: EdgeInsets.symmetric(
                                      vertical: height / height30,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color27,
                                      borderRadius: BorderRadius.circular(
                                          width / width10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: width / width278,
                                          child: IconTextWidget(
                                            icon: Icons.location_on,
                                            iconSize: width / width24,
                                            text: schedules[
                                                    'ShiftLocationAddress'] ??
                                                "",
                                            color: color30,
                                            Iconcolor: Colors.redAccent,
                                            space: width / width8,
                                            fontsize: width / width14,
                                          ),
                                        ),
                                        SizedBox(
                                          width: width / width278,
                                          child: IconTextWidget(
                                            iconSize: width / width24,
                                            icon: Icons.access_time,
                                            text:
                                                '${schedules['ShiftStartTime'] ?? ""} - ${schedules['ShiftEndTime'] ?? ""}',
                                            color: color30,
                                            Iconcolor: Primarycolor,
                                            space: width / width8,
                                            fontsize: width / width14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: schedules_list.length,
                      ),
                    )
                  :*/
              // ScreenIndex == 3
              //     ?
              //     : SliverToBoxAdapter()
            ],
          ),
        ),
      ),
    );
  }
}
