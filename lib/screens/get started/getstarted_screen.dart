import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tact_tik/screens/get%20started/page_type1.dart';
import 'package:tact_tik/screens/get%20started/page_type2.dart';
import '../../fonts/poppins_bold.dart';
import '../../utils/colors.dart';

class GetStartedScreens extends StatefulWidget {
  GetStartedScreens({super.key});

  @override
  State<GetStartedScreens> createState() => _GetStartedScreensState();
}

class _GetStartedScreensState extends State<GetStartedScreens> {
  bool LastPage = false;

  final _pagecontroller = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    super.dispose();
    _pagecontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomSheet: LastPage
            ? const SizedBox()
            : Container(
                height: 66.h,
                color: Secondarycolor,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          _pagecontroller.jumpToPage(3);
                        },
                        child: PoppinsBold(
                          text: 'Skip',
                          fontsize: 16.sp,
                          color: Primarycolor,
                        ),
                      ),
                      SmoothPageIndicator(
                        controller: _pagecontroller,
                        count: 3,
                        effect: WormEffect(
                          dotColor: color3,
                          activeDotColor: Primarycolor,
                          dotHeight: 13.h,
                          dotWidth: 13.w,
                          type: WormType.thinUnderground,
                        ),
                        onDotClicked: (index) => _pagecontroller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _pagecontroller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 24.sp,
                          color: Primarycolor,
                        ),
                      )
                    ],
                  ),
                ),
              ),
        body: PageView(
          onPageChanged: (index) {
            setState(() {
              LastPage = 3 == index;
            });
          },
          controller: _pagecontroller,
          children: [
            PageType1(
              index: 0,
            ),
            PageType1(
              index: 1,
            ),
            PageType1(
              index: 2,
            ),
            PageType2(
              index: 3,
            ),
          ],
        ),
      ),
    );
  }
}
