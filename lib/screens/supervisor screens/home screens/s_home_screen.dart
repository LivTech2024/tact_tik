import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/Scheduling/create_shedule_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/widgets/rounded_button.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../services/auth/auth.dart';
import '../../../utils/colors.dart';
import '../../feature screens/petroling/patrolling.dart';
import '../../get started/getstarted_screen.dart';
import '../../home screens/widgets/home_screen_part1.dart';
import '../../home screens/widgets/homescreen_custom_navigation.dart';
import 'Scheduling/all_schedules_screen.dart';

class SHomeScreen extends StatefulWidget {
  const SHomeScreen({super.key});

  @override
  State<SHomeScreen> createState() => _SHomeScreenState();
}

class _SHomeScreenState extends State<SHomeScreen> {
  List IconColors = [Primarycolor, color4, color4, color4];
  int ScreenIndex = 0;
  List<DocumentSnapshot<Object?>> _guardsInfo = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
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
  String _CompanyId = "";

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
          NavigateScreen(AllSchedulesScreen(BranchId: _CompanyId));
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

  void NavigateScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
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
        String CompanyId = userInfo['EmployeeCompanyId'];
        String Imgurl = userInfo['EmployeeImg'];
        var guardsInfo =
            await fireStoreService.getGuardForSupervisor(CompanyId);
        var patrolInfo = await fireStoreService
            .getPatrolsByEmployeeIdFromUserInfo(EmployeeId);
        setState(() {
          _userName = userName;
          _userImg = Imgurl;
          _guardsInfo = guardsInfo;
          _CompanyId = CompanyId;
        });
        print('User Info: ${userInfo.data()}');
      } else {
        print('Shift info not found');
      }
    } else {
      print('User info not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

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
                          onTap: () => ChangeScreenIndex(2),
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
                          if (index < _guardsInfo.length) {
                            return HomeScreenUserCard(
                              guardsInfo: _guardsInfo[index],
                              CompanyId: _CompanyId,
                            );
                          } else {
                            return SizedBox(); // Return an empty SizedBox for index out of bounds
                          }
                        },
                        childCount: _guardsInfo.length,
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

class HomeScreenUserCard extends StatefulWidget {
  final DocumentSnapshot<Object?> guardsInfo;
  String CompanyId;
  HomeScreenUserCard({
    Key? key,
    required this.guardsInfo,
    required this.CompanyId,
  }) : super(key: key);

  @override
  State<HomeScreenUserCard> createState() => _HomeScreenUserCardState();
}

class _HomeScreenUserCardState extends State<HomeScreenUserCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: Container(
        constraints: _expanded
            ? BoxConstraints(minHeight: height / height140)
            : BoxConstraints(minHeight: height / height60),
        decoration: BoxDecoration(
          color: color19,
          borderRadius: BorderRadius.circular(width / width12),
        ),
        margin: EdgeInsets.only(bottom: height / height10),
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: height / height48,
              padding: EdgeInsets.symmetric(horizontal: width / width20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: height / height50,
                        width: width / width50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image:
                                NetworkImage(widget.guardsInfo['EmployeeImg']),
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: width / width20),
                      InterBold(
                        text: widget.guardsInfo['EmployeeName'],
                        letterSpacing: -.3,
                        color: color1,
                      ),
                    ],
                  ),
                  Container(
                    height: height / height16,
                    width: width / width16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  )
                ],
              ),
            ),
            if (_expanded)
              Column(
                children: [
                  Divider(),
                  SizedBox(height: height / height5),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / width20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateSheduleScreen(
                                        GuardId:
                                            widget.guardsInfo["EmployeeId"],
                                        GuardName:
                                            widget.guardsInfo["EmployeeName"],
                                        GuardImg:
                                            widget.guardsInfo["EmployeeImg"],
                                        CompanyId: widget.CompanyId,
                                      )),
                            );
                          },
                          child: RoundedButton(
                            icon: Icons.add,
                          ),
                        ),
                        RoundedButton(
                          icon: Icons.add_card,
                        ),
                        RoundedButton(
                          useSVG: true,
                          svg: 'assets/images/lab_profile.svg',
                        ),
                        RoundedButton(
                          useSVG: true,
                          svg: 'assets/images/device_reset.svg',
                        ),
                      ],
                    ),
                  )
                ],
              ),
          ],
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
