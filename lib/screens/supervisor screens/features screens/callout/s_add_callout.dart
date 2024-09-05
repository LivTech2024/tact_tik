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
        body: Container(
          height: screenHeight,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.amber, width: 2)),
          child: Column(
            children: [
              //Full Container
              Container(
                  padding: EdgeInsets.all(screenHeight * 0.035),
                  height: 800,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InterBold(
                        text: "Create callout",
                        fontsize: 16.sp,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      SizedBox(width: (screenHeight * 0.035)),
                      SizedBox(
                        height: 20.h,
                      ),
                      //Select Location Card
                      GestureDetector(
                        onTap: () {
                          print("Select Location clicked");
                        },
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
                              Container(
                                margin: EdgeInsets.all(10),
                                width: 43.5,
                                height: 43.5,
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
                              const InterLight(
                                text: "Select Location",
                                letterSpacing: 0.5,
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      //Select Employee
                      GestureDetector(
                        onTap: () {
                          print("Select employee clicked");
                        },
                        child: Container(
                          width: double.maxFinite,
                          height: 64.sp,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: isDark
                                          ? DarkColor.AppBarcolor
                                          : LightColor.AppBarcolor))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.all(10),
                                width: 43.5,
                                height: 43.5,
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
                                          ? DarkColor.AppBarcolor
                                          : LightColor.AppBarcolor))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.all(10),
                                width: 43.5,
                                height: 43.5,
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
                                          ? DarkColor.AppBarcolor
                                          : LightColor.AppBarcolor))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.all(10),
                                width: 43.5,
                                height: 43.5,
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
                      // Align(
                      //     alignment: Alignment.bottomCenter,
                      //     child: ElevatedButton(
                      //         onPressed: () {}, child: Text("Done"))),
                      Align(
                        // alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                                onPressed: () {}, child: Text("Done"))
                          ],
                        ),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
