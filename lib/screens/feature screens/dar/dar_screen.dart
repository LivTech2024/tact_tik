import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/dar/create_dar_screen.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:tact_tik/utils/utils_functions.dart';

import '../../../common/sizes.dart';
import 'dar_open_all_screen.dart';

class DarDisplayScreen extends StatefulWidget {
  final String EmpEmail;
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
  List colors = [DarkColor.Primarycolor, DarkColor. color25];

  bool showAllDARS = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

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
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
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
                  child: Text('No DAR entries found.'),
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
                          fontsize: width / width20,
                          color: DarkColor. Primarycolor,
                          letterSpacing: -.3,
                        ),
                        SizedBox(height: height / height20),
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
                              width: double.maxFinite,
                              height: height / height200,
                              decoration: BoxDecoration(
                                color: DarkColor. WidgetColor,
                                borderRadius:
                                    BorderRadius.circular(width / width20),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: width / width20,
                                vertical: height / height10,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InterBold(
                                    text: document['EmpDarShiftName'] ?? "",
                                    fontsize: width / width18,
                                    color: DarkColor. Primarycolor,
                                  ),
                                  isNew
                                      ? InterBold(
                                          text: "New",
                                          fontsize: width / width18,
                                          color: Colors.green,
                                        )
                                      : SizedBox(),
                                  SizedBox(height: height / height10),
                                  Flexible(
                                    child: InterRegular(
                                      text: document['EmpDarLocationName'],
                                      fontsize: width / width16,
                                      color: DarkColor. color26,
                                      maxLines: 4,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width / width10),
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.image,
                                          size: width / width18,
                                          color: DarkColor. color2,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.video_collection,
                                          size: width / width18,
                                          color: DarkColor. color2,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: height / height10),
                      ],
                    ));
                  }
                });
                return entries;
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    shadowColor: isDark ? DarkColor.color3 : LightColor.color3.withOpacity(.1),
                    backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
                    elevation: 10,
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
                      },
                    ),
                    title: InterRegular(
                      text: 'DAR',
                      fontsize: width / width18,
                      color: isDark ? DarkColor.color1 : LightColor.color3,
                      letterSpacing: -.3,
                    ),
                    centerTitle: true,
                    floating: true,
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: height / height65,
                      width: double.maxFinite,
                      color: DarkColor. color24,
                      padding:
                          EdgeInsets.symmetric(vertical: height / height16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showAllDARS = false;
                                  colors[0] = DarkColor.color25;
                                  colors[1] = DarkColor.Primarycolor;
                                });
                              },
                              child: SizedBox(
                                child: Center(
                                  child: InterBold(
                                    text: 'Today',
                                    color: colors[1],
                                    fontsize: width / width18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showAllDARS = true;
                                  colors[0] = DarkColor.Primarycolor;
                                  colors[1] = DarkColor.color25;
                                });
                              },
                              child: SizedBox(
                                child: Center(
                                  child: InterBold(
                                    text: 'History',
                                    color: colors[0],
                                    fontsize: width / width18,
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
                      horizontal: width / width16,
                      vertical: height / height20,
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
                child: Text('Error loading DAR entries.'),
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
