import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../../fonts/inter_regular.dart';

class SHistoryScreen extends StatefulWidget {
  final String empID;
  final String empName;

  const SHistoryScreen({super.key, required this.empID, required this.empName});

  @override
  State<SHistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<SHistoryScreen> {
  @override
  void initState() {
    fetchShiftHistoryDetails();
    super.initState();
  }

  List<Map<String, dynamic>> shiftHistory = [];
  FireStoreService fireStoreService = FireStoreService();
  void fetchShiftHistoryDetails() async {
    print("Emp ID ${widget.empID}");
    var shifthistory = await fireStoreService.getShiftHistory(widget.empID);
    setState(() {
      shiftHistory = shifthistory;
    });
    print('Shift History :  ${shifthistory}');
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        body: CustomScrollView(
          // physics: const PageScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? DarkColor.color1 : LightColor.color3,
                  size: width / width24,
                ),
                padding: EdgeInsets.only(left: width / width20),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigtor debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterMedium(
                text: '${widget.empName} History',
                fontsize: width / width18,
                color: isDark ? DarkColor.color1 : LightColor.color3,
                letterSpacing: -.3,
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: height / height30,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var shift = shiftHistory[index];
                  DateTime shiftDate =
                      (shift['ShiftDate'] as Timestamp).toDate();
                  String date =
                      '${shiftDate.day}/${shiftDate.month}/${shiftDate.year}';
                  String dayOfWeek = _getDayOfWeek(shiftDate.weekday);
                  return Padding(
                    padding: EdgeInsets.only(
                        left: width / width30,
                        right: width / width30,
                        bottom: height / height40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterBold(
                          text: "${date}  ${dayOfWeek}",
                          fontsize: width / width18,
                          color: isDark
                              ? DarkColor.color1
                              : LightColor.color3,
                        ),
                        SizedBox(height: height / height20),
                        Container(
                          height: height / height340,
                          padding: EdgeInsets.only(
                            top: height / height20,
                          ),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(width / width10),
                            color: isDark
                                ? DarkColor.WidgetColor
                                : LightColor.WidgetColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / width20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: 'Shift Name',
                                      fontsize: width / width16,
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                    ),
                                    SizedBox(width: width / width40),
                                    Flexible(
                                      child: InterSemibold(
                                        text: shift['ShiftName'],
                                        fontsize: width / width16,
                                        color: isDark
                                            ? DarkColor.color1
                                            : LightColor.color3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: height / height10,
                              ),
                              Container(
                                height: height / height100,
                                color: isDark
                                    ? DarkColor.colorRed
                                    : LightColor.colorRed,
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / width20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: 'Location',
                                      fontsize: width / width16,
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                    ),
                                    SizedBox(width: width / width40),
                                    Flexible(
                                      child: InterSemibold(
                                        text: shift['ShiftLocationAddress'],
                                        fontsize: width / width16,
                                        color: isDark
                                            ? DarkColor.color1
                                            : LightColor.color3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: height / height30),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / width20),
                                width: double.maxFinite,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InterSemibold(
                                          text: 'Shift Timimg',
                                          fontsize: width / width16,
                                          color: isDark
                                              ? DarkColor.color1
                                              : LightColor.color3,
                                        ),
                                        SizedBox(
                                          height: height / height20,
                                        ),
                                        InterSemibold(
                                          text:
                                              '${shift['ShiftStartTime']} to ${shift['ShiftEndTime']}',
                                          fontsize: width / width16,
                                          color: isDark
                                              ? DarkColor.color1
                                              : LightColor.color3,
                                        ),
                                      ],
                                    ),
                                    // SizedBox(height: height / height20),
                                    SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InterSemibold(
                                            text: 'Total',
                                            fontsize: width / width16,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                          ),
                                          SizedBox(
                                            height: height / height20,
                                          ),
                                          InterSemibold(
                                            text: '02hr 36min',
                                            fontsize: width / width16,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: height / height20,
                              ),
                              Button1(
                                text: 'text',
                                useWidget: true,
                                MyWidget: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.download_for_offline,
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                      size: width / width24,
                                    ),
                                    SizedBox(
                                      width: width / width10,
                                    ),
                                    InterSemibold(
                                      text: 'Download',
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                      fontsize: width / width16,
                                    )
                                  ],
                                ),
                                onPressed: () {},
                                backgroundcolor: isDark
                                    ? DarkColor.Primarycolorlight
                                    : LightColor.Primarycolorlight,
                                useBorderRadius: true,
                                MyBorderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(width / width12),
                                  bottomRight: Radius.circular(width / width12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
} /**/
