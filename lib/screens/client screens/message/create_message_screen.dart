import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
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
                },
              ),
              title: InterRegular(
                text: 'Write Message',
                fontsize: width / width18,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
              centerTitle: true,
            ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height / height30),
                    InterBold(
                      text: 'Employee',
                      fontsize: width / width18,
                      color: color1,
                    ),
                    SizedBox(height: height / height20),
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
                    SizedBox(height: height / height20),
                    Container(
                      height: height / height60,
                      padding: EdgeInsets.symmetric(horizontal: width / width20),
                      decoration: BoxDecoration(
                        color: WidgetColor,
                        borderRadius: BorderRadius.circular(width / width10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InterMedium(
                                text: 'Send To Admin',
                                color: color8,
                                fontsize: width / width16,
                                letterSpacing: -.3,
                              )
                            ],
                          ),
                          Checkbox(
                            activeColor: Primarycolor,
                            checkColor: color1,
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
                    SizedBox(height: height / height20),
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
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button1(
                      height: height / height60,
                      backgroundcolor: Primarycolor,
                      borderRadius: width / width10,
                      fontsize: width / width18,
                      color: color1,
                      text: 'Send',
                      onPressed: () {},
                    ),
                    SizedBox(
                      height: height / height60,
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