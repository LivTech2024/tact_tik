import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/widgets/setTimeWidget.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import '../../supervisor screens/home screens/widgets/set_details_widget.dart';

class CreateVisitors extends StatefulWidget {
  CreateVisitors({super.key});

  @override
  State<CreateVisitors> createState() => _CreateVisitorsState();
}

class _CreateVisitorsState extends State<CreateVisitors> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController EmailController = TextEditingController();

  final TextEditingController ContactNoController = TextEditingController();

  final TextEditingController AssetHandoverController = TextEditingController();

  final TextEditingController AssetReturnController = TextEditingController();

  final TextEditingController LicensePlateNumberController =
      TextEditingController();

  final TextEditingController SetCountdownController = TextEditingController();

  final TextEditingController CommentsController = TextEditingController();

  final TextEditingController NoOfPersonController = TextEditingController();

  final TextEditingController CompanyNameController = TextEditingController();

  TimeOfDay? InTime;

  TimeOfDay? OutTime;

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

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppBarcolor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: width / width24,
                ),
                padding: EdgeInsets.only(left: width / width20),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigtor debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterRegular(
                text: 'Create Visitors',
                fontsize: width / width18,
                color: Colors.white,
                letterSpacing: -.3,
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height / height30),
                    InterBold(text: 'Add Visitor' , color: Primarycolor, fontsize: width / width20,),
                    SizedBox(height: height / height30),
                    Row(
                      children: [
                        SetTimeWidget(
                          hintText: InTime == null ? 'In Time' : '${InTime}',
                          // icon: Icons.access_time_rounded,
                          onTap: () => _selectTime(context, true),
                          flex: 2,
                        ),
                        SizedBox(width: width / width6),
                        SetTimeWidget(
                          hintText: OutTime == null ? 'Out Time' : '${OutTime}',
                          // icon: Icons.access_time_rounded,
                          onTap: () => _selectTime(context, false),
                          flex: 2,
                        ),
                      ],
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Name',
                      controller: nameController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Email',
                      controller: EmailController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Contact Number',
                      controller: ContactNoController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Asset Handover',
                      controller: AssetHandoverController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Asset Return',
                      controller: AssetReturnController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'License Plate Number ',
                      controller: LicensePlateNumberController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Set Countdown',
                      controller: SetCountdownController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Comments ',
                      controller: CommentsController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'No. Of Person',
                      controller: NoOfPersonController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Company Name',
                      controller: CompanyNameController,
                    ),
                    SizedBox(height: height / height30,),
                    Button1(
                      text: 'Save',
                      onPressed: () {},
                      backgroundcolor: Primarycolor,
                      color: color22,
                      borderRadius: width / width10,
                      fontsize: width / width18,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
