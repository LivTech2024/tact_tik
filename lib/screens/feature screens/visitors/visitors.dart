import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/create_visitors.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class VisiTorsScreen extends StatefulWidget {
  const VisiTorsScreen({Key? key});

  @override
  State<VisiTorsScreen> createState() => _VisiTorsScreenState();
}

class _VisiTorsScreenState extends State<VisiTorsScreen> {
  late UserService _userService;
  FireStoreService fireStoreService = FireStoreService();

  bool isVisitorCompleted(Map<String, dynamic> documentData) {
    final inTimeTimestamp = documentData['VisitorInTime'] as Timestamp?;
    final outTimeTimestamp = documentData['VisitorOutTime'] as Timestamp?;

    return inTimeTimestamp != null && outTimeTimestamp != null;
  }

  @override
  void initState() {
    super.initState();
    _userService = UserService(firestoreService: FireStoreService());
    _userService.getShiftInfo();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateVisitors(visitorData: null),
              ),
            );
          },
          backgroundColor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('Visitors')
              .where('VisitorLocationId',
                  isEqualTo: _userService.shiftLocationId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final documents = snapshot.data!.docs;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  shadowColor: isDark ? DarkColor.color1 : LightColor.color3.withOpacity(.1),
                  backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
                  elevation: 5,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: isDark
                          ? DarkColor.color1
                          : LightColor.color3,
                      size: width / width24,
                    ),
                    padding: EdgeInsets.only(left: width / width20),
                    onPressed: () {
                      Navigator.pop(context);
                      print(
                          "Navigator debug: ${Navigator.of(context).toString()}");
                    },
                  ),
                  title: InterRegular(
                    text: 'Visitors',
                    fontsize: width / width18,
                    color: isDark
                        ? DarkColor.color1
                        : LightColor.color3,
                    letterSpacing: -0.3,
                  ),
                  centerTitle: true,
                  floating: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / width30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: height / height30,
                        ),
                        InterBold(
                          text: 'Today',
                          fontsize: width / width20,
                          color: isDark
                              ? DarkColor.Primarycolor
                              : LightColor.color3,
                        ),
                        SizedBox(
                          height: height / height30,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final document = documents[index];
                      final documentData =
                          document.data() as Map<String, dynamic>?;

                      print("document_data:$documentData");

                      if (documentData != null) {
                        final visitorCompleted =
                            isVisitorCompleted(documentData);
                        final visitorName = documentData['VisitorName'] ?? '';
                        final inTimeTimestamp =
                            documentData['VisitorInTime'] as Timestamp?;
                        final outTimeTimestamp =
                            documentData['VisitorOutTime'] as Timestamp?;
                        final location =
                            documentData['VisitorLocationName'] ?? '';

                        final inTime = inTimeTimestamp != null
                            ? DateFormat.jm().format(inTimeTimestamp.toDate())
                            : '';
                        final outTime = outTimeTimestamp != null
                            ? DateFormat.jm().format(outTimeTimestamp.toDate())
                            : '';

                        return GestureDetector(
                          onTap: visitorCompleted
                              ? null // Do nothing if visitor is completed
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateVisitors(
                                        visitorData: documentData,
                                      ),
                                    ),
                                  );
                                },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width / width30),
                            child: Container(
                              height: width / width120,
                              width: double.maxFinite,
                              margin:
                                  EdgeInsets.only(bottom: height / height10),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? DarkColor.color1.withOpacity(.1)
                                        : LightColor.color3.withOpacity(.1),
                                    blurRadius: 1,
                                    spreadRadius: 2,
                                    offset: Offset(0, 3),
                                  )
                                ],
                                borderRadius:
                                    BorderRadius.circular(width / width10),
                                color: isDark
                                    ? DarkColor.WidgetColor
                                    : LightColor.WidgetColor,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width / width10,
                                        vertical: height / height10,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: width / width40,
                                            height: height / height40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      width / width10),
                                              color:
                                                  isDark
                                                  ? DarkColor.Primarycolorlight
                                                  : LightColor.Primarycolorlight,
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                'assets/images/man.svg',
                                                height: height / height20,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width / width120,
                                            child: InterMedium(
                                              text: visitorName,
                                              color: isDark
                                                  ? DarkColor.color1
                                                  : LightColor.color3,
                                              fontsize: width / width16,
                                              maxLines: 1,
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                children: [
                                                  InterBold(
                                                    text: 'in time',
                                                    fontsize: width / width10,
                                                    color: isDark
                                                        ? DarkColor.color4
                                                        : LightColor
                                                            .color3,
                                                  ),
                                                  SizedBox(
                                                      width: width / width6),
                                                  InterMedium(
                                                    text: inTime,
                                                    fontsize: width / width12,
                                                    color: isDark
                                                        ? DarkColor.color3
                                                        : LightColor
                                                            .color3,
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  InterBold(
                                                    text: 'out time',
                                                    fontsize: width / width10,
                                                    color: isDark
                                                        ? DarkColor.color4
                                                        : LightColor
                                                            .color3,
                                                  ),
                                                  SizedBox(
                                                      width: width / width6),
                                                  InterMedium(
                                                    text: outTime,
                                                    fontsize: width / width12,
                                                    color: isDark
                                                        ? DarkColor.color3
                                                        : LightColor
                                                            .color3,
                                                  )
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width / width10),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? DarkColor.colorRed
                                            : LightColor.colorRed,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft:
                                              Radius.circular(width / width10),
                                          bottomRight:
                                              Radius.circular(width / width10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          InterSemibold(
                                            text: 'Location',
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                            fontsize: width / width14,
                                          ),
                                          SizedBox(
                                            width: width / width200,
                                            child: InterRegular(
                                              text: location,
                                              fontsize: width / width12,
                                              color: isDark
                                                  ? DarkColor.color2
                                                  : LightColor.color3,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                    childCount: documents.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
