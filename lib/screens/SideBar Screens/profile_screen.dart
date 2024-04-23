import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';

import '../../common/sizes.dart';
import '../../fonts/inter_regular.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';
import '../home screens/widgets/profile_edit_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
            text: 'Your Profile',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 340,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      const Color(0xFF9C6400),
                    ],
                    begin: Alignment(0, -1.5),
                    end: Alignment.bottomCenter,
                    // // stops: [0.0, 1.0],
                    // tileMode: LinearGradient,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4), // Border width
                        decoration: BoxDecoration(
                            color: Color(0xFFAC7310), shape: BoxShape.circle),
                        child: ClipOval(
                          child: SizedBox.fromSize(
                            size: Size.fromRadius(50), // Image radius
                            child: Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShFeAzAlYSLdCn3V8OOjNxeKeCaV1mL4zkWxac5NtYwQ&s',
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      SizedBox(height: height / height20),
                      PoppinsMedium(
                        text: 'Nick Jones',
                        fontsize: width / width18,
                        color: color1,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: height / height40),
                      child: ProfileEditWidget(
                        tittle: 'Name',
                        content: 'Nick Jones Saturn',
                      ),
                    ),
                    ProfileEditWidget(
                      tittle: 'Contact No',
                      content: '+91 9876543210',
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: height / height40),
                      child: ProfileEditWidget(
                        tittle: 'Email',
                        content: 'BX123@gmail.com',
                      ),
                    ),
                    ProfileEditWidget(
                      tittle: 'Designation',
                      content: 'guard',
                    ),
                  ],
                ),
              ),
              SizedBox(height: height / height60),
              Center(
                child: PoppinsRegular(
                  text: 'complete your profile !',
                  fontsize: width / width20,
                  color: color3,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
