import 'package:flutter/material.dart';
import 'package:tact_tik/login_screen.dart';

import '../../common/sizes.dart';
import '../../fonts/poppins_medium.dart';
import '../../fonts/poppins_regular.dart';
import '../../fonts/poppis_semibold.dart';
import '../../utils/colors.dart';

class PageType2 extends StatelessWidget {
  PageType2({
    super.key,
    required this.index,
  });

  final int index;

  List images = [
    'assets/images/g1.png',
    'assets/images/g2.png',
    'assets/images/g3.png',
    'assets/images/g4.png'
  ];

  List tittls = [
    'App For Security Guards',
    'Access Schedules',
    'Receive Post Orders',
    'Stay Connected'
  ];

  List description = [
    'Tacttik is designed to simplify your job as a\nsecurity guard so you can provide excellent\npatrol service.',
    'Easily confirm the shifts right within your\napp or pick up open shifts that match your\nschedule. Find out when, where, and how\nlong you are working ahead of time.',
    'Easily access clear instructions about the\npost site right within the app. Tacttik\nmobile app makes it easy to review\nthe important information on the go',
    'Get updates from your security team,\nabout reports, time clocks,\ncommunication and much more.'
  ];

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Container(
      color: Secondarycolor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: height / height470,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Primarycolor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(width / width40),
                bottomLeft: Radius.circular(width / width40),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: width / width65,
                right: width / width65,
                top: height / height76,
                bottom: height / height144,
              ),
              child: SizedBox(
                height: height / height250,
                width: width / width300,
                // color: Colors.white,
                child: Image.asset(images[index]),
              ),
            ),
          ),
          SizedBox(
            height: height / height20,
          ),
          PoppinsSemibold(
            text: tittls[index],
            fontsize: width / width32,
            color: color1,
          ),
          SizedBox(height: height / height27),
          SizedBox(
            width: width / width54,
            child: Divider(
              height: 3,
            ),
          ),
          SizedBox(height: height / height10),
          PoppinsRegular(
            text: description[index],
            fontsize: width / width14,
            color: color2,
            textAlign: TextAlign.center,
          ),
          Visibility(
            visible: true,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: Container(
                height: height / height60,
                margin: EdgeInsets.only(left: width / width24, right: width / width24, top: height / height74),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Primarycolor,
                ),
                child: Center(
                  child: PoppinsMedium(
                    text: 'Get Started',
                    fontsize: width / width16,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
