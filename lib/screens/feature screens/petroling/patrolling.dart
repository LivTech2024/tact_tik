import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../home screens/widgets/icon_text_widget.dart';

class Movie {
  final String Name;
  final String patrolArea;
  final String patrolLocationName;
  final String patrolTime;
  final String patrolDate;
  final String patrolId;
  final String PatrolAssignedGuardId;
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
    this.PatrolAssignedGuardId,
    // this.patrolCheckPoints
  );
}

class OpenPatrollingScreen extends StatefulWidget {
  final String empId;
  const OpenPatrollingScreen({super.key, required this.empId});

  @override
  State<OpenPatrollingScreen> createState() => _OpenPatrollingScreenState();
}

FireStoreService fireStoreService = FireStoreService();

class _OpenPatrollingScreenState extends State<OpenPatrollingScreen> {
  List<Movie> movies = [];
  final LocalStorage storage = LocalStorage('currentUserEmail');
  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void _getUserInfo() async {
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();

    if (widget.empId.isNotEmpty) {
      var patrolInfoList = await fireStoreService
          .getAllPatrolsByEmployeeIdFromUserInfo(widget.empId);

      List<Movie> updatedMovies = [];
      for (var patrolInfo in patrolInfoList) {
        String PatrolArea = patrolInfo['PatrolArea'];
        String PatrolCompanyId = patrolInfo['PatrolCompanyId'];
        String PatrolLocationName = patrolInfo['PatrolLocationName'];
        String PatrolName = patrolInfo['PatrolName'];
        int PatrolRestrictedRadius = patrolInfo['PatrolRestrictedRadius'];
        String PatrolAssignedGuardId = patrolInfo['PatrolAssignedGuardId'];
        String patrolId = patrolInfo["PatrolId"];
        Timestamp PatrolTime = patrolInfo['PatrolTime'];
        DateTime dateTime = PatrolTime.toDate();
        String time = DateFormat.Hms().format(dateTime);
        String date = DateFormat.yMd().format(dateTime);
        List<Map<String, dynamic>> checkpoints = [];
        for (var checkpoint in patrolInfo['PatrolCheckPoints']) {
          String checkpointName = checkpoint['CheckPointName'];
          String checkpointLocation = checkpoint['CheckPointId'];
          String CheckPointStatus = checkpoint['CheckPointStatus'];
          checkpoints.add({
            'CheckPointName': checkpointName,
            'CheckPointId': checkpointLocation,
            'CheckPointStatus': CheckPointStatus,
          });
        }

        updatedMovies.add(Movie(PatrolName, PatrolArea, PatrolLocationName,
            time, checkpoints, date, patrolId, PatrolAssignedGuardId));

        print('PatrolArea: $PatrolArea');
        print('PatrolCompanyId: $PatrolCompanyId');
        print('PatrolLocationName: $PatrolLocationName');
        print('PatrolName: $PatrolName');
        print('PatrolRestrictedRadius: $PatrolRestrictedRadius');
        print('PatrolAssignedGuardId: $PatrolAssignedGuardId');
        print('patrolId: $patrolId');
        print('PatrolTime: $time');
        print('PatrolDate: $date');
        print('Checkpoints: $checkpoints');
      }

      setState(() {
        movies = updatedMovies;
      });
      print("Updated Movies: ${updatedMovies}");
    } else {
      print('Patrol info not found');
    }
  }

  Future<void> _refreshData() async {
    // Fetch patrol data from Firestore (assuming your logic exists)
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
    // ... (existing data fetching logic based on user ID)

    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.only(left: 20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Patrolling',
            fontsize: 18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Primarycolor,
          shape: const CircleBorder(),
          onPressed: () {},
          child: Icon(
            Icons.qr_code_scanner,
            color: color1,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (movies.isEmpty) {
                      return Center(child: Text('No Patrols available'));
                    }

                    final category = movies[index].patrolLocationName;
                    final categoryMovies = movies
                        .where((movie) => movie.patrolLocationName == category)
                        .toList();
                    return MovieCategory(category, categoryMovies);
                  },
                  childCount: movies
                      .map((movie) => movie.patrolLocationName)
                      .toSet()
                      .length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieCategory extends StatefulWidget {
  final String category;
  final List<Movie> movies;
  final Map<String, dynamic>? patrolInfo;

  MovieCategory(this.category, this.movies, {this.patrolInfo});

  @override
  _MovieCategoryState createState() => _MovieCategoryState();
}

class _MovieCategoryState extends State<MovieCategory> {
  bool _expanded = false;
  String Result = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterBold(
            text: widget.movies[0].patrolDate,
            fontsize: 18,
            color: color1,
          ),
          SizedBox(height: 30),
          for (var movie in widget.movies)
            Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: WidgetColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: _expanded
                      ? BoxConstraints(minHeight: 200)
                      : BoxConstraints(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          children: [
                            SizedBox(height: 5),
                            IconTextWidget(
                              iconSize: 24,
                              icon: Icons.location_on,
                              text: movie.patrolArea,
                              useBold: false,
                              color: color13,
                            ),
                            SizedBox(height: 16),
                            Divider(
                              color: color14,
                            ),
                            SizedBox(height: 5),
                            IconTextWidget(
                              iconSize: 24,
                              icon: Icons.access_time,
                              text: movie.patrolTime,
                              useBold: false,
                              color: color13,
                            ),
                            SizedBox(height: 16),
                            Divider(
                              color: color14,
                            ),
                            SizedBox(height: 5),
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
                                      size: 24,
                                    ),
                                    SizedBox(width: 20),
                                    InterMedium(
                                      text:
                                          'Total ${movie.totalCheckpoints}     Completed ${movie.completedCheckpoints}',
                                      fontsize: 14,
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
                                    size: 24,
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
                          children: movie.checkpoints
                              .map((checkpoint) => GestureDetector(
                                    onTap: () async {
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
                                              checkpoint['CheckPointId']) {
                                            fireStoreService
                                                .updatePatrolsStatus(
                                              movie.PatrolAssignedGuardId,
                                              movie.patrolId,
                                              checkpoint['CheckPointId'],
                                            );
                                            // Show an alert indicating a match
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      Text('Checkpoint Match'),
                                                  content: Text(
                                                      'The scanned QR code matches the checkpoint ID.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
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
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Checkpoint Mismatch',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  content: Text(
                                                    'The scanned QR code does not match the checkpoint ID.',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
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
                                    },
                                    child: Container(
                                      height: 70,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 11.0),
                                      margin: EdgeInsets.only(top: 10.0),
                                      decoration: BoxDecoration(
                                        color: color15,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 48,
                                                width: 48,
                                                decoration: BoxDecoration(
                                                  color: color16,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.qr_code_scanner,
                                                    size: 24,
                                                    color: checkpoint[
                                                                'CheckPointStatus'] ==
                                                            'checked'
                                                        ? colorGreen
                                                        : Primarycolor,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              InterRegular(
                                                text: checkpoint[
                                                    'CheckPointName'],
                                                color: color17,
                                                fontsize: 18,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 34,
                                            width: 34,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color16,
                                            ),
                                            child: Center(
                                              child: IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          'Report Qr',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        content: Text(
                                                          'The scanned QR code does work.',
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
                                                            child:
                                                                Text('Submit'),
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
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
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
