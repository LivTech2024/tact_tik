import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/create_discrepancy_screen.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/pay_discrepancy_screen.dart';
import 'package:tact_tik/screens/client%20screens/DAR/client_dar.dart';
import 'package:tact_tik/screens/client%20screens/Reports/client_report_screen.dart';
import 'package:tact_tik/screens/new%20guard/new_guard_screen.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/write_msg_screen.dart';
import '../../../common/sizes.dart';
import '../../../fonts/poppins_light.dart';
import '../../../fonts/poppis_semibold.dart';
import '../../../utils/colors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../SideBar Screens/profile_screen.dart';
import '../../client screens/client_profile_screen.dart';
import '../../feature screens/Log Book/logbook_screen.dart';
import '../../feature screens/Report/report_screen.dart';
import '../../feature screens/assets/assets_screen.dart';
import '../../feature screens/dar/dar_screen.dart';
import '../../feature screens/keys/keys_screen.dart';
import '../../feature screens/post_order.dart/post_order_screen.dart';
import '../../feature screens/site_tours/site_tour_screen.dart';
import '../../feature screens/task/task_feature_screen.dart';
import '../../feature screens/visitors/visitors.dart';
import '../guard_notification_screen.dart';
import '../notification_screen.dart';

class Screens {
  final String name;
  final IconData icon;

  Screens(this.name, this.icon);
}

class HomeScreenPart1 extends StatefulWidget {
  final String userName;
  final String employeeImg;
  final String empId;
  final String? empEmail;
  final String shiftCompanyId;
  final String branchId;
  final String shiftId;
  final String shiftClientId;
  final String shiftLocationId;
  final String shiftLocationName;
  final bool isEmployee;

  // final String url;
  final VoidCallback drawerOnClicked;
  final bool? showWish;
  final bool isClient;

  const HomeScreenPart1({
    Key? key,
    required this.userName,
    // required this.url,
    required this.employeeImg,
    required this.drawerOnClicked,
    this.showWish = true,
    this.isEmployee = true,
    required this.empId,
    required this.empEmail,
    required this.shiftCompanyId,
    required this.branchId,
    required this.shiftId,
    required this.shiftClientId,
    required this.shiftLocationId,
    required this.shiftLocationName,
    required this.isClient,
  }) : super(key: key);

  @override
  State<HomeScreenPart1> createState() => _HomeScreenPart1State();
}

class _HomeScreenPart1State extends State<HomeScreenPart1> {
  bool isUnread = true;

  bool cleartext = false;

  DateTime now = DateTime.now();

  int hour = DateTime.now().hour;

  String greeting = 'Loading..';

  final TextEditingController _controller = TextEditingController();

  final List<Screens> _screens = [
    Screens('Site Tours', Icons.ac_unit_outlined),
    Screens('DAR Screen', Icons.ac_unit_outlined),
    Screens('Reports Screen', Icons.ac_unit_outlined),
    Screens('Post Screen', Icons.ac_unit_outlined),
    Screens('Task Screen', Icons.ac_unit_outlined),
    Screens('LogBook Screen', Icons.ac_unit_outlined),
    Screens('Visitors Screen', Icons.ac_unit_outlined),
    Screens('Assets Screen', Icons.ac_unit_outlined),
    Screens('Key Screen', Icons.ac_unit_outlined),
  ];

  final List<Screens> _ClientScreens = [
    Screens('Dar Screen', Icons.ac_unit_outlined),
    Screens('Report Screen', Icons.ac_unit_outlined),
  ];

  Widget gridLayoutBuilder(
    BuildContext context,
    List<Widget> items,
  ) {
    return Container(
      color: Theme.of(context).cardColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 58,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        reverse:
            SuggestionsController.of<Screens>(context).effectiveDirection ==
                VerticalDirection.up,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  Future<List<Screens>> suggestionsCallback(String pattern) async =>
      Future<List<Screens>>.delayed(
        Duration(milliseconds: 300),
        () => _screens.where((product) {
          // print(product.name);
          final nameLower = product.name.toLowerCase().split(' ').join('');
          final patternLower = pattern.toLowerCase().split(' ').join('');
          return nameLower.contains(patternLower);
        }).toList(),
      );

  Future<List<Screens>> ClientsuggestionsCallback(String pattern) async =>
      Future<List<Screens>>.delayed(
        Duration(milliseconds: 300),
        () => _ClientScreens.where((product) {
          // print(product.name);
          final nameLower = product.name.toLowerCase().split(' ').join('');
          final patternLower = pattern.toLowerCase().split(' ').join('');
          return nameLower.contains(patternLower);
        }).toList(),
      );

  /*_ClientScreens*/

  @override
  Widget build(BuildContext context) {
    // final double height = MediaQuery.of(context).size.height;
    // final double width = MediaQuery.of(context).size.width;
    if (hour < 12) {
      greeting = 'Good Morning,';
    } else if (hour < 18) {
      greeting = 'Good Afternoon,';
    } else {
      greeting = 'Good Evening,';
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 30.w,
        right: 30.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          SizedBox(
            height: 55.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => widget.isEmployee
                            ? ProfileScreen(
                                empId: widget.empId,
                              )
                            : ClientProfileScreen(
                                empId: widget.empId,
                              ),
                      ),
                    );
                  },
                  child: Container(
                    height: 55.h,
                    width: 55.w,
                    decoration: widget.employeeImg != ""
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(widget.employeeImg ?? ""),
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                            ),
                          )
                        : BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                            image: DecorationImage(
                              image: AssetImage('assets/images/default.png'),
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                Row(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            //   TODO If the role is guard then Navigate to this
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        GuardNotificationScreen()));

                            // TODO: If the role is client and supervisor then Navigate this.
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => NotificationScreen()));
                          },
                          child: Icon(
                            Icons.notifications,
                            // Use the notifications_active icon
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .color, // Change color if unread
                            size: 28.sp,
                          ),
                        ),
                        if (isUnread)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(2.sp),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color, // Background color for unread indicator
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      width: 26.w,
                    ),
                    GestureDetector(
                      onTap: widget.drawerOnClicked,
                      child: Transform.scale(
                        scaleX: -1,
                        child: Icon(
                          Icons.short_text_rounded,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                          size: 40.sp,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: widget.showWish! ? 40.h : 57.h),
          widget.showWish!
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PoppinsSemibold(
                      text: '${greeting}',
                      color: Theme.of(context).textTheme.bodySmall!.color,
                      letterSpacing: -.5,
                      fontsize: 35.sp,
                    ),
                    SizedBox(height: 2.h),
                    PoppinsLight(
                      text:
                          widget.userName != '' ? widget.userName : 'Loading..',
                      color: Theme.of(context).textTheme.bodySmall!.color,
                      fontsize: 30.sp,
                    ),
                    SizedBox(height: 46.h),
                  ],
                )
              : const SizedBox(),
          Container(
            constraints: BoxConstraints(
              minHeight: cleartext ? 64.h : 64.h,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
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
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TypeAheadField<Screens>(
                        autoFlipDirection: false,
                        controller: _controller,
                        direction: VerticalDirection.down,
                        builder: (context, _controller, focusNode) => TextField(
                          maxLength: 20,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          onTapOutside: (event) {
                            print('onTapOutside');
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          onChanged: (text) {
                            setState(() {
                              if (text != '') {
                                cleartext = true;
                              } else {
                                cleartext = false;
                              }
                            });
                          },
                          controller: _controller,
                          focusNode: focusNode,
                          autofocus: false,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300,
                            fontSize: 18.sp,
                            color:
                                Theme.of(context).textTheme.titleLarge!.color,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.r),
                              ),
                            ),
                            focusedBorder: InputBorder.none,
                            hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w300,
                              fontSize: 18.sp,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                            hintText: 'Search screen',
                            contentPadding: EdgeInsets.zero,
                            counterText: "",
                          ),
                          cursorColor: Theme.of(context).primaryColor,
                        ),
                        suggestionsCallback: widget.isEmployee
                            ? suggestionsCallback
                            : ClientsuggestionsCallback,
                        itemBuilder: (context, Screens screen) {
                          return ListTile(
                            leading:
                                Icon(screen.icon, color: Colors.blueAccent),
                            title: InterRegular(
                              text: screen.name,
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          );
                        },
                        emptyBuilder: (context) => Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.h,
                            horizontal: 10.w,
                          ),
                          child: InterRegular(
                            text: 'No Such Screen found',
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: 18.sp,
                          ),
                        ),
                        decorationBuilder: (context, child) => Material(
                          type: MaterialType.card,
                          elevation: 4,
                          borderRadius: BorderRadius.circular(10.r),
                          child: child,
                        ),
                        debounceDuration: const Duration(milliseconds: 300),
                        onSelected: (Screens value) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          print(
                              'home screen search bar############################################');

                          print(value.name);
                          if (widget.isClient) {
                            switch (value) {
                              case 'DAR Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClientDarScreen(
                                          clientId: widget.empId,
                                          companyId:
                                              widget.shiftCompanyId ?? ""),
                                    ));
                                break;

                              case 'Reports Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClientReportScreen(
                                        employeeId: widget.empId,
                                        companyId: widget.shiftCompanyId,
                                      ),
                                    ));
                                break;
                            }
                          } else {
                            switch (value) {
                              case 'Site Tours':
                                // showDialog(
                                //   context: context,
                                //   builder: (BuildContext context) {
                                //     return SiteTourScreen(
                                //       height: height,
                                //       width: width,
                                //       schedulesList: schedules_list,
                                //     );
                                //   },
                                // );
                                break;
                              case 'DAR Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DarDisplayScreen(
                                              EmpEmail: widget.empEmail,
                                              EmpID: widget.empId,
                                              EmpDarCompanyId:
                                                  widget.shiftCompanyId ?? "",
                                              EmpDarCompanyBranchId:
                                                  widget.branchId,
                                              EmpDarShiftID: widget.shiftId,
                                              EmpDarClientID:
                                                  widget.shiftClientId,
                                              Username: widget.userName,
                                            )));
                                break;
                              case 'Reports Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportScreen(
                                              locationId:
                                                  widget.shiftLocationId,
                                              locationName:
                                                  widget.shiftLocationId,
                                              companyId:
                                                  widget.shiftCompanyId ?? "",
                                              empId: widget.empId,
                                              empName: widget.userName,
                                              clientId: widget.shiftClientId,
                                              ShiftId: widget.shiftId,
                                              isguard: false,
                                              BranchID: widget.branchId,
                                            )));
                                break;
                              case 'Post Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PostOrder(
                                              locationId:
                                                  widget.shiftLocationId,
                                            )));
                                break;
                              case 'Task Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TaskFeatureScreen()));
                                break;
                              case 'LogBook Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LogBookScreen(
                                              EmpId: widget.empId,
                                            )));
                                break;
                              case 'Visitors Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VisiTorsScreen(
                                              locationId:
                                                  widget.shiftLocationId,
                                            )));
                                break;
                              case 'Assets Screen':
                              case 'Assets Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            // KeysScreen(
                                            //     keyId: _employeeId)
                                            AssetsScreen(
                                                assetEmpId: widget.empId)));
                                break;
                              case 'Key Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => KeysScreen(
                                              LocationId:
                                                  widget.shiftLocationId,
                                              keyId: widget.empId,
                                              companyId: widget.shiftCompanyId,
                                              branchId: widget.branchId,
                                            )));
                              // AssetsScreen(
                              //     assetEmpId:
                              //         _employeeId)
                              case 'Reports Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClientReportScreen(
                                        companyId: widget.shiftCompanyId,
                                        employeeId: widget.empId,
                                      ),
                                    ));
                                break;
                            }

                            switch (value) {
                              case 'Site Tours':
                                // showDialog(
                                //   context: context,
                                //   builder: (BuildContext context) {
                                //     return SiteTourScreen(
                                //       height: height,
                                //       width: width,
                                //       schedulesList: schedules_list,
                                //     );
                                //   },
                                // );
                                break;
                              case 'DAR Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DarDisplayScreen(
                                              EmpEmail: widget.empEmail,
                                              EmpID: widget.empId,
                                              EmpDarCompanyId:
                                                  widget.shiftCompanyId ?? "",
                                              EmpDarCompanyBranchId:
                                                  widget.branchId,
                                              EmpDarShiftID: widget.shiftId,
                                              EmpDarClientID:
                                                  widget.shiftClientId,
                                              Username: widget.userName,
                                            )));
                                break;
                              case 'Reports Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportScreen(
                                              locationId:
                                                  widget.shiftLocationId,
                                              locationName:
                                                  widget.shiftLocationId,
                                              companyId:
                                                  widget.shiftCompanyId ?? "",
                                              empId: widget.empId,
                                              empName: widget.userName,
                                              clientId: widget.shiftClientId,
                                              ShiftId: widget.shiftId,
                                              isguard: false,
                                              BranchID: widget.branchId,
                                            )));
                                break;
                              case 'Post Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PostOrder(
                                              locationId:
                                                  widget.shiftLocationId,
                                            )));
                                break;
                              case 'Task Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TaskFeatureScreen()));
                                break;
                              case 'LogBook Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LogBookScreen(
                                              EmpId: widget.empId,
                                            )));
                                break;
                              case 'Visitors Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VisiTorsScreen(
                                              locationId:
                                                  widget.shiftLocationId,
                                            )));
                                break;
                              case 'Assets Screen':
                              case 'Assets Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            // KeysScreen(
                                            //     keyId: _employeeId)
                                            AssetsScreen(
                                                assetEmpId: widget.empId)));
                                break;
                              case 'Key Screen':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => KeysScreen(
                                              LocationId:
                                                  widget.shiftLocationId,
                                              keyId: widget.empId,
                                              companyId: widget.shiftCompanyId,
                                              branchId: widget.branchId,
                                            )
                                        // AssetsScreen(
                                        //     assetEmpId:
                                        //         _employeeId)

                                        ));
                                break;
                            }
                          }
                        },
                        listBuilder: gridLayoutBuilder,
                      ),
                    ),
                    Container(
                      height: 43.h,
                      width: 43.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.search,
                          size: 19.sp,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    )
                  ],
                ),
                cleartext
                    ? TextButton(
                        onPressed: () {
                          setState(() {
                            cleartext = false;
                            _controller.text = '';
                          });
                        },
                        child: InterRegular(
                          text: 'CLEAR',
                          fontsize: 14.sp,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
