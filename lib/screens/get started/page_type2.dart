import 'package:flutter/material.dart';

import '../../fonts/poppins_medium.dart';
import '../../fonts/poppins_regular.dart';
import '../../fonts/poppis_semibold.dart';
import '../../utils/colors.dart';

class PageType2 extends StatelessWidget {
  PageType2(
      {super.key, required  this.index,});

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
    return Container(
      color: Secondarycolor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 470,
            width: double.maxFinite,
            decoration: const BoxDecoration(
              color: Primarycolor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 65.0,
                right: 65.0,
                top: 76.0,
                bottom: 144.0,
              ),
              child: SizedBox(
                height: 250,
                width: 300,
                // color: Colors.white,
                child: Image.asset(images[index]),
              ),
            ),
          ),
          SizedBox(
            height: 100,
          ),
          PoppinsSemibold(
            text: tittls[index],
            fontsize: 32,
            color: color1,
          ),
          SizedBox(height: 27),
          SizedBox(
            width: 54,
            child: Divider(
              height: 3,
            ),
          ),
          SizedBox(height: 30),
          PoppinsRegular(
            text: description[index],
            fontsize: 14,
            color: color2,
            textAlign: TextAlign.center,
          ),
          Visibility(
            visible: true,
            child: Container(
              height: 60,
              margin:
              const EdgeInsets.only(left: 24.0, right: 24.0, top: 74.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Primarycolor,
              ),
              child: const Center(
                child: PoppinsMedium(
                  text: 'Get Started',
                  fontsize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
