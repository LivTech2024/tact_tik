import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/svg.dart";
import "package:get/get.dart";
import "package:hive/hive.dart";
import "package:tact_tik/fonts/inter_bold.dart";
import "package:tact_tik/fonts/inter_medium.dart";

import "../../../../fonts/inter_light.dart";
import "../../../../utils/colors.dart";

class SAddCallout extends StatefulWidget {
  const SAddCallout({super.key});

  @override
  State<SAddCallout> createState() => _SAddCalloutState();
}

class _SAddCalloutState extends State<SAddCallout> {
  @override
  Widget build(BuildContext context) {
    // Width of the User's Device
    double screenWidth = MediaQuery.sizeOf(context).width;

    // Calculating the Safe Area and Height of the User's Device
    var padding = MediaQuery.paddingOf(context);
    double screenHeight =
        MediaQuery.sizeOf(context).height - padding.top - padding.bottom;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
          centerTitle: true,
          title: InterBold(
            text: "Call out",
            fontsize: 16.sp,
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_sharp)),
        ),
        // Parent Coloumn
        body: Column(
          children: [
            //Full Container
            Container(
                padding: EdgeInsets.all(screenHeight * 0.035),
                height: screenHeight - AppBar().preferredSize.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterBold(
                      text: "Create callout",
                      fontsize: 16.sp,
                      color: isDark ? Colors.white : Colors.black,
                    ),

                    // Used for Vertical Padding
                    SizedBox(
                      height: 20.h,
                    ),

                    //Select Location Card
                    GestureDetector(
                      onTap: () {
                        print("Select Location clicked");
                      },
                      // Outer Container
                      child: Container(
                        width: double.maxFinite,
                        height: 64.sp,
                        decoration: BoxDecoration(
                          color: isDark
                              ? DarkColor.AppBarcolor
                              : LightColor.color9,
                          borderRadius: BorderRadius.all(Radius.circular(13)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Location Icon Container
                            Container(
                              margin: EdgeInsets.all(screenWidth * 0.03),
                              width: screenWidth * 0.11,
                              height: screenWidth * 0.11,
                              decoration: BoxDecoration(
                                  color: isDark
                                      ? DarkColor.Primarycolor
                                      : LightColor.Primarycolor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9))),
                              child: SvgPicture.asset(
                                'assets/images/locationIcon.svg',
                                fit: BoxFit.scaleDown,
                              ),
                            ),

                            // Select Location Text
                            const InterLight(
                              text: "Select Location",
                              letterSpacing: 0.5,
                            )
                          ],
                        ),
                      ),
                    ),

                    // Vertical Padding
                    SizedBox(
                      height: 30.h,
                    ),

                    //Select Employee
                    GestureDetector(
                      onTap: () {
                        print("Select employee clicked");
                      },

                      // Container And Border
                      child: Container(
                        width: double.maxFinite,
                        height: 64.sp,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: isDark
                                        ? LightColor.AppBarcolor
                                        : DarkColor.AppBarcolor))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              // If Margin Required Replace Widget with Container
                              // margin: EdgeInsets.all(screenWidth * 0.03),
                              width: screenWidth * 0.11,
                              height: screenWidth * 0.11,
                              child: Icon(
                                Icons.account_circle_outlined,
                                color: isDark ? Colors.white : Colors.black,
                                // size: 30.h,
                              ),
                            ),
                            const InterMedium(
                              text: "Select Employee",
                              fontsize: 16,
                            )
                          ],
                        ),
                      ),
                    ),

                    //Callout Time
                    GestureDetector(
                      onTap: () {
                        print("Callout Time clicked");
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 64.sp,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: isDark
                                        ? LightColor.AppBarcolor
                                        : DarkColor.AppBarcolor))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              // margin: EdgeInsets.all(screenWidth * 0.03),
                              width: screenWidth * 0.11,
                              height: screenWidth * 0.11,
                              child: Icon(
                                Icons.access_time,
                                color: isDark ? Colors.white : Colors.black,
                                // size: 30.h,
                              ),
                            ),
                            const InterMedium(
                              text: "Callout Time",
                              fontsize: 16,
                            )
                          ],
                        ),
                      ),
                    ),
                    //End Time
                    GestureDetector(
                      onTap: () {
                        print("End Time clicked");
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 64.sp,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: isDark
                                        ? LightColor.AppBarcolor
                                        : DarkColor.AppBarcolor))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              // margin: EdgeInsets.all(screenWidth * 0.03),
                              width: screenWidth * 0.11,
                              height: screenWidth * 0.11,
                              child: Icon(
                                Icons.access_time,
                                color: isDark ? Colors.white : Colors.black,
                                // size: 30.h,
                              ),
                            ),
                            const InterMedium(
                              text: "End Time",
                              fontsize: 16,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    InterBold(
                      text: "Assigned Employee",
                      fontsize: 18.sp,
                      letterSpacing: 0.5,
                    ),
                    // Add Assigned Employee Card Here
                    const Spacer(),
                    SizedBox(
                        width: screenWidth,
                        height: 60.sp,
                        child: ElevatedButton(
                            onPressed: () {
                              print("Pressed On Done Button");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? DarkColor.Primarycolor
                                  : LightColor.Primarycolor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            child: Text(
                              "Done",
                              style: TextStyle(
                                color: isDark ? Colors.black : Colors.white,
                                fontSize: 18.sp,
                                letterSpacing: 0.5,
                              ),
                            )))
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
