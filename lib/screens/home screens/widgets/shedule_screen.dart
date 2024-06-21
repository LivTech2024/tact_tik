import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';
import 'icon_text_widget.dart';

class SheduleScreen extends StatelessWidget {
  const SheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: width / width20),
            height: 68,
            color: Theme.of(context).cardColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: DarkColor.Primarycolor,
                    size: width / width24,
                  ),
                ),
                InterBold(
                  text: '14/03/2024',
                  fontsize: width / width19,
                  color: DarkColor.Primarycolor,
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: DarkColor.Primarycolor,
                    )),
              ],
            ),
          ),
          SizedBox(height: 10),
          ListView.builder(
            itemCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                color: Theme.of(context).cardColor,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                height: 242,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 30, left: width / width30),
                      height: 126,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconTextWidget(
                            icon: Icons.location_on,
                            text:
                                '2972 Westheimer Rd. Santa Ana, Illinois 85486',
                          ),
                          IconTextWidget(
                            icon: Icons.access_time,
                            text: '12:00 am - 12:00 pm',
                          ),
                          IconTextWidget(
                            icon: Icons.qr_code_scanner,
                            text: 'Total 6    Completed 4',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width16),
                      height: 56,
                      color: DarkColor.Primarycolor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PoppinsBold(
                            text: 'Go to shift',
                            color: Colors.white,
                            fontsize: width / width18,
                            letterSpacing: .03,
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
