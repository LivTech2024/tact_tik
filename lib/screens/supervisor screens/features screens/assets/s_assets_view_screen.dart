import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/assets/s_create_assign_asset.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SAssetsViewScreen extends StatefulWidget {
  final String empId;
  final String companyId;

  const SAssetsViewScreen({super.key, required this.empId, required this.companyId});

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
        .collection('EquipmentAllocations')
        .where('EquipmentAllocationEmpId', isEqualTo: widget.empId)
        .get();

    groupEquipmentsByDate(querySnapshot.docs);
  }

  void groupEquipmentsByDate(List<QueryDocumentSnapshot> equipments) {
    final Map<String, List<QueryDocumentSnapshot>> tempGroupedEquipments = {};

    for (var equipment in equipments) {
      final createdAt = equipment['EquipmentAllocationCreatedAt'].toDate();
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
        
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SCreateAssignAssetScreen(companyId: widget.companyId, empId: '', OnlyView: false, equipemtAllocId: '',),
                ));
          },
          backgroundColor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add),
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
                    // InterBold(
                    //   text: 'Today',
                    //   fontsize: 20.w,
                    //   color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                    // ),
                    SizedBox(
                      height: 30.h,
                    ),
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
                            horizontal: 30.w,
                            vertical: 30.h),
                        child: InterBold(
                          text: getDateHeader(date),
                          fontsize: 20.sp,
                          color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                        ),
                      );
                    }
                    final equipment = equipmentsForDate[index - 1];
                    final createdAt = equipment['EquipmentAllocationCreatedAt'].toDate();
                    final formattedTime =
                        DateFormat('hh:mm a').format(createdAt);
                    final equipmentAllocationId = equipment['EquipmentAllocationId'];

                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.w),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SCreateAssignAssetScreen(
                                        equipemtAllocId: equipmentAllocationId,
                                        companyId: widget.companyId,
                                        empId: widget.empId,
                                        OnlyView: true,
                                      )));
                        },
                        child: Container(
                          height: 60.h,
                          width: double.maxFinite,
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.transparent
                                    : LightColor.color3.withOpacity(.05),
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset: Offset(0, 3),
                              )
                            ],
                            borderRadius:
                                BorderRadius.circular(10.w),
                            color:
                                Theme.of(context).cardColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 44.h,
                                      width: 44.w,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            10.w),
                                        color: isDark
                                            ? DarkColor.Primarycolorlight
                                            : LightColor.Primarycolorlight,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.home_repair_service,
                                          color: isDark
                                              ? DarkColor.Primarycolor
                                              : LightColor.Primarycolor,
                                          size: 24.w,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 20.w),
                                    FutureBuilder<String>(
                                      future: getEquipmentName(equipment['EquipmentAllocationEquipId']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return InterMedium(
                                            text: 'Loading...',
                                            fontsize: 16.sp,
                                            color: DarkColor.color1,
                                          );
                                        } else if (snapshot.hasError) {
                                          return InterMedium(
                                            text: 'Error: ${snapshot.error}',
                                            fontsize: 16.sp,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                          );
                                        } else {
                                          return InterMedium(
                                            text: snapshot.data ?? 'Unknown Equipment',
                                            fontsize: 16.sp,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              InterMedium(
                                text: formattedTime,
                                color: isDark
                                    ? DarkColor.color17
                                    : LightColor.color3,
                                fontsize: 16.sp,
                              ),
                              SizedBox(width:20.w),
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
