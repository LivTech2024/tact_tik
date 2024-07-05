import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/assets/s_assets_view_alloted.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/assets/s_create_assign_asset.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SAssetsViewScreen extends StatefulWidget {
  final String empId;
  final String companyId;
  final String EmpName;
  const SAssetsViewScreen(
      {super.key,
      required this.empId,
      required this.companyId,
      required this.EmpName});

  @override
  _SAssetsViewScreenState createState() => _SAssetsViewScreenState();
}

class _SAssetsViewScreenState extends State<SAssetsViewScreen> {
  Map<String, List<QueryDocumentSnapshot>> groupedEquipments = {};

  @override
  void initState() {
    super.initState();
    fetchEquipments();
  }

  Future<void> fetchEquipments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Equipments')
        .where('EquipmentCompanyId', isEqualTo: widget.companyId)
        .get();

    groupEquipmentsByDate(querySnapshot.docs);
  }

  void groupEquipmentsByDate(List<QueryDocumentSnapshot> equipments) {
    final Map<String, List<QueryDocumentSnapshot>> tempGroupedEquipments = {};

    for (var equipment in equipments) {
      final createdAt = equipment['EquipmentCreatedAt'].toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(createdAt);

      if (!tempGroupedEquipments.containsKey(dateKey)) {
        tempGroupedEquipments[dateKey] = [];
      }
      tempGroupedEquipments[dateKey]!.add(equipment);
    }

    setState(() {
      groupedEquipments = Map.fromEntries(
        tempGroupedEquipments.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SCreateAssignAssetScreen(
                    companyId: widget.companyId,
                    empId: '',
                    OnlyView: false,
                    equipemtAllocId: '',
                    onRefresh: () {},
                  ),
                ));
          },
          backgroundColor: Theme.of(context).primaryColor,
          shape: CircleBorder(),
          child: Icon(Icons.add,color: Colors.white,),
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
                text: 'Assets',
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
                    /*SizedBox(
                      height: 30.h,
                    ),*/
                  ],
                ),
              ),
            ),
            ...groupedEquipments.entries.map((entry) {
              final date = entry.key;
              final equipmentsForDate = entry.value;

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
                    final equipment = equipmentsForDate[index - 1];
                    final createdAt = equipment['EquipmentCreatedAt'].toDate();
                    final formattedTime =
                        DateFormat('hh:mm a').format(createdAt);
                    final equipmentAllocationId = equipment['EquipmentId'];

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             SCreateAssignAssetScreen(
                          //               equipemtAllocId: equipmentAllocationId,
                          //               companyId: widget.companyId,
                          //               empId: widget.empId,
                          //               OnlyView: true,
                          //             )));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SAssetsViewAllotedScreen(
                                        companyId: widget.companyId,
                                        empId: equipment['EquipmentId'],
                                        EmpName: equipment['EquipmentName'],
                                        onRefresh: () {
                                          fetchEquipments();
                                        },
                                      )));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),
                          constraints: BoxConstraints(
                            minHeight: 100.w,
                          ),
                          width: double.maxFinite,
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset: Offset(0, 3),
                              )
                            ],
                            borderRadius: BorderRadius.circular(10.w),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 44.h,
                                        width: 44.w,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(10.w),
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.home_repair_service,
                                            color: Theme.of(context)
                                                .primaryColor,
                                            size: 24.w,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20.w),
                                      FutureBuilder<String>(
                                        future: getEquipmentName(
                                            equipment['EquipmentId']),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return InterMedium(
                                              text: 'Loading...',
                                              fontsize: 16.sp,
                                              color: DarkColor.color1,
                                            );
                                          } else if (snapshot.hasError) {
                                            return InterMedium(
                                              text:
                                              'Error: ${snapshot.error}',
                                              fontsize: 16.sp,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color,
                                            );
                                          } else {
                                            return InterMedium(
                                              text: snapshot.data ??
                                                  'Unknown Equipment',
                                              fontsize: 16.sp,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  InterMedium(
                                    text: formattedTime,
                                    color: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .color,
                                    fontsize: 16.sp,
                                  ),
                                  SizedBox(width: 20.w),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 24.w,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20.w),
                                      InterMedium(
                                        text:
                                            " TotalQuantity: ${equipment['EquipmentTotalQuantity'].toString()}",
                                        fontsize: 12.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                      SizedBox(width: 20.w),
                                      InterMedium(
                                        text:
                                            " Allocated Quantity: ${equipment['EquipmentAllotedQuantity'].toString()}",
                                        fontsize: 12.sp,
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
                  childCount: equipmentsForDate.length + 1,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<String> getEquipmentName(String equipmentId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Equipments')
        .where('EquipmentId', isEqualTo: equipmentId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['EquipmentName'];
    }

    return 'Unknown Equipment';
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
