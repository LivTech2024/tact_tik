import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/services/LocationChecker/LocationCheckerFucntions.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../home screens/widgets/icon_text_widget.dart';
import '../widgets/custome_textfield.dart';

class Movie {
  final String Name;
  final String patrolArea;
  final String patrolLocationName;
  final String patrolTime;
  final String patrolDate;
  final String patrolId;

  // final String PatrolAssignedGuardId;
  // final List<String, dynamic> guardIds;
  final List<Map<String, dynamic>> guardIds;

  // final String Empid;
  final String BranchId;
  final String CompanyID;
  final String PatrolCompletedCount;
  final String PatrolRequiredCount;
  final double patrolLocationLatitude;
  final double patrolLocationLongitude;
  final bool keepINRaius;
  final int PatrolRadius;

  // String address, String reportName, String Empid,
  //     String BranchId, String Data, String CompanyId

  final List<Map<String, dynamic>> checkpoints;

  int get totalCheckpoints => checkpoints.length;

  int get completedCheckpoints => checkpoints
      .where((checkpoint) => checkpoint['CheckPointStatus'] == 'checked')
      .length;

  // final List<String> patrolCheckPoints;
  Movie(
    this.Name,
    this.patrolArea,
    this.patrolLocationName,
    this.patrolTime,
    this.checkpoints,
    this.patrolDate,
    this.patrolId,
    // this.PatrolAssignedGuardId,
    // this.Empid,
    this.BranchId,
    this.CompanyID,
    this.guardIds,
    this.PatrolCompletedCount,
    this.PatrolRequiredCount,
    this.patrolLocationLatitude,
    this.patrolLocationLongitude,
    this.keepINRaius,
    this.PatrolRadius,
    // this.patrolCheckPoints
  );
}

class OpenPatrollingScreen extends StatefulWidget {
  final String empId;
  final String empName;
  final String empEmail;
  final String BranchId;
  final String CompanyID;

  const OpenPatrollingScreen(
      {super.key,
      required this.empId,
      required this.empEmail,
      required this.BranchId,
      required this.CompanyID,
      required this.empName});

  @override
  State<OpenPatrollingScreen> createState() => _OpenPatrollingScreenState();
}

FireStoreService fireStoreService = FireStoreService();

class _OpenPatrollingScreenState extends State<OpenPatrollingScreen> {
  List<Movie> movies = [];
  final LocalStorage storage = LocalStorage('currentUserEmail');
  late final String EmployeId;
  late final String EmployeName;

  @override
  void initState() {
    super.initState();
    // _getUserInfo();
  }

  UserLocationChecker locationChecker = UserLocationChecker();


  List<Map<String, dynamic>> uploads = [];

  void _deleteItem(int index) {
    setState(() {
      uploads.removeAt(index);
    });
  }


  Future<void> _addImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        appBar: AppBar(
          backgroundColor: AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Patrolling',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        /*floatingActionButton: FloatingActionButton(
          backgroundColor: Primarycolor,
          shape: const CircleBorder(),
          onPressed: () {},
          child: Icon(
            Icons.qr_code_scanner,
            color: color1,
          ),
        ),*/

        // body:
        /*body: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (movies.isEmpty) {
                      return Center(
                        child: Text(
                          'No Patrols available',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      );
                    }

                    final category = movies[index].patrolLocationName;
                    final categoryMovies = movies
                        .where((movie) => movie.patrolLocationName == category)
                        .toList();
                    return MovieCategory(
                      category,
                      categoryMovies,
                      EmployeeId: widget.empId,
                      EmployeeEmail: widget.empName,
                    );
                  },
                  childCount: movies
                      .map((movie) => movie.patrolLocationName)
                      .toSet()
                      .length,
                ),
              ),
            ],
          ),
        ),*/
      ),
    );
  }
}

class MovieCategory extends StatefulWidget {
  final String category;
  final List<Movie> movies;
  final Map<String, dynamic>? patrolInfo;
  final String EmployeeId;
  final String EmployeeEmail;

  MovieCategory(this.category, this.movies,
      {this.patrolInfo, required this.EmployeeId, required this.EmployeeEmail});

  @override
  _MovieCategoryState createState() => _MovieCategoryState();
}

UserLocationChecker locationChecker = UserLocationChecker();

void showCustomDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          content,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

class _MovieCategoryState extends State<MovieCategory> {
  bool _expanded = false;
  String Result = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width / width30, vertical: height / height30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterBold(
            text: widget.movies[0].patrolDate,
            fontsize: width / width18,
            color: color1,
          ),
          SizedBox(height: height / height30),
          for (var movie in widget.movies)
            Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: WidgetColor,
                    borderRadius: BorderRadius.circular(width / width10),
                  ),
                  constraints: _expanded
                      ? BoxConstraints(minHeight: height / height200)
                      : BoxConstraints(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / width10,
                            vertical: height / height20),
                        child: Column(
                          children: [
                            SizedBox(height: height / height5),
                            IconTextWidget(
                              iconSize: width / width24,
                              icon: Icons.location_on,
                              text: movie.patrolArea,
                              useBold: false,
                              color: color13,
                            ),
                            SizedBox(height: height / height16),
                            Divider(
                              color: color14,
                            ),
                            SizedBox(height: height / height5),
                            IconTextWidget(
                              iconSize: width / width24,
                              icon: Icons.access_time,
                              text: movie.patrolTime,
                              useBold: false,
                              color: color13,
                            ),
                            SizedBox(height: height / height16),
                            Divider(
                              color: color14,
                            ),
                            SizedBox(height: height / height5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner,
                                      color: Primarycolor,
                                      size: width / width24,
                                    ),
                                    SizedBox(width: width / width20),
                                    InterMedium(
                                      text:
                                          'Total ${movie.PatrolRequiredCount} Completed ${movie.PatrolCompletedCount}',
                                      fontsize: width / width14,
                                      color: color13,
                                    )
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _expanded = !_expanded;
                                    });
                                  },
                                  icon: Icon(
                                    _expanded
                                        ? Icons.arrow_circle_up_outlined
                                        : Icons.arrow_circle_down_outlined,
                                    size: width / width24,
                                    color: Primarycolor,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_expanded)
                        Column(
                          children: [
                            Button1(
                              text: 'START',
                              backgroundcolor: colorGreen,
                              color: Colors.green,
                              borderRadius: width / width10,
                              onPressed: () async {
                                if (movie.keepINRaius == true) {
                                  Timer.periodic(Duration(seconds: 60),
                                      (Timer timer) async {
                                    bool isWithinRaius =
                                        await locationChecker.checkLocation(
                                            movie.patrolLocationLatitude,
                                            movie.patrolLocationLongitude,
                                            movie.PatrolRadius);
                                    if (isWithinRaius != true) {
                                      showCustomDialog(context, "Radius",
                                          "Move into Radius to continue");
                                    }
                                  });
                                  bool isWithinRaius =
                                      await locationChecker.checkLocation(
                                          movie.patrolLocationLatitude,
                                          movie.patrolLocationLongitude,
                                          movie.PatrolRadius);
                                  if (isWithinRaius) {
                                    print("WithIn Radius");
                                  } else {
                                    showCustomDialog(context, "Radius",
                                        "Move into Radius to continue");
                                  }
                                  // if (isWithinRaius) {
                                  // } else {
                                  //   showCustomDialog(context, "Raius Error",
                                  //       "Move inside the Patrol Radius to start the patrol");
                                  // }
                                } else {
                                  // CupertinoAlertDialog()
                                  print("Started");
                                  fireStoreService.startPatrol(
                                    //  Category,
                                    movie.patrolId,
                                    // movie.patrolLocationName,
                                    // movie.PatrolAssignedGuardId,
                                    // movie.Empid,
                                    // movie.BranchId,
                                    // movie.CompanyID,
                                    // movie.guardIds,
                                    // movie.CompanyID,
                                    // movie.Name,
                                    // movie.patrolLocationName,
                                    // movie.BranchId,

                                    // movie.s
                                  );
                                  //Pop Up of Completion
                                }
                                //Save As Report
                              },
                            ),
                            Column(
                              children: movie.checkpoints
                                  .map(
                                    (checkpoint) => GestureDetector(
                                      onTap: () async {
                                        if (checkpoint['CheckPointStatus'] !=
                                            'checked') {
                                          if (movie.keepINRaius == true) {
                                            bool isWithinRaius =
                                                await locationChecker.checkLocation(
                                                    movie
                                                        .patrolLocationLatitude,
                                                    movie
                                                        .patrolLocationLongitude,
                                                    movie.PatrolRadius);

                                            if (isWithinRaius) {
                                              var res = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SimpleBarcodeScannerPage(),
                                                  ));
                                              setState(() {
                                                if (res is String) {
                                                  Result = res;
                                                  print(res);

                                                  if (Result ==
                                                      checkpoint[
                                                          'CheckPointId']) {
                                                    // fireStoreService
                                                    //     .updatePatrolsStatus(
                                                    //   widget.EmployeeId,
                                                    //   movie.patrolId,
                                                    //   checkpoint[
                                                    //       'CheckPointId'],
                                                    // );
                                                    // Show an alert indicating a match
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            'Checkpoint Match',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          content: Text(
                                                            'The scanned QR code matches the checkpoint ID.',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text('OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    // Show an alert indicating no match
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            'Checkpoint Mismatch',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          content: Text(
                                                            'The scanned QR code does not match the checkpoint ID.',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text('OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                              });
                                            } else {
                                              showCustomDialog(
                                                  context,
                                                  "Patrol Radius",
                                                  "Move inside the Patrol Radius");
                                            }
                                          } else {
                                            var res = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SimpleBarcodeScannerPage(),
                                                ));
                                            setState(() {
                                              if (res is String) {
                                                Result = res;
                                                print(res);

                                                if (Result ==
                                                    checkpoint[
                                                        'CheckPointId']) {
                                                  // fireStoreService
                                                  //     .updatePatrolsStatus(
                                                  //   widget.EmployeeId,
                                                  //   movie.patrolId,
                                                  //   checkpoint['CheckPointId'],
                                                  // );
                                                  // Show an alert indicating a match
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          'Checkpoint Match',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        content: Text(
                                                          'The scanned QR code matches the checkpoint ID.',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text('OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  // Show an alert indicating no match
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          'Checkpoint Mismatch',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        content: Text(
                                                          'The scanned QR code does not match the checkpoint ID.',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text('OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              }
                                            });
                                            // showCustomDialog(
                                            //     context,
                                            //     "Patrol Radius",
                                            //     "Move inside the Patrol Radius");
                                          }
                                        }
                                      },
                                      child: Container(
                                        height: height / height70,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width / width20,
                                            vertical: height / height11),
                                        margin: EdgeInsets.only(
                                            top: height / height10),
                                        decoration: BoxDecoration(
                                          color: color15,
                                          borderRadius: BorderRadius.circular(
                                              width / width10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  height: height / height48,
                                                  width: width / width48,
                                                  decoration: BoxDecoration(
                                                    color: color16,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            width / width10),
                                                  ),
                                                  child: Center(
                                                    child: checkpoint[
                                                                'CheckPointStatus'] ==
                                                            'checked'
                                                        ? Container(
                                                            height: height /
                                                                height30,
                                                            width:
                                                                width / width30,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: color2,
                                                            ),
                                                            child: Icon(
                                                              Icons.done,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          )
                                                        : Icon(
                                                            Icons
                                                                .qr_code_scanner,
                                                            size:
                                                                width / width24,
                                                            color: Primarycolor,
                                                          ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width / width20,
                                                ),
                                                InterRegular(
                                                  text: checkpoint[
                                                      'CheckPointName'],
                                                  color: color17,
                                                  fontsize: width / width18,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: height / height34,
                                              width: width / width34,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: color16,
                                              ),
                                              child: Center(
                                                child: IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            'Report Qr',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          content: Text(
                                                            'The scanned QR code does work.',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                    "Cancel")),
                                                            TextButton(
                                                              onPressed: () {
                                                                // fireStoreService.updatePatrolsReport(
                                                                //     movie
                                                                //         .PatrolAssignedGuardId,
                                                                //     movie
                                                                //         .patrolId,
                                                                //     checkpoint[
                                                                //         'CheckPointId']);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  'Submit'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                    print("Info Icon Pressed");
                                                  },
                                                  icon: Icon(
                                                    Icons.info,
                                                    color: color18,
                                                    size: width / width24,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            SizedBox(
                              height: height / height10,
                            ),
                            Button1(
                                text: 'END',
                                backgroundcolor: colorRed2,
                                color: Colors.redAccent,
                                borderRadius: 10,
                                onPressed: () async {
                                  if (movie.PatrolRequiredCount ==
                                      movie.PatrolCompletedCount) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'End Patrolling',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          content: Text(
                                            'Do you want to end patrolling',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                fireStoreService.EndPatrol(
                                                  //  Category,
                                                  // movie.patrolId,
                                                  // movie.patrolLocationName,
                                                  // movie.PatrolAssignedGuardId,
                                                  // movie.Empid,
                                                  // movie.BranchId,
                                                  // movie.CompanyID,
                                                  widget.EmployeeId,
                                                  movie.CompanyID,
                                                  movie.Name,
                                                  movie.patrolLocationName,
                                                  movie.BranchId,
                                                  movie.patrolId,
                                                  widget.EmployeeEmail,
                                                  // movie.s
                                                );

                                                Navigator.of(context).pop();
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    // Navigator.of(context).pop();
                                  } else {
                                    if (movie.totalCheckpoints ==
                                        movie.completedCheckpoints) {
                                      await fireStoreService
                                          .updatePatrolsCounter(
                                              widget.EmployeeId,
                                              movie.patrolId);
                                      print("Updated");
                                      //Update the counter and reset the checkpoint status
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                              'Patrol Incomplete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            content: Text(
                                              'Complete all checkpoints to end patrolling',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                }),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
