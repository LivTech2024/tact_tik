import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        body: StreamBuilder(
          stream: _assetAllocationStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            else {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final documents = snapshot.data?.docs;
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      shadowColor: isDark
                            ? DarkColor.color3
                            : LightColor.color3.withOpacity(.1),
                      backgroundColor: isDark
                            ? DarkColor.AppBarcolor
                            : LightColor.AppBarcolor,
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
                          print("Navigator debug: ${Navigator.of(context)
                              .toString()}");
                        },
                      ),
                      title: InterRegular(
                        text: 'Assets',
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
                        padding: EdgeInsets.symmetric(
                            horizontal: width / width30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height / height30,
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
                          final documentsByDate = groupDocumentsByDate(documents);
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
                                      horizontal: width / width30,
                                    ),
                                    child: InterBold(
                                      text: isToday
                                          ? 'Today'
                                          : DateFormat.yMMMd().format(date),
                                      fontsize: width / width20,
                                      color: isDark
                                          ? DarkColor.Primarycolor
                                          : LightColor.color3,
                                    ),
                                  ),
                                  SizedBox(height: height / height30),
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
                                            horizontal: width / width30),
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
                                            height: width / width60,
                                            width: double.maxFinite,
                                            margin: EdgeInsets.only(
                                                bottom: height / height10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      width / width10),
                                              color: isDark
                                                  ? DarkColor.WidgetColor
                                                  : LightColor.WidgetColor,
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
                                                      height: height / height44,
                                                      width: width / width44,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  width /
                                                                      width10),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(width /
                                                                    width10),
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
                                                          size: width / width24,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: width / width20),
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
                                                          fontsize:
                                                              width / width16,
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
                                                  color: isDark
                                                      ? DarkColor.color17
                                                      : LightColor.color2,
                                                  fontsize: width / width16,
                                                ),
                                                SizedBox(
                                                    width: width / width20),
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
              ;
            }),
      ),
    );
  }
}
