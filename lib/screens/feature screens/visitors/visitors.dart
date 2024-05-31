import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/create_visitors.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class VisiTorsScreen extends StatefulWidget {
  final String locationId;

  const VisiTorsScreen({Key? key, required this.locationId});

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
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
          backgroundColor: Primarycolor,
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
            size: 24.sp,
          ),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('Visitors')
              .where('VisitorLocationId', isEqualTo: widget.locationId)
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
                  backgroundColor: AppBarcolor,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    padding: EdgeInsets.only(left: 20.w),
                    onPressed: () {
                      Navigator.pop(context);
                      print(
                          "Navigator debug: ${Navigator.of(context).toString()}");
                    },
                  ),
                  title: InterRegular(
                    text: 'Visitors',
                    fontsize: 18.sp,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                  centerTitle: true,
                  floating: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30.h,
                        ),
                        InterBold(
                          text: 'Today',
                          fontsize: 20.sp,
                          color: Primarycolor,
                        ),
                        SizedBox(
                          height: 30.h,
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
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Container(
                              height: 120.h,
                              width: double.maxFinite,
                              margin: EdgeInsets.only(bottom: 16.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: WidgetColor,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 10.h,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 40.w,
                                                height: 40.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
                                                  color: Primarycolorlight,
                                                ),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    'assets/images/man.svg',
                                                    height: 20.h,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20.w,
                                              ),
                                              SizedBox(
                                                width: 120.w,
                                                child: InterMedium(
                                                  text: visitorName,
                                                  color: color1,
                                                  fontsize: 16.sp,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
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
                                                    fontsize: 10.sp,
                                                    color: color4,
                                                  ),
                                                  SizedBox(
                                                      width: 6.w),
                                                  InterMedium(
                                                    text: inTime,
                                                    fontsize: 12.sp,
                                                    color: color3,
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  InterBold(
                                                    text: 'out time',
                                                    fontsize: 10.sp,
                                                    color: color4,
                                                  ),
                                                  SizedBox(
                                                      width: 6.w),
                                                  InterMedium(
                                                    text: outTime,
                                                    fontsize: 12.sp,
                                                    color: color3,
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
                                          horizontal: 10.w),
                                      decoration: BoxDecoration(
                                        color: colorRed,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft:
                                              Radius.circular(10.r),
                                          bottomRight:
                                              Radius.circular(10.r),
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
                                            color: color1,
                                            fontsize: 14.sp,
                                          ),
                                          SizedBox(
                                            width: 200.w,
                                            child: InterRegular(
                                              text: location,
                                              fontsize: 12.sp,
                                              color: color2,
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
