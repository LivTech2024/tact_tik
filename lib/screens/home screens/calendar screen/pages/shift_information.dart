import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../../common/sizes.dart';

class ShiftInformation extends StatelessWidget {
  const ShiftInformation({super.key, this.toRequest = false});
  final bool toRequest;

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
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: toRequest ? 'Shift' :'Shift- Guard Name',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: toRequest,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height / height30),
                    InterBold(
                      text: 'Guard Name Here',
                      fontsize: width / width18,
                      color: color1,
                    ),
                    SizedBox(height: height / height30),
                    InterBold(
                      text: 'Shift Name...',
                      fontsize: width / width18,
                      color: color1,
                    ),
                    SizedBox(height: height / height30),
                    InterBold(
                      text: 'Details',
                      fontsize: width / width16,
                      color: color1,
                    ),
                    SizedBox(height: height / height14),
                    InterRegular(
                      text:
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse varius enim in eros elementum tristique. Lorem ipsum dolor sit amet',
                      fontsize: width / width14,
                      color: color2,
                      maxLines: 3,
                    ),
                    SizedBox(height: height / height30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InterBold(
                          text: 'Supervisor:',
                          fontsize: width / width16,
                          color: color1,
                        ),
                        SizedBox(width: width / width4),
                        InterRegular(
                          text: 'Supervisor name...',
                          fontsize: width / width14,
                          color: color2,
                        )
                      ],
                    ),
                    SizedBox(height: height / height30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InterBold(
                          text: 'Time:',
                          fontsize: width / width16,
                          color: color1,
                        ),
                        SizedBox(width: width / width4),
                        InterRegular(
                          text: '9:30am-11:30am',
                          fontsize: width / width14,
                          color: color2,
                        ),
                      ],
                    ),
                    SizedBox(height: height / height30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: width / width24,
                          color: color1,
                        ),
                        SizedBox(width: width / width4),
                        InterRegular(
                          text: '9:30am-11:30am',
                          fontsize: width / width14,
                          color: color2,
                        ),
                      ],
                    ),
                    if (toRequest)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height / height50),
                          InterBold(
                            text: '*Shift already taken',
                            fontsize: width / width18,
                            color: color1,
                          ),
                          SizedBox(height: height / height30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InterBold(
                                text: 'Time:',
                                fontsize: width / width16,
                                color: color1,
                              ),
                              SizedBox(width: width / width4),
                              InterRegular(
                                text: '9:30am-11:30am',
                                fontsize: width / width14,
                                color: color2,
                              ),
                            ],
                          ),
                        ],
                      )
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button1(
                    text: toRequest?'Exchange' :'Accept',
                    onPressed: () {

                    },
                    backgroundcolor: Primarycolor,
                    borderRadius: width / width10,
                    fontsize: width / width18,
                    color: color1,
                  ),
                  SizedBox(height: height / height100),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
