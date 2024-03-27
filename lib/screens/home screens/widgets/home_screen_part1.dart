import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../fonts/poppins_light.dart';
import '../../../fonts/poppis_semibold.dart';
import '../../../utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/utils.dart';

class HomeScreenPart1 extends StatelessWidget {
  final String userName;
  // final String employeeImg;
  final VoidCallback drawerOnClicked;
  HomeScreenPart1(
      {Key? key,
      required this.userName,
      // required this.employeeImg,
      required this.drawerOnClicked})
      : super(key: key);

  bool isUnread = true;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://t4.ftcdn.net/jpg/03/64/21/11/360_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg'),
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
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
                        Icon(
                          Icons.notifications,
                          // Use the notifications_active icon
                          color: Primarycolor, // Change color if unread
                          size: 28,
                        ),
                        if (isUnread)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Primarycolor, // Background color for unread indicator
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    GestureDetector(
                      onTap: drawerOnClicked,
                      child: Transform.scale(
                        scaleX: -1,
                        child: Icon(
                          Icons.short_text_rounded,
                          color: Primarycolor,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 60),
          PoppinsSemibold(
            text: 'Good Morning,',
            color: Primarycolor,
            letterSpacing: -.5,
            fontsize: 35,
          ),
          SizedBox(height: 10),
          PoppinsLight(
            text: userName,
            color: Primarycolor,
            fontsize: 30,
          ),
          SizedBox(height: 46),
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: WidgetColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                      color: Colors.white, // Change text color to white
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      focusedBorder: InputBorder.none,
                      // filled: true,
                      // fillColor: Colors.transparent, // Change background color to red
                      /*labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                        color: Colors.white, // Change text color to white
                      ),*/
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                        color: color2, // Change text color to white
                      ),
                      hintText: 'Search',
                      contentPadding: EdgeInsets.zero, // Remove padding
                    ),
                    cursorColor: Primarycolor,
                  ),
                ),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Primarycolor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 10),
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
          //             Icons.search,
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
    );
  }
}
