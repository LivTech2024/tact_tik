import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/widgets/custome_textfield.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_medium.dart';
import '../../../utils/colors.dart';

class CreateMessageScreen extends StatefulWidget {
  CreateMessageScreen({super.key});

  @override
  State<CreateMessageScreen> createState() => _CreateMessageScreenState();
}

class _CreateMessageScreenState extends State<CreateMessageScreen> {
  String dropdownValue = 'Select';
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 24.w,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterMedium(
            text: 'Write Message',
            letterSpacing: -0.3,
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    InterBold(
                      text: 'Employee',
                      fontsize: width / width18,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(height: 20.h),
                    // TODO : Comment out this
                    /*Container(
                      height: height / height60,
                      padding: EdgeInsets.symmetric(horizontal: width / width20),
                      decoration: BoxDecoration(
                        color: WidgetColor,
                        borderRadius: BorderRadius.circular(width / width10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          iconSize: width / width24,
                          dropdownColor: WidgetColor,
                          style: TextStyle(color: color2),
                          borderRadius: BorderRadius.circular(10),
                          value: dropdownValue,
                          items: <String?>[...tittles]
                              .map<DropdownMenuItem<String>>((String? value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value ?? ''),
                            );
                          }).toList(),
                          onChanged: (String? value) {},
                        ),
                      ),
                    ),*/
                    SizedBox(height: 20.h),
                    Container(
                      height: 60.h,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InterMedium(
                                text: 'Send To Admin',
                                color: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .color,
                                fontsize: 16.sp,
                                letterSpacing: -.3,
                              )
                            ],
                          ),
                          Checkbox(
                            activeColor: Theme.of(context).primaryColor,
                            checkColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = !isChecked;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomeTextField(
                      hint: 'Write Your Message...',
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button1(
                      height: 60.h,
                      backgroundcolor: Theme.of(context).primaryColor,
                      borderRadius: 10.r,
                      fontsize: 18.sp,
                      color: Theme.of(context).textTheme.headlineMedium!.color,
                      text: 'Send',
                      onPressed: () {},
                    ),
                    SizedBox(
                      height: 60.h,
                    )
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
