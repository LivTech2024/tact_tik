import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/new%20guard/address_details.dart';
import 'package:tact_tik/screens/new%20guard/certificate_detailes.dart';
import 'package:tact_tik/screens/new%20guard/licenses_details.dart';
import 'package:tact_tik/screens/new%20guard/personel_details.dart';
import 'package:tact_tik/screens/new%20guard/bank_details.dart';
import 'package:tact_tik/utils/colors.dart';

class NewGuardScreen extends StatefulWidget {
  NewGuardScreen({super.key});

  @override
  State<NewGuardScreen> createState() => _NewGuardScreenState();
}

class _NewGuardScreenState extends State<NewGuardScreen> {
  bool LastPage = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final _pagecontroller = PageController(
      initialPage: 0,
    );

    return Scaffold(
      backgroundColor:
          isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
      appBar: AppBar(
        backgroundColor:
            isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? DarkColor.color1 : LightColor.color3,
            size: width / width24,
          ),
          padding: EdgeInsets.only(left: width / width20),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: InterMedium(
          text: 'New Guard',
          fontsize: width / width18,
          color: isDark ? DarkColor.color1 : LightColor.color3,
          letterSpacing: -.3,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: PageView(
        controller: _pagecontroller,
        onPageChanged: (index) {
          setState(() {
            LastPage = 4 == index;
          });
        },
        children: [
          PersonalDetails(),
          BankDetails(),
          LicensesDetails(),
          CertificateDetails(),
          AddressDetails()
        ],
      )),
      bottomSheet: LastPage
          ?  Button1(
            text: 'Submit',
            onPressed: (){},
            backgroundcolor:
                isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
            color: isDark ? DarkColor.color1 : LightColor.color1,
            borderRadius: width / width10,
            fontsize: width / width18,
          )
          : Container(
              height: height / height66,
              color:
                  isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => _pagecontroller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: width / width24,
                        color:
                            isDark ? DarkColor.Primarycolor : LightColor.color3,
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
                        color:
                            isDark ? DarkColor.Primarycolor : LightColor.color3,
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
