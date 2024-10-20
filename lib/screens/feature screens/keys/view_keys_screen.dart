import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/new%20guard/personel_details.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/key%20management/s_key_manag_create_screen.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../common/widgets/setTextfieldWidget.dart';
import '../../../services/Userservice.dart';
import '../../../services/firebaseFunctions/firebase_function.dart';
import '../../../utils/colors.dart';
import '../visitors/widgets/setTimeWidget.dart';

class ViewKeysScreen extends StatefulWidget {
  final String locationid;
  final String companyid;

  final String branchId;

  ViewKeysScreen({
    super.key,
    required this.locationid,
    required this.branchId,
    required this.companyid,
  });

  @override
  State<ViewKeysScreen> createState() => _ViewAssetsScreenState();
}

class _ViewAssetsScreenState extends State<ViewKeysScreen> {
  Map<String, List<QueryDocumentSnapshot>> groupedKeys = {};

  @override
  void initState() {
    super.initState();
    fetchKeys();
  }

  Future<void> fetchKeys() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('KeyAllocations')
        .where('KeyAllocationLocationId', isEqualTo: widget.locationid)
        .get();

    groupKeysByDate(querySnapshot.docs);
  }

  void groupKeysByDate(List<QueryDocumentSnapshot> keys) {
    final Map<String, List<QueryDocumentSnapshot>> tempGroupedKeys = {};

    for (var key in keys) {
      final createdAt = key['KeyAllocationCreatedAt'].toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(createdAt);

      if (!tempGroupedKeys.containsKey(dateKey)) {
        tempGroupedKeys[dateKey] = [];
      }
      tempGroupedKeys[dateKey]!.add(key);
    }

    setState(() {
      groupedKeys = Map.fromEntries(
        tempGroupedKeys.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => SCreateKeyManagScreen(
            //       keyId: '',
            //       companyId: widget.locationid,
            //       branchId: '',
            //       AllocationKeyId: '',
            //       guardcreation: false,
            //     ),
            //   ),
            // );
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SCreateKeyManagScreen(
                    keyId: "",
                    companyId: widget.companyid,
                    branchId: widget.branchId,
                    AllocationKeyId: '',
                    guardcreation: true,
                    locationId: widget.locationid,
                  ),
                ));
          },
          backgroundColor: Theme.of(context).primaryColor,
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
                padding: EdgeInsets.only(left: 20.w),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigator debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterMedium(
                text: 'Keys',
              ),
              centerTitle: true,
              floating: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30.h,
                    ),
                    InterBold(
                      text: 'Allotted Keys',
                      fontsize: 20.sp,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                  ],
                ),
              ),
            ),
            ...groupedKeys.entries.map((entry) {
              final date = entry.key;
              final keysForDate = entry.value;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.w, vertical: 30.h),
                        child: InterBold(
                          text: getDateHeader(date),
                          fontsize: 20.sp,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      );
                    }
                    final key = keysForDate[index - 1];
                    final createdAt = key['KeyAllocationCreatedAt'].toDate();
                    final formattedTime =
                        DateFormat('hh:mm a').format(createdAt);

                    final keyId = key.id; // Get the document ID

                    return FutureBuilder<String?>(
                      future: fireStoreService.FetchKeyName(
                          key['KeyAllocationKeyId']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        final keyName = snapshot.data;

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: GestureDetector(
                            onTap: () {
                              print(
                                  "key['KeyAllocationId'] ${key['KeyAllocationId']}");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SCreateKeyManagScreen(
                                    keyId: keyId,
                                    companyId: widget.locationid,
                                    branchId: widget.branchId,
                                    AllocationKeyId: key['KeyAllocationId'],
                                    guardcreation: false,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: 100.w,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 10.h),
                              width: double.maxFinite,
                              margin: EdgeInsets.only(bottom: 10.h),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10.r),
                                color: Theme.of(context).cardColor,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 44.h,
                                            width: 44.w,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.w),
                                              color: Theme.of(context)
                                                  .primaryColorLight,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.vpn_key,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                size: 24.w,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20.w),
                                          InterMedium(
                                            text: keyName ?? '',
                                            fontsize: 16.sp,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
                                          ),
                                        ],
                                      ),
                                      InterMedium(
                                        text: formattedTime,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                        fontsize: 16.sp,
                                      ),
                                      // SizedBox(width: 10.w),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 44.h,
                                            width: 44.w,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.w),
                                              color: Theme.of(context)
                                                  .primaryColorLight,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.account_circle_outlined,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                size: 24.w,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20.w),
                                          InterMedium(
                                            text:
                                                key['KeyAllocationRecipientName'] ??
                                                    '',
                                            fontsize: 16.sp,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
                                          ),
                                        ],
                                      ),
                                      // InterMedium(
                                      //   text: formattedTime,
                                      //   color: Theme.of(context)
                                      //       .textTheme
                                      //       .bodyMedium!
                                      //       .color,
                                      //   fontsize: 16.sp,
                                      // ),
                                      // SizedBox(width: 10.w),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: keysForDate.length + 1,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String getDateHeader(String date) {
    final today = DateTime.now().toUtc().toLocal();
    final dateTime = DateTime.parse(date);

    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      return 'Today';
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
    }
  }
}
