import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../fonts/poppins_bold.dart';
import '../../../../services/firebaseFunctions/firebase_function.dart';
import '../../../../utils/colors.dart';
import '../../../message screen/message_screen.dart';

class SuperInboxScreen extends StatefulWidget {
  SuperInboxScreen({super.key, required this.companyId});

  final String companyId;

  @override
  State<SuperInboxScreen> createState() => _SuperInboxScreenState();
}

class _SuperInboxScreenState extends State<SuperInboxScreen> {
  bool showGuards = true;

  List<DocumentSnapshot<Object?>> _guardsInfo = [];

  /*void _getUserInfo() async {
    FireStoreService fireStoreService = FireStoreService();
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
    if (mounted) {
      if (userInfo != null) {
        String userName = userInfo['EmployeeName'] ?? "";
        String EmployeeId = userInfo['EmployeeId'] ?? "";
        String CompanyId = userInfo['EmployeeCompanyId'] ?? "";
        var guardsInfo =
        await fireStoreService.getGuardForSupervisor(widget.companyId);
        var patrolInfo = await fireStoreService
            .getPatrolsByEmployeeIdFromUserInfo(EmployeeId);
        for (var doc in guardsInfo) {
          print("All Guards : ${doc.data()}");
        }
        // setState(() {
        //   _userName = userName;
        //   _employeeId = EmployeeId;
        //   _CompanyId = CompanyId;
        // });
        if (guardsInfo != null) {
          setState(() {
            _guardsInfo = guardsInfo;
          });
        } else {
          print('GUards Info: ${guardsInfo}');
        }
        print('User Info: ${userInfo.data()}');
      } else {
        print('User info not found');
      }
    }
  }*/

  String dropdownValue = 'All Guards'; // Initialize default value
  List<Color> colors = [
    themeManager.themeMode == ThemeMode.dark
        ? DarkColor.Primarycolor
        : LightColor.color3,
    themeManager.themeMode == ThemeMode.dark
        ? DarkColor.color25
        : LightColor.color2,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Inbox',
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            // SizedBox(height: 5),
            Container(
              height: 65.h,
              width: double.maxFinite,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  )
                ],
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showGuards = true;
                          colors[0] = Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .color as Color;
                          colors[1] = Theme.of(context).highlightColor;
                        });
                      },
                      child: SizedBox(
                        child: Center(
                          child: InterBold(
                            text: 'Guards',
                            color: colors[0],
                            fontsize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showGuards = false;
                          colors[0] = Theme.of(context).highlightColor;
                          colors[1] = Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .color as Color;
                        });
                      },
                      child: SizedBox(
                        child: Center(
                          child: InterBold(
                            text: 'Admin',
                            color: colors[1],
                            fontsize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            showGuards
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            iconSize: 24.w,
                            dropdownColor: Theme.of(context).cardColor,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                                fontSize: 14.sp),
                            borderRadius: BorderRadius.circular(10.r),
                            value: dropdownValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: <String>[
                              'All Guards',
                              'available',
                              'unavailable'
                            ] // Add your options here
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        /*_guardsInfo.length == 0
                  ?*/
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: /*_guardsInfo.length*/ 1,
                          itemBuilder: (context, index) {
                            // var guardInfo = _guardsInfo[index];
                            // String name = guardInfo['EmployeeName'] ?? "";
                            // String id = guardInfo['EmployeeId'] ?? "";
                            // String url = guardInfo['EmployeeImg'] ?? "";
                            //
                            // print(guardInfo);
                            return GestureDetector(
                              onTap: () {
                                // MobileChatScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MobileChatScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 60.h,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? DarkColor.color19
                                      : LightColor.WidgetColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                margin: EdgeInsets.only(bottom: 10.h),
                                width: double.maxFinite,
                                child: Container(
                                  height: 48.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 50.h,
                                            width: 50.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: DarkColor.Primarycolor,
                                              // image: DecorationImage(
                                              //   image: NetworkImage(
                                              //     'url',
                                              //   ),
                                              //   filterQuality:
                                              //       FilterQuality.high,
                                              //   fit: BoxFit.cover,
                                              // ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          InterBold(
                                            text: 'name',
                                            letterSpacing: -.3,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
                                          ),
                                        ],
                                      ),
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                SvgPicture.asset(
                                                    'assets/images/chat_bubble.svg'),
                                                Positioned(
                                                  top: -4,
                                                  left: -8,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 4.w,
                                                    ),
                                                    height: 14.h,
                                                    // width: width / width20,
                                                    constraints: BoxConstraints(
                                                      minWidth: 20.w,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        50.r,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: InterBold(
                                                        text: '2',
                                                        fontsize: 8.sp,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .color,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
