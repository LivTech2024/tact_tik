import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/enums/shift_task_enums.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/shift_task_type_widget.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../common/sizes.dart';
import '../../fonts/inter_regular.dart';
import '../../utils/colors.dart';

class ShiftTaskScreen extends StatefulWidget {
  final String shiftId;
  final String EmpId;
  final String Name;
  final String EmpName;
  const ShiftTaskScreen(
      {super.key,
      required this.shiftId,
      required this.Name,
      required this.EmpId,
      required this.EmpName});

  @override
  State<ShiftTaskScreen> createState() => _ShiftTaskScreenState();
}

class _ShiftTaskScreenState extends State<ShiftTaskScreen> {
  FireStoreService fireStoreService = FireStoreService();
  int completedTaskCount = 0;
  int totalTaskCount = 0;
  List<Map<String, dynamic>>? fetchedTasks = [];
  List<TextEditingController> commentControllers = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in commentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void fetchData() async {
    List<Map<String, dynamic>>? fetchedData =
        await fireStoreService.fetchShiftTask(widget.shiftId);
    if (fetchedData != null) {
      setState(() {
        fetchedTasks = fetchedData;
        print("Fetched Shift Tasks  ${fetchedData}");
      });
      int completedTaskCount = 0;
      int totalTaskCount = 0;

      // Initialize controllers for each task with existing comments if available
      commentControllers = List.generate(fetchedData.length, (index) {
        final task = fetchedData[index];
        final taskStatusList = task['ShiftTaskStatus'] ?? [];
        final filteredStatus = taskStatusList
            .where((status) => status['TaskCompletedById'] == widget.EmpId)
            .toList();
        String commentText = "";
        if (filteredStatus.isNotEmpty) {
          commentText = filteredStatus.first['TaskComment'] ?? "";
        }
        return TextEditingController(text: commentText);
      });

      for (int i = 0; i < fetchedData.length; i++) {
        final task = fetchedData[i];
        if (task.containsKey('ShiftTaskStatus') &&
            task['ShiftTaskStatus'] is List &&
            task['ShiftTaskStatus'].isNotEmpty &&
            task['ShiftTaskStatus'][0].containsKey('TaskStatus') &&
            task['ShiftTaskStatus'][0]['TaskStatus'] == 'completed') {
          completedTaskCount++;
        }
        totalTaskCount++;
      }

      setState(() {
        this.completedTaskCount = completedTaskCount;
        this.totalTaskCount = totalTaskCount;
      });
      if (completedTaskCount == totalTaskCount) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }

      print(fetchedData);
    } else {
      print('No tasks fetched');
    }
  }

  Future<void> _refreshData() async {
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
          title: InterMedium(
            text: "${widget.Name}",
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width / width30,
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 60.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InterBold(
                          text: '',
                          fontsize: 18.sp,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                        InterBold(
                          text: '$completedTaskCount/$totalTaskCount',
                          fontsize: 18.sp,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      ShiftTaskEnum? taskType;
                      String? taskStatu;
                      bool ShiftTaskReturnStatus = false;
                      if (fetchedTasks != null &&
                          index < fetchedTasks!.length) {
                        final task = fetchedTasks![index];
                        if (task.containsKey('ShiftTaskQrCodeReq') &&
                            task['ShiftTaskQrCodeReq']) {
                          taskType = ShiftTaskEnum.upload;
                        } else {
                          taskType = ShiftTaskEnum.upload;
                        }

                        print("Shift Task Status Filtering  : ${task}");
                        final shiftTaskStatus = task['ShiftTaskStatus'] ?? [];
                        final filteredStatus = shiftTaskStatus
                            .where((status) =>
                                status['TaskCompletedById'] == widget.EmpId)
                            .toList();
                        print(
                            "Task FilteredStatus Status : - ${filteredStatus}");

                        if (filteredStatus.isNotEmpty) {
                          taskStatu = filteredStatus.first['TaskStatus'];
                          ShiftTaskReturnStatus =
                              filteredStatus.first['ShiftTaskReturnStatus'] ??
                                  false;
                        }
                        print("Task Completion Status : - ${taskStatu}");
                      }
                      print(fetchedTasks?[index]?['ShiftTaskStatus']);
                      List<String> taskPhotos = [];
                      String commentText = "";
                      if (fetchedTasks?[index]?['ShiftTaskStatus'] != null) {
                        List taskStatusList =
                            fetchedTasks?[index]?['ShiftTaskStatus'];
                        if (taskStatusList.isNotEmpty) {
                          Map taskStatusMap = taskStatusList[0];
                          if (taskStatusMap.containsKey('TaskPhotos')) {
                            taskPhotos =
                                List<String>.from(taskStatusMap['TaskPhotos']);
                          }
                          if (taskStatusMap.containsKey("TaskComment")) {
                            commentText = taskStatusMap['TaskComment'];
                          }
                        }
                      }

                      return ShiftTaskTypeWidget(
                        type: taskType ?? ShiftTaskEnum.upload,
                        taskName: fetchedTasks?[index]['ShiftTask'] ?? "",
                        taskId: fetchedTasks?[index]['ShiftTaskId'] ?? "",
                        ShiftId: widget.shiftId,
                        taskStatus: taskStatu ?? "",
                        EmpID: widget.EmpId,
                        shiftReturnTask: false,
                        refreshDataCallback: _refreshData,
                        EmpName: widget.EmpName,
                        ShiftTaskReturnStatus: ShiftTaskReturnStatus,
                        taskPhotos: taskPhotos,
                        commentController: commentControllers[index],
                      );
                    },
                    childCount: fetchedTasks?.length ?? 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
