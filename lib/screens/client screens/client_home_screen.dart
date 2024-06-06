import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/login_screen.dart';
import 'package:tact_tik/screens/client%20screens/patrol/client_check_patrol_screen.dart';
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
import 'Reports/client_oprn_report.dart';

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
  List IconColors = [Primarycolor, color4, color4, color4];
  int ScreenIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKeyClient = GlobalKey();
  List<Map<String, dynamic>> patrolsList = [];
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

  void NavigateScreen(Widget screen, BuildContext context) {
    void NavigateScreen(Widget screen, BuildContext context) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    }
  }

  void ChangeIconColor(int index) {
    setState(() {
      switch (index) {
        case 0:
          IconColors[0] = Primarycolor;
          IconColors[1] = color4;
          IconColors[2] = color4;
          IconColors[3] = color4;
          break;
        case 1:
          IconColors[0] = color4;
          IconColors[1] = Primarycolor;
          IconColors[2] = color4;
          IconColors[3] = color4;
          break;
        case 2:
          IconColors[0] = color4;
          IconColors[1] = color4;
          IconColors[2] = Primarycolor;
          IconColors[3] = color4;
          break;
        case 3:
          IconColors[0] = color4;
          IconColors[1] = color4;
          IconColors[2] = color4;
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

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    fetchShifts();
  }

  List<Map<String, dynamic>> shifts = [];
  bool isLoading = true;

  Future<void> fetchShifts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Shifts')
          .where('ShiftClientId', isEqualTo: _employeeId)
          .get();
      print('Snapshot ${querySnapshot}');
      List<Map<String, dynamic>> fetchedShifts = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'ShiftDate': data['ShiftDate'].toDate(),
          'ShiftName': data['ShiftName'],
          'ShiftLocationAddress': data['ShiftLocationAddress'],
          'ShiftStartTime': data['ShiftStartTime'],
          'ShiftEndTime': data['ShiftEndTime'],
          // 'members': data['members'],
        };
      }).toList();

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

  // 12 datani mall shift start id A local stoarage
  // 2 capital mall
  void _getUserInfo() async {
    print("Fetching user info");
    var userInfo = await fireStoreService.getClientInfoByCurrentUserEmail();
    if (mounted) {
      if (userInfo != null) {
        String userName = userInfo['ClientName'];
        String EmployeeId = userInfo['ClientId'];
        String empEmail = userInfo['ClientEmail'];
        String empImage = userInfo['ClientHomePageBgImg'] ?? "";
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

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
          color: isSelected
              ? Primarycolor
              : color3, // Change color based on selection
          size: width / width24,
        ),
        title: PoppinsBold(
          text: title,
          color: isSelected ? Primarycolor : color3,
          fontsize: width / width14,
        ),
        onTap: onPressed,
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        key: _scaffoldKeyClient, // Assign the GlobalKey to the Scaffold
        endDrawer: Drawer(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 180.h,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    color:
                        Primarycolor, // Background color for the drawer header
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
                                  size: Size.fromRadius(50.r),
                                  child: Image.network(
                                    employeeImg!,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          ),
                          SizedBox(height: height / height10),
                          PoppinsSemibold(
                            text: _userName,
                            color: WidgetColor,
                            fontsize: width / width16,
                            letterSpacing: -.3,
                          ),
                          SizedBox(height: height / height5),
                          PoppinsRegular(
                            text: _empEmail,
                            color: WidgetColor,
                            fontsize: width / width16,
                            letterSpacing: -.3,
                          )
                        ]),
                  ),
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
                      () async {},
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
              physics: PageScrollPhysics(),
              slivers: [
                HomeScreenPart1(
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
                  // employeeImg: _employeeImg,
                  showWish: _showWish,
                  drawerOnClicked: () {
                    _scaffoldKeyClient.currentState?.openEndDrawer();
                  },
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
                                color: IconColors[0],
                                textcolor: ScreenIndex == 0 ? color1 : color4,
                              ),
                            ),
                            Bounce(
                              // onTap: () => ChangeScreenIndex(1),
                              child: HomeScreenCustomNavigation(
                                text: 'Shifts',
                                icon: Icons.add_task,
                                color: IconColors[1],
                                textcolor: ScreenIndex == 1 ? color1 : color4,
                              ),
                            ),
                            Bounce(
                              onTap: () => ChangeScreenIndex(2),
                              child: HomeScreenCustomNavigation(
                                useSVG: true,
                                SVG: 'assets/images/lab_profile.svg',
                                text: 'Reports',
                                icon: Icons.celebration,
                                color: IconColors[2],
                                textcolor: ScreenIndex == 2 ? color1 : color4,
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
                                textcolor: ScreenIndex == 3 ? color1 : color4,
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
                                                  PatrolIdl: PatrolId)));
                                },
                                child: Container(
                                  height: 100.h,
                                  margin: EdgeInsets.only(top: 10.h),
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    color: Primarycolor,
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  padding: EdgeInsets.only(
                                      top: 20.h, bottom: 20.h, right: 10.w),
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
                                                  color: WidgetColor,
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
                                                    color: color22,
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
                                                            text:
                                                                '2972 Westheimer Rd. Santa Ana, Illinois 85486 ',
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
                                                  color: color2,
                                                ),
                                                SizedBox(height: 10.h),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.qr_code,
                                                      color: Primarycolor,
                                                      size: 24.sp,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    InterMedium(
                                                      text: '100',
                                                      fontsize: 13.sp,
                                                      color: color1,
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
                                          PatrolIdl: '',
                                        ),
                                        context,
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InterBold(
                                          text: dateString,
                                          color: Primarycolor,
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
                                            color: Primarycolor,
                                            borderRadius:
                                                BorderRadius.circular(14.sp),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20.h),
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
                                                            Radius.circular(
                                                                10.r),
                                                        bottomRight:
                                                            Radius.circular(
                                                                10.r),
                                                      ),
                                                      color: color22,
                                                    ),
                                                  ),
                                                  SizedBox(width: 14.w),
                                                  SizedBox(
                                                    width: 190.w,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        InterSemibold(
                                                          text: shifts[index]
                                                              ['ShiftName'],
                                                          color: color22,
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
                                                            color: color22,
                                                          ),
                                                          SizedBox(
                                                              height: 12.h),
                                                          Wrap(
                                                            spacing: -5.0,
                                                            children: [
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
                                                                    shifts[index]
                                                                        [
                                                                        'members'][i],
                                                                  ),
                                                                ),
                                                              if (shifts[index][
                                                                          'members']
                                                                      .length >
                                                                  3)
                                                                CircleAvatar(
                                                                  radius: 12.r,
                                                                  backgroundColor:
                                                                      color23,
                                                                  child:
                                                                      InterMedium(
                                                                    text:
                                                                        '+${shifts[index]['members'].length - 3}',
                                                                    fontsize:
                                                                        12.sp,
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
                                                            color: color22,
                                                            fontsize: 14.sp,
                                                          ),
                                                          SizedBox(height: 5.h),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .check_circle_outlined,
                                                                size: 24.sp,
                                                                color: color22,
                                                              ),
                                                              SizedBox(
                                                                  width: 6.w),
                                                              InterMedium(
                                                                text: shifts[
                                                                        index][
                                                                    'ShiftStartTime'],
                                                                fontsize: 14.sp,
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
                                                            text: 'Ended At',
                                                            color: color22,
                                                            fontsize: 14.sp,
                                                          ),
                                                          SizedBox(height: 5.h),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                  width: 6.w),
                                                              InterMedium(
                                                                text: shifts[
                                                                        index][
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
                        : ScreenIndex == 2
                            ? SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: 30.w,
                                        right: 30.w,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InterBold(
                                            text: '19/9/2004',
                                            color: color1,
                                            fontsize: 20.sp,
                                          ),
                                          SizedBox(
                                            height: 10.sp,
                                          ),
                                          // ClientOpenReport
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ClientOpenReport()));
                                            },
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  minHeight: 200.h),
                                              width: double.maxFinite,
                                              decoration: BoxDecoration(
                                                color: WidgetColor,
                                                borderRadius:
                                                    BorderRadius.circular(14.r),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 18.h,
                                                horizontal: 18.w,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  InterSemibold(
                                                    text: 'Guard Name',
                                                    fontsize: 18.sp,
                                                    color: Primarycolor,
                                                  ),
                                                  SizedBox(height: 19.h),
                                                  SizedBox(
                                                    width: 240.w,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InterMedium(
                                                              text:
                                                                  'Report Name:',
                                                              fontsize: 16.sp,
                                                              color: color1,
                                                            ),
                                                            InterMedium(
                                                              text:
                                                                  'Report Name',
                                                              fontsize: 16.sp,
                                                              color: color3,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 10.h),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InterMedium(
                                                              text: 'Category:',
                                                              fontsize: 16.sp,
                                                              color: color1,
                                                            ),
                                                            InterMedium(
                                                              text:
                                                                  'Category Name',
                                                              fontsize: 16.sp,
                                                              color: color3,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 10.h),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InterMedium(
                                                              text: 'Emp Name:',
                                                              fontsize: 16.sp,
                                                              color: color1,
                                                            ),
                                                            InterMedium(
                                                              text:
                                                                  'Employee Name',
                                                              fontsize: 16.sp,
                                                              color: color3,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 10.h),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InterMedium(
                                                              text: 'Status:',
                                                              fontsize: 16.sp,
                                                              color: color1,
                                                            ),
                                                            InterMedium(
                                                              text: 'Status',
                                                              fontsize: 16.sp,
                                                              color: color3,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.sp,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  childCount: 3,
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
                                            color: Primarycolor,
                                            fontsize: 14.sp,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Primarycolor,
                                                size: 20.sp,
                                              ),
                                              SizedBox(width: 4.w),
                                              InterBold(
                                                text: 'Create Message',
                                                fontsize: 14.sp,
                                                color: Primarycolor,
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
                                  NavigateScreen(
                                      ClientOpenPatrolScreen(
                                        guardName: '',
                                        startDate: '',
                                        startTime: '',
                                        endTime: '',
                                        patrolLogCount: 0,
                                        status: '',
                                        feedback: '',
                                        checkpoints: [],
                                      ),
                                      context);
                                },
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
                                        margin: EdgeInsets.only(left: 9.w),
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
                                                  CrossAxisAlignment.center,
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
                                                      Icons.arrow_forward_ios,
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
                    : SliverToBoxAdapter()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
