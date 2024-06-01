import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/create_visitors.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import 'create_visitors.dart';

class SVisiTorsScreen extends StatefulWidget {
  const SVisiTorsScreen({Key? key});

  @override
  State<SVisiTorsScreen> createState() => _VisiTorsScreenState();
}

class _VisiTorsScreenState extends State<SVisiTorsScreen> {
  late UserService _userService;
  FireStoreService fireStoreService = FireStoreService();

  bool isVisitorCompleted(Map<String, dynamic> documentData) {
    final inTimeTimestamp = documentData['VisitorInTime'] as Timestamp?;
    final outTimeTimestamp = documentData['VisitorOutTime'] as Timestamp?;

    return inTimeTimestamp != null && outTimeTimestamp != null;
  }

  @override
  void initState() {
    super.initState();
    _userService = UserService(firestoreService: FireStoreService());
    _userService.getShiftInfo();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateVisitors(visitorData: null),
              ),
            );
          },
          backgroundColor: Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('Visitors')
              .where('VisitorLocationId',
              isEqualTo: _userService.shiftLocationId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            var documents = snapshot.data!.docs;

            // Sort documents by a specific date field
            documents.sort((a, b) {
              final timestampA = a['VisitorCreatedAt'] as Timestamp;
              final timestampB = b['VisitorCreatedAt'] as Timestamp;
              return timestampB.compareTo(timestampA);
            });

            // Group documents by date
            final Map<String, List<QueryDocumentSnapshot>> groupedDocuments = {};
            final todayDate = DateTime.now();
            final todayKey = DateFormat.yMd().format(todayDate);

            for (var doc in documents) {
              final documentData = doc.data() as Map<String, dynamic>?;
              if (documentData != null) {
                final createdAtTimestamp = documentData['VisitorCreatedAt'] as Timestamp?;
                final createdAtDate = createdAtTimestamp?.toDate();
                final formattedDate = createdAtDate != null ? DateFormat.yMd().format(createdAtDate) : '';

                if (groupedDocuments.containsKey(formattedDate)) {
                  groupedDocuments[formattedDate]!.add(doc);
                } else {
                  groupedDocuments[formattedDate] = [doc];
                }
              }
            }

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
                      print(
                          "Navigator debug: ${Navigator.of(context).toString()}");
                    },
                  ),
                  title: InterRegular(
                    text: 'Visitors',
                    fontsize: width / width18,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                  centerTitle: true,
                  floating: true,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final dateKey = groupedDocuments.keys.elementAt(index);
                      final isToday = dateKey == todayKey;
                      final dateHeading = isToday ? 'Today' : dateKey;
                      final visitorDocuments = groupedDocuments[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width / width30),
                            child: InterBold(
                              text: dateHeading,
                              fontsize: width / width20,
                              color: Primarycolor,
                            ),
                          ),
                          SizedBox(height: height / height30),
                          ...visitorDocuments.map((doc) {
                            final documentData = doc.data() as Map<String, dynamic>;
                            final visitorCompleted = isVisitorCompleted(documentData);
                            final visitorName = documentData['VisitorName'] ?? '';
                            final inTimeTimestamp = documentData['VisitorInTime'] as Timestamp?;
                            final outTimeTimestamp = documentData['VisitorOutTime'] as Timestamp?;
                            final location = documentData['VisitorLocationName'] ?? '';

                            final inTime = inTimeTimestamp != null
                                ? DateFormat.jm().format(inTimeTimestamp.toDate())
                                : '';
                            final outTime = outTimeTimestamp != null
                                ? DateFormat.jm().format(outTimeTimestamp.toDate())
                                : '';

                            return GestureDetector(
                              onTap: visitorCompleted
                                  ? null // Do nothing if visitor is completed
                                  : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SCreateVisitors(
                                      visitorData: documentData,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: width / width30),
                                child: Container(
                                  height: width / width120,
                                  width: double.maxFinite,
                                  margin: EdgeInsets.only(bottom: height / height10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(width / width10),
                                    color: WidgetColor,
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: width / width10,
                                            vertical: height / height10,
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: width / width40,
                                                height: height / height40,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(width / width10),
                                                  color: Primarycolorlight,
                                                ),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    'assets/images/man.svg',
                                                    height: height / height20,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: width / width120,
                                                child: InterMedium(
                                                  text: visitorName,
                                                  color: color1,
                                                  fontsize: width / width16,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      InterBold(
                                                        text: 'in time',
                                                        fontsize: width / width10,
                                                        color: color4,
                                                      ),
                                                      SizedBox(width: width / width6),
                                                      InterMedium(
                                                        text: inTime,
                                                        fontsize: width / width12,
                                                        color: color3,
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      InterBold(
                                                        text: 'out time',
                                                        fontsize: width / width10,
                                                        color: color4,
                                                      ),
                                                      SizedBox(width: width / width6),
                                                      InterMedium(
                                                        text: outTime,
                                                        fontsize: width / width12,
                                                        color: color3,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: width / width10),
                                          decoration: BoxDecoration(
                                            color: colorRed,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(width / width10),
                                              bottomRight: Radius.circular(width / width10),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              InterSemibold(
                                                text: 'Location',
                                                color: color1,
                                                fontsize: width / width14,
                                              ),
                                              SizedBox(
                                                width: width / width200,
                                                child: InterRegular(
                                                  text: location,
                                                  fontsize: width / width12,
                                                  color: color2,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                    childCount: groupedDocuments.keys.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
