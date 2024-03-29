import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../services/auth/auth.dart';
import '../../../utils/colors.dart';
import '../../feature screens/petroling/patrolling.dart';
import '../../get started/getstarted_screen.dart';
import '../../home screens/widgets/home_screen_part1.dart';
import '../../home screens/widgets/homescreen_custom_navigation.dart';

class SHomeScreen extends StatefulWidget {
  const SHomeScreen({super.key});

  @override
  State<SHomeScreen> createState() => _SHomeScreenState();
}

class _SHomeScreenState extends State<SHomeScreen> {
  List IconColors = [Primarycolor, color4, color4, color4];
  int ScreenIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final Auth auth = Auth();
  String _userName = "";
  String _ShiftDate = "";
  String _ShiftLocation = "";
  String _ShiftName = "";
  String _ShiftEndTime = "";
  String _ShiftStartTime = "";
  double _shiftLatitude = 0;
  double _shiftLongitude = 0;
  String _employeeId = "";
  String _shiftId = "";
  String _patrolArea = "";
  String _patrolTime = "";
  String _patrolDate = "";
  String _patrolCompanyId = "";
  String _patrolLocationName = "";
  int _patrolRestrictedRadius = 0;

  void ChangeScreenIndex(int index) {
    setState(() {
      ScreenIndex = index;
      ChangeIconColor(index);
      print(ScreenIndex);
    });
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

  @override
  void initState() {
    // selectedEvent = events[selectedDay] ?? [];
    _getUserInfo();
    // checkLocation();
    super.initState();
  }

  void _getUserInfo() async {
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
    if (mounted) {
      if (userInfo != null) {
        String userName = userInfo['EmployeeName'];
        String EmployeeId = userInfo['EmployeeId'];
        _employeeId = EmployeeId;
        var shiftInfo =
        await fireStoreService.getShiftByEmployeeIdFromUserInfo(EmployeeId);
        var patrolInfo = await fireStoreService
            .getPatrolsByEmployeeIdFromUserInfo(EmployeeId);
        setState(() {
          _userName = userName;
        });
        print('User Info: ${userInfo.data()}');
        if (patrolInfo != null) {
          String PatrolArea = patrolInfo['PatrolArea'];
          String PatrolCompanyId = patrolInfo['PatrolCompanyId'];
          // Bool PatrolKeepGuardInRadiusOfLocation = patrolInfo['PatrolKeepGuardInRadiusOfLocation'];
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
          print('Shift Info: ${patrolInfo.data()}');

          setState(() {
            _patrolArea = PatrolArea;
            _patrolCompanyId = PatrolCompanyId;
            // _patrolKeepGuardInRadiusOfLocation =
            //     PatrolKeepGuardInRadiusOfLocation;
            _patrolLocationName = PatrolLocationName;
            _patrolRestrictedRadius = PatrolRestrictedRadius;
            _patrolTime = patrolTimeString;
            _patrolDate = patrolDateString;
            // issShift = false;
          });
        }
        if (shiftInfo != null) {
          String shiftDateStr =
          DateFormat.yMMMMd().format(shiftInfo['ShiftDate'].toDate());
          String shiftEndTimeStr = shiftInfo['ShiftEndTime'];
          String shiftStartTimeStr = shiftInfo['ShiftStartTime'];
          String shiftLocation = shiftInfo['ShiftAddress'];
          String shiftName = shiftInfo['ShiftName'];
          String shiftId = shiftInfo['ShiftId'];
          GeoPoint shiftGeolocation = shiftInfo['ShiftLocation'];
          double shiftLocationLatitude = shiftGeolocation.latitude;
          double shiftLocationLongitude = shiftGeolocation.longitude;
          // String employeeImg = shiftInfo['EmployeeImg'];
          setState(() {
            _ShiftDate = shiftDateStr;
            _ShiftEndTime = shiftEndTimeStr;
            _ShiftStartTime = shiftStartTimeStr;
            _ShiftLocation = shiftLocation;
            _ShiftName = shiftName;
            _shiftLatitude = shiftLocationLatitude;
            _shiftLongitude = shiftLocationLongitude;
            _shiftId = shiftId;
            // _employeeImg = employeeImg;
          });
          print('Shift Info: ${shiftInfo.data()}');
        } else {
          print('Shift info not found');
        }
      } else {
        print('User info not found');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery
        .of(context)
        .size
        .height;
    final double width = MediaQuery
        .of(context)
        .size
        .width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Primarycolor, // Background color for the drawer header
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                // Logout icon in red color
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                // Logout text in red color
                onTap: () {
                  auth.signOut(context, GetStartedScreens());
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: height / height40,
            left: width / width30,
            right: width / width30,
          ),
          child: CustomScrollView(
            slivers: [
              HomeScreenPart1(
                userName: _userName,
                // employeeImg: _employeeImg,
                drawerOnClicked: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => ChangeScreenIndex(0),
                          child: HomeScreenCustomNavigation(
                            icon: Icons.add_task,
                            color: IconColors[0],
                          ),
                        ),
                        GestureDetector(
                          // onTap: () => ChangeScreenIndex(1),
                          child: HomeScreenCustomNavigation(
                            icon: Icons.grid_view_rounded,
                            color: IconColors[1],
                          ),
                        ),
                        GestureDetector(
                          // onTap: () => ChangeScreenIndex(2),
                          // onTap: () => ChangeScreenIndex(2),
                          child: HomeScreenCustomNavigation(
                            icon: Icons.calendar_today,
                            color: IconColors[2],
                          ),
                        ),
                        GestureDetector(
                          // onTap: () => ChangeScreenIndex(3),
                          child: HomeScreenCustomNavigation(
                            icon: Icons.chat_bubble_outline,
                            color: IconColors[3],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height / height30)
                  ],
                ),
              ),
              ScreenIndex == 0
                  ? SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return AnimatedContainer(
                      decoration: BoxDecoration(
                        color: color19,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                      width: double.maxFinite,
                      duration: Duration(microseconds: 500),
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              'https://t4.ftcdn.net/jpg/03/64/21/11/360_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg'),
                                          filterQuality:
                                          FilterQuality.high,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    InterBold(
                                      text: 'Harold M. Madrigal',
                                      letterSpacing: -.3,
                                      color: color1,
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                )
                              ],
                            ),

                          )
                        ],
                      ),
                    );
                  },
                ),
              )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

/*SliverToBoxAdapter(
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InterBold(
                                text: 'All Guards',
                                fontsize: 18,
                                color: color1,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 24,
                                    color: Primarycolor,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  InterBold(
                                    text: 'Add',
                                    fontsize: 14,
                                  ),
                                ],
                              )
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return AnimatedContainer(
                                  duration: Duration(microseconds: 500),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      'https://t4.ftcdn.net/jpg/03/64/21/11/360_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg'),
                                                  filterQuality:
                                                      FilterQuality.high,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            InterBold(
                                              text: 'Harold M. Madrigal',
                                              letterSpacing: -.3,
                                              color: color1,
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              height: 16,
                                              width: 16,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green,
                                              ),
                                            )
                                          ],
                                        ),

                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    )*/

/*AnimatedContainer(
                                  duration: Duration(microseconds: 500),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      'https://t4.ftcdn.net/jpg/03/64/21/11/360_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg'),
                                                  filterQuality:
                                                      FilterQuality.high,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            InterBold(
                                              text: 'Harold M. Madrigal',
                                              letterSpacing: -.3,
                                              color: color1,
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              height: 16,
                                              width: 16,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green,
                                              ),
                                            )
                                          ],
                                        ),

                                      )
                                    ],
                                  ),
                                )*/
