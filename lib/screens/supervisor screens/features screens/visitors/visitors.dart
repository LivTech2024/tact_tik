import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/create_visitors.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import 'create_visitors.dart';

class SVisiTorsScreen extends StatefulWidget {
  const SVisiTorsScreen({Key? key});

  @override
  State<SVisiTorsScreen> createState() => _VisiTorsScreenState();
}

class _VisiTorsScreenState extends State<SVisiTorsScreen> {
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
          backgroundColor:
               Theme.of(context).primaryColor,
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

            var documents = snapshot.data!.docs;

            // Sort documents by a specific date field
            documents.sort((a, b) {
              final timestampA = a['VisitorCreatedAt'] as Timestamp;
              final timestampB = b['VisitorCreatedAt'] as Timestamp;
              return timestampB.compareTo(timestampA);
            });

            // Group documents by date
            final Map<String, List<QueryDocumentSnapshot>> groupedDocuments =
                {};
            final todayDate = DateTime.now();
            final todayKey = DateFormat.yMd().format(todayDate);

            for (var doc in documents) {
              final documentData = doc.data() as Map<String, dynamic>?;
              if (documentData != null) {
                final createdAtTimestamp =
                    documentData['VisitorCreatedAt'] as Timestamp?;
                final createdAtDate = createdAtTimestamp?.toDate();
                final formattedDate = createdAtDate != null
                    ? DateFormat.yMd().format(createdAtDate)
                    : '';

                if (groupedDocuments.containsKey(formattedDate)) {
                  groupedDocuments[formattedDate]!.add(doc);
                } else {
                  groupedDocuments[formattedDate] = [doc];
                }
              }
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                     
                    ),
                    padding: EdgeInsets.only(left: 20.w),
                    onPressed: () {
                      Navigator.pop(context);
                      print(
                          "Navigator debug: ${Navigator.of(context).toString()}");
                    },
                  ),
                  title: InterMedium(
                    text: 'Visitors',
                  
                  ),
                  centerTitle: true,
                  floating: true,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dateKey = groupedDocuments.keys.elementAt(index);
                      final isToday = dateKey == todayKey;
                      final dateHeading = isToday ? 'Today' : dateKey;
                      final visitorDocuments = groupedDocuments[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w),
                            child: InterBold(
                              text: dateHeading,
                              fontsize: 20.sp,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                          SizedBox(height: 30.h),
                          ...visitorDocuments.map((doc) {
                            final documentData =
                                doc.data() as Map<String, dynamic>;
                            final visitorCompleted =
                                isVisitorCompleted(documentData);
                            final visitorName =
                                documentData['VisitorName'] ?? '';
                            final inTimeTimestamp =
                                documentData['VisitorInTime'] as Timestamp?;
                            final outTimeTimestamp =
                                documentData['VisitorOutTime'] as Timestamp?;
                            final location =
                                documentData['VisitorLocationName'] ?? '';

                            final inTime = inTimeTimestamp != null
                                ? DateFormat.jm()
                                    .format(inTimeTimestamp.toDate())
                                : '';
                            final outTime = outTimeTimestamp != null
                                ? DateFormat.jm()
                                    .format(outTimeTimestamp.toDate())
                                : '';

                            return GestureDetector(
                              onTap: visitorCompleted
                                  ? null // Do nothing if visitor is completed
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SCreateVisitors(
                                            visitorData: documentData,
                                          ),
                                        ),
                                      );
                                    },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30.w),
                                child: Container(
                                  height: 120.h,
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      bottom: 10.h),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).shadowColor,
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                        offset: Offset(0, 3),
                                      )
                                    ],
                                    borderRadius:
                                        BorderRadius.circular(10.r),
                                    color: Theme.of(context).cardColor,
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
                                              Container(
                                                width: 40.w,
                                                height: 40.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
                                                ),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                     Theme.of(context)
                                                            .brightness == Brightness.dark
                                                        ? 'assets/images/man.svg'
                                                        : 'assets/images/man_light.svg',
                                                    height: 20.h,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120.w,
                                                child: InterMedium(
                                                  text: visitorName,
                                                  color:  Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color,
                                                  fontsize: 16.w,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      InterBold(
                                                        text: 'in time',
                                                        fontsize:
                                                            10.sp,
                                                        color:  Theme.of(context)
                                                            .focusColor,
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              6.w),
                                                      InterMedium(
                                                        text: inTime,
                                                        fontsize:
                                                            12.w,
                                                        color:  Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall!
                                                            .color,
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      InterBold(
                                                        text: 'out time',
                                                        fontsize:
                                                            10.sp,
                                                        color:  Theme.of(context)
                                                            .focusColor,
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              6.w),
                                                      InterMedium(
                                                        text: outTime,
                                                        fontsize:
                                                            12.sp,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall!
                                                            .color,
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
                                            color:  Theme.of(context)
                                                    .brightness == Brightness.dark
                                                ? DarkColor.colorRed
                                                : LightColor.colorRed,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                  10.w),
                                              bottomRight: Radius.circular(
                                                  10.w),
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
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                                fontsize: 14.sp,
                                              ),
                                              SizedBox(
                                                width: 200.w,
                                                child: InterRegular(
                                                  text: location,
                                                  fontsize: 12.sp,
                                                  color:  Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color,
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
                          }).toList(),
                        ],
                      );
                    },
                    childCount: groupedDocuments.keys.length,
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
