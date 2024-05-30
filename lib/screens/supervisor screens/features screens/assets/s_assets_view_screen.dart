import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
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
              shadowColor: isDark ? Colors.transparent : LightColor.WidgetColor.withOpacity(.1),
              backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
              elevation: 5,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: width / width24,
                ),
                padding: EdgeInsets.only(left: width / width20),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigator debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterRegular(
                text: 'Assets',
                fontsize: width / width18,
                color: isDark ? DarkColor.color1 : LightColor.color3,
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
                      color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                    ),
                    SizedBox(
                      height: height / height30,
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
                            horizontal: width / width30,
                            vertical: height / height30),
                        child: InterBold(
                          text: getDateHeader(date),
                          fontsize: width / width20,
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
                          EdgeInsets.symmetric(horizontal: width / width30),
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
                          height: width / width60,
                          width: double.maxFinite,
                          margin: EdgeInsets.only(bottom: height / height10),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(width / width10),
                            color:
                                isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: height / height44,
                                    width: width / width44,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width / width10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          width / width10),
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
                                        size: width / width24,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width / width20),
                                  FutureBuilder<String>(
                                    future: getEquipmentName(equipment['EquipmentAllocationEquipId']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return InterMedium(
                                          text: 'Loading...',
                                          fontsize: width / width16,
                                          color: DarkColor.color1,
                                        );
                                      } else if (snapshot.hasError) {
                                        return InterMedium(
                                          text: 'Error: ${snapshot.error}',
                                          fontsize: width / width16,
                                          color: isDark
                                              ? DarkColor.color1
                                              : LightColor.color3,
                                        );
                                      } else {
                                        return InterMedium(
                                          text: snapshot.data ?? 'Unknown Equipment',
                                          fontsize: width / width16,
                                          color: isDark
                                              ? DarkColor.color1
                                              : LightColor.color3,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              InterMedium(
                                text: formattedTime,
                                color: isDark
                                    ? DarkColor.color17
                                    : LightColor.color3,
                                fontsize: width / width16,
                              ),
                              SizedBox(width: width / width20),
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
