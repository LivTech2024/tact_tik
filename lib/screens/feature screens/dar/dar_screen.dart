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
      required this.EmpDarClientID})
      : super(key: key);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    // keep this code in firebase_function file  and handle its errors here
    Future<void> _submitDAR() async {
      final _userService = UserService(firestoreService: FireStoreService());
      await _userService.getShiftInfo();
      // if (_isSubmitting) return;

      // final title = _titleController.text.trim();
      // final darContent = _darController.text.trim();
      // setState(() {
      //   _isSubmitting = true;
      // });

      try {
        final date = DateTime.now();
        List darList = [];
        final CollectionReference employeesDARCollection =
            FirebaseFirestore.instance.collection('EmployeesDAR');

        final QuerySnapshot querySnapshot = await employeesDARCollection
            .where('EmpDarEmpId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          for (var dar in querySnapshot.docs) {
            final data = dar.data() as Map<String, dynamic>;
            final date2 = UtilsFuctions.convertDate(data['EmpDarCreatedAt']);
            print('date3 = ${date2[0]}');
            if (date2[0] == date.day &&
                date2[1] == date.month &&
                date2[2] == date.year) {
              if (dar.exists) {
                return null;
              }
            }
          }
        }

        var docRef = await _firestore.collection('EmployeesDAR').add({
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
        });
        await docRef.update({'EmpDarId': docRef.id});
      } catch (e) {
        print('error = $e');
      }
      print('function run successfully');
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
                          if (documents != null && index < documents.length) {
                            final document = documents[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: height / height20),
                                InterBold(
                                  text: _formatTimestamp(
                                      document['EmpDarCreatedAt']),
                                  fontsize: width / width20,
                                  color: Primarycolor,
                                  letterSpacing: -.3,
                                ),
                                SizedBox(height: height / height30),
                                GestureDetector(
                                  onTap: () {
                                    /*DarOpenAllScreen*/
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DarOpenAllScreen(
                                          passdate: (document['EmpDarCreatedAt']
                                                  as Timestamp)
                                              .toDate(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: double.maxFinite,
                                    height: height / height200,
                                    // constraints: BoxConstraints(
                                    //     minHeight: height / height200,
                                    //     ),
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
                                          text: document['EmpDarEmpName'],
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
                                ),
                                SizedBox(height: height / height10),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        childCount: documents?.length ?? 0,
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
          onPressed: () {
            _submitDAR().whenComplete(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DarOpenAllScreen(),
                  ));
            });
          },
          backgroundColor: Primarycolor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    return DateFormat('dd /MM /yyyy').format(dateTime);
  }
}
