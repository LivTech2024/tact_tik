import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../utils/colors.dart';
import '../select_client_guards_screen.dart';
import 'client_open_patrol_screen.dart';

class ClientCheckPatrolScreen extends StatefulWidget {
  final String ScreenName;
  final String PatrolIdl;
  final String companyId;
  ClientCheckPatrolScreen(
      {super.key, required this.PatrolIdl, required this.ScreenName, required this.companyId});

  @override
  State<ClientCheckPatrolScreen> createState() =>
      _ClientCheckPatrolScreenState();
}

class _ClientCheckPatrolScreenState extends State<ClientCheckPatrolScreen> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> patrolsList = [];
  final FireStoreService fireStoreService = FireStoreService();
  String selectedGuardId = '';

  @override
  void initState() {
    super.initState();
    get_PatrolInfo();
  }

  void onGuardSelected(String guardId) {
    setState(() {
      selectedGuardId = guardId;
    });
    print('Selected Guard ID: $selectedGuardId');
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    setState(() {
      if (picked != null) {
        selectedDate = picked;
        get_PatrolInfo(); // Refresh the patrol info when a new date is selected
      }
    });
  }

  void get_PatrolInfo() async {
    var PatrologsData = await fireStoreService.getPatrolsLogs(widget.PatrolIdl);
    if (PatrologsData != null && PatrologsData.isNotEmpty) {
      setState(() {
        patrolsList = PatrologsData;
      });
    }
    print(PatrologsData);
    try {} catch (error) {
      print("Error $error");
    }
  }

  void NavigateScreen(Widget screen, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
   
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
            text: widget.ScreenName,
     
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: SizedBox(
                        width: 190.w,
                        child: IconTextWidget(
                          icon: Icons.calendar_today,
                          Iconcolor: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .color as Color,
                          text: selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                              : 'Select Date',
                          fontsize: 14.sp,
                          color: Theme.of(context).textTheme.bodySmall!.color
                              as Color,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140.w,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectClientGuardsScreen(
                                companyId: widget.companyId,
                                onGuardSelected: onGuardSelected,
                              ),
                            ),
                          );
                        },
                        child: IconTextWidget(
                          space: 6.w,
                          icon: Icons.add,
                          Iconcolor: Theme.of(context).textTheme.bodySmall!.color
                              as Color,
                          iconSize: 20.sp,
                          text: 'Select Guard',
                          useBold: true,
                          fontsize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium!.color
                              as Color,
                          // Iconcolor: DarkColor.color1,
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: FilterListWidget<String>(
                    //     listData: [
                    //       "Apple",
                    //       "Banana",
                    //       "Cherry",
                    //       "Date",
                    //       "Fig",
                    //       "Grape"
                    //     ],
                    //     selectedListData: ["Apple", "Cherry"],
                    //     hideHeader: false,
                    //     onApplyButtonClick: (selectedItems) {
                    //       // Handle the selected items
                    //       print('Selected items: $selectedItems');
                    //     },
                    //     choiceChipLabel: (item) {
                    //       // Display text on the choice chip
                    //       return item;
                    //     },
                    //     validateSelectedItem: (List<String>? list, String val) {
                    //       // Check if the item is selected
                    //       return list?.contains(val) ?? false;
                    //     },
                    //     onItemSearch: (list, query) {
                    //       // Filter and return list based on search text
                    //       if (list != null) {
                    //         return list
                    //             // .where((element) => element
                    //             //     .toLowerCase()
                    //             //     .contains(query.toLowerCase()))
                    //             // .toList();
                    //       }
                    //       // return [];
                    //     },
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 20.h),
                patrolsList.isEmpty ||
                    (selectedDate != null &&
                        selectedGuardId != '' &&
                        patrolsList.every((patrol) {
                          final patrolDate = DateTime.fromMillisecondsSinceEpoch(
                              patrol['PatrolLogStartedAt'].millisecondsSinceEpoch);
                          final guardId = patrol['PatrolLogGuardId'];
                          return (patrolDate.year != selectedDate!.year ||
                              patrolDate.month != selectedDate!.month ||
                              patrolDate.day != selectedDate!.day) ||
                              guardId != selectedGuardId;
                        })) ||
                    (selectedDate != null &&
                        selectedGuardId == '' &&
                        patrolsList.every((patrol) {
                          final patrolDate = DateTime.fromMillisecondsSinceEpoch(
                              patrol['PatrolLogStartedAt'].millisecondsSinceEpoch);
                          return patrolDate.year != selectedDate!.year ||
                              patrolDate.month != selectedDate!.month ||
                              patrolDate.day != selectedDate!.day;
                        })) ||
                    (selectedDate == null &&
                        selectedGuardId != '' &&
                        patrolsList.every((patrol) {
                          final guardId = patrol['PatrolLogGuardId'];
                          return guardId != selectedGuardId;
                        }))
                    ? Center(
                  child: Text(
                    patrolsList.isEmpty
                        ? 'No Patrols Found'
                        : selectedGuardId != '' && selectedDate != null
                        ? 'No Patrols Found for Selected Date and Guard'
                        : selectedDate != null
                        ? 'No Patrols Found for Selected Date'
                        : 'No Patrols Found for Selected Guard',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                )
                    : ListView.builder(
                        itemCount: patrolsList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final patrol = patrolsList[index];
                          final patrolDate =
                              DateTime.fromMillisecondsSinceEpoch(
                            patrol['PatrolLogStartedAt'].millisecondsSinceEpoch,
                          );

                          if (selectedDate == null ||
                              (patrolDate.year == selectedDate!.year &&
                                  patrolDate.month == selectedDate!.month &&
                                  patrolDate.day == selectedDate!.day)) {
                            return GestureDetector(
                              onTap: () {
                                final DateTime startTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                  patrol['PatrolLogStartedAt']
                                      .millisecondsSinceEpoch,
                                );
                                final DateTime endTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                  patrol['PatrolLogEndedAt']
                                      .millisecondsSinceEpoch,
                                );

                                NavigateScreen(
                                  ClientOpenPatrolScreen(
                                    guardName:
                                        patrol['PatrolLogGuardName'] ?? '',
                                    startDate: DateFormat('dd/MM/yyyy')
                                        .format(startTime),
                                    startTime:
                                        DateFormat('hh:mm a').format(startTime),
                                    endTime:
                                        DateFormat('hh:mm a').format(endTime),
                                    patrolLogCount:
                                        patrol['PatrolLogPatrolCount'] ?? 0,
                                    status: patrol['PatrolLogStatus'] ?? '',
                                    feedback:
                                        patrol['PatrolLogFeedbackComment'] ??
                                            '',
                                    checkpoints:
                                        patrol['PatrolLogCheckPoints'] ?? [],
                                  ),
                                  context,
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20.h),
                                  InterMedium(text: 'Date hear',),
                                  SizedBox(height: 10.h),
                                  Container(
                                    height: 140.h,
                                    margin: EdgeInsets.only(top: 10.h,left: 4.w,right:4.w),
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
                                                    borderRadius: BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(10.r),
                                                      bottomRight:
                                                          Radius.circular(10.r),
                                                    ),
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 14.w),
                                            SizedBox(
                                              width: 190.w,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  InterSemibold(
                                                    text: patrol[
                                                            'PatrolLogGuardName'] ??
                                                        "",
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall!
                                                        .color as Color,
                                                    fontsize: 18.sp,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 18.w, right: 24.w),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: 80.w,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    InterRegular(
                                                      text: 'Started at',
                                                      fontsize: 12.sp,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .displaySmall!
                                                          .color as Color,
                                                    ),
                                                    SizedBox(height: 12.h),
                                                    InterMedium(
                                                      text: DateFormat('hh:mm a')
                                                          .format(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                          patrol['PatrolLogStartedAt']
                                                              .millisecondsSinceEpoch,
                                                        ),
                                                      ),
                                                      fontsize: 12.sp,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .displaySmall!
                                                          .color as Color,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 60.w,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    InterRegular(
                                                      text: 'Ended at',
                                                      fontsize: 12.sp,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .displaySmall!
                                                          .color as Color,
                                                    ),
                                                    SizedBox(height: 12.h),
                                                    InterMedium(
                                                      text: DateFormat('hh:mm a')
                                                          .format(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                          patrol['PatrolLogEndedAt']
                                                              .millisecondsSinceEpoch,
                                                        ),
                                                      ),
                                                      fontsize: 12.sp,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .displaySmall!
                                                          .color as Color,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 80.w,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    InterRegular(
                                                      text: 'Status',
                                                      fontsize: 12.sp,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .displaySmall!
                                                          .color as Color,
                                                    ),
                                                    SizedBox(height: 12.h),
                                                    InterMedium(
                                                      text: patrol[
                                                              'PatrolLogStatus'] ??
                                                          'incomplete',
                                                      fontsize: 12.sp,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .displaySmall!
                                                          .color as Color,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                'assets/images/icons/backarrow.svg',
                                                width: 22.w,
                                                height: 22.w,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
