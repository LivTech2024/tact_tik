import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/screens/feature%20screens/dar/create_dar_screen.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/utils_functions.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../utils/colors.dart';

class DarOpenAllScreen extends StatefulWidget {
  final DateTime? passdate;
  final String? DarId;
  final String Username;
  final String Empid;
  const DarOpenAllScreen(
      {super.key,
      this.passdate,
      this.DarId,
      required this.Username,
      required this.Empid});

  @override
  State<DarOpenAllScreen> createState() => _DarOpenAllScreenState();
}

class _DarOpenAllScreenState extends State<DarOpenAllScreen> {
  List colors = [Primarycolor, color25];
  bool showDARS = true;
  List<Map<String, dynamic>> hourlyShiftDetails = [];
  List<Map<String, dynamic>> hourlyShiftDetails2 = [];

  final _userService = UserService(firestoreService: FireStoreService());
  String _employeeId = '';

  @override
  void initState() {
    super.initState();
    _fetchShiftDetails();
    // fetchDarTileData();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchReports() async {
    final employeeId = FirebaseAuth.instance.currentUser?.uid;
    print("testtfwdf:$employeeId");

    final reportsCollection =
        FirebaseFirestore.instance.collection('PatrolLogs');
    final querySnapshot = await reportsCollection
        .where('PatrolShiftId', isEqualTo: _userService.ShiftId)
        .get();

    final reports = querySnapshot.docs.map((doc) => doc.data()).toList();

    Map<String, List<Map<String, dynamic>>> reportsByHour = {};
    for (var report in reports) {
      final timestampStr = report['PatrolLogStartedAt'] as Timestamp;
      final creationTime = timestampStr.toDate();
      final hour = creationTime.hour;
      final hourKey = '${hour.toString().padLeft(2, '0')}:00';

      if (reportsByHour.containsKey(hourKey)) {
        reportsByHour[hourKey]!.add(report);
      } else {
        reportsByHour[hourKey] = [report];
      }
    }

    return reportsByHour;
  }

  // patrol logs

  Future<Map<String, List<Map<String, dynamic>>>> fetchReportLogs() async {
    final employeeId = FirebaseAuth.instance.currentUser?.uid;

    final patrolLogsCollection =
        FirebaseFirestore.instance.collection('Reports');
    final querySnapshot = await patrolLogsCollection
        .where('ReportEmployeeId', isEqualTo: employeeId)
        .get();

    final patrolLogs = querySnapshot.docs.map((doc) => doc.data()).toList();

    Map<String, List<Map<String, dynamic>>> patrolLogsByHour = {};
    for (var patrolLog in patrolLogs) {
      final timestampStr = patrolLog['ReportCreatedAt'] as Timestamp;
      final creationTime = timestampStr.toDate();
      final hour = creationTime.hour;
      final hourKey = '${hour.toString().padLeft(2, '0')}:00';

      if (patrolLogsByHour.containsKey(hourKey)) {
        patrolLogsByHour[hourKey]!.add(patrolLog);
      } else {
        patrolLogsByHour[hourKey] = [patrolLog];
      }
    }

    return patrolLogsByHour;
  }

  Future<void> _fetchShiftDetails() async {
    try {
      await _userService.getShiftInfo();
      String? shiftStartTime = _userService.shiftStartTime;
      print("shiftStartTime :$shiftStartTime");
      String? shiftEndTime = _userService.shiftEndTime;
      print("shiftEndTime :$shiftEndTime");
      if (shiftStartTime != null && shiftEndTime != null) {
        final List<Map<String, dynamic>> shiftDetails = [
          {
            'startTime': shiftStartTime,
            'endTime': shiftEndTime,
          },
        ];
        print("_fetchShiftDetails startTime&endTime ${shiftDetails}");
        _processShiftDetails(shiftDetails);
        _createBlankDARCards();
        setState(() {});
      } else {
        print('Shift data is null.');
      }
    } catch (e) {
      print('Error fetching shift details: $e');
    }
  }

  void _processShiftDetails(List<Map<String, dynamic>> shiftDetails) {
    hourlyShiftDetails.clear(); // Clear previous details
    for (var shift in shiftDetails) {
      final startTime = shift['startTime']; // Extract startTime
      final endTime = shift['endTime']; // Extract endTime

      final startTimeParts = startTime.split(':');
      final endTimeParts = endTime.split(':');

      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

      // Handle shifts starting before and ending after midnight
      if (endHour > startHour ||
          (endHour == startHour && endMinute > startMinute)) {
        // Shift doesn't cross midnight
        for (int hour = startHour; hour < 24; hour++) {
          if (hour < 24) {
            // Ensure hours are within a day
            final hourStart =
                '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
            final hourEnd =
                '${(hour + 1).toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

            hourlyShiftDetails.add({
              'startTime': hourStart,
              'endTime': hourEnd,
            });
            print("process 1 ${hourlyShiftDetails}");
          }
        }
      } else {
        // Shift crosses midnight
        for (int hour = startHour; hour < 24; hour++) {
          if (hour < 24) {
            // Ensure hours are within a day
            final hourStart =
                '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
            final hourEnd =
                '${(hour + 1).toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

            hourlyShiftDetails.add({
              'startTime': hourStart,
              'endTime': hourEnd,
            });
            print("process 2 ${hourlyShiftDetails}");
          }
        }
        // Add tiles for remaining hours after midnight (if any)
        final remainingEndHour = endHour < startHour ? endHour + 24 : endHour;

        for (int hour = 0; hour <= remainingEndHour; hour++) {
          if (hour < endHour) {
            // Ensure hours are within a day
            final hourStart =
                '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
            final hourEnd =
                '${(hour + 1).toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

            hourlyShiftDetails2.add({
              'startTime': hourStart,
              'endTime': hourEnd,
            });
            print("process 3 ${hourlyShiftDetails2}");
          }
        }
      }
    }
  }

  Future<void> _createBlankDARCards() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _getUserInfo();
        final String employeeId = _employeeId;
        print("employeeId: $employeeId");

        final CollectionReference employeesDARCollection =
            FirebaseFirestore.instance.collection('EmployeesDAR');

        final QuerySnapshot querySnapshot = await employeesDARCollection
            .where('EmpDarEmpId', isEqualTo: employeeId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference? docRef;
          final date = DateTime.now();
          bool isDarlistPresent = false;

          for (var dar in querySnapshot.docs) {
            print('DarID ${widget.DarId}');
            final data = dar.data() as Map<String, dynamic>;
            if (data['EmpDarId'] == widget.DarId) {
              // Assuming YOUR_EMPDARID_HERE is the EmpDarId you're checking for
              docRef = dar.reference;
              if (data['EmpDarTile'] == null || data['EmpDarTile'] == "") {
                isDarlistPresent = false; // Tile does not exist
              } else {
                isDarlistPresent = true; // Tile exists
              }
              break; // Exit the loop once the DAR is found
            }
          }

          final List<Map<String, dynamic>> darTiles = [];
          final List<Map<String, dynamic>> darTiles2 = [];

          for (var shift in hourlyShiftDetails) {
            final String startTime = shift['startTime']!;
            final String endTime = shift['endTime']!;
            print("shiftStartTime $startTime");
            print("shiftEndTime $endTime");

            final int startHour = int.parse(startTime.split(':')[0]);
            final int endHour = int.parse(endTime.split(':')[0]);
            print("startHour $startHour");
            print("endHour $endHour");

            if (endHour < startHour) {
              // Handle shifts that span across midnight
              for (int hour = startHour; hour < 24; hour++) {
                darTiles.add({
                  'TileContent': '',
                  'TileImages': [],
                  'TileLocation': '',
                  'TileTime': '$hour:00 - ${(hour + 1) % 24}:00',
                  'TileDate': '${date.year}-${date.month}-${date.day}',
                });
              }
            } else {
              for (int hour = startHour; hour < endHour; hour++) {
                darTiles.add({
                  'TileContent': '',
                  'TileImages': [],
                  'TileLocation': '',
                  'TileTime': '$hour:00 - ${(hour + 1) % 24}:00',
                  'TileDate': '${date.year}-${date.month}-${date.day}',
                });
              }
            }
          }
          // final DateTime date = DateTime.now();
          final DateTime nextDate = date.add(Duration(days: 1)); // Next day
          for (var shift in hourlyShiftDetails2) {
            final String startTime = shift['startTime']!;
            final String endTime = shift['endTime']!;
            print("shiftStartTime $startTime");
            print("shiftEndTime $endTime");

            final int startHour = int.parse(startTime.split(':')[0]);
            final int endHour = int.parse(endTime.split(':')[0]);
            print("startHour $startHour");
            print("endHour $endHour");

            for (int hour = startHour; hour < endHour; hour++) {
              darTiles2.add({
                'TileContent': '',
                'TileImages': [],
                'TileLocation': '',
                'TileTime': '$hour:00 - ${(hour + 1) % 24}:00',
                'TileDate':
                    '${nextDate.year}-${nextDate.month}-${nextDate.day}',
              });
            }
          }
          // var id = await _submitDAR();
          // await id?.set({'EmpDarTile': darTiles2}, SetOptions(merge: true));

          if (docRef != null) {
            if (!isDarlistPresent) {
              await docRef
                  .set({'EmpDarTile': darTiles}, SetOptions(merge: true));
              if (darTiles2.isNotEmpty) {
                var id = await _submitDAR();
                await id
                    ?.set({'EmpDarTile': darTiles2}, SetOptions(merge: true));
              }
            }
          } else {
            // await
          }
        } else {
          print('No document found with the matching _employeeId.');
        }
      } else {
        print('User is not logged in.');
      }
    } catch (e) {
      print('Error creating blank DAR cards: $e');
    }
  }

  Future<DocumentReference?> _submitDAR() async {
    final _userService = UserService(firestoreService: FireStoreService());
    await _userService.getShiftInfo();

    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      var docRef = await _firestore.collection('EmployeesDAR').add({
        'EmpDarLocationId': _userService.shiftLocationId,
        'EmpDarLocationName': _userService.shiftLocation,
        'EmpDarShiftId': _userService.ShiftId,
        'EmpDarDate': _userService.shiftDate,
        'EmpDarCreatedAt':
            Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
        'EmpDarEmpName': _userService.userName,
        'EmpDarEmpId': FirebaseAuth.instance.currentUser!.uid,
        'EmpDarCompanyId': _userService.shiftCompanyId,
        'EmpDarCompanyBranchId': _userService.shiftCompanyBranchId,
        'EmpDarClientId': _userService.shiftClientId,
        'EmpDarShiftName': _userService.shiftName
      });
      await docRef.update({'EmpDarId': docRef.id});
      return docRef;
    } catch (e) {
      print('error = $e');
      return null;
    }
  }

  Future<void> _getUserInfo() async {
    try {
      var userInfo = await FirebaseFirestore.instance
          .collection('Employees')
          .where(
            'EmployeeId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
          )
          .limit(1)
          .get();
      if (userInfo.docs.isNotEmpty) {
        String employeeId = userInfo.docs.first['EmployeeId'];
        setState(() {
          _employeeId = employeeId;
        });

        print('User Info: ${userInfo.docs.first.data()}');
      } else {
        print('User information not found.');
      }
    } catch (e) {
      print('Error getting user information: $e');
    }
  }

  Future<List> fetchDarTileData(DateTime? time, String? DarID) async {
    final date = time ?? DateTime.now();
    print("aajkadin:$date");
    List darList = [];
    List<Map<String, dynamic>> empDarTile = [];
    final CollectionReference employeesDARCollection =
        FirebaseFirestore.instance.collection('EmployeesDAR');
    print('empid = ${_employeeId}');

    DateTime today = DateTime.now();
    DateTime startDate = DateTime(today.year, today.month, today.day);
    String formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
    print('Formatted Date: $formattedDate');
    print("startDate $startDate");
    DateTime endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final QuerySnapshot querySnapshot = await employeesDARCollection
        .where('EmpDarEmpId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('EmpDarId', isEqualTo: DarID)
        // .where('EmpDarShiftId', isEqualTo: _userService.ShiftId)
        // .where('TileDate', isEqualTo: formattedDate)
        // .where('TileDate', isLessThan: Timestamp.fromDate(endDate))
        .get();
    String formattedDate2 = DateFormat('yyyy-M-dd').format(startDate);
    if (querySnapshot.docs.isNotEmpty) {
      // Assuming there is only one document for today's date
      Map<String, dynamic>? docRef;

      for (var dar in querySnapshot.docs) {
        final data = dar.data() as Map<String, dynamic>;
        final date2 = UtilsFuctions.convertDate(data['EmpDarCreatedAt']);
        print('date3 = ${date2[0]}');
        if (date2[0] == date.day &&
            date2[1] == date.month &&
            date2[2] == date.year) {}
        docRef = dar.data() as Map<String, dynamic>;
      }
      print('docRef = ${docRef}');
      if (docRef != null) {
        darList = docRef['EmpDarTile'];
      }
      if (docRef != null) {
        darList = docRef['EmpDarTile'];
      }
      // print("darList2 ${darList2}");
    } else {
      print("doc is empty");
    }
    print("darlist ${darList}");
    return darList;
  }

  // Future<List<Map<String, dynamic>>> fetchDarTileData(DateTime? time) async {
  //   final date = time ?? DateTime.now();
  //   print("aajkadin:$date");
  //   List<Map<String, dynamic>> darList = [];
  //   final CollectionReference employeesDARCollection =
  //       FirebaseFirestore.instance.collection('EmployeesDAR');
  //   print('empid = ${_employeeId}');

  //   final QuerySnapshot querySnapshot = await employeesDARCollection
  //       .where('EmpDarEmpId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
  //       .get();

  //   if (querySnapshot.docs.isNotEmpty) {
  //     for (var dar in querySnapshot.docs) {
  //       final data = dar.data() as Map<String, dynamic>;
  //       darList.addAll(data['EmpDarTile']);
  //     }
  //   } else {
  //     print("No DAR documents found for the current user.");
  //   }
  //   print("darList: $darList");
  //   return darList;
  // }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: height / height65,
                width: double.maxFinite,
                color: color24,
                padding: EdgeInsets.symmetric(vertical: height / height16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showDARS = true;
                            colors[0] = Primarycolor;
                            colors[1] = color25;
                          });
                        },
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Edit',
                              color: colors[0],
                              fontsize: width / width18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Primarycolor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showDARS = false;
                            colors[0] = color25;
                            colors[1] = Primarycolor;
                          });
                        },
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Reports',
                              color: colors[1],
                              fontsize: width / width18,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: height / height20),
              showDARS
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width30),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              InterRegular(
                                text: 'Shift Name :',
                                fontsize: width / width20,
                                color: color17,
                              ),
                              SizedBox(
                                width: width / width6,
                              ),
                              Flexible(
                                child: InterRegular(
                                  text: _userService.shiftName ?? 'Loading...',
                                  color: Primarycolor,
                                  fontsize: width / width20,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / height10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterRegular(
                                text: 'Location :',
                                fontsize: width / width20,
                                color: color17,
                              ),
                              SizedBox(
                                width: width / width6,
                              ),
                              Flexible(
                                child: InterRegular(
                                  text: _userService.shiftLocation ??
                                      'Loading...',
                                  color: Primarycolor,
                                  fontsize: width / width20,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / height20),
                          FutureBuilder(
                            future:
                                fetchDarTileData(widget.passdate, widget.DarId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                  child: Text('error'),
                                );
                              }
                              final data = snapshot.data;
                              print("Data length ${data?.length}");
                              // print(
                              //     'image length = ${(data![0]['images'] as List).length}');
                              return data == null
                                  ? const Center(
                                      child: Text(
                                        'Null',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: List.generate(
                                        data?.length ?? 0,
                                        (index) => GestureDetector(
                                          onTap: () {
                                            print(data[index]);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateDarScreen(
                                                  // darTiles: data,
                                                  // index: index,
                                                  index: index,
                                                  DarId: widget.DarId,
                                                  darTiles: data,
                                                  EmployeeId: widget.Empid,
                                                  EmployeeName: widget.Username,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                bottom: height / height10),
                                            width: double.maxFinite,
                                            decoration: BoxDecoration(
                                              color: WidgetColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      width / width10),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: height / height20,
                                                horizontal: width / width20),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  InterMedium(
                                                    text:
                                                        "${data[index]['TileTime']}",
                                                    // '${hourlyShiftDetails[index]['startTime'] != null ? hourlyShiftDetails[index]['startTime']!.substring(0, 4) : ''} - ${hourlyShiftDetails[index]['endTime'] != null ? hourlyShiftDetails[index]['endTime']!.substring(0, 4) : ''}',
                                                    color: color21,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          height / height10),
                                                  InterRegular(
                                                    text:
                                                        '${data[index]['TileContent']}',
                                                    fontsize: width / width16,
                                                    color: color12,
                                                    maxLines: 5,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          height / height20),
                                                  Row(
                                                    children: List.generate(
                                                      (data[index]['TileImages']
                                                              as List)
                                                          .length,
                                                      (i) => Container(
                                                        margin: EdgeInsets.only(
                                                            right: height /
                                                                height10),
                                                        height:
                                                            height / height50,
                                                        width: width / width50,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(width /
                                                                      width10),
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                              data[index][
                                                                  'TileImages'][i],
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  FutureBuilder<
                                                      Map<
                                                          String,
                                                          List<
                                                              Map<String,
                                                                  dynamic>>>>(
                                                    future: fetchReports(),
                                                    builder: (context,
                                                        reportsSnapshot) {
                                                      if (reportsSnapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const CircularProgressIndicator();
                                                      }

                                                      final reportsByHour =
                                                          reportsSnapshot
                                                                  .data ??
                                                              {};
                                                      final hourKey = data[
                                                                      index][
                                                                  'startTime'] !=
                                                              null
                                                          ? '${hourlyShiftDetails[index]['startTime']!.substring(0, 2)}:00'
                                                          : '';
                                                      final reportsForHour =
                                                          reportsByHour[
                                                                  hourKey] ??
                                                              [];

                                                      return Column(
                                                        children: reportsForHour
                                                            .map((report) {
                                                          final patrolLogCheckPoints =
                                                              report['PatrolLogCheckPoints']
                                                                      as List<
                                                                          dynamic>? ??
                                                                  [];
                                                          final timestamp =
                                                              report['PatrolLogStartedAt']
                                                                  as Timestamp;
                                                          final formattedTime =
                                                              timestamp != null
                                                                  ? DateFormat
                                                                          .jm()
                                                                      .format(timestamp
                                                                          .toDate())
                                                                  : '';
                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                formattedTime,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          195,
                                                                          21,
                                                                          21),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              ...patrolLogCheckPoints
                                                                  .expand(
                                                                      (checkPoint) {
                                                                final checkPointImages =
                                                                    checkPoint['CheckPointImage']
                                                                            as List<dynamic>? ??
                                                                        [];

                                                                if (checkPointImages
                                                                    .isNotEmpty) {
                                                                  return [
                                                                    Image
                                                                        .network(
                                                                      checkPointImages
                                                                          .first
                                                                          .toString(),
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  ];
                                                                } else {
                                                                  return [];
                                                                }
                                                              }).toList(),
                                                            ],
                                                          );
                                                        }).toList(),
                                                      );
                                                    },
                                                  ),
                                                ]),
                                          ),
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InterBold(
                            text: 'Reports',
                            fontsize: width / 20,
                            color: Primarycolor,
                          ),
                          SizedBox(height: height / 25),
                          FutureBuilder<
                              Map<String, List<Map<String, dynamic>>>>(
                            future: fetchReportLogs(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              final reportsByHour = snapshot.data ?? {};

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reportsByHour.length,
                                itemBuilder: (context, index) {
                                  final hourKey =
                                      reportsByHour.keys.toList()[index];
                                  final reportsForHour =
                                      reportsByHour[hourKey] ?? [];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reports for $hourKey',
                                        style: const TextStyle(
                                          color: Primarycolor,
                                        ),
                                      ),
                                      ...reportsForHour.map((report) {
                                        final timestampStr =
                                            report['ReportCreatedAt']
                                                as Timestamp;
                                        final formattedTime = timestampStr !=
                                                null
                                            ? DateFormat.jm()
                                                .format(timestampStr.toDate())
                                            : '';
                                        return Container(
                                          margin: EdgeInsets.only(
                                              bottom: height / 30),
                                          height: height / 25,
                                          color: const Color(0xFF7C7C7C),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 20,
                                                height: double.infinity,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: Text(
                                                  '# ${report['ReportSearchId'] ?? ''}',
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 48, 48, 48),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                formattedTime,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 48, 48, 48),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
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
      ),
    );
  }
}
