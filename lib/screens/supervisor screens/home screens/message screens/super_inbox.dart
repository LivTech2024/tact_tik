import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../fonts/inter_semibold.dart';
import '../../../../fonts/poppins_bold.dart';
import '../../../../services/firebaseFunctions/firebase_function.dart';
import '../../../../utils/colors.dart';
import '../../../message screen/message_screen.dart';

class SuperInboxScreen extends StatefulWidget {
  SuperInboxScreen(
      {super.key,
      required this.companyId,
      required this.userName,
      required this.isClient,
      required this.isGuard});
  final String userName;
  final String companyId;
  final bool isClient;
  final bool isGuard;
  @override
  State<SuperInboxScreen> createState() => _SuperInboxScreenState();
}

class _SuperInboxScreenState extends State<SuperInboxScreen> {
  bool showGuards = true;
  User? currentUser = FirebaseAuth.instance.currentUser;
  String dropdownValue = 'All Guards'; // Initialize default value
  List<Color> colors = [
    themeManager.themeMode == ThemeMode.dark
        ? DarkColor.color1
        : LightColor.color3,
    themeManager.themeMode == ThemeMode.dark
        ? DarkColor.color25
        : LightColor.color2,
  ];

  Stream<QuerySnapshot> getGuardStream() {
    Query query = FirebaseFirestore.instance
        .collection('Employees')
        .where('EmployeeRole', isNotEqualTo: 'SUPERVISOR')
        .where('EmployeeCompanyId', isEqualTo: widget.companyId);

    if (dropdownValue != 'All Guards') {
      query = query.where('EmployeeIsAvailable', isEqualTo: dropdownValue);
    }

    return query.snapshots();
  }

  Future<List<Map<String, dynamic>>> getSortedGuards(
      QuerySnapshot snapshot) async {
    List<Map<String, dynamic>> guards =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    for (var guard in guards) {
      QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
          .collection('Messages')
          .where('MessageCreatedById', isEqualTo: guard['EmployeeId'])
          .where('MessageReceiversId',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('MessageCreatedAt', descending: true)
          .limit(1)
          .get();

      if (messageSnapshot.docs.isNotEmpty) {
        var latestMessage =
            messageSnapshot.docs.first.data() as Map<String, dynamic>;
        if (latestMessage['MessageType'] == 'message') {
          guard['latestMessageTime'] = latestMessage['MessageCreatedAt'];
        } else {
          guard['latestMessageTime'] = Timestamp.fromDate(DateTime(1970, 1, 1));
        }
      } else {
        guard['latestMessageTime'] = Timestamp.fromDate(DateTime(1970, 1, 1));
      }
    }

    guards.sort(
        (a, b) => b['latestMessageTime'].compareTo(a['latestMessageTime']));

    if (dropdownValue != 'All Guards') {
      guards = guards
          .where((guard) => guard['EmployeeIsAvailable'] == dropdownValue)
          .toList();
    }

    return guards;
  }

  Future<List<Map<String, dynamic>>> getSortedCombinedList(
      List<QuerySnapshot> snapshots) async {
    List<Map<String, dynamic>> combinedList = [];

    var supervisors = snapshots[0].docs;
    combinedList.addAll(supervisors.map((doc) => {
          'name': doc['EmployeeName'] ?? "",
          'id': doc['EmployeeId'] ?? "",
          'imageUrl': doc['EmployeeImg'] ?? "",
          'isClient': false,
        }));

    if (!widget.isClient && snapshots.length > 1) {
      var clients = snapshots[1].docs;
      combinedList.addAll(clients.map((doc) => {
            'name': doc['ClientName'] ?? "",
            'id': doc['ClientId'] ?? "",
            'imageUrl': doc['ClientHomePageBgImg'] ?? "",
            'isClient': true,
          }));
    }

    for (var item in combinedList) {
      QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
          .collection('Messages')
          .where('MessageCreatedById', isEqualTo: item['id'])
          .where('MessageReceiversId',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('MessageCreatedAt', descending: true)
          .limit(1)
          .get();

      if (messageSnapshot.docs.isNotEmpty) {
        var latestMessage =
            messageSnapshot.docs.first.data() as Map<String, dynamic>;
        if (latestMessage['MessageType'] == 'message') {
          item['latestMessageTime'] = latestMessage['MessageCreatedAt'];
        } else {
          item['latestMessageTime'] = Timestamp.fromDate(DateTime(1970, 1, 1));
        }
      } else {
        item['latestMessageTime'] = Timestamp.fromDate(DateTime(1970, 1, 1));
      }
    }

    combinedList.sort(
        (a, b) => b['latestMessageTime'].compareTo(a['latestMessageTime']));

    return combinedList;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Inbox',
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            // SizedBox(height: 5),
            Container(
              height: 65.h,
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
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: widget.isGuard
                  ? Container(
                      color: Theme.of(context).cardColor,
                      child: Center(
                        child: InterBold(
                          text: 'Guards',
                          color: Theme.of(context).textTheme.bodyMedium!.color
                              as Color,
                          fontsize: 18.sp,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showGuards = true;
                                colors[0] = Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color as Color;
                                colors[1] = Theme.of(context).highlightColor;
                              });
                            },
                            child: Container(
                              color: Theme.of(context).cardColor,
                              child: Center(
                                child: InterBold(
                                  text: 'Guards',
                                  color: colors[0],
                                  fontsize: 18.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showGuards = false;
                                colors[0] = Theme.of(context).highlightColor;
                                colors[1] = Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color as Color;
                              });
                            },
                            child: Container(
                              color: Theme.of(context).cardColor,
                              child: Center(
                                child: InterBold(
                                  text: widget.isClient
                                      ? 'Admin'
                                      : "Admin & Client",
                                  color: colors[1],
                                  fontsize: 18.sp,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
            ),
            showGuards
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /*SizedBox(height: 20.h),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            iconSize: 24.w,
                            dropdownColor: Theme.of(context).cardColor,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                                fontSize: 14.sp),
                            borderRadius: BorderRadius.circular(10.r),
                            value: dropdownValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                                getGuardStream();
                              });
                            },
                            items: <String>[
                              'All Guards',
                              'available',
                              'unavailable'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),*/
                        SizedBox(height: 20.h),
                        StreamBuilder<QuerySnapshot>(
                          stream: getGuardStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            return FutureBuilder<List<Map<String, dynamic>>>(
                              future: getSortedGuards(snapshot.data!),
                              builder: (context, sortedSnapshot) {
                                if (sortedSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                if (!sortedSnapshot.hasData ||
                                    sortedSnapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text('No guards available'));
                                }

                                var _guardsInfo = sortedSnapshot.data!;

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _guardsInfo.length,
                                  itemBuilder: (context, index) {
                                    var guardInfo = _guardsInfo[index];
                                    String name =
                                        guardInfo['EmployeeName'] ?? "";
                                    String id = guardInfo['EmployeeId'] ?? "";
                                    String url = guardInfo['EmployeeImg'] ?? "";

                                    if (id == currentUser?.uid) {
                                      return SizedBox.shrink();
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MobileChatScreen(
                                                    receiverId: id,
                                                    companyId: widget.companyId,
                                                    receiverName: name,
                                                    userName: widget.userName),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Theme.of(context).shadowColor,
                                              blurRadius: 5,
                                              spreadRadius: 2,
                                              offset: Offset(0, 3),
                                            )
                                          ],
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        margin: EdgeInsets.only(bottom: 10.h),
                                        width: double.maxFinite,
                                        child: Container(
                                          height: 48.h,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.w),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 50.h,
                                                    width: 50.w,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: DarkColor
                                                          .Primarycolor,
                                                      image: DecorationImage(
                                                        image:
                                                            NetworkImage(url),
                                                        filterQuality:
                                                            FilterQuality.high,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 20.w),
                                                  InterBold(
                                                    text: name,
                                                    letterSpacing: -.3,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color,
                                                  ),
                                                ],
                                              ),
                                              /*Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      SvgPicture.asset(
                                                          'assets/images/chat_bubble.svg'),
                                                      Positioned(
                                                        top: -4,
                                                        left: -8,
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      4.w),
                                                          height: 14.h,
                                                          constraints:
                                                              BoxConstraints(
                                                                  minWidth:
                                                                      20.w),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.red,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50.r),
                                                          ),
                                                          child: Center(
                                                            child: InterBold(
                                                              text: '2',
                                                              fontsize: 8.sp,
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .color,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),*/
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        StreamBuilder<List<QuerySnapshot>>(
                          stream: CombineLatestStream.list([
                            FirebaseFirestore.instance
                                .collection('Employees')
                                .where('EmployeeRole', isEqualTo: 'SUPERVISOR')
                                .where('EmployeeCompanyId',
                                    isEqualTo: widget.companyId)
                                .where('EmployeeId',
                                    isNotEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid)
                                .snapshots(),
                            if (!widget.isClient)
                              FirebaseFirestore.instance
                                  .collection('Clients')
                                  .where('ClientCompanyId',
                                      isEqualTo: widget.companyId)
                                  .snapshots(),
                          ]),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            return FutureBuilder<List<Map<String, dynamic>>>(
                              future: getSortedCombinedList(snapshot.data!),
                              builder: (context, sortedSnapshot) {
                                if (sortedSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                if (!sortedSnapshot.hasData ||
                                    sortedSnapshot.data!.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 300.h,
                                          child: SvgPicture.asset(isDark
                                              ? 'assets/images/no_data_dark.svg'
                                              : 'assets/images/no_data.svg'),
                                        ),
                                        InterSemibold(
                                          text: 'Nothing to preview',
                                          fontsize: 16.sp,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color,
                                        )
                                      ],
                                    ),
                                  );
                                }

                                var combinedList = sortedSnapshot.data!;

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: combinedList.length,
                                  itemBuilder: (context, index) {
                                    var info = combinedList[index];
                                    String name = info['name'];
                                    String id = info['id'];
                                    String url = info['imageUrl'];

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MobileChatScreen(
                                              receiverId: id,
                                              companyId: widget.companyId,
                                              receiverName: name,
                                              userName: widget.userName,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Theme.of(context).shadowColor,
                                              blurRadius: 5,
                                              spreadRadius: 2,
                                              offset: Offset(0, 3),
                                            )
                                          ],
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        margin: EdgeInsets.only(bottom: 10.h),
                                        width: double.maxFinite,
                                        child: Container(
                                          height: 48.h,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.w),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 50.h,
                                                    width: 50.w,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: DarkColor
                                                          .Primarycolor,
                                                      image: DecorationImage(
                                                        image:
                                                            NetworkImage(url),
                                                        filterQuality:
                                                            FilterQuality.high,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 20.w),
                                                  InterBold(
                                                    text: name,
                                                    letterSpacing: -.3,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color,
                                                  ),
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
                            );
                          },
                        )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
