import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  List colors = [isDark?DarkColor.Primarycolor:LightColor.Primarycolor, isDark ? DarkColor.color25 : LightColor.Primarycolorlight
  ];

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

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        appBar: AppBar(
          backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.WidgetColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? DarkColor.color1 : LightColor.color3,
              size: width / width24,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Inbox',
            fontsize: width / width18,
            color:  isDark ? DarkColor.color1 : LightColor.color3,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Container(
              height: height / height65,
              width: double.maxFinite,
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
                color: isDark ? DarkColor.color24 : LightColor.WidgetColor,
              ),
             
              padding: EdgeInsets.symmetric(vertical: height / height16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showGuards = true;
                          colors[0] =
                              isDark ? DarkColor.Primarycolor : LightColor.Primarycolor;
                          colors[1] =  isDark ? DarkColor.Primarycolorlight : LightColor.Primarycolorlight;
                        });
                      },
                      child: SizedBox(
                        child: Center(
                          child: InterBold(
                            text: 'Guards',
                            color: colors[0],
                            fontsize: width / width18,
                          ),
                        ),
                      ),
                    ),
                  ),
                   VerticalDivider(
                    color:  isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showGuards = false;
                          colors[0] = isDark
                              ? DarkColor.Primarycolorlight
                              : LightColor.Primarycolorlight;
                          colors[1] = isDark
                              ? DarkColor.Primarycolor
                              : LightColor.Primarycolor;
                        });
                      },
                      child: SizedBox(
                        child: Center(
                          child: InterBold(
                            text: 'Admin',
                            color: colors[1],
                            fontsize: width / width18,
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
                    padding: EdgeInsets.symmetric(horizontal: width / width30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height / height20),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            iconSize: width / width24,
                            dropdownColor: isDark
                                ? DarkColor.WidgetColor
                                : LightColor.WidgetColor,
                            style: TextStyle(
                                color: isDark
                                    ? DarkColor.color2
                                    : LightColor.color3, fontSize: width / width14),
                            borderRadius:
                                BorderRadius.circular(width / width10),
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
                        SizedBox(height: height / height20),
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
                                height: height / height60,
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
                                  color: isDark
                                      ? DarkColor.color19
                                      : LightColor.WidgetColor,
                                  borderRadius:
                                      BorderRadius.circular(width / width12),
                                ),
                                margin:
                                    EdgeInsets.only(bottom: height / height10),
                                width: double.maxFinite,
                                child: Container(
                                  height: height / height48,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width / width20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: height / height50,
                                            width: width / width50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:DarkColor.Primarycolor ,
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
                                            width: width / width20,
                                          ),
                                          InterBold(
                                            text: 'name',
                                            letterSpacing: -.3,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
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
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: width / width4,
                                                  ),
                                                  height: height / height14,
                                                  // width: width / width20,
                                                  constraints: BoxConstraints(
                                                    minWidth: width / width20,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      width / width50,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: InterBold(
                                                      text: '2',
                                                      fontsize: width / width8,
                                                      color: isDark
                                                          ? DarkColor
                                                              .color1
                                                          : LightColor
                                                              .color3,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]
                                          ),
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
