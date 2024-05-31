import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/new%20guard/new_guard_screen.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import '../../../common/sizes.dart';
import '../../../fonts/poppins_light.dart';
import '../../../fonts/poppis_semibold.dart';
import '../../../utils/colors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../feature screens/site_tours/site_tour_screen.dart';

class Screens {
  final String name;
  final IconData icon;

  Screens(this.name, this.icon);
}

class HomeScreenPart1 extends StatefulWidget {
  final String userName;
  final String employeeImg;

  // final String url;
  final VoidCallback drawerOnClicked;
  bool? showWish;

  HomeScreenPart1({
    Key? key,
    required this.userName,
    // required this.url,
    required this.employeeImg,
    required this.drawerOnClicked,
    this.showWish = true,
  }) : super(key: key);

  @override
  State<HomeScreenPart1> createState() => _HomeScreenPart1State();
}

class _HomeScreenPart1State extends State<HomeScreenPart1> {
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
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
          left: width / width30,
          right: width / width30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height / height55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: height / height50,
                    width: width / width50,
                    decoration:widget. employeeImg != ""
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
                            color: isDark ? DarkColor.Primarycolor : LightColor.color3,
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context,MaterialPageRoute(builder:  (context) => NewGuardScreen()));
                            },
                            child: Icon(
                              Icons.notifications,
                              // Use the notifications_active icon
                              color: isDark
                                  ? DarkColor.Primarycolor
                                  : LightColor.color3, // Change color if unread
                              size: width / width28,
                            ),
                          ),
                          if (isUnread)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(width / width4 / 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? DarkColor.Primarycolor
                                      : LightColor
                                          .color3, // Background color for unread indicator
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        width: width / width30,
                      ),
                      GestureDetector(
                        onTap: widget.drawerOnClicked,
                        child: Transform.scale(
                          scaleX: -1,
                          child: Icon(
                            Icons.short_text_rounded,
                            color: isDark
                                ? DarkColor.Primarycolor
                                : LightColor.color3,
                            size: width / width40,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: height / height30),
            widget.showWish!
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PoppinsSemibold(
                        text: '${greeting}',
                        color:
                            isDark ? DarkColor.Primarycolor : LightColor.color3,
                        letterSpacing: -.5,
                        fontsize: width / width35,
                      ),
                      SizedBox(height: height / height10),
                      PoppinsLight(
                        text: widget.userName != '' ? widget.userName : 'User not found',
                        color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                        fontsize: width / width30,
                      ),
                      SizedBox(height: height / height16),
                    ],
                  )
                : const SizedBox(),
            Container(
              height: height / height64,
              padding: EdgeInsets.symmetric(horizontal: width / width10),
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
                borderRadius: BorderRadius.circular(width / width13),
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
                          controller: _controller,
                          focusNode: focusNode,
                          autofocus: false,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300,
                            fontSize: width / width18,
                            color: Colors.white,
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
                              color: isDark ? DarkColor.color2 : LightColor.color2,
                            ),
                            hintText: 'Search screen',
                            contentPadding: EdgeInsets.zero,
                          ),
                          cursorColor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor),
                      suggestionsCallback: suggestionsCallback,
                      itemBuilder: (context, Screens screen) {
                        return ListTile(
                          leading: Icon(screen.icon, color: Colors.blueAccent),
                          title: InterRegular(
                            text: screen.name,
                            color: isDark ? DarkColor.color2 : LightColor.color2,
                          ),
                        );
                      },
                      emptyBuilder: (context) => Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: height / height10,
                            horizontal: width / width10),
                        child: InterRegular(
                          text: 'No Such Screen found',
                          color: isDark ? DarkColor.color2 : LightColor.color2,
                          fontsize: width / width18,
                        ),
                      ),
                      decorationBuilder: (context, child) => Material(
                        type: MaterialType.card,
                        elevation: 4,
                        borderRadius: BorderRadius.circular(width / width10),
                        child: child,
                      ),
                      debounceDuration: const Duration(milliseconds: 300),
                      onSelected: (Screens value) {
                        // _controller.text = value.name;
                        print(
                            'home screen search bar############################################');
                        print(value.name);
                        switch(value){
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
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //
                            //         DarDisplayScreen(
                            //           EmpEmail: _empEmail,
                            //           EmpID: _employeeId,
                            //           EmpDarCompanyId:
                            //           _ShiftCompanyId ?? "",
                            //           EmpDarCompanyBranchId:
                            //           _branchId,
                            //           EmpDarShiftID: _shiftId,
                            //           EmpDarClientID:
                            //           _shiftCLientId,
                            //           Username: _userName,
                            //         )));
                            break;
                          case 'Reports Screen':
                            /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ReportScreen(
                                          locationId:
                                          _shiftLocationId,
                                          locationName:
                                          _ShiftLocationName,
                                          companyId:
                                          _ShiftCompanyId ?? "",
                                          empId: _employeeId,
                                          empName: _userName,
                                          clientId: _shiftCLientId,
                                          ShiftId: _shiftId,
                                        )));*/
                            break;
                          case 'Post Screen':
                            /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PostOrder(
                                      locationId:
                                      _shiftLocationId,
                                    )));*/
                            break;
                          case 'Task Screen':
                            /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TaskFeatureScreen()));*/
                            break;
                          case 'LogBook Screen':
                            /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LogBookScreen(
                                          EmpId: _employeeId,
                                        )));*/
                            break;
                          case 'Visitors Screen':
                            /*  Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VisiTorsScreen(
                                                      locationId:
                                                          _shiftLocationId,
                                                    )));*/
                            break;
                          case 'Assets Screen':
                            /*Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    // KeysScreen(
                                                    //     keyId: _employeeId)
                                                    AssetsScreen(
                                                        assetEmpId:
                                                            _employeeId)));*/
                            break;
                          case 'Key Screen':
                            /*   Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    KeysScreen(
                                                        keyId: _employeeId)
                                                // AssetsScreen(
                                                //     assetEmpId:
                                                //         _employeeId)

                                                ));*/
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
                        color: isDark
                            ? Colors.white
                            : LightColor.color3, // Change text color to white
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
                          color: DarkColor.color2, // Change text color to white
                        ),
                        hintText: 'Search',
                        contentPadding: EdgeInsets.zero, // Remove padding
                      ),
                      cursorColor: isDark
                          ? DarkColor.Primarycolor
                          : LightColor.Primarycolor,
                    ),
                  ),*/

                  Container(
                    height: height / height44,
                    width: width / width44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? DarkColor.Primarycolor
                          : LightColor.Primarycolor,
                      borderRadius: BorderRadius.circular(width / width10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.search,
                        size: width / width20,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: height / height10),
          ],
        ),
      ),
    );
  }
}
