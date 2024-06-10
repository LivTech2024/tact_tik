import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/key%20management/s_key_manag_create_screen.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import 's_key_manag_create_screen.dart';

class SKeyManagementViewScreen extends StatefulWidget {
  final String companyId;

  const SKeyManagementViewScreen({super.key, required this.companyId});

  @override
  _SKeyManagementViewScreenState createState() =>
      _SKeyManagementViewScreenState();
}

class _SKeyManagementViewScreenState extends State<SKeyManagementViewScreen> {
  Map<String, List<QueryDocumentSnapshot>> groupedKeys = {};

  @override
  void initState() {
    super.initState();
    fetchKeys();
  }

  Future<void> fetchKeys() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Keys')
        .where('KeyCompanyId', isEqualTo: widget.companyId)
        .get();

    groupKeysByDate(querySnapshot.docs);
  }

  void groupKeysByDate(List<QueryDocumentSnapshot> keys) {
    final Map<String, List<QueryDocumentSnapshot>> tempGroupedKeys = {};

    for (var key in keys) {
      final createdAt = key['KeyCreatedAt'].toDate();
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
        
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SCreateKeyManagScreen(keyId: '', companyId: widget.companyId,),
              ),
            );
          },
          backgroundColor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
           
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
                      text: 'Keys',
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
                            horizontal: 30.w,
                            vertical: 30.h),
                        child: InterBold(
                          text: getDateHeader(date),
                          fontsize: 20.sp,
                          color:  Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      );
                    }
                    final key = keysForDate[index - 1];
                    final createdAt = key['KeyCreatedAt'].toDate();
                    final formattedTime =
                    DateFormat('hh:mm a').format(createdAt);
                    final keyId = key.id; // Get the document ID

                    return Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 30.w),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SCreateKeyManagScreen(
                                keyId: keyId,
                                companyId: widget.companyId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 60.w,
                          width: double.maxFinite,
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(10.r),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
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
                                        Icons.vpn_key,
                                        color: isDark
                                            ? DarkColor.Primarycolor
                                            : LightColor.Primarycolor,
                                        size: 24.w,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  InterMedium(
                                    text: key['KeyName'],
                                    fontsize: 16.sp,
                                    color:  Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                ],
                              ),
                              InterMedium(
                                text: formattedTime,
                                color:  Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                fontsize: 16.sp,
                              ),
                              SizedBox(width: 20.w),
                            ],
                          ),
                        ),
                      ),
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
