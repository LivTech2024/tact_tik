import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/screens/feature%20screens/dar/create_dar_screen.dart';
import 'package:tact_tik/screens/feature%20screens/dar/dar_open_all_screen.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:tact_tik/utils/utils_functions.dart';

import '../../../common/sizes.dart';

class DarDisplayScreen extends StatelessWidget {
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
          'EmpDarDate': _userService.shiftDate,
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('EmployeesDAR')
              .where('EmpDarEmpId', isEqualTo: EmpID)
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

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppBarcolor,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
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
                      color: Colors.white,
                      letterSpacing: -.3,
                    ),
                    centerTitle: true,
                    floating: true,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: width / width20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final date = groupedByDate.keys.elementAt(index);
                          final darEntries = groupedByDate[date]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterBold(
                                text: date,
                                fontsize: width / width20,
                                color: Primarycolor,
                                letterSpacing: -.3,
                              ),
                              SizedBox(height: height / height20),
                              ...darEntries.map((document) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DarOpenAllScreen(
                                          passdate: (document['EmpDarCreatedAt']
                                                  as Timestamp)
                                              .toDate(),
                                          Username: Username,
                                          Empid: EmpID,
                                          DarId: document['EmpDarId'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: double.maxFinite,
                                    height: height / height200,
                                    decoration: BoxDecoration(
                                      color: WidgetColor,
                                      borderRadius: BorderRadius.circular(
                                          width / width20),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width / width20,
                                      vertical: height / height10,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InterBold(
                                          text:
                                              document['EmpDarShiftName'] ?? "",
                                          fontsize: width / width18,
                                          color: Primarycolor,
                                        ),
                                        SizedBox(height: height / height10),
                                        Flexible(
                                          child: InterRegular(
                                            text:
                                                document['EmpDarLocationName'],
                                            fontsize: width / width16,
                                            color: color26,
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
                                                color: color2,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.video_collection,
                                                size: width / width18,
                                                color: color2,
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
                          );
                        },
                        childCount: groupedByDate.length,
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var id = await _submitDAR();

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DarOpenAllScreen(
                    Username: Username,
                    Empid: EmpID,
                    DarId: id,
                  ),
                ));
          },
          backgroundColor: Primarycolor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

String _formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  return DateFormat('dd /MM /yyyy').format(dateTime);
}
