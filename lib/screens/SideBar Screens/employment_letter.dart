import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../common/sizes.dart';
import '../../fonts/inter_regular.dart';

class EmploymentLetterScreen extends StatelessWidget {
  const EmploymentLetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

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
            text: 'Employment Letter',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            height: height / height500,
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
                  padding: EdgeInsets.only(top: height / height20 , left: width / width10),
                  child: InterBold(text: 'Nick Jones', fontsize: width / width18,color: Primarycolor,),
                ),
                Center(
                  child: SvgPicture.asset(
                    'assets/images/folder.svg',
                    width: width / width190,
                  ),
                ),
                Button1(
                  text: 'text',
                  useWidget: true,
                  MyWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_for_offline , color: color1,size: width / width24,),
                      SizedBox(
                        width: width / width10,
                      ),
                      InterSemibold(text: 'Download' , color: color1,fontsize: width / width16,)
                    ],
                  ),
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
          ),
        ),
      ),
    );
  }
}
