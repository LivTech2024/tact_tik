import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/client%20screens/patrol/client_open_patrol_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';

import '../../common/sizes.dart';
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
import '../get started/getstarted_screen.dart';
import '../home screens/widgets/home_screen_part1.dart';
import '../home screens/widgets/homescreen_custom_navigation.dart';

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
 List IconColors = [
    isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
    isDark ? DarkColor.color4 : LightColor.color3,
    isDark ? DarkColor.color4 : LightColor.color3,
    isDark ? DarkColor.color4 : LightColor.color3
  ];
  int ScreenIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _showWish = true;
  bool NewMessage = false;

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

  void NavigateScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void ChangeIconColor(int index) {
    setState(() {
      switch (index) {
        case 0:
          IconColors[0] =
              isDark ? DarkColor.Primarycolor : LightColor.Primarycolor;
          IconColors[1] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[2] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[3] = isDark ? DarkColor.color4 : LightColor.color3;
          break;
        case 1:
          IconColors[0] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[1] =
              isDark ? DarkColor.Primarycolor : LightColor.Primarycolor;
          IconColors[2] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[3] = isDark ? DarkColor.color4 : LightColor.color3;
          break;
        case 2:
          IconColors[0] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[1] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[2] =
              isDark ? DarkColor.Primarycolor : LightColor.Primarycolor;
          IconColors[3] = isDark ? DarkColor.color4 : LightColor.color3;
         
          break;
        case 3:
          IconColors[0] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[1] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[2] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[3] =
              isDark ? DarkColor.Primarycolor : LightColor.Primarycolor;
          
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
    var userInfo = await fireStoreService.getClientInfoByCurrentUserEmail();
    if (mounted) {
      if (userInfo != null) {
        String userName = userInfo['ClientName'];
        String EmployeeId = userInfo['ClientId'];
        String empEmail = userInfo['ClientEmail'];
        String empImage = userInfo['EmployeeImg'] ?? "";
        var shiftInfo =
            await fireStoreService.getShiftByEmployeeIdFromUserInfo(EmployeeId);
        var patrolInfo = await fireStoreService
            .getPatrolsByEmployeeIdFromUserInfo(EmployeeId);
        setState(() {
          _userName = userName;
          _employeeId = EmployeeId;
          _empEmail = empEmail;
          employeeImg = empImage;
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
          String patrolTimeString =
              DateFormat('hh:mm a').format(patrolDateTime);
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
          GeoPoint shiftGeolocation = shiftInfo['ShiftLocation'] ?? 0;
          double shiftLocationLatitude = shiftGeolocation.latitude;
          double shiftLocationLongitude = shiftGeolocation.longitude;
          String companyBranchId = shiftInfo["ShiftCompanyBranchId"] ?? " ";
          String shiftCompanyId = shiftInfo["ShiftCompanyId"] ?? " ";
          String shiftClientId = shiftInfo["ShiftClientId"] ?? " ";

          int ShiftRestrictedRadius = shiftInfo["ShiftRestrictedRadius"] ?? 0;
          bool shiftKeepUserInRadius = shiftInfo["ShiftEnableRestrictedRadius"];
          // String ShiftClientId = shiftInfo['ShiftClientId'];
          // EmpEmail: _empEmail,
          //                     Branchid: _branchId,
          //                     cmpId: _cmpId,
          // String employeeImg = shiftInfo['EmployeeImg'];
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
            // storage.setItem("shiftId", shiftId);
            // storage.setItem("EmpId", EmployeeId);

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
        // getAndPrintAllSchedules();
      } else {
        print('User info not found');
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    ListTile buildListTile(
        IconData icon, String title, int index, VoidCallback onPressed,
        {bool isLogout = false}) {
      final bool isSelected = _selectedIndex == index;

      return ListTile(
        leading: Icon(
          icon,
          color:  isDark
              ? (isSelected ? DarkColor.Primarycolor : DarkColor.color3)
              : (isSelected
                  ? LightColor.Primarycolor
                  : LightColor.color3), // Change color based on selection
          size: width / width24,
        ),
        title: PoppinsBold(
          text: title,
          color:  isDark
              ? (isSelected ? DarkColor.Primarycolor : DarkColor.color3)
              : (isSelected ? LightColor.Primarycolor : LightColor.color3),
          fontsize: width / width14,
        ),
        onTap: onPressed,
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
        endDrawer: Drawer(
          backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
          child: Column(
            children: [
              Container(
                height: height / height180,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width / width15),
                  color: isDark
                      ? DarkColor.Primarycolor
                      : LightColor
                          .Primarycolor, // Background color for the drawer header
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
                                size: Size.fromRadius(width / width50),
                                child: Image.network(
                                  employeeImg!,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        ),
                        SizedBox(height: height / height10),
                        PoppinsSemibold(
                          text: _userName,
                          color: isDark
                              ? DarkColor.WidgetColor
                              : LightColor.WidgetColor,
                          fontsize: width / width16,
                          letterSpacing: -.3,
                        ),
                        SizedBox(height: height / height5),
                        PoppinsRegular(
                          text: _empEmail,
                          color: isDark
                              ? DarkColor.WidgetColor
                              : LightColor.WidgetColor,
                          fontsize: width / width16,
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
                            builder: (context) => ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    buildListTile(
                      Icons.add_card,
                      'Payment',
                      2,
                      () {},
                    ),
                    buildListTile(
                      Icons.article,
                      'Employment Letter',
                      3,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmploymentLetterScreen(),
                          ),
                        );
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
                      Icons.settings,
                      'Settings',
                      5,
                      () async {
                        // List<String> emails = [];
                        // emails.add("sutarvaibhav37@gmail.com");
                        // emails.add("pankaj.kumar1312@yahoo.com");
                        // emails.add("security@lestonholdings.com");
                        // emails.add("dan@tpssolution.com");
                        // // "security@lestonholdings.com"
                        // List<String> patrolLogIds = [];
                        // patrolLogIds.add("jz05XKEGNGazZQPl4KiV");
                        // patrolLogIds.add("ygLQKPhSsc2Uc8Sfbw7O");
                        // patrolLogIds.add("vRVAWBW25mSSG7SxA0JM");
                        // //Sending Shift end report
                        // var data =
                        //     await fireStoreService.fetchTemplateDataForPdf(
                        //   "Hijql0nkNjA1tOhSf8wW",
                        //   "PjiJ0MqsUA9oUwlPsUnr",
                        // );

                        // await sendShiftTemplateEmail(
                        //   "Leston holdings ",
                        //   emails,
                        //   'Tacttik Shift Report',
                        //   "Tacttik Shift Report",
                        //   data,
                        //   "Shift",
                        //   "25 April",
                        //   "Dan Martin",
                        //   "20:00",
                        //   "6:00",
                        //   "High level place",
                        //   "completed",
                        //   "formattedDateTime",
                        //   "formattedEndTime",
                        // );
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: width / width24,
                ),
                title: PoppinsBold(
                  text: 'Logout',
                  color: Colors.red,
                  fontsize: width / width14,
                ),
                onTap: () {
                  auth.signOut(context, GetStartedScreens(), _employeeId);
                },
              ),
              SizedBox(height: height / height20)
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: height / height30,
          ),
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              physics: PageScrollPhysics(),
              slivers: [
                HomeScreenPart1(
                  userName: _userName,
                  employeeImg: employeeImg,
                  // employeeImg: _employeeImg,
                  showWish: _showWish,
                  drawerOnClicked: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: width / width30,
                      right: width / width30,
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
                                color: IconColors[0],
                                textcolor: isDark
                                    ? (ScreenIndex == 0
                                        ? DarkColor.color1
                                        : DarkColor.color4)
                                    : (ScreenIndex == 0
                                        ? LightColor.Primarycolor
                                        : DarkColor.color4),
                              ),
                            ),
                            Bounce(
                              onTap: () => ChangeScreenIndex(1),
                              child: HomeScreenCustomNavigation(
                                text: 'Shifts',
                                icon: Icons.add_task,
                                color: IconColors[1],
                                
                                textcolor: isDark
                                    ? (ScreenIndex == 1
                                        ? DarkColor.color1
                                        : DarkColor.color4)
                                    : (ScreenIndex == 1
                                        ? LightColor.Primarycolor
                                        : DarkColor.color4),
                              ),
                            ),
                            Bounce(
                              // onTap: () => ChangeScreenIndex(2),
                              child: HomeScreenCustomNavigation(
                                useSVG: true,
                                SVG: 'assets/images/lab_profile.svg',
                                text: 'Reports',
                                icon: Icons.celebration,
                                color: IconColors[2],
                                textcolor: isDark
                                    ? (ScreenIndex == 2
                                        ? DarkColor.color1
                                        : DarkColor.color4)
                                    : (ScreenIndex == 2
                                        ? LightColor.Primarycolor
                                        : DarkColor.color4),
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
                                textcolor: isDark
                                    ? (ScreenIndex == 3
                                        ? DarkColor.color1
                                        : DarkColor.color4)
                                    : (ScreenIndex == 3
                                        ? LightColor.Primarycolor
                                        : DarkColor.color4),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height / height30)
                      ],
                    ),
                  ),
                ),
                ScreenIndex == 0
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            String guardStatus = "";

                            return Padding(
                              padding: EdgeInsets.only(
                                left: width / width30,
                                right: width / width30,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  NavigateScreen(ClientOpenPatrolScreen());
                                },
                                child: Container(
                                  height: height / height160,
                                  margin:
                                      EdgeInsets.only(top: height / height10),
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? DarkColor.Primarycolor
                                        : LightColor.color1,
                                    borderRadius:
                                        BorderRadius.circular(width / width14),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: height / height20),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: height / height30,
                                            width: width / width4,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(
                                                    width / width10),
                                                bottomRight: Radius.circular(
                                                    width / width10),
                                              ),
                                              color: isDark
                                                  ? DarkColor.color22
                                                  : LightColor.color3,
                                            ),
                                          ),
                                          SizedBox(width: width / width14),
                                          SizedBox(
                                            width: width / width190,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                InterSemibold(
                                                  text: 'Marvin McKinney',
                                                  color: DarkColor. color22,
                                                  fontsize: width / width14,
                                                ),
                                                SizedBox(
                                                    height: height / height5),
                                                InterRegular(
                                                  text:
                                                      '2972 Westheimer Rd.  Anaa xyz road 123 building',
                                                  maxLines: 1,
                                                  fontsize: width / width14,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: height / height10),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width / width18,
                                          right: width / width24,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: width / width100,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  InterRegular(
                                                    text: 'Guards',
                                                    fontsize: width / width14,
                                                    color: DarkColor.color22,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          height / height12),
                                                  Wrap(
                                                    spacing: -5.0,
                                                    // spacing between avatars
                                                    // runSpacing: 8.0, // spacing between rows
                                                    children: [
                                                      for (int i = 0;
                                                          i <
                                                              (members.length >
                                                                      3
                                                                  ? 3
                                                                  : members
                                                                      .length);
                                                          i++)
                                                        CircleAvatar(
                                                          radius:
                                                              width / width10,
                                                          backgroundImage:
                                                              NetworkImage(
                                                            members[i],
                                                          ), // Assuming members list contains URLs of profile photos
                                                        ),
                                                      if (members.length > 3)
                                                        CircleAvatar(
                                                          radius:
                                                              width / width12,
                                                          backgroundColor:
                                                            DarkColor.  color23,
                                                          child: InterMedium(
                                                            text:
                                                                '+${members.length - 3}',
                                                            fontsize:
                                                                width / width12,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // shift time and date
                                            SizedBox(
                                              width: width / width100,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  InterRegular(
                                                    text: 'CheckPoints',
                                                    color: DarkColor. color22,
                                                    fontsize: width / width14,
                                                  ),
                                                  SizedBox(
                                                      height: height / height5),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .check_circle_outlined,
                                                        size: width / width24,
                                                        color:
                                                            DarkColor. color22,
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              width / width6),
                                                      InterMedium(
                                                        text: '100',
                                                        fontsize:
                                                            width / width14,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: width / width100,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  InterRegular(
                                                    text: 'Required Times',
                                                    color: DarkColor. color22,
                                                    fontsize: width / width14,
                                                  ),
                                                  SizedBox(
                                                      height: height / height5),
                                                  Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/images/avg_pace.svg',
                                                        width: width / width24,
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              width / width6),
                                                      InterMedium(
                                                        text: '2',
                                                        fontsize:
                                                            width / width14,
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
                              ),
                            );
                          },
                          childCount: 4,
                        ),
                      )
                    : ScreenIndex == 1
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                String guardStatus = "";

                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: width / width30,
                                    right: width / width30,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      NavigateScreen(ClientOpenPatrolScreen());
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InterBold(
                                          text: '23 / 04 / 2024',
                                          color: isDark
                                              ? DarkColor.Primarycolor
                                              : LightColor.Primarycolor,
                                          fontsize: width / width14,
                                        ),
                                        SizedBox(
                                          height: height / height10,
                                        ),
                                        Container(
                                          height: height / height160,
                                          margin: EdgeInsets.only(
                                              top: height / height10),
                                          width: double.maxFinite,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? DarkColor.Primarycolor
                                                : LightColor.WidgetColor,
                                            borderRadius: BorderRadius.circular(
                                                width / width14),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: height / height20),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: height / height30,
                                                    width: width / width4,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(
                                                                width /
                                                                    width10),
                                                        bottomRight:
                                                            Radius.circular(
                                                                width /
                                                                    width10),
                                                      ),
                                                      color: isDark
                                                          ? DarkColor
                                                              .color22
                                                          : LightColor
                                                              .Primarycolorlight,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: width / width14),
                                                  SizedBox(
                                                    width: width / width190,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        InterSemibold(
                                                          text:
                                                              'Marvin McKinney',
                                                          color: DarkColor.color22,
                                                          fontsize:
                                                              width / width14,
                                                        ),
                                                        SizedBox(
                                                            height: height /
                                                                height5),
                                                        InterRegular(
                                                          text:
                                                              '2972 Westheimer Rd.  Anaa xyz road 123 building',
                                                          maxLines: 1,
                                                          fontsize:
                                                              width / width14,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                  height: height / height10),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: width / width18,
                                                  right: width / width24,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: width / width100,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          InterRegular(
                                                            text: 'Guards',
                                                            fontsize:
                                                                width / width14,
                                                            color: DarkColor
                                                                .color22,
                                                          ),
                                                          SizedBox(
                                                              height: height /
                                                                  height12),
                                                          Wrap(
                                                            spacing: -5.0,
                                                            // spacing between avatars
                                                            // runSpacing: 8.0, // spacing between rows
                                                            children: [
                                                              for (int i = 0;
                                                                  i <
                                                                      (members.length >
                                                                              3
                                                                          ? 3
                                                                          : members
                                                                              .length);
                                                                  i++)
                                                                CircleAvatar(
                                                                  radius: width /
                                                                      width10,
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                    members[i],
                                                                  ), // Assuming members list contains URLs of profile photos
                                                                ),
                                                              if (members
                                                                      .length >
                                                                  3)
                                                                CircleAvatar(
                                                                  radius: width /
                                                                      width12,
                                                                  backgroundColor:
                                                                     isDark
                                                                      ? DarkColor
                                                                          .color23
                                                                      : LightColor
                                                                          .Primarycolor,
                                                                  child:
                                                                      InterMedium(
                                                                    text:
                                                                        '+${members.length - 3}',
                                                                    fontsize:
                                                                        width /
                                                                            width12,
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // shift time and date
                                                    SizedBox(
                                                      width: width / width100,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          InterRegular(
                                                            text: 'CheckPoints',
                                                            color: DarkColor
                                                                .color22,
                                                            fontsize:
                                                                width / width14,
                                                          ),
                                                          SizedBox(
                                                              height: height /
                                                                  height5),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .check_circle_outlined,
                                                                size: width /
                                                                    width24,
                                                                color: DarkColor
                                                                    . color22,
                                                              ),
                                                              SizedBox(
                                                                  width: width /
                                                                      width6),
                                                              InterMedium(
                                                                text: '100',
                                                                fontsize:
                                                                    width /
                                                                        width14,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: width / width100,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          InterRegular(
                                                            text:
                                                                'Required Times',
                                                            color: DarkColor
                                                                .color22,
                                                            fontsize:
                                                                width / width14,
                                                          ),
                                                          SizedBox(
                                                              height: height /
                                                                  height5),
                                                          Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/avg_pace.svg',
                                                                width: width /
                                                                    width24,
                                                              ),
                                                              SizedBox(
                                                                  width: width /
                                                                      width6),
                                                              InterMedium(
                                                                text: '2',
                                                                fontsize:
                                                                    width /
                                                                        width14,
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
                                          height: height / height10,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: 4,
                            ),
                          )
                        : ScreenIndex == 2
                            ? SliverToBoxAdapter()
                            : ScreenIndex == 3
                                ? SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width / width30,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InterBold(
                                            text: 'Received Message ',
                                            color: isDark
                                                ? DarkColor.Primarycolor
                                                : LightColor.Primarycolor,
                                            fontsize: width / width14,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: isDark
                                                    ? DarkColor.Primarycolor
                                                    : LightColor.Primarycolor,
                                                size: width / width20,
                                              ),
                                              SizedBox(width: width / width4),
                                              InterBold(
                                                text: 'Create Message',
                                                fontsize: width / width14,
                                                color: isDark
                                                    ? DarkColor.Primarycolor
                                                    : LightColor.Primarycolor,
                                                maxLine: 2,
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SliverToBoxAdapter(),
                ScreenIndex == 3
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: width / width30,
                                right: width / width30,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  NavigateScreen(ClientOpenPatrolScreen());
                                },
                                child: Container(
                                  height: height / height80,
                                  margin: EdgeInsets.only(
                                    top: height / height10,
                                  ),
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1,
                                        color: isDark
                                            ? DarkColor.Primarycolor
                                            : LightColor.Primarycolor,
                                      ),
                                    ),
                                    // color: WidgetColor,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: height / height20,
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
                                              height: height / height10,
                                              width: width / width10,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            )
                                          : SizedBox(),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: width / width6),
                                        height: height / height40,
                                        width: width / width40,
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
                                        width: width / width10,
                                      ),
                                      SizedBox(
                                        width: width / width300,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InterRegular(
                                                  text: 'Supervisor',
                                                  fontsize: width / width16,
                                                  color: isDark
                                                      ? DarkColor.color3
                                                      : LightColor.color3,
                                                ),
                                                Row(
                                                  // mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    PoppinsRegular(
                                                      text: '9:36 AM',
                                                      color:  isDark
                                                          ? DarkColor.color3
                                                          : LightColor.color3,
                                                      fontsize: width / width14,
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color:  isDark
                                                          ? DarkColor.color1
                                                          : LightColor.color3,
                                                      size: width / width18,
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: height / height5),
                                            Flexible(
                                              child: InterRegular(
                                                text:
                                                    'Nice. I don\'t know why people get all worked up about hawaiian pizza. I ...',
                                                fontsize: width / width14,
                                                color:  isDark
                                                    ? DarkColor.color3
                                                    : LightColor.color3,
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
                    : SliverToBoxAdapter()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
