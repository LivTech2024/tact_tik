import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  const DarOpenAllScreen({super.key, this.passdate});

  @override
  State<DarOpenAllScreen> createState() => _DarOpenAllScreenState();
}

class _DarOpenAllScreenState extends State<DarOpenAllScreen> {
  List colors = [Primarycolor, color25];
  bool showDARS = true;
  List<Map<String, dynamic>> hourlyShiftDetails = [];
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

  // void _processShiftDetails(List<Map<String, dynamic>> shiftDetails) {
  //   hourlyShiftDetails.clear(); // Clear previous details
  //   for (var shift in shiftDetails) {
  //     //

  //     final startTime = '09:00'; // Extract startTime
  //     final endTime = '13:00'; // Extract endTime

  //     // Split startTime and endTime strings to get hours and minutes
  //     final startTimeParts = startTime.split(':');
  //     final endTimeParts = endTime.split(':');

  //     final startHour = int.parse(startTimeParts[0]);
  //     final startMinute = int.parse(startTimeParts[1]);
  //     final endHour = int.parse(endTimeParts[0]);
  //     final endMinute = int.parse(endTimeParts[1]);

  //     if (endHour > startHour ||
  //         (endHour == startHour && endMinute > startMinute)) {
  //       // Shift doesn't cross midnight
  //       for (int hour = startHour; hour < endHour; hour++) {
  //         final hourStart =
  //             '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  //         final hourEnd =
  //             '${(hour + 1).toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  //         hourlyShiftDetails.add({
  //           'startTime': hourStart,
  //           'endTime': hourEnd,
  //         });
  //       }
  //       // Add last hour
  //       final lastHourStart =
  //           '${endHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  //       final lastHourEnd =
  //           '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  //       hourlyShiftDetails.add({
  //         'startTime': lastHourStart,
  //         'endTime': lastHourEnd,
  //       });
  //     } else {
  //       // Shift crosses midnight
  //       for (int hour = startHour; hour < 24; hour++) {
  //         final hourStart =
  //             '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  //         final hourEnd =
  //             '${(hour + 1).toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  //         hourlyShiftDetails.add({
  //           'startTime': hourStart,
  //           'endTime': hourEnd,
  //         });
  //       }
  //       for (int hour = 0; hour < endHour; hour++) {
  //         final hourStart =
  //             '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  //         final hourEnd =
  //             '${(hour + 1).toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  //         hourlyShiftDetails.add({
  //           'startTime': hourStart,
  //           'endTime': hourEnd,
  //         });
  //       }
  //       // Add last hour
  //       // final lastHourStart = '00:${startMinute.toString().padLeft(2, '0')}';
  //       // final lastHourEnd =
  //       //     '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  //       // hourlyShiftDetails.add({
  //       //   'startTime': lastHourStart,
  //       //   'endTime': lastHourEnd,
  //       // });
  //     }
  //   }
  // }

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

      if (endHour > startHour ||
          (endHour == startHour && endMinute > startMinute)) {
        // Shift doesn't cross midnight
        for (int hour = startHour; hour < endHour; hour++) {
          final hourStart =
              '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
          final hourEnd =
              '${(hour + 1).toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

          hourlyShiftDetails.add({
            'startTime': hourStart,
            'endTime': hourEnd,
          });
        }
      } else {
        // Shift crosses midnight
        for (int hour = startHour; hour < 24; hour++) {
          final hourStart =
              '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
          final hourEnd =
              '${(hour + 1).toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

          hourlyShiftDetails.add({
            'startTime': hourStart,
            'endTime': hourEnd,
          });
        }
        for (int hour = 0; hour < endHour; hour++) {
          final hourStart =
              '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
          final hourEnd =
              '${(hour + 1).toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

          hourlyShiftDetails.add({
            'startTime': hourStart,
            'endTime': hourEnd,
          });
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
            final data = dar.data() as Map<String, dynamic>;
            final date2 = UtilsFuctions.convertDate(data['EmpDarCreatedAt']);
            print('date = ${date2[0]}');
            if (date2[0] == date.day &&
                date2[1] == date.month &&
                date2[2] == date.year) {
              if (data['EmpDarTile'] != null) {
                isDarlistPresent = true;
              }
              docRef = dar.reference;
            }
          }

          final List<Map<String, dynamic>> darTiles = [];
          for (var shift in hourlyShiftDetails) {
            final String startTime = shift['startTime']!;
            final String endTime = shift['endTime']!;
            final Map<String, dynamic> darTile = {
              'TileContent': '',
              'TileTime': '$startTime - $endTime',
              'TileImages': [],
              'TileLocation:': '',
            };
            darTiles.add(darTile);
          }

          if (docRef != null) {
            if (!isDarlistPresent) {
              await docRef
                  .set({'EmpDarTile': darTiles}, SetOptions(merge: true));
            }
          } else {
            print('No document found with the matching date.');
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

  Future<List> fetchDarTileData(DateTime? time) async {
    final date = time ?? DateTime.now();
    print("aajkadin:$date");
    List darList = [];
    final CollectionReference employeesDARCollection =
        FirebaseFirestore.instance.collection('EmployeesDAR');
    print('empid = ${_employeeId}');

    final QuerySnapshot querySnapshot = await employeesDARCollection
        .where('EmpDarEmpId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic>? docRef;

      for (var dar in querySnapshot.docs) {
        final data = dar.data() as Map<String, dynamic>;
        final date2 = UtilsFuctions.convertDate(data['EmpDarCreatedAt']);
        print('date3 = ${date2[0]}');
        if (date2[0] == date.day &&
            date2[1] == date.month &&
            date2[2] == date.year) {
          docRef = dar.data() as Map<String, dynamic>;
        }
      }
      print('docRef = ${docRef}');
      if (docRef != null) {
        darList = docRef['EmpDarTile'];
      }
    }
// print('darList = ${darList[0]}');
    return darList;
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: isLight ? color18 : Secondarycolor,
        appBar: AppBar(
          backgroundColor: isLight ?  color1:AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isLight ? WidgetColor: Colors.white,
              size: width / width24,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: '',
            fontsize: width / width18,
            color:isLight ? WidgetColor:  Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: height / height65,
                width: double.maxFinite,
                color: isLight ? color1: color24,
                padding: EdgeInsets.symmetric(vertical: height / height16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showDARS = true;
                            colors[0] = isLight ? IconSelected: Primarycolor;
                            colors[1] = color25;
                          });
                        },
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Edit',
                              color: isLight ? WidgetColor: colors[0],
                              fontsize: width / width18,
                            ),
                          ),
                        ),
                      ),
                    ),
                     VerticalDivider(
                      color: isLight ? WidgetColor: Primarycolor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showDARS = false;
                            colors[0] = color25;
                            colors[1] = isLight ? IconSelected: Primarycolor;
                          });
                        },
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Reports',
                              color: isLight ? WidgetColor: colors[1],
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
                                color: isLight ? WidgetColor: color17,
                              ),
                              SizedBox(
                                width: width / width6,
                              ),
                              Flexible(
                                child: InterRegular(
                                  text: _userService.shiftName ?? 'Loading...',
                                  color: isLight ? IconSelected: Primarycolor,
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
                                color: isLight ? WidgetColor: color17,
                              ),
                              SizedBox(
                                width: width / width6,
                              ),
                              Flexible(
                                child: InterRegular(
                                  text: _userService.shiftLocation ??
                                      'Loading...',
                                  color: isLight ? IconSelected: Primarycolor,
                                  fontsize: width / width20,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / height20),
                          FutureBuilder(
                            future: fetchDarTileData(widget.passdate),
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
                                        data.length,
                                        (index) => GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateDarScreen(
                                                  index: index,
                                                  darTiles: data,
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
                                                        '${hourlyShiftDetails[index]['startTime'] != null ? hourlyShiftDetails[index]['startTime']!.substring(0, 4) : ''} - ${hourlyShiftDetails[index]['endTime'] != null ? hourlyShiftDetails[index]['endTime']!.substring(0, 4) : ''}',
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
                                                      final hourKey =
                                                          '${hourlyShiftDetails[index]['startTime']!.substring(0, 2)}:00';
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

                                                                return checkPointImages
                                                                    .map(
                                                                        (imageUrl) {
                                                                  return Image
                                                                      .network(
                                                                    imageUrl
                                                                        .toString(),
                                                                    width:
                                                                        100, // Adjust the width as per your requirement
                                                                    height:
                                                                        100, // Adjust the height as per your requirement
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  );
                                                                }).toList();
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
                            color: isLight ? IconSelected: Primarycolor,
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
                                        style:  TextStyle(
                                          color: isLight ? IconSelected: Primarycolor,
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
                                          color: isLight ? color1: Color(0xFF7C7C7C),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 20,
                                                height: double.infinity,
                                                color: isLight ? IconSelected: Colors.red,
                                              ),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: Text(
                                                  '# ${report['ReportSearchId'] ?? ''}',
                                                  style:  TextStyle(
                                                    color: isLight ? WidgetColor: Color.fromARGB(
                                                        255, 48, 48, 48),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                formattedTime,
                                                style:  TextStyle(
                                                  color: isLight ? WidgetColor: Color.fromARGB(
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
