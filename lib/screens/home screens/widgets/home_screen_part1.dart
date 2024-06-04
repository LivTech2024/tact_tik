import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import '../../../common/sizes.dart';
import '../../../fonts/poppins_light.dart';
import '../../../fonts/poppis_semibold.dart';
import '../../../utils/colors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../feature screens/Log Book/logbook_screen.dart';
import '../../feature screens/Report/report_screen.dart';
import '../../feature screens/assets/assets_screen.dart';
import '../../feature screens/dar/dar_screen.dart';
import '../../feature screens/keys/keys_screen.dart';
import '../../feature screens/post_order.dart/post_order_screen.dart';
import '../../feature screens/site_tours/site_tour_screen.dart';
import '../../feature screens/task/task_feature_screen.dart';
import '../../feature screens/visitors/visitors.dart';

class Screens {
  final String name;
  final IconData icon;

  Screens(this.name, this.icon);
}

class HomeScreenPart1 extends StatelessWidget {
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



  // final String url;
  final VoidCallback drawerOnClicked;
  bool? showWish;

  HomeScreenPart1({
    Key? key,
    required this.userName,
    // required this.url,
    required this.employeeImg,
    required this.drawerOnClicked,
    this.showWish = true, required this.empId, required this.empEmail, required this.shiftCompanyId, required this.branchId, required this.shiftId, required this.shiftClientId, required this.shiftLocationId, required this.shiftLocationName,
  }) : super(key: key);

  bool isUnread = true;
  DateTime now = DateTime.now();
  int hour = DateTime.now().hour;
  String greeting = 'Good ';
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

  Widget gridLayoutBuilder(
    BuildContext context,
    List<Widget> items,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 58,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      reverse: SuggestionsController.of<Screens>(context).effectiveDirection ==
          VerticalDirection.up,
      itemBuilder: (context, index) => items[index],
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

    return SliverToBoxAdapter(
      child: Padding(
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
                  Container(
                    height: 55.h,
                    width: 55.w,
                    decoration: employeeImg != ""
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(employeeImg ?? ""),
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                            ),
                          )
                        : BoxDecoration(
                            shape: BoxShape.circle,
                            color: Primarycolor,
                            image: DecorationImage(
                              image: AssetImage('assets/images/default.png'),
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Icon(
                            Icons.notifications,
                            // Use the notifications_active icon
                            color: Primarycolor, // Change color if unread
                            size: 28.sp,
                          ),
                          if (isUnread)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(2.sp),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Primarycolor, // Background color for unread indicator
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        width: 26.w,
                      ),
                      GestureDetector(
                        onTap: drawerOnClicked,
                        child: Transform.scale(
                          scaleX: -1,
                          child: Icon(
                            Icons.short_text_rounded,
                            color: Primarycolor,
                            size: 40.sp,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: showWish! ? 40.h : 57.h),
            showWish!
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PoppinsSemibold(
                        text: '${greeting}',
                        color: Primarycolor,
                        letterSpacing: -.5,
                        fontsize: 35.sp,
                      ),
                      SizedBox(height: 2.h),
                      PoppinsLight(
                        text: userName != '' ? userName : 'User not found',
                        color: Primarycolor,
                        fontsize: 30.sp,
                      ),
                      SizedBox(height: 46.h),
                    ],
                  )
                : const SizedBox(),
            Container(
              height: 64.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: WidgetColor,
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TypeAheadField<Screens>(
                      autoFlipDirection: true,
                      controller: _controller,
                      direction: VerticalDirection.down,
                      builder: (context, _controller, focusNode) => TextField(
                        // maxLength: 20,
                        // maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        controller: _controller,
                        focusNode: focusNode,
                        autofocus: false,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w300,
                          fontSize: 18.sp,
                          color: Colors.white,
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
                            color: color2,
                          ),
                          hintText: 'Search screen',
                          contentPadding: EdgeInsets.zero,
                        ),
                        cursorColor: Primarycolor,
                      ),
                      suggestionsCallback: suggestionsCallback,
                      itemBuilder: (context, Screens screen) {
                        return ListTile(
                          leading: Icon(screen.icon, color: Colors.blueAccent),
                          title: InterRegular(
                            text: screen.name,
                            color: color2,
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
                          color: color2,
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
                        print(
                            'home screen search bar############################################');

                        print(value.name);
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
                                    builder: (context) =>
                                    DarDisplayScreen(
                                      EmpEmail: empEmail,
                                      EmpID: empId,
                                      EmpDarCompanyId:
                                      shiftCompanyId ?? "",
                                      EmpDarCompanyBranchId:
                                      branchId,
                                      EmpDarShiftID: shiftId,
                                      EmpDarClientID:
                                      shiftClientId,
                                      Username: userName,
                                    )));
                            break;
                          case 'Reports Screen':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ReportScreen(
                                          locationId:
                                          shiftLocationId,
                                          locationName:
                                          shiftLocationId,
                                          companyId:
                                          shiftCompanyId ?? "",
                                          empId: empId,
                                          empName: userName,
                                          clientId: shiftClientId,
                                          ShiftId: shiftId,
                                        )));
                            break;
                          case 'Post Screen':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PostOrder(
                                      locationId:
                                      shiftLocationId,
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
                                    builder: (context) =>
                                        LogBookScreen(
                                          EmpId: empId,
                                        )));
                            break;
                          case 'Visitors Screen':
                            Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VisiTorsScreen(
                                                      locationId:
                                                          shiftLocationId,
                                                    )));
                            break;
                          case 'Assets Screen':
                            Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    // KeysScreen(
                                                    //     keyId: _employeeId)
                                                    AssetsScreen(
                                                        assetEmpId:
                                                            empId)));
                            break;
                          case 'Key Screen':
                            Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    KeysScreen(
                                                        keyId: empId, companyId: shiftCompanyId,
                                                    )
                                                // AssetsScreen(
                                                //     assetEmpId:
                                                //         _employeeId)

                                                ));
                            break;
                        }
                      },
                      listBuilder: gridLayoutBuilder,
                    ),
                  ),
                  /*Expanded(
                    child: TextField(
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w300,
                        fontSize: width / width18,
                        color: Colors.white, // Change text color to white
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(
                            Radius.circular(width / width10),
                          ),
                        ),
                        focusedBorder: InputBorder.none,
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w300,
                          fontSize: width / width18,
                          color: color2, // Change text color to white
                        ),
                        hintText: 'Search',
                        contentPadding: EdgeInsets.zero, // Remove padding
                      ),
                      cursorColor: Primarycolor,
                    ),
                  ),*/

                  Container(
                    height: 43.h,
                    width: 43.w,
                    decoration: BoxDecoration(
                      color: Primarycolor,
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.search,
                        size: 19.sp,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
