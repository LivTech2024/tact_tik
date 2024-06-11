import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../utils/colors.dart';
import '../select_client_guards_screen.dart';
import 'client_dar_open_screen.dart';

class ClientDarScreen extends StatefulWidget {
  final String clientId;
  final String companyId;
  ClientDarScreen({
    super.key,
    required this.clientId,
    required this.companyId,
  });

  @override
  State<ClientDarScreen> createState() => _ClientDarScreenState();
}

class _ClientDarScreenState extends State<ClientDarScreen> {
  DateTime? selectedDate;
  List<DocumentSnapshot> darList = [];
  List<MapEntry<String, List<DocumentSnapshot>>> groupedData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDARData();
  }

  void fetchDARData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('EmployeesDAR')
        .where('EmpDarClientId', isEqualTo: widget.clientId)
        .orderBy('EmpDarDate', descending: true)
        .get();

    // Group the data by date
    Map<String, List<DocumentSnapshot>> dataByDate = {};
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      var date = (data['EmpDarDate'] as Timestamp).toDate();
      var formattedDate = DateFormat('dd/MM/yyyy').format(date);

      if (dataByDate.containsKey(formattedDate)) {
        dataByDate[formattedDate]!.add(doc);
      } else {
        dataByDate[formattedDate] = [doc];
      }
    }

    groupedData = dataByDate.entries.toList();

    setState(() {
      isLoading = false;
    });
  }

  void NavigateScreen(Widget screen, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    setState(() {
      if (picked != null) {
        selectedDate = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
    Theme.of(context).brightness == Brightness.dark ? true : false;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            text: "DAR Screen",
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: SizedBox(
                        width: 140.w,
                        child: IconTextWidget(
                          icon: Icons.calendar_today,
                          text: selectedDate != null
                              ? "${selectedDate!.toLocal()}".split(' ')[0]
                              : 'Select Date',
                          fontsize: 14.sp,
                          color: Theme.of(context).textTheme.bodySmall!.color
                              as Color,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SelectClientGuardsScreen(
                                          companyId: widget.companyId,
                                        )));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80.w,
                                child: IconTextWidget(
                                  space: 6.w,
                                  icon: Icons.add,
                                  iconSize: 20.sp,
                                  text: 'Select',
                                  useBold: true,
                                  fontsize: 14.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color as Color,
                                  Iconcolor: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color as Color,
                                ),
                              ),
                              InterBold(
                                text: 'Location',
                                fontsize: 16.sp,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: Platform.isIOS ? 30.w : 10.w,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SelectClientGuardsScreen(
                                          companyId: widget.companyId,
                                        )));
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                width: 80.w,
                                child: IconTextWidget(
                                  space: 6.w,
                                  icon: Icons.add,
                                  iconSize: 20.sp,
                                  text: 'Select',
                                  useBold: true,
                                  fontsize: 14.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color as Color,
                                  Iconcolor: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color as Color,
                                ),
                              ),
                              InterBold(
                                text: 'Employee',
                                fontsize: 16.sp,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: groupedData.length,
                    itemBuilder: (context, index) {
                      var entry = groupedData[index];
                      var date = entry.key;
                      var data = entry.value;
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            InterBold(text: date, fontsize: 18.sp),
                            SizedBox(height: 10.h),
                            ...data.map(
                              (doc) => GestureDetector(
                                onTap: () {
                                  Map<String, dynamic> docData =
                                      doc.data() as Map<String, dynamic>;
                                  String employeeName =
                                      docData['EmpDarEmpName'];
                                  String startTime = DateFormat('HH:mm').format(
                                      (docData['EmpDarDate'] as Timestamp)
                                          .toDate());
                                  List<dynamic> empDarTile =
                                      docData['EmpDarTile'] ?? [];
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ClientDarOpenScreen(
                                                employeeName: employeeName,
                                                startTime: startTime,
                                                empDarTile: empDarTile,
                                              )));
                                },
                                child: Container(
                                  height: 130.h,
                                  margin: EdgeInsets.only(top: 10.h),
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).shadowColor,
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                        offset: Offset(0, 3),
                                      )
                                    ],
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 20.h),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(height: 5.h),
                                              Container(
                                                height: 30.h,
                                                width: 4.w,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10.r),
                                                    bottomRight:
                                                        Radius.circular(10.r),
                                                  ),
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 14.w),
                                          SizedBox(
                                            width: 190.w,
                                            child: InterSemibold(
                                              text: (doc.data() as Map<String,
                                                  dynamic>)['EmpDarEmpName'],
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color,
                                              fontsize: 18.sp,
                                            ),
                                          )
                                        ],
                                      ),
                                      // SizedBox(height: 10.h),
                                      Padding(
                                        padding: EdgeInsets.only(left: 20.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InterRegular(
                                              text: (doc.data() as Map<String,
                                                  dynamic>)['EmpDarShiftName'],
                                              fontsize: 14.sp,
                                              color: isDark
                                                  ? DarkColor.color21
                                                  : LightColor.color2,
                                            ),
                                            SizedBox(height: 12.h),
                                            InterMedium(
                                              text: (doc.data()
                                                      as Map<String, dynamic>)[
                                                  'EmpDarLocationName'],
                                              fontsize: 14.sp,
                                              maxLines: 1,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
