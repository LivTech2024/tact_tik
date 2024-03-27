import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_semibold.dart';

class StartTaskScreen extends StatefulWidget {
  const StartTaskScreen({super.key});

  @override
  State<StartTaskScreen> createState() => _StartTaskScreenState();
}

class _StartTaskScreenState extends State<StartTaskScreen> {
  bool clickedIn = false;
  bool issShift = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: WidgetColor,
          ),
          padding: EdgeInsets.only(left: 26, top: 10, right: 12),
          child: Column(
            children: [
              Row(
                children: [
                  InterBold(
                    text: 'Today',
                    color: color1,
                    fontsize: 18,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.contact_support_outlined,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                  )
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 98,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'In time',
                          fontsize: 28,
                          color: color1,
                        ),
                        SizedBox(height: 10),
                        InterRegular(
                          text: '12 : 00 pm',
                          fontsize: 19,
                          color: color7,
                        ),
                        SizedBox(height: 20),
                        clickedIn ? InterSemibold(text: '13m Late',color: Colors.redAccent,fontsize: 14,) : SizedBox()
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 98,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'In time',
                          fontsize: 28,
                          color: color1,
                        ),
                        SizedBox(height: 10),
                        InterRegular(
                          text: '12 : 00 pm',
                          fontsize: 19,
                          color: color7,
                        ),
                        SizedBox(height: 20),
                        clickedIn ? InterSemibold(text: '00 : 00 : 00',color: color8,fontsize: 14,) : SizedBox()
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 12),
                    height: 74,
                    width: 70,
                    decoration: BoxDecoration(
                      // color: Colors.redAccent,
                      image: DecorationImage(
                          image: AssetImage('assets/images/log_book.png'),
                          fit: BoxFit.fitHeight,
                          filterQuality: FilterQuality.high),
                    ),
                  )
                ],
              ),

            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 65,
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: WidgetColor,
          ),
          child: Row(
            children: [

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!clickedIn) {
                        clickedIn = true;
                      } else {
                        print('already clicked');
                      }
                    });
                  },
                  child: Container(
                    color: WidgetColor,
                    child: Center(
                      child: InterBold(
                        text: 'IN',
                        fontsize: 18,
                        color: clickedIn ? Primarycolorlight : Primarycolor,
                      ),
                    ),
                  ),
                ),
              ),
              VerticalDivider(
                color: Colors.white,
              ),
              /*Button1(
                text: 'OUT',
                fontsize: 18,
                color: clickedIn ? Primarycolor : Primarycolorlight,
                flex: 2,
                onPressed: () {
                  setState(() {
                    if (!clickedIn) {
                      clickedIn = true;
                    } else {
                      print('already clicked');
                    }
                  });
                },
              ),*/
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: WidgetColor,
                    child: Center(
                      child: InterBold(
                        text: 'OUT',
                        fontsize: 18,
                        color: clickedIn ? Primarycolor : Primarycolorlight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        clickedIn ? Container(
          height: 65,
          color: WidgetColor,
          child: Center(
            child: InterBold(text: 'Break', fontsize: 18, color: Primarycolor,),
          ),
        ) : const SizedBox(),
        issShift ? const SizedBox() :Button1(
          text: 'Check Patrolling',
          fontsize: 18,
          color: color5,
          backgroundcolor:
           WidgetColor,
          onPressed: () {},
        ),
      ],
    );
  }
}
