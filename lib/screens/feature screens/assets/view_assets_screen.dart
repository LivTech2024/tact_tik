import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/fonts/inter_regular.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/setTextfieldWidget.dart';
import '../../../utils/colors.dart';
import '../visitors/widgets/setTimeWidget.dart';

class ViewAssetsScreen extends StatelessWidget {
  final String startDate;
  final String endDate;
  final String equipmentId;
  final int equipmentQty;
  ViewAssetsScreen(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.equipmentId,
      required this.equipmentQty});

  Future<TimeOfDay?> showCustomTimePicker(BuildContext context) async {
    TimeOfDay? selectedTime;

    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: DarkColor. Primarycolor, // Change primary color to red
              secondary: DarkColor. Primarycolor,
            ),
          ),
          child: child!,
        );
      },
    );

    return selectedTime;
  }

/*
  void _selectTime(BuildContext context, bool isStartTime) async {
    final selectedTime = await showCustomTimePicker(context);
    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          InTime = selectedTime;
        } else {
          OutTime = selectedTime;
        }
      });
      print('InTime: $InTime');
      print('OutTime: $OutTime');
    }
  }
*/
/*
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }
*/

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        appBar: AppBar(
          backgroundColor: DarkColor. AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24.sp,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'View Assets',
            fontsize: 18.sp,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              InterBold(
                text: 'Allocation Date',
                color: isDark ? DarkColor.Primarycolor : LightColor.color1,
                fontsize: 20.sp,
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InterMedium(
                            text: startDate,
                            fontsize: 16.sp,
                            color: isDark ? DarkColor.color2 : LightColor.color3,
                          ),
                          SvgPicture.asset(
                            'assets/images/calendar_clock.svg',
                            width: 20.w,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InterMedium(
                            text: endDate,
                            fontsize: 16.sp,
                            color: isDark ? DarkColor.color2 : LightColor.color3,
                          ),
                          SvgPicture.asset(
                            'assets/images/calendar_clock.svg',
                            width: 20.w,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              InterBold(
                text: 'Equipment',
                color: isDark ? DarkColor.Primarycolor : LightColor.color1,
                fontsize: 16.sp,
              ),
              SizedBox(height: 20.h),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('Equipments')
                    .where('EquipmentId', isEqualTo: equipmentId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final documents = snapshot.data!.docs;
                    final equipmentName = documents.isNotEmpty
                        ? (documents.first.data()['EquipmentName'] ??
                            'Equipment Not Available')
                        : 'Equipment Not Available';

                    return Container(
                      height: 60.h,
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          InterMedium(
                            text: equipmentName,
                            color: isDark ? DarkColor.color2 : LightColor.color3,
                            fontsize: 16.sp,
                          ),
                          InterMedium(
                            text: "Quantity: $equipmentQty",
                            color: isDark ? DarkColor.color2 : LightColor.color3,
                            fontsize: 16.sp,
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
