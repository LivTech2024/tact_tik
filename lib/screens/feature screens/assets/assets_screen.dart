import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/assets/view_assets_screen.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class AssetsScreen extends StatefulWidget {
  final String assetEmpId;

  const AssetsScreen({super.key, required this.assetEmpId});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  late Stream<QuerySnapshot> _assetAllocationStream;

  Map<DateTime, List<QueryDocumentSnapshot>> groupDocumentsByDate(
      List<QueryDocumentSnapshot>? documents) {
    documents?.sort((a, b) {
      final timestampA = a['EquipmentAllocationCreatedAt'] as Timestamp;
      final timestampB = b['EquipmentAllocationCreatedAt'] as Timestamp;
      return timestampB.compareTo(timestampA);
    });

    final Map<DateTime, List<QueryDocumentSnapshot>> documentsByDate = {};

    if (documents != null) {
      for (final document in documents) {
        final allocationDate =
            (document['EquipmentAllocationCreatedAt'] as Timestamp).toDate();
        final date = DateTime(
            allocationDate.year, allocationDate.month, allocationDate.day);

        documentsByDate.putIfAbsent(date, () => []).add(document);
      }
    }

    return documentsByDate;
  }

  @override
  void initState() {
    super.initState();
    _assetAllocationStream = FirebaseFirestore.instance
        .collection('EquipmentAllocations')
        .where('EquipmentAllocationEmpId', isEqualTo: widget.assetEmpId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        
        body: StreamBuilder(
            stream: _assetAllocationStream,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final documents = snapshot.data?.docs;
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
                          text: 'Assets',
                          
                          letterSpacing: -0.3,
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
                              // InterBold(
                              //   text: 'Today', //CHANGE HERE MATCH WITH CURRENT DATE (EquipmentAllocationCreatedAt)
                              //   fontsize: width / width20,
                              //   color: Primarycolor,
                              // ),
                              // SizedBox(
                              //   height: height / height30,
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final documentsByDate =
                                groupDocumentsByDate(documents);
                            final dates = documentsByDate.keys.toList();

                            if (index < dates.length) {
                              final date = dates[index];
                              final isToday =
                                  date.year == DateTime.now().year &&
                                      date.month == DateTime.now().month &&
                                      date.day == DateTime.now().day;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30.w,
                                    ),
                                    child: InterBold(
                                      text: isToday
                                          ? 'Today'
                                          : DateFormat.yMMMd().format(date),
                                   fontsize: 20.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .color,
                                    ),
                                  ),
                                  SizedBox(height: 30.h),
                                  ...documentsByDate[date]!.map(
                                    (document) {
                                      final allocationDate = (document[
                                                  'EquipmentAllocationCreatedAt']
                                              as Timestamp)
                                          .toDate();
                                      final allocationDateTime = DateFormat.Hm()
                                          .format(allocationDate);
                                      final startDate = (document[
                                                  'EquipmentAllocationStartDate']
                                              as Timestamp)
                                          .toDate();
                                      final endDate = (document[
                                                  'EquipmentAllocationEndDate']
                                              as Timestamp)
                                          .toDate();
                                      final equipmentId = document[
                                          'EquipmentAllocationEquipId'];
                                      final equipmentQty = document[
                                          'EquipmentAllocationEquipQty'];

                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30.w),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewAssetsScreen(
                                                  startDate: DateFormat.yMd()
                                                      .format(startDate),
                                                  endDate: DateFormat.yMd()
                                                      .format(endDate),
                                                  equipmentId: equipmentId,
                                                  equipmentQty: equipmentQty,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: 60.h,
                                            width: double.maxFinite,
                                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                                            margin:
                                                EdgeInsets.only(bottom: 10.h),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                     BorderRadius.circular(10.r),
                                              color: Theme.of(context).cardColor,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 10.w,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.r),
                                                        color:
                                                         isDark
                                                            ? DarkColor
                                                                .Primarycolorlight
                                                            : LightColor
                                                                .Primarycolorlight,
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons
                                                              .home_repair_service,
                                                          color: isDark
                                                              ? DarkColor
                                                                  .Primarycolor
                                                              : LightColor
                                                                  .Primarycolor,
                                                          size: 24.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 20.w),
                                                    StreamBuilder<
                                                        QuerySnapshot>(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'Equipments')
                                                          .where('EquipmentId',
                                                              isEqualTo:
                                                                  equipmentId)
                                                          .snapshots(),
                                                      builder:
                                                          (context, snapshot) {
                                                        String equipmentName =
                                                            'Equipment Not Available';
                                                        if (snapshot.hasData) {
                                                          final documents =
                                                              snapshot
                                                                  .data!.docs;
                                                          equipmentName = documents
                                                                  .isNotEmpty
                                                              ? (documents.first
                                                                          .data()
                                                                      as Map<
                                                                          String,
                                                                          dynamic>)['EquipmentName'] ??
                                                                  'Equipment Not Available'
                                                              : 'Equipment Not Available';
                                                        }
                                                        return InterMedium(
                                                          text: equipmentName,
                                                             fontsize: 16.sp,
                                                          color: isDark
                                                              ? DarkColor
                                                                  .color1
                                                              : LightColor
                                                                  .color3,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                InterMedium(
                                                  text: allocationDateTime,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium!
                                                      .color,
                                                fontsize: 16.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            }

                            return SizedBox.shrink();
                          },
                          childCount:
                              groupDocumentsByDate(documents).keys.length + 1,
                        ),
                      ),
                    ],
                  );
                }
              }
            }),
      ),
    );
  }
}
