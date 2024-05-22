import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/setTextfieldWidget.dart';
import '../../../utils/colors.dart';
import '../visitors/widgets/setTimeWidget.dart';

class ViewAssetsScreen extends StatelessWidget {
  final String startDate;
  final String endDate;
  final String equipmentId;
  ViewAssetsScreen({super.key, required this.startDate, required this.endDate, required this.equipmentId});

  Future<TimeOfDay?> showCustomTimePicker(BuildContext context) async {
    TimeOfDay? selectedTime;

    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Primarycolor, // Change primary color to red
              secondary: Primarycolor,
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
    final double height = MediaQuery
        .of(context)
        .size
        .height;
    final double width = MediaQuery
        .of(context)
        .size
        .width;

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height / height30),
            InterBold(
              text: 'Allocation Date',
              color: Primarycolor,
              fontsize: width / width20,
            ),
            SizedBox(height: height / height30),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: height / height60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width / width10),
                      color: WidgetColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InterMedium(text: startDate,
                          fontsize: width / width16,
                          color: color2,),
                        SvgPicture.asset('assets/images/calendar_clock.svg',
                          width: width / width20,)
                      ],
                    ),
                  ),
                ),
                SizedBox(width: width / width6),
                Expanded(
                  child: Container(
                    height: height / height60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width / width10),
                      color: WidgetColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InterMedium(text: endDate,
                          fontsize: width / width16,
                          color: color2,),
                        SvgPicture.asset('assets/images/calendar_clock.svg',
                          width: width / width20,)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height / height30),
            InterBold(text: 'Equipment' , color: color1,fontsize: width / width16,),
            SizedBox(height: height / height20),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Equipments')
                  .where('EquipmentId', isEqualTo: equipmentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final documents = snapshot.data!.docs;
                  final equipmentName = documents.isNotEmpty
                      ? (documents.first.data()['EquipmentName'] ?? 'Equipment Not Available')
                      : 'Equipment Not Available';

                  return Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width / width10),
                      color: WidgetColor,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: width / width10),
                        InterMedium(
                          text: equipmentName,
                          color: color2,
                          fontsize: width / width16,
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
    );
  }
}
