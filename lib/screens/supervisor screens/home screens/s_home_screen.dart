import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/login_screen.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import 'package:tact_tik/screens/supervisor%20screens/TrackingScreen/s_tracking_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/history/s_history_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/loogbook/s_loogbook_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/Scheduling/create_shedule_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/widgets/rounded_button.dart';
import 'package:tact_tik/screens/supervisor%20screens/patrol_logs.dart';

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
import '../features screens/assets/select_assets_guards.dart';
import '../features screens/dar/select_dar_guards.dart';
import '../features screens/history/select_history_guards.dart';
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
  List IconColors = [
    isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
    isDark ? DarkColor.color4 : LightColor.color3,
    isDark ? DarkColor.color4 : LightColor.color3,
    isDark ? DarkColor.color4 : LightColor.color3
  ];
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
  String _empEmail = "";
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
          IconColors[0] = DarkColor.Primarycolor;
          IconColors[1] = DarkColor.color4;
          IconColors[2] = DarkColor.color4;
          IconColors[3] = DarkColor.color4;
          ScreenIndex = 0;
          NavigateScreen(AllSchedulesScreen(
            BranchId: '9tgQzYBJTL3QqJKe34eJ',
            CompanyId: 'aSvLtwII6Cjs7uCISBRR',
          ));
          break;
        case 3:
          IconColors[0] = DarkColor.Primarycolor;
          IconColors[1] = DarkColor.color4;
          IconColors[2] = DarkColor.color4;
          IconColors[3] = DarkColor.color4;
          ScreenIndex = 0;
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
    if (isDark) {
      IconColors[0] = DarkColor.Primarycolor;
      IconColors[1] = DarkColor.color4;
      IconColors[2] = DarkColor.color4;
      IconColors[3] = DarkColor.color4;
    } else {
      IconColors[0] = LightColor.Primarycolor;
      IconColors[1] = LightColor.color3;
      IconColors[2] = LightColor.color3;
      IconColors[3] = LightColor.color3;
    }

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
        String EmpEmail = userInfo['EmployeeEmail'];
        // bool isemployeeAvailable = userInfo['EmployeeIsAvailable'];
        var guardsInfo =
            await fireStoreService.getGuardForSupervisor(CompanyId);
        print("Guards INfor ${guardsInfo}");
        var patrolInfo = await fireStoreService
            .getPatrolsByEmployeeIdFromUserInfo(EmployeeId);
        setState(() {
          _userName = userName;
          _userImg = Imgurl;
          _guardsInfo = guardsInfo;
          _CompanyId = CompanyId;
          _employeeId = EmployeeId;
          _empEmail = EmpEmail;
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
      ['assets/images/site_tour.png', 'Track Guard'],
      ['assets/images/dar.png', 'DAR'],
      ['assets/images/reports.png', 'Reports'],
      ['assets/images/post_order.png', 'Post Orders'],
      ['assets/images/task.png', 'Task'], // TODO
      ['assets/images/log_book.png', 'Log Book'],
      ['assets/images/visitors.png', 'Visitors'], // TODO
      ['assets/images/assets.png', 'Assets'],
      ['assets/images/keys.png', 'Key'],
    ];

    

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
          color: isDark
              ? (isSelected ? DarkColor.Primarycolor : DarkColor.color3)
              : (isSelected
                  ? LightColor.Primarycolor
                  : LightColor.color3), // Change color based on selection
          size: 24.w,
        ),
        title: PoppinsBold(
          text: title,
          color: isDark
              ? (isSelected ? DarkColor.Primarycolor : DarkColor.color3)
              : (isSelected ? LightColor.Primarycolor : LightColor.color3),
          fontsize: 14.w,
        ),
        onTap: onPressed,
      );
    }

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKeyS,
        backgroundColor:
            isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        endDrawer: Drawer(
          backgroundColor:
              isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
          child: Column(
            children: [
              Container(
                height: 180.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.w),
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
                        CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/default.png'),
                          foregroundImage: NetworkImage(_userImg),
                          radius: width / width50,
                          backgroundColor: DarkColor.Primarycolor,
                          // maxRadius: width / width50,
                          // minRadius: width / width50,
                        ),
                        SizedBox(height: 10.h),
                        PoppinsSemibold(
                          text: _userName,
                          color: DarkColor.WidgetColor,
                          fontsize: 16.sp,
                          letterSpacing: -.3,
                        ),
                        SizedBox(height: 5.h),
                        PoppinsRegular(
                          text: _empEmail,
                          color:isDark? DarkColor.WidgetColor:LightColor.WidgetColor,
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
                    buildListTile(Icons.home, 'Home', 0, () {}),
                    buildListTile(
                      Icons.account_circle_outlined,
                      'Profile',
                      1,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen()),
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
                    buildListTile(Icons.swipe_down_alt, 'Theme', 5, () {
                      setState(() {
                        isDark = !isDark;
                      });
                    }),
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
                  auth.signOut(context, LoginScreen(), _employeeId);
                },
              ),
              SizedBox(height: 20.h)
            ],
          ),
        ),
        body: CustomScrollView(
          physics: PageScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30.h,
              ),
            ),
            HomeScreenPart1(
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
                            text: 'Guards',
                            icon: Icons.add_task,
                            color: isDark
                                ? (ScreenIndex == 0
                                    ? DarkColor.color1
                                    : DarkColor.color4)
                                : (ScreenIndex == 0
                                    ? LightColor.Primarycolor
                                    : LightColor.color3),
                            textcolor: isDark
                                ? (ScreenIndex == 0
                                    ? DarkColor.color1
                                    : DarkColor.color4)
                                : (ScreenIndex == 0
                                    ? LightColor.Primarycolor
                                    : LightColor.color3),
                          ),
                        ),
                        Bounce(
                          onTap: () => ChangeScreenIndex(1),
                          child: HomeScreenCustomNavigation(
                            text: 'Explore',
                            icon: Icons.grid_view_rounded,
                            color: isDark
                                ? (ScreenIndex == 1
                                    ? DarkColor.color1
                                    : DarkColor.color4)
                                : (ScreenIndex == 1
                                    ? LightColor.Primarycolor
                                    : LightColor.color3),
                            textcolor: isDark
                                ? (ScreenIndex == 1
                                    ? DarkColor.color1
                                    : DarkColor.color4)
                                : (ScreenIndex == 1
                                    ? LightColor.Primarycolor
                                    : LightColor.color3),
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
                            color: isDark
                                ? (ScreenIndex == 2
                                    ? DarkColor.color1
                                    : DarkColor.color4)
                                : (ScreenIndex == 2
                                    ? LightColor.Primarycolor
                                    : LightColor.color3),
                            textcolor: isDark
                                ? (ScreenIndex == 2
                                    ? DarkColor.color1
                                    : DarkColor.color4)
                                : (ScreenIndex == 2
                                    ? LightColor.Primarycolor
                                    : LightColor.color3),
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
                            color: isDark
                                ? (ScreenIndex == 3
                                    ? DarkColor.color1
                                    : DarkColor.color4)
                                : (ScreenIndex == 3
                                    ? LightColor.Primarycolor
                                    : LightColor.color3),
                            textcolor: isDark
                                ? (ScreenIndex == 3
                                    ? DarkColor.color1
                                    : DarkColor.color4)
                                : (ScreenIndex == 3
                                    ? LightColor.Primarycolor
                                    : LightColor.color3),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h)
                  ],
                ),
              ),
            ),
            /*ScreenIndex == 0
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
                          return Center(
                            child: InterMedium(text: 'No Guards Available'),
                          ); // Return an empty SizedBox for index out of bounds
                        }
                      },
                      childCount: _guardsInfo.length,
                    ),
                  )
                :*/
            ScreenIndex == 1
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
                              case 0:
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SPanicScreen(
                                              empId: _employeeId,
                                            )));
                              case 1:
                                Get.to(() => SupervisorTrackingScreen(
                                      companyId: _CompanyId,
                                      guardsInfo: _guardsInfo,
                                    ));
                              //   break;
                              // case 2:
                              //   Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (context) =>
                              //               DarDisplayScreen(
                              //                 EmpEmail: _employeeId,
                              //               )));
                              //   break;
                              case 2:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectDARGuardsScreen(
                                      companyId: _CompanyId,
                                    ),
                                  ),
                                );
                                break;
                              case 4:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SPostOrder(
                                      locationId: 'DrD1H6YXEui4G72EHTEZ',
                                    ),
                                  ),
                                );
                                break;
                              // case 5:
                              //   // TODO Task Screen
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           PatrollLogsScreen(),
                              //     ),
                              //   );
                              //   break;
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
                                        SelectAssetsGuardsScreen(
                                      companyId: _CompanyId,
                                    ),
                                  ),
                                );
                                break;
                              case 9:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SelectKeysGuardsScreen(
                                      companyId: _CompanyId,
                                    ),
                                  ),
                                );
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
            ScreenIndex == 0
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
              color: isDark
                  ? Colors.transparent
                  : LightColor.color3.withOpacity(.05),
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(0, 3),
            )
          ],
          color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
          borderRadius: BorderRadius.circular(12.w),
        ),padding: EdgeInsets.symmetric(
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
                        color: isDark ? DarkColor.color1 : LightColor.color3,
                      ),
                    ],
                  ),
                  Container(
                    height: 16.h,
                    width: 16.w,
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
                                  builder: (context) => CreateSheduleScreen(
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
                        Bounce(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SLogBookScreen(
                                          empId:
                                              widget.guardsInfo['EmployeeId'],
                                          empName:
                                              widget.guardsInfo['EmployeeName'],
                                        )));
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
