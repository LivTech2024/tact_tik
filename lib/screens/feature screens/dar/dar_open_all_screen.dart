import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  const DarOpenAllScreen({super.key});

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
    fetchDarTileData();
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

  void _processShiftDetails(List<Map<String, dynamic>> shiftDetails) {
    hourlyShiftDetails.clear(); // Clear previous details
    for (var shift in shiftDetails) {
      final startTime = shift['startTime']; // Extract startTime
      final endTime = shift['endTime']; // Extract endTime

      // Split startTime and endTime strings to get hours and minutes
      final startTimeParts = startTime.split(':');
      final endTimeParts = endTime.split(':');

      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

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

      if (endMinute > startMinute) {
        final lastHourStart =
            '${endHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}'; // Format last hour start time
        final lastHourEnd =
            '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}'; // Format last hour end time
        hourlyShiftDetails.add({
          'startTime': lastHourStart,
          'endTime': lastHourEnd,
        });
      }
    }
  }

  // void _processShiftDetails(List<Map<String, dynamic>> shiftDetails) {
  //   hourlyShiftDetails.clear(); // Clear previous details
  //   for (var shift in shiftDetails) {
  //     final startTime = DateTime.parse(shift['startTime']);
  //     final endTime = DateTime.parse(shift['endTime']);
  //     final duration = endTime.difference(startTime);
  //     final hourlyDuration = const Duration(hours: 1);
  //     final totalHours = duration.inHours;

  //     for (int i = 0; i < totalHours; i++) {
  //       final hourStart = startTime.add(Duration(hours: i));
  //       final hourEnd = hourStart.add(hourlyDuration);
  //       hourlyShiftDetails.add({
  //         'startTime': hourStart.toString(),
  //         'endTime': hourEnd.toString(),
  //       });
  //     }

  //     final remainingMinutes = duration.inMinutes.remainder(60);
  //     if (remainingMinutes > 0) {
  //       final lastHourStart =
  //           endTime.subtract(Duration(minutes: remainingMinutes));
  //       final lastHourEnd = endTime;
  //       hourlyShiftDetails.add({
  //         'startTime': lastHourStart.toString(),
  //         'endTime': lastHourEnd.toString(),
  //       });
  //     }
  //   }
  // }

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
            final date2 = UtilsFuctions.convertDate(data['EmpDarDate']);
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

  Future<List> fetchDarTileData() async {
    final date = DateTime.now();
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
        final date2 = UtilsFuctions.convertDate(data['EmpDarDate']);
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
                    const VerticalDivider(
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
                              future: fetchDarTileData(),
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
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                              }),
                        ],
                      ),
                    )
                  : Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InterBold(
                            text: 'Reports',
                            fontsize: width / width20,
                            color: Primarycolor,
                          ),
                          SizedBox(height: height / height10),
                          Column(
                            children: List.generate(
                              20,
                              (index) => Container(
                                margin: EdgeInsets.only(
                                  bottom: height / height10,
                                ),
                                height: height / height35,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: height / height35,
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                        color: WidgetColor,
                                        borderRadius: BorderRadius.circular(
                                            width / width10),
                                      ),
                                    ),
                                    Container(
                                      height: height / height35,
                                      width: width / width16,
                                      decoration: BoxDecoration(
                                        color: colorRed3,
                                        borderRadius: BorderRadius.circular(
                                            width / width10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
