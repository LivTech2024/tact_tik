import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/feature%20screens/widgets/custome_textfield.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../fonts/inter_medium.dart';

class UncheckedPatrolScreen extends StatefulWidget {
  UncheckedPatrolScreen({super.key});

  @override
  State<UncheckedPatrolScreen> createState() => _UncheckedPatrolScreenState();
}

class _UncheckedPatrolScreenState extends State<UncheckedPatrolScreen> {
  List<TextEditingController> _dataController = [];
  List<Map<String, dynamic>> data = [
    {'data': '', 'index': 0}
  ];
  bool isExpand = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each item
    for (int i = 0; i < 10; i++) {
      _dataController.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _dataController) {
      controller.dispose();
    }
    super.dispose();
  }

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
            Navigator.pop(context);
          },
        ),
        title: InterRegular(
          text: "Reason",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              InterBold(
                  text: 'Let us know why you have missed?', fontsize: 18.sp),
              SizedBox(height: 20.h),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return CheckReason(
                    index: index,
                    dataController: _dataController[index],
                  );
                },
              ),
              SizedBox(height: 20.h),
              Button1(
                borderRadius: 10.r,
                height: 70.h,
                text: 'Submit',
                backgroundcolor: Theme.of(context).primaryColor,
                color: Theme.of(context).textTheme.headlineMedium!.color,
                onPressed: () {},
              ),
              SizedBox(height: 40.h)
            ],
          ),
        ),
      ),
    ));
  }
}

class CheckReason extends StatefulWidget {
  CheckReason(
      {super.key,
      /* required this.data,*/ required this.index,
      required this.dataController});

  // List<Map<String, dynamic>> data;
  final TextEditingController dataController;
  final int index;

  @override
  State<CheckReason> createState() => _CheckReasonState();
}

class _CheckReasonState extends State<CheckReason> {
  bool isExpand = false;

  // List<TextEditingController> dataController = [];

  @override
  Widget build(BuildContext context) {
    print('current index : ${widget.index}');
    return Container(
      constraints: BoxConstraints(minHeight: 46.h),
      width: double.maxFinite,
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: DarkColor.WidgetColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 12.h,
                    width: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 144.w,
                    child: InterMedium(
                      text: 'checkpointName',
                      // color: color21,
                      fontsize: 16.sp,
                    ),
                  )
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  print('clicked');
                  setState(() {
                    isExpand = !isExpand;
                  });
                },
                icon: Transform.rotate(
                  angle: isExpand ? 30 : -30, //set the angel
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 24.sp,
                  ),
                ),
              )
            ],
          ),
          Visibility(
            visible: isExpand,
            child: Column(
              children: [
                TextField(
                  controller: widget.dataController,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300,
                    fontSize: 18.sp,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.r),
                      ),
                    ),
                    focusedBorder: InputBorder.none,
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      fontSize: 18.sp,
                      color: Colors.grey, // color2,
                    ),
                    hintText: 'White hear something..',
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Primarycolor,
                  onChanged: (value) {
                    // data[index]['data'] = value;

                    // setState(() {
                    //   tasks[index]['name'] = value;
                    // });
                    print("textfield value $value");
                  },
                ),
                SizedBox(height: 10.h)
              ],
            ),
          )
        ],
      ),
    );
  }
}
