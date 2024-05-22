import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/Scheduling/create_shedule_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/widgets/rounded_button.dart';
import 'package:tact_tik/screens/supervisor%20screens/patrol_logs.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/poppins_bold.dart';
import '../../../fonts/poppins_regular.dart';
import '../../../services/auth/auth.dart';
import '../../../utils/colors.dart';
import '../../feature screens/pani button/panic_button.dart';
import '../../feature screens/petroling/patrolling.dart';
import '../../get started/getstarted_screen.dart';
import '../../home screens/widgets/grid_widget.dart';
import '../../home screens/widgets/home_screen_part1.dart';
import '../../home screens/widgets/homescreen_custom_navigation.dart';
import '../features screens/post order/s_post_order_screen.dart';
import 'Scheduling/all_schedules_screen.dart';
import 'message screens/super_inbox.dart';

class SHomeScreen extends StatefulWidget {
  const SHomeScreen({super.key});

  @override
  State<SHomeScreen> createState() => _SHomeScreenState();
}

class _SHomeScreenState extends State<SHomeScreen> {
  List IconColors = [
    isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
    isDark ? DarkColor.color4 : LightColor.color3,
    isDark ? DarkColor.color4 : LightColor.color3,
    isDark ? DarkColor.color4 : LightColor.color3
  ];
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

  bool NewMessage = false;

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
          NavigateScreen(AllSchedulesScreen(BranchId: _CompanyId));
          break;
        case 3:
          IconColors[0] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[1] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[2] = isDark ? DarkColor.color4 : LightColor.color3;
          IconColors[3] =
              isDark ? DarkColor.Primarycolor : LightColor.Primarycolor;
          NavigateScreen(SuperInboxScreen(
            companyId: 'aSvLtwII6Cjs7uCISBRR',
          ));
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
    IconColors[0] = isDark ? DarkColor.Primarycolor : LightColor.Primarycolor;
    IconColors[1] = isDark ? DarkColor.color4 : LightColor.color3;
    IconColors[2] = isDark ? DarkColor.color4 : LightColor.color3;
    IconColors[3] = isDark ? DarkColor.color4 : LightColor.color3;
    ScreenIndex = 0;
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
        // bool isemployeeAvailable = userInfo['EmployeeIsAvailable'];
        var guardsInfo =
            await fireStoreService.getGuardForSupervisor(CompanyId);
        var patrolInfo = await fireStoreService
            .getPatrolsByEmployeeIdFromUserInfo(EmployeeId);
        setState(() {
          _userName = userName;
          _userImg = Imgurl;
          _guardsInfo = guardsInfo;
          _CompanyId = CompanyId;
          _employeeId = EmployeeId;
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

    final List<List<String>> data = [
      ['assets/images/panic_mode.png', 'Panic Mode'],
      ['assets/images/site_tour.png', 'Site Tours'],
      ['assets/images/dar.png', 'DAR'],
      ['assets/images/reports.png', 'Reports'],
      ['assets/images/post_order.png', 'Post Orders'],
      ['assets/images/task.png', 'Task'],
      ['assets/images/log_book.png', 'Log Book'],
      ['assets/images/visitors.png', 'Visitors'],
      ['assets/images/key&assets.png', 'Key & Assets'],
    ];

    int _selectedIndex = 0; // Index of the selected screen

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    ListTile buildListTile(IconData icon, String title, int index,
        {bool isLogout = false}) {
      final bool isSelected = _selectedIndex == index;

      return ListTile(
        leading: Icon(
          icon,
          color: isDark
              ? (isSelected ? DarkColor.Primarycolor : DarkColor.color3)
              : (isSelected
                  ? LightColor.Primarycolor
                  : LightColor.color3), // Change color based on selection
          size: width / width24,
        ),
        title: PoppinsBold(
          text: title,
          color: isDark
              ? (isSelected ? DarkColor.Primarycolor : DarkColor.color3)
              : (isSelected ? LightColor.Primarycolor : LightColor.color3),
          fontsize: width / width14,
        ),
        onTap: () {
          if (!isLogout) {
            _onItemTapped(index);
          } else {
            // Handle logout action
          }
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor:
            isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        endDrawer: Drawer(
          backgroundColor:
              isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
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
              ),
              Expanded(
                child: Column(
                  children: [
                    buildListTile(Icons.home, 'Home', 0),
                    buildListTile(Icons.account_circle_outlined, 'Profile', 1),
                    buildListTile(Icons.add_card, 'Payment', 2),
                    buildListTile(Icons.article, 'Employment Letter', 3),
                    buildListTile(Icons.restart_alt, 'History', 4),
                    buildListTile(Icons.settings, 'Settings', 5),
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
            top: height / height40,
          ),
          child: CustomScrollView(
            physics: PageScrollPhysics(),
            slivers: [
              HomeScreenPart1(
                userName: _userName ?? "",
                // employeeImg: _userImg,
                employeeImg: _userImg ?? "",
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
                              text: 'Guards',
                              icon: Icons.add_task,
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
                              text: 'Explore',
                              icon: Icons.grid_view_rounded,
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
                            onTap: () => ChangeScreenIndex(2),
                            // onTap: () => ChangeScreenIndex(2),
                            child: HomeScreenCustomNavigation(
                              useSVG: true,
                              SVG: 'assets/images/calendar_clock.svg',
                              text: 'Calendar',
                              icon: Icons.calendar_today,
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

                          if (index < _guardsInfo.length) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: width / width30,
                                right: width / width30,
                              ),
                              child: HomeScreenUserCard(
                                guardsInfo: _guardsInfo[index],
                                CompanyId: _CompanyId,
                              ),
                            );
                          } else {
                            return SizedBox(); // Return an empty SizedBox for index out of bounds
                          }
                        },
                        childCount: _guardsInfo.length,
                      ),
                    )
                  : ScreenIndex == 1
                      ? SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Number of columns
                            // mainAxisSpacing: 10.0, // Spacing between rows
                            // crossAxisSpacing: 14.0,
                            // childAspectRatio: 1.0, // Aspect ratio of each grid item (width / height)
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Bounce(
                                onTap: () {
                                  switch (index) {
                                    case 4:
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SPostOrder();
                                        },
                                      );
                                      break;
                                    // case 2:
                                    //   Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //           builder: (context) =>
                                    //               DarDisplayScreen(
                                    //                 EmpEmail: _employeeId,
                                    //               )));
                                    //   break;
                                    case 4:
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SPostOrder()));
                                      break;
                                    case 5:
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PatrollLogsScreen()));
                                      break;
                                    // case 6:
                                    //   Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //           builder: (context) =>
                                    //               LogBookScreen()));
                                    //   break;
                                    // case 7:
                                    //   Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //           builder: (context) =>
                                    //               VisiTorsScreen()));
                                    //   break;
                                    default:
                                  }
                                },
                                child: gridWidget(
                                  img: data[index][0],
                                  tittle: data[index][1],
                                ),
                              );
                            },
                            childCount: 9,
                          ),
                        )
                      : SliverToBoxAdapter(),
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
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? DarkColor.color1.withOpacity(.1)
                  : LightColor.color3.withOpacity(.1),
              blurRadius: 1,
              spreadRadius: 2,
              offset: Offset(0, 3),
            )
          ],
          color: isDark ? DarkColor.color19 : LightColor.WidgetColor,
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
                            image: NetworkImage(
                                widget.guardsInfo['EmployeeImg'] ?? ""),
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: width / width20),
                      InterBold(
                        text: widget.guardsInfo['EmployeeName'] ?? "",
                        letterSpacing: -.3,
                        color: isDark ? DarkColor.color1 : LightColor.color3,
                      ),
                    ],
                  ),
                  Container(
                    height: height / height16,
                    width: width / width16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.guardsInfo['EmployeeIsAvailable'] ==
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
                                            widget.guardsInfo["EmployeeId"] ??
                                                "",
                                        GuardName:
                                            widget.guardsInfo["EmployeeName"] ??
                                                "",
                                        GuardImg:
                                            widget.guardsInfo["EmployeeImg"] ??
                                                "",
                                        CompanyId: widget.CompanyId ?? "",
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
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
