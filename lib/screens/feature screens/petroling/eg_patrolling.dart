import 'package:flutter/material.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import '../../home screens/widgets/icon_text_widget.dart';

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Patrols'),
//       ),
//       body: MyPatrolsList(),
//     );
//   }
// }

class MyPatrolsList extends StatefulWidget {
  @override
  State<MyPatrolsList> createState() => _MyPatrolsListState();
}

class _MyPatrolsListState extends State<MyPatrolsList> {
  // bool _expand = false;
  // bool _expand2 = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    int? clickedIIndex;

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
                childCount: patrolsData.length,
                (context, index) {
                  Patrol p = patrolsData[index];
                  return PatrollingWidget(p: p,);
                },
              )),
              /*ListView.builder(
                itemCount: patrolsData.length,
                itemBuilder: (context, index) {
                  Patrol p = patrolsData[index];
                  return;
                },
              ),*/
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
    _expandCategoryMap = {};
  }


  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InterBold(
          text: 'Today',
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
                    vertical: height / height20),
                child: Column(
                  children: [
                    SizedBox(height: height / height5),
                    IconTextWidget(
                      iconSize: width / width24,
                      icon: Icons.location_on,
                      text: 'movie.patrolArea',
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
                      text: 'movie.patrolTime',
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
                Visibility(visible: _expand,
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.p.categories.map((category) {
                    print("_expandCategoryMap: $_expandCategoryMap");
                    final expand = _expandCategoryMap[category.title] ?? false;
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Handle tap action to expand checkpoints
                            // Toggle visibility of checkpoints associated with this category
                            setState(() {
                              _expandCategoryMap[category.title] = !_expandCategoryMap[category.title]!;
                              // _expand2 = !_expand2;
                            });
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
                                      child: /*Center(
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
                                                        )*/
                                      Icon(
                                        Icons.home_sharp,
                                        size: width / width24,
                                        color: Primarycolor,
                                      ),

                                      /*Container(
                                                    height: height / height30,
                                                    width: width / width30,
                                                    decoration: BoxDecoration(
                                                      // shape: BoxShape.circle,
                                                      color: color2,
                                                    ),
                                                    child: Icon(
                                                      Icons.home_rounded,
                                                      color: Primarycolor,
                                                    ),
                                                  ),*/
                                    ),
                                    SizedBox(
                                      width: width / width20,
                                    ),
                                    InterRegular(
                                      text: 'Exterior',
                                      color: color17,
                                      fontsize: width / width18,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _expandCategoryMap[category.title] = !_expandCategoryMap[category.title]!;
                                    });
                                  },
                                  icon: Icon(
                                    expand ? Icons.arrow_circle_up_outlined : Icons.arrow_circle_down_outlined,
                                    size: width / width24,
                                    color: Primarycolor,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible:  expand,
                          // Set to a variable to toggle visibility
                          child: Column(
                            children: category.checkpoints
                                .map((checkpoint) {
                              return Container(
                                height: height / height70,
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / width20,
                                    vertical: height / height11),
                                margin: EdgeInsets.only(
                                    top: height / height10),
                                decoration: BoxDecoration(
                                  color: color15,
                                  borderRadius:
                                  BorderRadius.circular(
                                      width / width10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height:
                                          height / height48,
                                          width: width / width48,
                                          decoration:
                                          BoxDecoration(
                                            color: color16,
                                            borderRadius:
                                            BorderRadius
                                                .circular(width /
                                                width10),
                                          ),
                                          child: /*Center(
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
                                                      )*/
                                          Container(
                                            height:
                                            height / height30,
                                            width:
                                            width / width30,
                                            decoration:
                                            BoxDecoration(
                                              shape:
                                              BoxShape.circle,
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
                                          text: 'name',
                                          color: color17,
                                          fontsize:
                                          width / width18,
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
                                              builder:
                                                  (BuildContext
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
                                                        onPressed:
                                                            () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                            "Cancel")),
                                                    TextButton(
                                                      onPressed:
                                                          () {
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
                                            print(
                                                "Info Icon Pressed");
                                          },
                                          icon: Icon(
                                            Icons.info,
                                            color: color18,
                                            size: width / width24,
                                          ),
                                          padding:
                                          EdgeInsets.zero,
                                        ),
                                      ),
                                    )
                                  ],
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
                /*onPressed: () async {
                                          if (movie.PatrolRequiredCount ==
                                              movie.PatrolCompletedCount) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'End Patrolling',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  content: Text(
                                                    'Do you want to end patrolling',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        fireStoreService
                                                            .EndPatrol(
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
                                                          movie
                                                              .patrolLocationName,
                                                          movie.BranchId,
                                                          movie.patrolId,
                                                          widget.EmployeeEmail,
                                                          // movie.s
                                                        );

                                                        Navigator.of(context)
                                                            .pop();
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
                                                builder:
                                                    (BuildContext context) {
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
                                        },*/
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

  Checkpoint({required this.title, required this.description});
}

final List<Patrol> patrolsData = [
  Patrol(
    title: 'Patrol 1',
    description: 'Description of Patrol 1',
    categories: [
      Category(
        title: 'Category 1',
        checkpoints: [
          Checkpoint(
              title: 'Checkpoint 1',
              description: 'Description of Checkpoint 1'),
          Checkpoint(
              title: 'Checkpoint 2',
              description: 'Description of Checkpoint 2'),
        ],
      ),
      Category(
        title: 'Category 2',
        checkpoints: [
          Checkpoint(
              title: 'Checkpoint 3',
              description: 'Description of Checkpoint 3'),
          Checkpoint(
              title: 'Checkpoint 4',
              description: 'Description of Checkpoint 4'),
        ],
      ),
    ],
  ),
  Patrol(
    title: 'Patrol 1',
    description: 'Description of Patrol 1',
    categories: [
      Category(
        title: 'Category 1',
        checkpoints: [
          Checkpoint(
              title: 'Checkpoint 1',
              description: 'Description of Checkpoint 1'),
          Checkpoint(
              title: 'Checkpoint 2',
              description: 'Description of Checkpoint 2'),
        ],
      ),
      Category(
        title: 'Category 2',
        checkpoints: [
          Checkpoint(
              title: 'Checkpoint 3',
              description: 'Description of Checkpoint 3'),
          Checkpoint(
              title: 'Checkpoint 4',
              description: 'Description of Checkpoint 4'),
        ],
      ),
    ],
  ),
  // Add more patrols as needed
];
