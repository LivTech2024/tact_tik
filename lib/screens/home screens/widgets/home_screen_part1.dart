import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/new%20guard/new_guard_screen.dart';
import '../../../common/sizes.dart';
import '../../../fonts/poppins_light.dart';
import '../../../fonts/poppis_semibold.dart';
import '../../../utils/colors.dart';

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
  
  get employeeImg => null;

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
                    decoration: employeeImg != null
                        ? BoxDecoration(
                      shape: BoxShape.circle,
                      // color: Primarycolor,
                      image: DecorationImage(
                        image: NetworkImage(
                            employeeImg ?? ""),
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.cover,
                      ),
                    )
                        : BoxDecoration(
                      shape: BoxShape.circle,
                      color: DarkColor. Primarycolor,
                      image: DecorationImage(
                        image: /*widget.guardsInfo['EmployeeImg'] != null ? NetworkImage(
                                widget.guardsInfo['EmployeeImg'] ?? "") :*/
                        AssetImage('assets/images/default.png'),
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  /*CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(
                      'https://t4.ftcdn.net/jpg/03/64/21/11/360_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg',
                    ),
                    // child: MyNetworkImage('https://t4.ftcdn.net/jpg/03/64/21/11/360_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg'),
                  ),*/
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
                        text: widget.userName,
                        color:
                            isDark ? DarkColor.Primarycolor : LightColor.color3,
                        fontsize: width / width30,
                      ),
                      SizedBox(height: height / height16),
                    ],
                  )
                : SizedBox(),
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
                  ),
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
            // Container(
            //   height: 64,
            //   padding: EdgeInsets.symmetric(horizontal: 10.0),
            //   decoration: BoxDecoration(
            //     color: WidgetColor,
            //     borderRadius: BorderRadius.circular(13),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Expanded(
            //         child: TextField(
            //           style: GoogleFonts.poppins(
            //             fontWeight: FontWeight.w300,
            //             fontSize: 18,
            //             color: Colors.white, // Change text color to white
            //           ),
            //           decoration: InputDecoration(
            //             border: OutlineInputBorder(
            //               borderSide: BorderSide.none,
            //               borderRadius: const BorderRadius.all(
            //                 const Radius.circular(10.0),
            //               ),
            //             ),
            //             focusedBorder: InputBorder.none,
            //             // filled: true,
            //             // fillColor: Colors.transparent, // Change background color to red
            //             /*labelStyle: GoogleFonts.poppins(
            //               fontWeight: FontWeight.w300,
            //               fontSize: 18,
            //               color: Colors.white, // Change text color to white
            //             ),*/
            //             hintStyle: GoogleFonts.poppins(
            //               fontWeight: FontWeight.w300,
            //               fontSize: 18,
            //               color: color2, // Change text color to white
            //             ),
            //             hintText: 'Search',
            //             contentPadding: EdgeInsets.zero, // Remove padding
            //           ),
            //           cursorColor: Primarycolor,
            //         ),
            //       ),
            //       Container(
            //         height: 44,
            //         width: 44,
            //         decoration: BoxDecoration(
            //           color: Primarycolor,
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         child: Center(
            //           child: Icon(
            //           Icons.search,
            //             size: 20,
            //             color: Colors.black,
            //           ),
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
