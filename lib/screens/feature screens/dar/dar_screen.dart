import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';

class DarDisplayScreen extends StatelessWidget {
  const DarDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
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
                  print("Navigtor debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterRegular(
                text: 'DAR',
                fontsize: width / width18,
                color: Colors.white,
                letterSpacing: -.3,
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: width / width20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height / height20,),
                        InterBold(
                          text: 'Yesterday',
                          fontsize: width / width20,
                          color: Primarycolor,
                          letterSpacing: -.3,
                        ),
                        SizedBox(height: height / height30),
                        Container(
                          width: double.maxFinite,
                          height: height / height200,
                          decoration: BoxDecoration(
                            color: WidgetColor,
                            borderRadius: BorderRadius.circular(width / width20),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: width / width20,
                              vertical: height / height10
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterBold(
                                text: 'Clark Place - Unknown person',
                                fontsize: width / width18,
                                color: Primarycolor,
                              ),
                              SizedBox(height: height / height10,),
                              Flexible(
                                child: InterRegular(
                                  text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500...",
                                  fontsize: width / width16,
                                  color: color26,
                                  maxLines: 4,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                    icon: SvgPicture.asset(
                                      'assets/images/pdf.svg',
                                      height: height / height16,
                                      color: color2,
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.symmetric(horizontal:  width / width10),
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.image,
                                      size: width / width18,
                                      color: color2,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.video_collection,
                                      size: width / width18,
                                      color: color2,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: height / height10,)
                      ],
                    );
                  },
                  childCount: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
