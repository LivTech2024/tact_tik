import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/s_home_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../utils/colors.dart';
import 'create_shedule_screen.dart';

class AllSchedulesScreen extends StatelessWidget {
  String BranchId;

  AllSchedulesScreen({
    Key? key,
    required this.BranchId,
  }) : super(key: key);

  final List<String> members = [
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
  ];

  void NavigateScreen(BuildContext context, Widget screen) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SHomeScreen()));
  }

  List<DocumentSnapshot<Object?>> _guardsInfo = [];

  void _getShift() async {
    FireStoreService fireStoreService = FireStoreService();
    var userInfo = await fireStoreService.getAllSchedules(BranchId);
    print("All Schedules: ${userInfo}");
  }

  void initState() {
    _getShift();
  }

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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SHomeScreen()));
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
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: Primarycolor,
            onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (builder) => CreateSheduleScreen(GuardId: '', GuardName: '', GuardImg: '', CompanyId: '')));},
            child: Icon(Icons.add),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Padding(
          padding:
              EdgeInsets.only(left: width / width30, right: width / width30),
          child: CustomScrollView(
            physics: PageScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height / height30),
                    InterBold(
                      text: 'Search',
                      fontsize: width / width20,
                      color: Colors.white,
                    ),
                    SizedBox(height: height / height24),
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
                    SizedBox(height: height / height30),
                    InterBold(
                      text: 'Today',
                      fontsize: width / width20,
                      color: Colors.white,
                    ),
                    SizedBox(height: height / height24),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: 10,
                  (context, index) {
                    return Container(
                      height: height / height160,
                      margin: EdgeInsets.only(top: height / height10),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Primarycolor,
                        borderRadius: BorderRadius.circular(width / width14),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: height / height20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: height / height30,
                                width: width / width4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(width / width10),
                                    bottomRight:
                                        Radius.circular(width / width10),
                                  ),
                                  color: color22,
                                ),
                              ),
                              SizedBox(width: width / width14),
                              SizedBox(
                                width: width / width190,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: 'Marvin McKinney',
                                      color: color22,
                                      fontsize: width / width14,
                                    ),
                                    SizedBox(height: height / height5),
                                    InterRegular(
                                      text:
                                          '2972 Westheimer Rd.  Anaa xyz road 123 building',
                                      maxLines: 1,
                                      fontsize: width / width14,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: height / height10),
                          Padding(
                            padding: EdgeInsets.only(
                              left: width / width18,
                              right: width / width24,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: width / width100,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Guards',
                                        fontsize: width / width14,
                                        color: color22,
                                      ),
                                      SizedBox(height: height / height12),
                                      Wrap(
                                        spacing: -5.0,
                                        // spacing between avatars
                                        // runSpacing: 8.0, // spacing between rows
                                        children: [
                                          for (int i = 0;
                                              i <
                                                  (members.length > 3
                                                      ? 3
                                                      : members.length);
                                              i++)
                                            CircleAvatar(
                                              radius: width / width10,
                                              backgroundImage: NetworkImage(members[
                                                  i]), // Assuming members list contains URLs of profile photos
                                            ),
                                          if (members.length > 3)
                                            CircleAvatar(
                                              radius: width / width10,
                                              backgroundColor: color23,
                                              child: InterMedium(
                                                text: '+${members.length - 3}',
                                                fontsize: width / width12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // shift time and date
                                SizedBox(
                                  width: width / width200,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Shift',
                                        color: color22,
                                        fontsize: width / width14,
                                      ),
                                      SizedBox(height: height / height5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                height: height / height14,
                                                width: width / width14,
                                                child: SvgPicture.asset(
                                                    'assets/images/calendar_line.svg'),
                                              ),
                                              SizedBox(width: width / width6),
                                              InterMedium(
                                                text: '12:00pm - 12:30am',
                                                fontsize: width / width14,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: height / height20,
                                            width: width / width20,
                                            child: SvgPicture.asset(
                                              'assets/images/edit_square.svg',
                                            ),
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
