import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/login_screen.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/Log%20Book/logbook_screen.dart';
import 'package:tact_tik/screens/feature%20screens/Report/report_screen.dart';
import 'package:tact_tik/screens/feature%20screens/assets/assets_screen.dart';
import 'package:tact_tik/screens/feature%20screens/briefing_box/briefing_box_screen.dart';
import 'package:tact_tik/screens/feature%20screens/dar/dar_screen.dart';
import 'package:tact_tik/screens/feature%20screens/keys/view_keys_screen.dart';
import 'package:tact_tik/screens/feature%20screens/post_order.dart/post_order_screen.dart';
import 'package:tact_tik/screens/feature%20screens/site_tours/site_tour_screen.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/visitors.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import 'package:tact_tik/screens/home%20screens/widgets/start_task_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/supervisor_custom_navigation.dart';
import 'package:tact_tik/screens/supervisor%20screens/TrackingScreen/s_tracking_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/history/s_history_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/loogbook/s_loogbook_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/Scheduling/create_schedule_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/widgets/rounded_button.dart';
import 'package:tact_tik/screens/supervisor%20screens/patrol_logs.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/poppins_bold.dart';
import '../../../fonts/poppins_regular.dart';
import '../../../fonts/poppis_semibold.dart';
import '../../../services/auth/auth.dart';
import '../../../utils/colors.dart';
import '../../SideBar Screens/employment_letter.dart';
import '../../SideBar Screens/profile_screen.dart';
import '../../feature screens/pani button/panic_button.dart';
import '../../feature screens/petroling/patrolling.dart';
import '../../get started/getstarted_screen.dart';
import '../../home screens/widgets/grid_widget.dart';
import '../../home screens/widgets/home_screen_part1.dart';
import '../../home screens/widgets/homescreen_custom_navigation.dart';
import '../../new guard/new_guard_screen.dart';
import '../features screens/Report/select_reports_guards.dart';
import '../features screens/assets/s_assets_view_screen.dart';
import '../features screens/assets/select_assets_guards.dart';
import '../features screens/callout/s_add_callout.dart';
import '../features screens/dar/select_dar_guards.dart';
import '../features screens/history/select_history_guards.dart';
import '../features screens/key management/s_key_managment_view_screen.dart';
import '../features screens/key management/select_keys_guards.dart';
import '../features screens/loogbook/select_loogbook_guards.dart';
import '../features screens/panic/s_panic_screen.dart';
import '../features screens/post order/s_post_order_screen.dart';
import '../features screens/visitors/select_visitors_guards.dart';
import 'Scheduling/all_schedules_screen.dart';
import 'message screens/super_inbox.dart';

class SHomeScreen extends StatefulWidget {
  const SHomeScreen({super.key});

  @override
  State<SHomeScreen> createState() => _SHomeScreenState();
}

class _SHomeScreenState extends State<SHomeScreen> {
  int ScreenIndex = 0;
  List<DocumentSnapshot<Object?>> _guardsInfo = [];
  final GlobalKey<ScaffoldState> _scaffoldKeyS = GlobalKey();
  final Auth auth = Auth();
  String _userName = "";
  String _userImg = "";

  String _ShiftDate = "";
  String _ShiftLocation = "";
  String _ShiftName = "";
  String _ShiftEndTime = "";
  String _ShiftStartTime = "";
  double _shiftLatitude = 0;
  double _shiftLongitude = 0;
  String _employeeId = "";
  String employeeImg = "";
  String _employeeCompanyID = "";
  String _employeeCompanyBranchID = "";
  String _empEmail = "";
  String _ShiftStatus = "";
  String _branchId = "";
  String _empRole = "";
  bool isRoleGuard = false;
  String _ShiftLocationName = "";
  bool ShiftExist = false;
  bool ShiftStarted = false;
  bool issShift = false;
  String _shiftId = "";
  bool _shiftKeepGuardInRadiusOfLocation = true;
  String _ShiftBranchId = "";
  String _CompanyId = "";
  int _shiftRestrictedRadius = 0;
  String _BranchId = "";
  int _photouploadInterval = 0;
  late DateTime ShiftStartedTime;
  String? _ShiftCompanyId = "";
  String _shiftCLientId = "";
  bool NewMessage = false;
  String _shiftLocationId = "";
  List<DocumentSnapshot> schedules_list = [];
  void NavigateScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  void initState() {
    // selectedEvent = events[selectedDay] ?? [];

    ScreenIndex = 0;
    _getUserInfo();
    getAndPrintAllSchedules();
    // checkLocation();
    super.initState();
  }

  FireStoreService fireStoreService = FireStoreService();
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

// void _getUserInfo() async {
//     var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
//     if (mounted) {
//       if (userInfo != null) {
//         String userName = userInfo['EmployeeName'];
//         String EmployeeId = userInfo['EmployeeId'];
//         String CompanyId = userInfo['EmployeeCompanyId'];
//         String BranchId = userInfo['EmployeeCompanyBranchId'];
//         String EmpRole = userInfo['EmployeeRole'];
//         String Imgurl = userInfo['EmployeeImg'];
//         String EmpEmail = userInfo['EmployeeEmail'];
//         // bool isemployeeAvailable = userInfo['EmployeeIsAvailable'];
//         var guardsInfo =
//             await fireStoreService.getGuardForSupervisor(EmployeeId);
//         print("Guards INfor ${guardsInfo}");
//         var patrolInfo = await fireStoreService
//             .getPatrolsByEmployeeIdFromUserInfo(EmployeeId);
//         setState(() {
//           _userName = userName;
//           _userImg = Imgurl;
//           _guardsInfo = guardsInfo;
//           _CompanyId = CompanyId;
//           _employeeId = EmployeeId;
//           _empEmail = EmpEmail;
//           _BranchId = BranchId;
//           _empRole = EmpRole;
//         });
//         print('User Info: ${userInfo.data()}');
//       } else {
//         print('Shift info not found');
//       }
//     } else {
//       print('User info not found');
//     }
//   }
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
        String empRole = userInfo['EmployeeRole'] ?? "";
        String CompanyId = userInfo['EmployeeCompanyId'];
        String BranchId = userInfo['EmployeeCompanyBranchId'];
        var guardsInfo =
            await fireStoreService.getGuardForSupervisor(EmployeeId);
        // print("GuardsInfo: ${guardsInfo}");
        // if (guardsInfos != null || guardsInfos.isNotEmpty) {
        //   setState(() {
        //     guardsInfos = guardsInfos;
        //   });
        // }
        if (empRole.isNotEmpty) {
          if (empRole == "GUARD") {
            isRoleGuard = true;
          } else {
            isRoleGuard = false;
          }
        }
        var shiftInfo =
            await fireStoreService.getShiftByEmployeeIdFromUserInfo(EmployeeId);
        var patrolInfo = await fireStoreService
            .getPatrolsByEmployeeIdFromUserInfo(EmployeeId);
        setState(() {
          _userName = userName;
          _guardsInfo = guardsInfo;
          _employeeId = EmployeeId;
          print('Employee Id ===> $_employeeId');
          _empEmail = empEmail;
          employeeImg = empImage;
          _BranchId = BranchId;
          _CompanyId = CompanyId;
          _employeeCompanyID = empCompanyId;
          _employeeCompanyBranchID = empBranchId;
          _empRole = empRole;
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

          // setState(() {
          //   _patrolArea = PatrolArea;
          //   _patrolCompanyId = PatrolCompanyId;
          //   _patrolKeepGuardInRadiusOfLocation =
          //       PatrolKeepGuardInRadiusOfLocation;
          //   _patrolLocationName = PatrolLocationName;
          //   _patrolRestrictedRadius = PatrolRestrictedRadius;
          //   // _patrolTime = patrolTimeString;
          //   _patrolDate = patrolDateString;

          //   // issShift = false;
          // });
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
          int photoInterval =
              shiftInfo['ShiftPhotoUploadIntervalInMinutes'] ?? 0;
          List<Map<String, dynamic>> shiftCurrentStatus =
              List<Map<String, dynamic>>.from(shiftInfo['ShiftCurrentStatus']);
          print("Shift Location Name: ${shiftLocationName}");
          List<Map<String, dynamic>> filteredStatus = shiftCurrentStatus
              .where((status) => status['StatusReportedById'] == _employeeId)
              .toList();

          String statusString = filteredStatus
                  .map((status) => status['Status'] as String)
                  .join(', ') ??
              "";
          String statusOnBreakString = filteredStatus
              .map((status) => (status['StatusIsBreak'] as bool).toString())
              .join(', ');

          // Print the result
          print("statusOnBreakString ${statusOnBreakString}");
          DateTime statusStartedTime;
          if (filteredStatus.isNotEmpty &&
              filteredStatus.first.containsKey('StatusStartedTime')) {
            statusStartedTime =
                (filteredStatus.first['StatusStartedTime'] as Timestamp)
                    .toDate();
            setState(() {
              ShiftStartedTime = statusStartedTime;
            });
          } else {
            setState(() {
              ShiftStartedTime = Timestamp.now().toDate();
            });
            // statusStartedTime = DateTime.now(); // or handle this case as needed
          }
          print("Shift CUrrent Status ${statusString}");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          // print("statusStartedTimeStringDateTIme ${statusStartedTime}");
          if (statusOnBreakString == "true") {
            prefs.setBool('onBreak', true);
            print("Break State Changed true ");
          } else {
            print("Break State Changed false ");
            prefs.setBool('onBreak', false);
          }
          if (statusString == "started") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('ShiftStarted', true);
            // prefs.setBool('onBreak', true);

            setState(() {
              ShiftStarted = true;
            });
            prefs.setBool('clickedIn', true);
          } else {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('ShiftStarted', false);
            prefs.setBool('clickedIn', false);
            // prefs.setBool('onBreak', false);

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
            _branchId = _ShiftBranchId;
            _photouploadInterval = photoInterval;
            // _shiftCLientId = ShiftClientId;
            // print("Date time parse: ${DateTime.parse(shiftDateStr)}");
            DateTime shiftDateTime = DateFormat.yMMMMd().parse(shiftDateStr);
            // if (!selectedDates
            //     .contains(DateFormat.yMMMMd().parse(shiftDateStr))) {
            //   setState(() {
            //     selectedDates.add(DateFormat.yMMMMd().parse(shiftDateStr));
            //   });
            // }
            // if (!selectedDates.any((date) =>
            //     date!.year == shiftDateTime.year &&
            //     date.month == shiftDateTime.month &&
            //     date.day == shiftDateTime.day)) {
            //   setState(() {
            //     selectedDates.add(shiftDateTime);
            //   });
            // }
            // print("SelectedDates ${selectedDates}");
            storage.setItem("shiftId", shiftId);
            storage.setItem("EmpId", EmployeeId);

            // _employeeImg = employeeImg;
          });
          // print("SelectedDates ${selectedDates}");

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
                  // if (!selectedDates.contains(DateTime.parse(formattedDate))) {
                  //   setState(() {
                  //     selectedDates.add(DateTime.parse(formattedDate));
                  //   });
                  // }
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

  void refreshHomeScreen() {
    _getUserInfo();
    getAndPrintAllSchedules();
    // fetchMessages();

    // Implement the refresh logic here
    // For example, you can call setState() to update the UI
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // final double height = MediaQuery
    //     .of(context)
    //     .size
    //     .height;
    // final double width = MediaQuery
    //     .of(context)
    //     .size
    //     .width;
    List IconColors = [
      Theme.of(context).primaryColor,
      Theme.of(context).focusColor,
      Theme.of(context).focusColor,
      Theme.of(context).focusColor,
    ];
    final List<List<String>> data = [
      ['assets/images/panic_mode.png', 'S_Panic Mode'],
      ['assets/images/site_tour.png', 'S_Track Guard'],
      ['assets/images/dar.png', 'S_DAR'],
      ['assets/images/reports.png', 'S_Reports'],
      ['assets/images/post_order.png', 'S_Post Orders'],
      ['assets/images/task.png', 'S_Task'], // TODO
      ['assets/images/log_book.png', 'S_Log Book'],
      ['assets/images/visitors.png', 'S_Visitors'], // TODO
      ['assets/images/assets.png', 'S_Assets'],
      ['assets/images/keys.png', 'S_Key'],
      ['assets/images/callout_icon.png', 'S_Callout'],
      ['assets/images/panic_mode.png', 'Panic Mode'],
      ['assets/images/site_tour.png', 'Site Tours'],
      ['assets/images/dar.png', 'DAR'],
      ['assets/images/reports.png', 'Reports'],
      ['assets/images/post_order.png', 'Post Orders'],
      ['assets/images/task.png', 'Breifing Box'],
      ['assets/images/log_book.png', 'Log Book'],
      ['assets/images/visitors.png', 'Visitors'],
      ['assets/images/assets.png', 'Assets'],
      ['assets/images/keys.png', 'Key'],
    ];

    int _selectedIndex = 0; // Index of the selected screen

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    void ChangeIconColor(int index) {
      setState(() {
        switch (index) {
          case 0:
            IconColors[0] = Theme.of(context).primaryColor;
            IconColors[1] = Theme.of(context).focusColor;
            IconColors[2] = Theme.of(context).focusColor;
            IconColors[3] = Theme.of(context).focusColor;
            break;
          case 1:
            IconColors[0] = Theme.of(context).primaryColor;
            IconColors[2] = Theme.of(context).focusColor;
            IconColors[3] = Theme.of(context).focusColor;
            IconColors[1] = Theme.of(context).focusColor;
            break;
          case 2:
            IconColors[0] = Theme.of(context).focusColor;
            IconColors[1] = Theme.of(context).primaryColor;
            IconColors[2] = Theme.of(context).focusColor;
            IconColors[3] = Theme.of(context).focusColor;
            break;
          case 3:
            IconColors[0] = Theme.of(context).focusColor;
            IconColors[1] = Theme.of(context).focusColor;
            IconColors[2] = Theme.of(context).primaryColor;
            IconColors[3] = Theme.of(context).focusColor;
            ScreenIndex = 0;
            NavigateScreen(AllSchedulesScreen(
              BranchId: _BranchId,
              CompanyId: _CompanyId,
            ));
            break;
          case 4:
            IconColors[0] = Theme.of(context).focusColor;
            IconColors[1] = Theme.of(context).focusColor;
            IconColors[2] = Theme.of(context).focusColor;
            IconColors[3] = Theme.of(context).primaryColor;
            ScreenIndex = 0;
            NavigateScreen(SuperInboxScreen(
              companyId: _CompanyId,
              userName: _userName,
              isClient: false,
              isGuard: false,
            ));
            break;
        }
      });
    }

    void ChangeScreenIndex(int index) {
      setState(() {
        ScreenIndex = index;
        ChangeIconColor(index);
        print(ScreenIndex);
      });
    }

    ListTile buildListTile(
        IconData icon, String title, int index, VoidCallback onPressed,
        {bool isLogout = false}) {
      final bool isSelected = _selectedIndex == index;

      return ListTile(
        leading: Icon(
          icon,
          color: (isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .color), // Change color based on selection
          size: 24.w,
        ),
        title: PoppinsBold(
          text: title,
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.headlineSmall!.color,
          fontsize: 14.w,
        ),
        onTap: onPressed,
      );
    }

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKeyS,
        endDrawer: Drawer(
          backgroundColor: Theme.of(context).canvasColor,
          child: Column(
            children: [
              Container(
                height: 180.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.w),
                  color: Theme.of(context)
                      .primaryColor, // Background color for the drawer header
                ),
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/default.png'),
                          foregroundImage: NetworkImage(_userImg),
                          radius: Platform.isIOS ? 40.r : 50.r,
                          backgroundColor: Theme.of(context).primaryColor,
                          // maxRadius: width / width50,
                          // minRadius: width / width50,
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
                      ]),
                ),
              ),

              /*CircleAvatar(
              backgroundImage: NetworkImage('url'), // Replace with actual image URL if available
              radius: width / width20,
              backgroundColor: Primarycolor,
              )*/
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
                                  )),
                        );
                      },
                    ),
                    buildListTile(Icons.add_card, 'Wages', 2, () {}),
                    buildListTile(
                      Icons.article,
                      'Employment Letter',
                      3,
                      () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmploymentLetterScreen(),
                            ));
                      },
                    ),
                    buildListTile(Icons.restart_alt, 'History', 4, () {
                      //   SelectHistoryGuardsScreen
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectHistoryGuardsScreen(
                              companyId: _CompanyId,
                            ),
                          ));
                    }),
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
        body: CustomScrollView(
          // physics: PageScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30.h,
              ),
            ),
            SliverToBoxAdapter(
              child: HomeScreenPart1(
                isClient: false,
                empId: _employeeId,
                branchId: '',
                empEmail: _empEmail,
                shiftClientId: '',
                shiftCompanyId: '',
                shiftId: '',
                shiftLocationId: '',
                shiftLocationName: '',
                userName: _userName ?? "",
                // employeeImg: _userImg,
                employeeImg: _userImg ?? "",
                drawerOnClicked: () {
                  _scaffoldKeyS.currentState?.openEndDrawer();
                },
                Role: _empRole,
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
                          child: SupervisorCustomNavigation(
                            text: 'Shift',
                            icon: Icons.add_task,
                            color: ScreenIndex == 0
                                ? ThemeMode.dark == themeManager.themeMode
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor
                                : Theme.of(context).focusColor,
                            textcolor: ScreenIndex == 0
                                ? ThemeMode.dark == themeManager.themeMode
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor
                                : Theme.of(context).focusColor,
                          ),
                        ),
                        Bounce(
                          onTap: () => ChangeScreenIndex(1),
                          child: SupervisorCustomNavigation(
                            text: 'Guards',
                            icon: Icons.add_task,
                            color: ScreenIndex == 1
                                ? ThemeMode.dark == themeManager.themeMode
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor
                                : Theme.of(context).focusColor,
                            textcolor: ScreenIndex == 1
                                ? ThemeMode.dark == themeManager.themeMode
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor
                                : Theme.of(context).focusColor,
                          ),
                        ),
                        Bounce(
                          onTap: () => ChangeScreenIndex(2),
                          child: SupervisorCustomNavigation(
                            text: 'Explore',
                            icon: Icons.grid_view_rounded,
                            color: ScreenIndex == 2
                                ? ThemeMode.dark == themeManager.themeMode
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor
                                : Theme.of(context).focusColor,
                            textcolor: ScreenIndex == 2
                                ? ThemeMode.dark == themeManager.themeMode
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor
                                : Theme.of(context).focusColor,
                          ),
                        ),
                        Bounce(
                          onTap: () => ChangeScreenIndex(3),
                          // onTap: () => ChangeScreenIndex(2),
                          child: SupervisorCustomNavigation(
                            useSVG: true,
                            SVG: 'assets/images/calendar_clock.svg',
                            text: 'Calendar',
                            icon: Icons.calendar_today,
                            color: ScreenIndex == 3
                                ? ThemeMode.dark == themeManager.themeMode
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor
                                : Theme.of(context).focusColor,
                            textcolor: ScreenIndex == 3
                                ? ThemeMode.dark == themeManager.themeMode
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor
                                : Theme.of(context).focusColor,
                          ),
                        ),
                        Bounce(
                          onTap: () => ChangeScreenIndex(4),
                          child: SupervisorCustomNavigation(
                            useSVG: true,
                            SVG: NewMessage
                                ? ScreenIndex == 4
                                    ? 'assets/images/message_dot.svg'
                                    : 'assets/images/no_message_dot.svg'
                                : ScreenIndex == 4
                                    ? 'assets/images/message.svg'
                                    : 'assets/images/no_message.svg',
                            text: 'Message',
                            icon: Icons.chat_bubble_outline,
                            color: ScreenIndex == 4
                                ? ThemeMode.dark == themeManager.themeMode
                                    ? DarkColor.color1
                                    : LightColor.Primarycolor
                                : Theme.of(context).focusColor,
                            textcolor: ScreenIndex == 4
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
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: ShiftExist
                          ? FutureBuilder(
                              future: Future.delayed(Duration(seconds: 1)),
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
                                      shiftStartedTime: ShiftStartedTime,
                                      photoUploadInterval: _photouploadInterval,
                                    )
                                  : Center(
                                      child: InterMedium(
                                        text: 'Loading...',
                                        color: Theme.of(context).primaryColor,
                                        fontsize: 14.sp,
                                      ),
                                    ),
                            )
                          : SizedBox(
                              height: 400.h,
                              width: double.maxFinite,
                              // color: Colors.redAccent,
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 150.h,
                                      width: 200.w,
                                      child: SvgPicture.asset(
                                        isDark
                                            ? 'assets/images/no_shift.svg'
                                            : 'assets/images/no_shift_light.svg',
                                      ),
                                    ),
                                    SizedBox(height: 30.h),
                                    InterSemibold(
                                      text: 'No shift Assigned yet',
                                      color: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .color,
                                      fontsize: 16.sp,
                                    ),
                                    SizedBox(height: 20.h),
                                    InterRegular(
                                      text: 'Go to calendar to check shift',
                                      color: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .color,
                                      fontsize: 14.sp,
                                    ),
                                    InterBold(
                                      text: 'or',
                                      color: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .color,
                                      fontsize: 20.sp,
                                    ),
                                    InterRegular(
                                      text: 'Refresh page',
                                      color: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .color,
                                      fontsize: 14.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  )
                : ScreenIndex == 1
                    ? SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InterBold(
                                    text: 'All Guards',
                                    fontsize: 14.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewGuardScreen(
                                                    companyId: _CompanyId,
                                                  )));
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 20.sp,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                        ),
                                        SizedBox(width: 10.w),
                                        InterBold(
                                          text: 'Add',
                                          fontsize: 14.sp,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h)
                            ],
                          ),
                        ),
                      )
                    : ScreenIndex == 2
                        ? SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Number of columns
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
                                                    SPanicScreen(
                                                      empId: _employeeId,
                                                    )));
                                      case 1:
                                        Get.to(() => SupervisorTrackingScreen(
                                              companyId: _CompanyId,
                                              guardsInfo: _guardsInfo,
                                            ));
                                        break;
                                      case 2:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SelectDARGuardsScreen(
                                              EmployeeId: _employeeId,
                                            ),
                                          ),
                                        );
                                        break;
                                      case 3:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SelectReportsGuardsScreen(
                                              EmpId: _employeeId,
                                            ),
                                          ),
                                        );
                                        break;
                                      case 4:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SPostOrder(
                                              companyId: _CompanyId,
                                            ),
                                          ),
                                        );
                                        break;
                                      case 5:
                                        // TODO Task Screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PatrollLogsScreen(),
                                          ),
                                        );
                                        break;
                                      case 6:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SelectLoogBookGuardsScreen(
                                              companyId: _CompanyId,
                                            ),
                                          ),
                                        );
                                        break;
                                      case 7:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SelectVisitorsGuardsScreen(
                                              companyId: _CompanyId,
                                            ),
                                          ),
                                        );
                                        break;
                                      case 8:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SAssetsViewScreen(
                                              companyId: _CompanyId,
                                              empId: _employeeId,
                                              EmpName: _employeeId,
                                            ),
                                          ),
                                        );
                                        break;
                                      case 9:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SKeyManagementViewScreen(
                                              companyId: _CompanyId,
                                              branchId: _BranchId,
                                            ),
                                          ),
                                        );
                                        break;
                                      case 10:
                                        // AssetsScreen
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SAddCallout()
                                                ));
                                        break;
                                      case 11:
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
                                      case 12:
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SiteTourScreen(
                                              schedulesList: schedules_list,
                                            );
                                          },
                                        );
                                        break;
                                      case 13:
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
                                      case 14:
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
                                                      isguard: isRoleGuard,
                                                      BranchID: _branchId,
                                                    )));
                                        break;
                                      case 15:
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => PostOrder(
                                                      locationId:
                                                          _shiftLocationId,
                                                    )));
                                        break;
                                      case 16:
                                        /*TaskScreen*/
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    // TaskFeatureScreen()
                                                    BriefingBoxScreen(
                                                        locationId:
                                                            _shiftLocationId,
                                                        shiftName:
                                                            _ShiftName)));
                                        break;
                                      case 17:
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LogBookScreen(
                                                      EmpId: _employeeId,
                                                    )));
                                        break;
                                      case 18:
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VisiTorsScreen(
                                                      locationId:
                                                          _shiftLocationId,
                                                    )));
                                        break;
                                      case 19:
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
                                      case 20:
                                        // AssetsScreen
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewKeysScreen(
                                                      locationid:
                                                          _shiftLocationId,
                                                      branchId: _branchId,
                                                      companyid: _ShiftCompanyId
                                                          as String,
                                                    )
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
                        : SliverToBoxAdapter(),
            ScreenIndex == 1
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        String guardStatus = "";

                        if (index < _guardsInfo.length) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 30.w,
                              right: 30.w,
                            ),
                            child: HomeScreenUserCard(
                              guardsInfo: _guardsInfo[index],
                              CompanyId: _CompanyId,
                              empid: _employeeId,
                            ),
                          );
                        } else {
                          return Center(
                            child: InterMedium(text: 'No Guards Available'),
                          ); // Return an empty SizedBox for index out of bounds
                        }
                      },
                      childCount: _guardsInfo.length,
                    ),
                  )
                : SliverToBoxAdapter()
          ],
        ),
      ),
    );
  }
}

class HomeScreenUserCard extends StatefulWidget {
  final DocumentSnapshot<Object?> guardsInfo;
  String CompanyId;
  final String empid;

  HomeScreenUserCard({
    Key? key,
    required this.guardsInfo,
    required this.CompanyId,
    required this.empid,
  }) : super(key: key);

  @override
  State<HomeScreenUserCard> createState() => _HomeScreenUserCardState();
}

class _HomeScreenUserCardState extends State<HomeScreenUserCard> {
  bool isAssigned = false;
  bool loading = true;
  bool _expanded = false;
  @override
  void initState() {
    super.initState();
    _checkShiftStatus();
  }

  FireStoreService fireStoreService = FireStoreService();
  Future<void> _checkShiftStatus() async {
    String empId = widget.guardsInfo['EmployeeId'];
    bool result =
        await fireStoreService.checkShiftsForEmployee(DateTime.now(), empId);
    print("result of status ${result}");
    setState(() {
      isAssigned = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: Container(
        constraints: _expanded
            ? BoxConstraints(minHeight: 80.h)
            : BoxConstraints(minHeight: 60.h),
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
          borderRadius: BorderRadius.circular(12.w),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 10.h,
        ),
        margin: EdgeInsets.only(bottom: 10.h),
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 50.h,
                        width: 50.w,
                        decoration: widget.guardsInfo['EmployeeImg'] != null
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                // color: Primarycolor,
                                image: DecorationImage(
                                  image: NetworkImage(
                                      widget.guardsInfo['EmployeeImg'] ?? ""),
                                  filterQuality: FilterQuality.high,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : BoxDecoration(
                                shape: BoxShape.circle,
                                color: DarkColor.Primarycolor,
                                image: DecorationImage(
                                  image: /*widget.guardsInfo['EmployeeImg'] != null ? NetworkImage(
                                widget.guardsInfo['EmployeeImg'] ?? "") :*/
                                      AssetImage('assets/images/default.png'),
                                  filterQuality: FilterQuality.high,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      SizedBox(width: 20.w),
                      InterBold(
                        text: widget.guardsInfo['EmployeeName'] ?? "",
                        letterSpacing: -.3,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ],
                  ),
                  Container(
                    height: 16.h,
                    width: 16.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: loading
                          ? Colors
                              .grey // Display a loading color while checking status
                          : isAssigned
                              ? Colors
                                  .red // Display red if the employee is assigned to a shift
                              : widget.guardsInfo['EmployeeIsAvailable'] ==
                                      "available"
                                  ? Colors.green
                                  : widget.guardsInfo['EmployeeIsAvailable'] ==
                                          "on_shift"
                                      ? Colors.orange
                                      : Colors.red,
                    ),
                  )
                ],
              ),
            ),
            if (_expanded)
              Column(
                children: [
                  Divider(),
                  SizedBox(height: 5.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateScheduleScreen(
                                        shiftId: '',
                                        supervisorEmail: '',
                                        BranchId: widget.guardsInfo[
                                                "EmployeeCompanyBranchId"] ??
                                            "",
                                        GuardId:
                                            widget.guardsInfo["EmployeeId"] ??
                                                "",
                                        GuardName:
                                            widget.guardsInfo["EmployeeName"] ??
                                                "",
                                        GuardImg:
                                            widget.guardsInfo["EmployeeImg"] ??
                                                "",
                                        CompanyId: widget.CompanyId ?? "",
                                        GuardRole:
                                            widget.guardsInfo["EmployeeRole"] ??
                                                "",
                                      )),
                            );
                          },
                          child: RoundedButton(
                            icon: Icons.add,
                          ),
                        ),
                        Bounce(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => ),
                            // );
                          },
                          child: RoundedButton(
                            icon: Icons.add_card,
                          ),
                        ),
                        Bounce(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectDARGuardsScreen(
                                    EmployeeId: widget.empid,
                                  ),
                                ));
                          },
                          child: RoundedButton(
                            useSVG: true,
                            svg: 'assets/images/lab_profile.svg',
                          ),
                        ),
                        Bounce(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SHistoryScreen(
                                          empID:
                                              widget.guardsInfo['EmployeeId'],
                                          empName:
                                              widget.guardsInfo['EmployeeName'],
                                        )));
                          },
                          child: RoundedButton(
                            useSVG: true,
                            svg: 'assets/images/device_reset.svg',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
