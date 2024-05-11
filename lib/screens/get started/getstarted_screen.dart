import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tact_tik/screens/get%20started/page_type1.dart';
import 'package:tact_tik/screens/get%20started/page_type2.dart';
import '../../common/sizes.dart';
import '../../fonts/poppins_bold.dart';
import '../../fonts/poppins_medium.dart';
import '../../fonts/poppins_regular.dart';
import '../../fonts/poppis_semibold.dart';
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
    bool isLight = Theme.of(context).brightness == Brightness.light;
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        bottomSheet: LastPage
            ? const SizedBox()
            : Container(
                height: height / height66,
                color: isLight ? color18 : Secondarycolor,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width / width40),
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
                          fontsize: width / width16,
                          color: isLight ? IconSelected :Primarycolor,
                        ),
                      ),
                      SmoothPageIndicator(
                        controller: _pagecontroller,
                        count: 3,
                        effect: WormEffect(
                          dotColor: color3,
                          activeDotColor: isLight ? IconSelected :Primarycolor,
                          dotHeight: height / height13,
                          dotWidth: width / width13,
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
                          size: width / width24,
                          color: isLight ? IconSelected :Primarycolor,
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
