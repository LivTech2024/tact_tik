import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/feature%20screens/briefing_box/create_briefing_box_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BriefingBoxScreen extends StatefulWidget {
  final String locationId;
  final String shiftName;
  const BriefingBoxScreen(
      {super.key, required this.locationId, required this.shiftName});

  @override
  State<BriefingBoxScreen> createState() => _BriefingBoxScreenState();
}

class _BriefingBoxScreenState extends State<BriefingBoxScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
  }

  Future<QuerySnapshot> getBriefings() {
    return FirebaseFirestore.instance
        .collection('BriefingBox')
        .where('BriefingLocationId', isEqualTo: widget.locationId)
        .where('BriefingCreatedBy', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('BriefingCreatedBy')
        .orderBy('BriefingCreatedAt', descending: true)
        .get();
  }

  Future<String> getEmployeeName(String employeeId) async {
    DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
        .collection('Employees')
        .doc(employeeId)
        .get();
    return employeeDoc['EmployeeName'] ?? 'Unknown';
  }

  Future<List<String>> getEmployeeImages(List<String> employeeIds) async {
    List<String> images = [];
    for (String id in employeeIds) {
      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection('Employees')
          .doc(id)
          .get();
      String? img = employeeDoc['EmployeeImg'] as String?;
      if (img != null) images.add(img);
    }
    return images;
  }

  Future<void> markAsRead(String docId) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('BriefingBox')
        .doc(docId)
        .update({
      'BriefingViewedBy': FieldValue.arrayUnion([currentUserId])
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateBriefingBoxScreen(
                  locationId: widget.locationId,
                  shiftName: widget.shiftName,
                ),
              ),
            );
            if (result == true) {
              setState(() {});
            }
          },
          backgroundColor: Theme.of(context).primaryColor,
          shape: CircleBorder(),
          child: Icon(
            color: Colors.white,
            Icons.add,
            size: 24.sp,
          ),
        ),
        body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: () async {
            setState(() {});
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  padding: EdgeInsets.only(left: 20.w),
                  onPressed: () => Navigator.pop(context),
                ),
                title: InterMedium(text: 'Briefing Box'),
                centerTitle: true,
                floating: true,
              ),
              FutureBuilder<QuerySnapshot>(
                future: getBriefings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }

                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                        child: Center(child: Text('Error: ${snapshot.error}')));
                  }

                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.docs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.h),
                          child: InterMedium(
                            text: 'No briefings available',
                            fontsize: 18.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ),
                    );
                  }

                  Map<String, List<DocumentSnapshot>> groupedBriefings = {};
                  snapshot.data!.docs.forEach((doc) {
                    DateTime createdAt =
                        (doc['BriefingCreatedAt'] as Timestamp).toDate();
                    String dateKey = DateFormat('yyyy-MM-dd').format(createdAt);
                    if (!groupedBriefings.containsKey(dateKey)) {
                      groupedBriefings[dateKey] = [];
                    }
                    groupedBriefings[dateKey]!.add(doc);
                  });

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        String dateKey = groupedBriefings.keys.elementAt(index);
                        List<DocumentSnapshot> briefings =
                            groupedBriefings[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30.w, vertical: 10.h),
                              child: InterSemibold(
                                text: DateFormat('MMMM d, yyyy')
                                    .format(DateTime.parse(dateKey)),
                                fontsize: 18.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              ),
                            ),
                            ...briefings
                                .map((doc) => FutureBuilder<String>(
                                      future: getEmployeeName(
                                          doc['BriefingCreatedBy']),
                                      builder: (context, employeeSnapshot) {
                                        if (employeeSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                left: 30.w,
                                                right: 30.w,
                                                bottom: 40.h),
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        List<String> viewedBy =
                                            List<String>.from(
                                                doc['BriefingViewedBy'] ?? []);
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            left: 30.w,
                                            right: 30.w,
                                            bottom: 40.h,
                                          ),
                                          child: Container(
                                            width: double.maxFinite,
                                            constraints: BoxConstraints(
                                              minHeight: 140.h,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 14.w,
                                              vertical: 10.h,
                                            ),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .shadowColor,
                                                  blurRadius: 5,
                                                  spreadRadius: 2,
                                                  offset: Offset(0, 3),
                                                )
                                              ],
                                              color:
                                                  Theme.of(context).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(10.h),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InterSemibold(
                                                      text: employeeSnapshot
                                                              .data ??
                                                          'Unknown',
                                                      fontsize: 20.sp,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall!
                                                          .color,
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await markAsRead(
                                                            doc.id);
                                                        setState(() {});
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ),
                                                      child: InterMedium(
                                                        text: 'Mark as read',
                                                        fontsize: 14.sp,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10.h),
                                                InterSemibold(
                                                  text: doc['BriefingTitle'],
                                                  fontsize: 20.sp,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color,
                                                  maxLines: 5,
                                                ),
                                                SizedBox(height: 5.h),
                                                InterMedium(
                                                  text: doc[
                                                      'BriefingDescription'],
                                                  fontsize: 14.sp,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall!
                                                      .color,
                                                  maxLines: 4,
                                                ),
                                                SizedBox(height: 10.h),
                                                InterMedium(text: "Viewed By:"),
                                                SizedBox(height: 10.h),
                                                FutureBuilder<List<String>>(
                                                  future: getEmployeeImages(
                                                      viewedBy),
                                                  builder:
                                                      (context, imageSnapshot) {
                                                    if (imageSnapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return CircularProgressIndicator();
                                                    }
                                                    List<String>
                                                        employeeImages =
                                                        imageSnapshot.data ??
                                                            [];
                                                    if (employeeImages
                                                        .isEmpty) {
                                                      return InterMedium(
                                                        text:
                                                            'Not viewed by anyone',
                                                        fontsize: 14.sp,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall!
                                                            .color,
                                                      );
                                                    }
                                                    return Wrap(
                                                      spacing: -5.0,
                                                      children: [
                                                        for (int i = 0;
                                                            i <
                                                                (employeeImages
                                                                            .length >
                                                                        3
                                                                    ? 3
                                                                    : employeeImages
                                                                        .length);
                                                            i++)
                                                          CircleAvatar(
                                                            radius: 10.r,
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    employeeImages[
                                                                        i]),
                                                          ),
                                                        if (employeeImages
                                                                .length >
                                                            3)
                                                          CircleAvatar(
                                                            radius: 10.r,
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium!
                                                                    .color,
                                                            child: InterMedium(
                                                              text:
                                                                  '+${employeeImages.length - 3}',
                                                              fontsize: 12.sp,
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ))
                                .toList(),
                          ],
                        );
                      },
                      childCount: groupedBriefings.length,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
