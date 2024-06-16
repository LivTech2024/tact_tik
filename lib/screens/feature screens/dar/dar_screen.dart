import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/dar/create_dar_screen.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:tact_tik/utils/utils_functions.dart';

import '../../../common/sizes.dart';
import '../../../utils/theme_manager.dart';
import 'dar_open_all_screen.dart';

class DarDisplayScreen extends StatefulWidget {
  final String? EmpEmail;
  final String EmpID;
  final String Username;
  final String EmpDarCompanyId;
  final String EmpDarCompanyBranchId;
  final String EmpDarShiftID;
  final String EmpDarClientID;

  DarDisplayScreen(
      {Key? key,
      required this.EmpEmail,
      required this.EmpID,
      required this.EmpDarCompanyId,
      required this.EmpDarCompanyBranchId,
      required this.EmpDarShiftID,
      required this.EmpDarClientID,
      required this.Username})
      : super(key: key);

  @override
  State<DarDisplayScreen> createState() => _DarDisplayScreenState();
}

class _DarDisplayScreenState extends State<DarDisplayScreen> {
  bool showAllDARS = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  

  List<Color> colors = [
    themeManager.themeMode == ThemeMode.dark
        ? DarkColor.Primarycolor
        : LightColor.color3,
    themeManager.themeMode == ThemeMode.dark
        ? DarkColor.color25
        : LightColor.color2,
  ];

  @override
  Widget build(BuildContext context) {
   
    // keep this code in firebase_function file  and handle its errors here
    Future<String?> _submitDAR() async {
      final _userService = UserService(firestoreService: FireStoreService());
      await _userService.getShiftInfo();
      try {
        final date = DateTime.now();
        final CollectionReference employeesDARCollection =
            FirebaseFirestore.instance.collection('EmployeesDAR');

        final QuerySnapshot querySnapshot = await employeesDARCollection
            .where('EmpDarEmpId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where('EmpDarShiftId', isEqualTo: _userService.ShiftId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          print(
              'Document with EmpDarShiftId ${_userService.ShiftId} already exists.');
          // return null;
        }

        var docRef = await employeesDARCollection.add({
          'EmpDarLocationId:': _userService.shiftLocationId,
          'EmpDarLocationName': _userService.shiftLocation,
          'EmpDarShiftId': _userService.ShiftId,
          'EmpDarDate': FieldValue.serverTimestamp(),
          'EmpDarCreatedAt': FieldValue.serverTimestamp(),
          'EmpDarEmpName': _userService.userName,
          'EmpDarEmpId': FirebaseAuth.instance.currentUser!.uid,
          'EmpDarCompanyId': _userService.shiftCompanyId,
          'EmpDarCompanyBranchId': _userService.shiftCompanyBranchId,
          'EmpDarClientId': _userService.shiftClientId,
          'EmpDarShiftName': _userService.shiftName
        });
        await docRef.update({'EmpDarId': docRef.id});
        print(
            'Document with EmpDarShiftId ${_userService.ShiftId} created successfully.');
        return docRef.id;
      } catch (e) {
        print('Error creating document: $e');
      }
    }

    bool isNewEntry(DocumentSnapshot document) {
      return document['EmpDarShiftId'] == widget.EmpDarShiftID;
    }

    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('EmployeesDAR')
              .where('EmpDarEmpId', isEqualTo: widget.EmpID)
              .orderBy('EmpDarDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final documents = snapshot.data?.docs;
              if (documents == null || documents.isEmpty) {
                return Center(
                  child: Text('No DAR entries found.', style: TextStyle()),
                );
              }

              Map<String, List<DocumentSnapshot>> groupedByDate = {};
              documents.forEach((document) {
                Timestamp timestamp = document['EmpDarCreatedAt'];
                DateTime date = timestamp.toDate();
                String formattedDate = DateFormat('dd /MM /yyyy').format(date);
                if (!groupedByDate.containsKey(formattedDate)) {
                  groupedByDate[formattedDate] = [];
                }
                groupedByDate[formattedDate]!.add(document);
              });

              List<Widget> buildDarEntries() {
                List<Widget> entries = [];
                groupedByDate.forEach((date, darEntries) {
                  if (showAllDARS) {
                    // In History tab, filter out DARs with isNew true
                    darEntries = darEntries
                        .where((document) => !isNewEntry(document))
                        .toList();
                  }
                  if (showAllDARS || darEntries.any(isNewEntry)) {
                    entries.add(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterBold(
                          text: date,
                          fontsize: 20.sp,
                          color:
                              Theme.of(context).textTheme.displayMedium!.color,
                          letterSpacing: -.3,
                        ),
                        SizedBox(height: 20.h),
                        ...darEntries.map((document) {
                          bool isNew = isNewEntry(document);
                          if (!showAllDARS && !isNew) {
                            return SizedBox();
                          }
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DarOpenAllScreen(
                                    passdate: (document['EmpDarCreatedAt']
                                            as Timestamp)
                                        .toDate(),
                                    Username: widget.Username,
                                    Empid: widget.EmpID,
                                    DarId: document['EmpDarId'],
                                    editable: isNew,
                                    shifID: widget.EmpDarShiftID,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              // margin: EdgeInsets.only(bottom: 20.h),
                              width: double.maxFinite,
                              height: 145.h,
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
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              margin: EdgeInsets.symmetric(
                                // horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InterBold(
                                    text: (document.data()
                                                as Map<String, dynamic>)
                                            .containsKey('EmpDarShiftName')
                                        ? document['EmpDarShiftName']
                                        : "",
                                    fontsize: 18.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .color,
                                  ),
                                  isNew
                                      ? InterBold(
                                          text: "New",
                                          fontsize: 18.sp,
                                          color: Colors.green,
                                        )
                                      : SizedBox(),
                                  SizedBox(height: 10.h),
                                  Flexible(
                                    child: InterRegular(
                                      text: document['EmpDarLocationName'],
                                      fontsize: 16.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .color,
                                      maxLines: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 10.h),
                      ],
                    ));
                  }
                });
                return entries;
              }

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
                      },
                    ),
                    title: InterMedium(
                      text: 'DAR',
                    ),
                    // title: Text('DAR'),
                    centerTitle: true,
                    floating: true,
                  ),
                  SliverToBoxAdapter(
                    child: Container(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showAllDARS = false;
                                  colors[0] = Theme.of(context).primaryColor;
                                  colors[1] = Theme.of(context).highlightColor;
                                });
                              },
                              child: Container(
                                height: 65.h,
                                color: Theme.of(context).cardColor,
                                child: Center(
                                  child: InterBold(
                                    text: 'Today',
                                    color: colors[0],
                                    fontsize: 18.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: VerticalDivider(
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showAllDARS = true;

                                  colors[0] = Theme.of(context).highlightColor;
                                  colors[1] = Theme.of(context).primaryColor;
                                });
                              },
                              child: Container(
                                height: 65.h,
                                color: Theme.of(context).cardColor,
                                child: Center(
                                  child: InterBold(
                                    text: 'History',
                                    color: colors[1],
                                    fontsize: 18.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        buildDarEntries(),
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading DAR entries.',
                  style: TextStyle(),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        // floatingActionButton: GestureDetector(
        //   onTap: () async {
        //     String? result = await _submitDAR();
        //     if (result != null) {
        //       print('DAR Submitted successfully');
        //     }
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => CreateDarScreen(
        //           EmpEmail: widget.EmpEmail,
        //           EmpID: widget.EmpID,
        //           Username: widget.Username,
        //           EmpDarCompanyId: widget.EmpDarCompanyId,
        //           EmpDarCompanyBranchId: widget.EmpDarCompanyBranchId,
        //           EmpDarShiftID: widget.EmpDarShiftID,
        //           EmpDarClientID: widget.EmpDarClientID,
        //         ),
        //       ),
        //     );
        //   },
        //   child: Container(
        //     height: height / height15,
        //     width: height / height15,
        //     decoration: BoxDecoration(
        //       color: Primarycolor,
        //       shape: BoxShape.circle,
        //     ),
        //     child: Center(
        //       child: SvgPicture.asset(
        //         'assets/images/create.svg',
        //         width: width / width18,
        //         height: height / height18,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
