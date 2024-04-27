import 'dart:async';
import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'package:tact_tik/fonts/poppis_semibold.dart';
import 'package:tact_tik/screens/feature%20screens/Log%20Book/logbook_screen.dart';
import 'package:tact_tik/screens/feature%20screens/dar/create_dar_screen.dart';
import 'package:tact_tik/screens/feature%20screens/dar/dar_screen.dart';
import 'package:tact_tik/screens/get%20started/getstarted_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/custom_calendar.dart';
import 'package:tact_tik/screens/home%20screens/widgets/grid_widget.dart';
import 'package:tact_tik/screens/home%20screens/widgets/home_screen_part1.dart';
import 'package:tact_tik/screens/home%20screens/widgets/homescreen_custom_navigation.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import 'package:tact_tik/screens/home%20screens/widgets/task_screen.dart';
import 'package:tact_tik/services/LocationChecker/LocationCheckerFucntions.dart';
import 'package:tact_tik/services/auth/auth.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import '../../common/sizes.dart';
import '../../fonts/poppins_light.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../fonts/roboto_bold.dart';
import '../../fonts/roboto_medium.dart';
import '../../services/EmailService/EmailJs_fucntion.dart';
import '../../utils/utils.dart';
import '../SideBar Screens/employment_letter.dart';
import '../SideBar Screens/history_screen.dart';
import '../SideBar Screens/profile_screen.dart';
import '../feature screens/pani button/panic_button.dart';
import '../feature screens/post_order.dart/post_order_screen.dart';
import '../feature screens/task/task_feature_screen.dart';
import '../feature screens/visitors/visitors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final LocalStorage storage = LocalStorage('ShiftDetails');

class _HomeScreenState extends State<HomeScreen> {
  //Get the current User
  final Auth auth = Auth();
  String _userName = "";
  String employeeImg = "";
  String _ShiftDate = "";
  String _ShiftLocation = "";
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
  late GoogleMapController mapController;
  List<DocumentSnapshot> schedules_list = [];
  final LatLng _center =
      const LatLng(19.3505737, 72.9158990); // San Francisco coordinates
  final double _zoom = 12.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _showWish = true;
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
    // checkLocation();
    // Timer.periodic(Duration(seconds: 1), (Timer timer) {
    //   // checkLocation();
    // });
    super.initState();
  }

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
  }

  void _getUserInfo() async {
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
    if (mounted) {
      if (userInfo != null) {
        String userName = userInfo['EmployeeName'];
        String EmployeeId = userInfo['EmployeeId'];
        String empEmail = userInfo['EmployeeEmail'];
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

    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

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
                                  'https://images.ctfassets.net/hrltx12pl8hq/28ECAQiPJZ78hxatLTa7Ts/2f695d869736ae3b0de3e56ceaca3958/free-nature-images.jpg?fit=fill&w=1200&h=630',
                                  fit: BoxFit.cover,
                                )),
                          ),
                        ),
                        SizedBox(height: height / height10),
                        PoppinsSemibold(
                          text: 'Nick Jones',
                          color: WidgetColor,
                          fontsize: width / width16,
                          letterSpacing: -.3,
                        ),
                        SizedBox(height: height / height5),
                        PoppinsRegular(
                          text: 'nickjones077@gmail.com',
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
                                builder: (context) => ProfileScreen()));
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
                                icon: Icons.add_task,
                                color: IconColors[0],
                              ),
                            ),
                            Bounce(
                              onTap: () => ChangeScreenIndex(1),
                              child: HomeScreenCustomNavigation(
                                icon: Icons.grid_view_rounded,
                                color: IconColors[1],
                              ),
                            ),
                            Bounce(
                              onTap: () => ChangeScreenIndex(2),
                              child: HomeScreenCustomNavigation(
                                icon: Icons.calendar_today,
                                color: IconColors[2],
                              ),
                            ),
                            Bounce(
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
                ),
                ScreenIndex == 0
                    ? SliverToBoxAdapter(
                        child: Padding(
                            padding: EdgeInsets.only(
                              left: width / width30,
                              right: width / width30,
                            ),
                            child: PageStorage(
                              bucket: PageStorageBucket(),
                              child: TaskScreen(
                                ShiftDate: _ShiftDate,
                                ShiftStartTime: _ShiftStartTime,
                                ShiftLocation: _ShiftLocation,
                                ShiftName: _ShiftLocation,
                                ShiftEndTime: _ShiftEndTime,
                                isWithINRadius: isWithinRadius,
                                empId: _employeeId,
                                shiftId: _shiftId,
                                patrolDate: _patrolDate,
                                patrolTime: _patrolTime,
                                patrollocation: _patrolArea,
                                issShiftFetched: issShift,
                                EmpEmail: _empEmail,
                                Branchid: _branchId,
                                cmpId: _cmpId,
                                EmpName: _userName,
                                ShiftLatitude: _shiftLatitude,
                                shiftLongitude: _shiftLongitude,
                                ShiftRadius: _shiftRestrictedRadius,
                                CheckUserRadius:
                                    _shiftKeepGuardInRadiusOfLocation,
                                ShiftCompanyId: _ShiftCompanyId ?? "",
                                ShiftBranchId: _ShiftBranchId ?? "",
                                ShiftLocationId: _shiftLocationId,
                                ShiftClientId: _shiftCLientId,
                                onRefreshHomeScreen: _refreshScreen,
                                onEndTask: _refreshScreen,
                                onRefreshStartTaskScreen: () {
                                  refreshHomeScreen();
                                },
                              ),
                            )),
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
                                      case 0:
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return PanicAlertDialog();
                                          },
                                        );
                                        break;
                                      case 2:
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DarDisplayScreen(
                                                      EmpEmail: _empEmail,
                                                      EmpID: _employeeId,
                                                      EmpDarCompanyId:
                                                          _ShiftCompanyId ?? '',
                                                      EmpDarCompanyBranchId:
                                                          _ShiftCompanyId ?? "",
                                                      EmpDarShiftID: _shiftId,
                                                      EmpDarClientID:
                                                          _shiftCLientId ?? "",
                                                    )));
                                        break;
                                      case 4:
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PostOrder()));
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
                                                    LogBookScreen()));
                                        break;
                                      case 7:
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VisiTorsScreen()));
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
                              childCount: 9,
                            ),
                          )
                        : ScreenIndex == 2
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
                            : const SizedBox(),
                ScreenIndex == 2
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
                    : SliverToBoxAdapter()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
