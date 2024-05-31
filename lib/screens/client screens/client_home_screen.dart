import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
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
          .collection('shifts')
          .where('ShiftClientId', isEqualTo: _employeeId)
          .get();

      List<Map<String, dynamic>> fetchedShifts = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'ShiftDate': data['ShiftDate'].toDate(),
          'ShiftName': data['ShiftName'],
          'ShiftLocationAddress': data['ShiftLocationAddress'],
          'ShiftStartTime': data['ShiftStartTime'],
          'ShiftEndTime': data['ShiftEndTime'],
          'members': data['members'],
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
        key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
        endDrawer: Drawer(
          child: Column(
            children: [
              Container(
                height: height / height180,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width / width15),
                  color: Primarycolor, // Background color for the drawer header
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
                                textcolor: ScreenIndex == 0 ? color1 : color4,
                              ),
                            ),
                            Bounce(
                              onTap: () => ChangeScreenIndex(1),
                              child: HomeScreenCustomNavigation(
                                text: 'Shifts',
                                icon: Icons.add_task,
                                color: IconColors[1],
                                textcolor: ScreenIndex == 1 ? color1 : color4,
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
                        SizedBox(height: height / height30)
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
                                left: width / width30,
                                right: width / width30,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // NavigateScreen(
                                  //     ClientCheckPatrolScreen(
                                  //       PatrolIdl: '',
                                  //     ),
                                  //     context);
                                  print("Clicked");
                                  // NavigateScreen(
                                  //     ClientCheckPatrolScreen(
                                  //       PatrolIdl: PatrolId,
                                  //     ),
                                  //     context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ClientCheckPatrolScreen(
                                                  PatrolIdl: PatrolId)));
                                },
                                child: Container(
                                  height: height / height160,
                                  margin:
                                      EdgeInsets.only(top: height / height10),
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    color: Primarycolor,
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
                                              color: WidgetColor,
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
                                                  text: PatrolName ?? "",
                                                  color: color22,
                                                  fontsize: width / width14,
                                                ),
                                                SizedBox(
                                                    height: height / height5),
                                                InterRegular(
                                                  text: PatrolLocation ?? "",
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
                                                    color: color22,
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
                                                              color23,
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
                                                    color: color22,
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
                                                        color: color22,
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              width / width6),
                                                      InterMedium(
                                                        text: CheckpointCount
                                                                .toString() ??
                                                            "",
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
                                                    color: color22,
                                                    fontsize: width / width14,
                                                  ),
                                                  SizedBox(
                                                      height: height / height5),
                                                  Row(
                                                    children: [
                                                      // SvgPicture.asset(
                                                      //   'assets/images/avg_pace.svg',
                                                      //   width: width / width24,
                                                      // ),
                                                      SizedBox(
                                                          width:
                                                              width / width6),
                                                      InterMedium(
                                                        text: "2",
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
                          childCount: patrolsList.length,
                        ),
                      )
                    : ScreenIndex == 1
                        ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      DateTime shiftDate = shifts[index]['ShiftDate'];
                      String dateString = (isSameDate(shiftDate, DateTime.now()))
                          ? 'Today'
                          : "${shiftDate.day} / ${shiftDate.month} / ${shiftDate.year}";

                      return Padding(
                        padding: EdgeInsets.only(
                          left: width / 30,
                          right: width / 30,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterBold(
                                text: dateString,
                                color: Primarycolor,
                                fontsize: width / 14,
                              ),
                              SizedBox(
                                height: height / 10,
                              ),
                              Container(
                                height: height / 160,
                                margin: EdgeInsets.only(top: height / 10),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  color: Primarycolor,
                                  borderRadius: BorderRadius.circular(width / 14),
                                ),
                                padding: EdgeInsets.symmetric(vertical: height / 20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: height / 30,
                                          width: width / 4,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(width / 10),
                                              bottomRight: Radius.circular(width / 10),
                                            ),
                                            color: color22,
                                          ),
                                        ),
                                        SizedBox(width: width / 14),
                                        SizedBox(
                                          width: width / 190,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              InterSemibold(
                                                text: shifts[index]['ShiftName'],
                                                color: color22,
                                                fontsize: width / 14,
                                              ),
                                              SizedBox(height: height / 5),
                                              InterRegular(
                                                text: shifts[index]
                                                ['ShiftLocationAddress'],
                                                maxLines: 1,
                                                fontsize: width / 14,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: height / 10),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: width / 18,
                                        right: width / 24,
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: width / 100,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                InterRegular(
                                                  text: 'Guards',
                                                  fontsize: width / 14,
                                                  color: color22,
                                                ),
                                                SizedBox(height: height / 12),
                                                Wrap(
                                                  spacing: -5.0,
                                                  children: [
                                                    for (int i = 0;
                                                    i <
                                                        (shifts[index]['members']
                                                            .length >
                                                            3
                                                            ? 3
                                                            : shifts[index]
                                                        ['members']
                                                            .length);
                                                    i++)
                                                      CircleAvatar(
                                                        radius: width / 10,
                                                        backgroundImage: NetworkImage(
                                                          shifts[index]['members'][i],
                                                        ),
                                                      ),
                                                    if (shifts[index]['members']
                                                        .length >
                                                        3)
                                                      CircleAvatar(
                                                        radius: width / 12,
                                                        backgroundColor: color23,
                                                        child: InterMedium(
                                                          text:
                                                          '+${shifts[index]['members'].length - 3}',
                                                          fontsize: width / 12,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: width / 100,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                InterRegular(
                                                  text: 'Started At',
                                                  color: color22,
                                                  fontsize: width / 14,
                                                ),
                                                SizedBox(height: height / 5),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle_outlined,
                                                      size: width / 24,
                                                      color: color22,
                                                    ),
                                                    SizedBox(width: width / 6),
                                                    InterMedium(
                                                      text: shifts[index]
                                                      ['ShiftStartTime'],
                                                      fontsize: width / 14,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: width / 100,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                InterRegular(
                                                  text: 'Ended At',
                                                  color: color22,
                                                  fontsize: width / 14,
                                                ),
                                                SizedBox(height: height / 5),
                                                Row(
                                                  children: [
                                                    SizedBox(width: width / 6),
                                                    InterMedium(
                                                      text: shifts[index]
                                                      ['ShiftEndTime'],
                                                      fontsize: width / 14,
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
                                height: height / 10,
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
                                            color: Primarycolor,
                                            fontsize: width / width14,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Primarycolor,
                                                size: width / width20,
                                              ),
                                              SizedBox(width: width / width4),
                                              InterBold(
                                                text: 'Create Message',
                                                fontsize: width / width14,
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
                                  height: height / height80,
                                  margin: EdgeInsets.only(
                                    top: height / height10,
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
                                                  color: color1,
                                                ),
                                                Row(
                                                  // mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    PoppinsRegular(
                                                      text: '9:36 AM',
                                                      color: color3,
                                                      fontsize: width / width14,
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: color1,
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
