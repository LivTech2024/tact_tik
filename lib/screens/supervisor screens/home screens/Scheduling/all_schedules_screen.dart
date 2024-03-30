import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import '../../../../common/sizes.dart';
import '../../../../utils/colors.dart';

class AllSchedulesScreen extends StatelessWidget {
  AllSchedulesScreen({super.key});

  final List<String> members = [
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
  ];

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
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'All Schedule',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    InterBold(
                      text: 'Search',
                      fontsize: 20,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Container(
                      height: height / height64,
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width10),
                      decoration: BoxDecoration(
                        color: WidgetColor,
                        borderRadius: BorderRadius.circular(width / width13),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300,
                                fontSize: width / width18,
                                color:
                                    Colors.white, // Change text color to white
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(width / width10),
                                  ),
                                ),
                                focusedBorder: InputBorder.none,
                                hintStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300,
                                  fontSize: width / width18,
                                  color: color2, // Change text color to white
                                ),
                                hintText: 'Search',
                                contentPadding:
                                    EdgeInsets.zero, // Remove padding
                              ),
                              cursorColor: Primarycolor,
                            ),
                          ),
                          Container(
                            height: height / height44,
                            width: width / width44,
                            decoration: BoxDecoration(
                              color: Primarycolor,
                              borderRadius:
                                  BorderRadius.circular(width / width10),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.search,
                                size: width / width20,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    InterBold(
                      text: 'Today',
                      fontsize: 20,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Container(
                      height: 160,
                      margin: EdgeInsets.only(top: 10),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Primarycolor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 30,
                                width: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  color: color22,
                                ),
                              ),
                              SizedBox(width: 14),
                              SizedBox(
                                width: 190,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: 'Marvin McKinney',
                                      color: color22,
                                    ),
                                    SizedBox(height: 5),
                                    InterRegular(
                                      text:
                                          '2972 Westheimer Rd.  Anaa xyz road 123 building',
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 28),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 18.0, right: 24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Guards',
                                        fontsize: 14,
                                        color: color22,
                                      ),
                                      SizedBox(height: 12),
                                      Wrap(
                                        spacing: -5.0, // spacing between avatars
                                        // runSpacing: 8.0, // spacing between rows
                                        children: [
                                          for (int i = 0; i < (members.length > 3 ? 3 : members.length); i++)
                                            CircleAvatar(
                                              radius: 10.0,
                                              backgroundImage: NetworkImage(members[i]), // Assuming members list contains URLs of profile photos
                                            ),
                                          if (members.length > 3)
                                            CircleAvatar(
                                              radius: 10.0,
                                              backgroundColor: color23,
                                              child: InterMedium(text: '+${members.length - 3}',fontsize: 12,),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // shift time and date
                                SizedBox(
                                  width: 200,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Shift',
                                        color: color22,
                                        fontsize: 14,
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                height: 14,
                                                width: 14,
                                                child: SvgPicture.asset(
                                                    'assets/images/calendar_line.svg'),
                                              ),
                                              SizedBox(width: 6),
                                              InterMedium(
                                                text: '12:00pm - 12:30am',
                                                fontsize: 14,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: SvgPicture.asset(
                                                'assets/images/edit_square.svg'),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
