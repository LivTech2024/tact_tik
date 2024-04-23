import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../common/sizes.dart';
import '../../common/widgets/button1.dart';
import '../../fonts/inter_bold.dart';
import '../../fonts/inter_regular.dart';
import '../../utils/colors.dart';

class PayStubScreen extends StatelessWidget {
  const PayStubScreen({super.key});

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
        backgroundColor: Secondarycolor,
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
            text: 'Paystub',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              height: height / height260,
              width: double.maxFinite,
              margin: EdgeInsets.symmetric(horizontal: width / width30),
              decoration: BoxDecoration(
                  color: WidgetColor,
                  borderRadius: BorderRadius.circular(width / width12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: height / height20, left: width / width10),
                    child: InterBold(
                      text: 'Pay Discrepancy',
                      fontsize: width / width18,
                      color: Primarycolor,
                    ),
                  ),
                  Button1(
                    text: 'Open',
                    color: color1,
                    onPressed: () {},
                    backgroundcolor: Primarycolorlight,
                    useBorderRadius: true,
                    MyBorderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(width / width12),
                      bottomRight: Radius.circular(width / width12),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
