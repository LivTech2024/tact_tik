import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import '../../home screens/widgets/icon_text_widget.dart';

FireStoreService fireStoreService = FireStoreService();

class MyPatrolsList extends StatefulWidget {
  final String ShiftLocationId;

  const MyPatrolsList({required this.ShiftLocationId});

  @override
  State<MyPatrolsList> createState() => _MyPatrolsListState();
}

class _MyPatrolsListState extends State<MyPatrolsList> {
  // late Map<String, dynamic> patrolsData = "";
  late List<Patrol> patrolsData = [];
  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void _getUserInfo() async {
    var patrolInfoList = await fireStoreService
        .getAllPatrolsByEmployeeIdFromUserInfo(widget.ShiftLocationId);

    List<Patrol> patrols = [];
    for (var patrol in patrolInfoList) {
      Map<String, dynamic> data = patrol.data() as Map<String, dynamic>;
      String patrolCompanyId = data['PatrolCompanyId'];
      String patrolLocationName = data['PatrolLocationName'];
      String patrolName = data['PatrolName'];

      List<Category> categories = [];
      for (var checkpoint in data['PatrolCheckPoints']) {
        String checkpointCategory = checkpoint['CheckPointCategory'];
        String checkpointId = checkpoint['CheckPointId'];
        String checkpointName = checkpoint['CheckPointName'];

        // Assuming CheckPointStatus is not used in this context
        Category category = categories.firstWhere(
            (element) => element.title == checkpointCategory, orElse: () {
          Category newCategory =
              Category(title: checkpointCategory, checkpoints: []);
          categories.add(newCategory);
          return newCategory;
        });

        category.checkpoints.add(Checkpoint(
          title: checkpointName,
          description: 'Description of $checkpointName',
          id: checkpointId,
        ));
      }

      patrols.add(
        Patrol(
          title: patrolName,
          description: patrolLocationName,
          categories: categories,
        ),
      );
    }

    setState(() {
      patrolsData = patrols;
    });
  }

  // bool _expand = false;
  // bool _expand2 = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width / width30,
            vertical: height / height30,
          ),
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Patrol p = patrolsData[index];
                    return PatrollingWidget(p: p);
                  },
                  childCount: patrolsData.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatrollingWidget extends StatefulWidget {
  const PatrollingWidget({super.key, required this.p});

  final Patrol p;

  @override
  State<PatrollingWidget> createState() => _PatrollingWidgetState();
}

class _PatrollingWidgetState extends State<PatrollingWidget> {
  bool _expand = false;
  bool _expand2 = false;
  late Map<String, bool> _expandCategoryMap;

  @override
  void initState() {
    super.initState();
    // Initialize expand state for each category
    _expandCategoryMap = Map.fromIterable(widget.p.categories,
        key: (category) => category.title, value: (_) => false);
  }

  String Result = "";
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InterBold(
          text: "Today",
          fontsize: width / width18,
          color: color1,
        ),
        SizedBox(height: height / height30),
        AnimatedContainer(
          margin: EdgeInsets.only(bottom: height / height30),
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: WidgetColor,
            borderRadius: BorderRadius.circular(width / width10),
          ),
          constraints: _expand
              ? BoxConstraints(minHeight: height / height200)
              : BoxConstraints(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width / width10,
                  vertical: height / height20,
                ),
                child: Column(
                  children: [
                    SizedBox(height: height / height5),
                    IconTextWidget(
                      iconSize: width / width24,
                      icon: Icons.location_on,
                      text: widget.p.title,
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
                      text: widget.p.description,
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
                      icon: Icons.qr_code_scanner,
                      text: 'Total       Completed',
                      useBold: false,
                      color: color13,
                    ),
                    SizedBox(height: height / height20),
                  ],
                ),
              ),
              Button1(
                text: 'START',
                backgroundcolor: colorGreen,
                color: Colors.green,
                borderRadius: width / width10,
                onPressed: () {
                  setState(() {
                    // clickedIIndex = index;
                    // print(clickedIIndex);
                    _expand = !_expand;
                  });
                },
              ),
              Visibility(
                  visible: _expand,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.p.categories.map((category) {
                      print("_expandCategoryMap: $category");
                      final expand =
                          _expandCategoryMap.containsKey(category.title)
                              ? _expandCategoryMap[category.title]!
                              : false;

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Handle tap action to expand checkpoints
                              // Toggle visibility of checkpoints associated with this category
                              setState(() {
                                if (_expandCategoryMap[category.title] !=
                                    null) {
                                  _expandCategoryMap[category.title] =
                                      !_expandCategoryMap[category.title]!;
                                }
                                // _expand2 = !_expand2;
                              });
                            },
                            child: Container(
                              height: height / height70,
                              padding: EdgeInsets.symmetric(
                                  horizontal: width / width20,
                                  vertical: height / height11),
                              margin: EdgeInsets.only(top: height / height10),
                              decoration: BoxDecoration(
                                color: color15,
                                borderRadius:
                                    BorderRadius.circular(width / width10),
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
                                          borderRadius: BorderRadius.circular(
                                              width / width10),
                                        ),
                                        child: Icon(
                                          Icons.home_sharp,
                                          size: width / width24,
                                          color: Primarycolor,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width / width20,
                                      ),
                                      InterRegular(
                                        text: category.title,
                                        color: color17,
                                        fontsize: width / width18,
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _expandCategoryMap[category.title] !=
                                            _expandCategoryMap[category.title];
                                      });
                                    },
                                    icon: Icon(
                                      expand
                                          ? Icons.arrow_circle_up_outlined
                                          : Icons.arrow_circle_down_outlined,
                                      size: width / width24,
                                      color: Primarycolor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: expand,
                            // Set to a variable to toggle visibility
                            child: Column(
                              children: category.checkpoints.map((checkpoint) {
                                return GestureDetector(
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

                                        if (Result == checkpoint.id) {
                                          // fireStoreService.updatePatrolsStatus(
                                          //   widget.EmployeeId,
                                          //   movie.patrolId,
                                          //   checkpoint['CheckPointId'],
                                          // );
                                          // Show an alert indicating a match
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  'Checkpoint Match',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                content: Text(
                                                  'The scanned QR code matches the checkpoint ID.',
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
                                    height: height / height70,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width / width20,
                                        vertical: height / height11),
                                    margin:
                                        EdgeInsets.only(top: height / height10),
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
                                              child: Container(
                                                height: height / height30,
                                                width: width / width30,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: color2,
                                                ),
                                                child: Icon(
                                                  Icons.done,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: width / width20,
                                            ),
                                            InterRegular(
                                              text: checkpoint
                                                  .title, //Subcheckpoint
                                              color: color17,
                                              fontsize: width / width18,
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
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
                                                  size: width / width24,
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  )),
              SizedBox(
                height: height / height10,
              ),
              _expand
                  ? Button1(
                      text: 'END',
                      backgroundcolor: colorRed2,
                      color: Colors.redAccent,
                      borderRadius: 10,
                      onPressed: () {},
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}

// Define your data classes here
class Patrol {
  final String title;
  final String description;
  final List<Category> categories;

  Patrol(
      {required this.title,
      required this.description,
      required this.categories});
}

class Category {
  final String title;
  final List<Checkpoint> checkpoints;

  Category({required this.title, required this.checkpoints});
}

class Checkpoint {
  final String title;
  final String description;
  final String id;

  Checkpoint(
      {required this.title, required this.description, required this.id});
}

final List<Patrol> patrolsData = [];
