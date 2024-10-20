import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/enums/shift_task_enums.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/screens/home%20screens/widgets/shift_task_return_type_widget.dart';
import 'package:tact_tik/screens/home%20screens/widgets/shift_task_type_widget.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../common/sizes.dart';
import '../../fonts/inter_regular.dart';
import '../../utils/colors.dart';

class ShiftReturnTaskScreen extends StatefulWidget {
  final String shiftId;
  final String Empid;
  final String ShiftName;
  final String EmpName;

  const ShiftReturnTaskScreen(
      {super.key,
      required this.shiftId,
      required this.Empid,
      required this.ShiftName,
      required this.EmpName});

  @override
  State<ShiftReturnTaskScreen> createState() => _ShiftTaskReturnScreenState();
}

class _ShiftTaskReturnScreenState extends State<ShiftReturnTaskScreen> {
  FireStoreService fireStoreService = FireStoreService();

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

  int completedTaskCount = 0;
  int totalTaskCount = 0;
  List<Map<String, dynamic>>? fetchedTasks = [];
  List<TextEditingController> commentControllers = [];
  void fetchData() async {
    List<Map<String, dynamic>>? fetchedData =
        await fireStoreService.fetchreturnShiftTasks(widget.shiftId);
    if (fetchedData != null) {
      setState(() {
        fetchedTasks = fetchedData;
        print("Fetched Shift Tasks  ${fetchedData}");
      });
      int completedTaskCount = 0;
      int totalTaskCount = 0;
      commentControllers = List.generate(fetchedData.length, (index) {
        final task = fetchedData[index];
        final taskStatusList = task['ShiftReturnTaskStatus'] ?? [];
        final filteredStatus = taskStatusList
            .where((status) => status['TaskCompletedById'] == widget.Empid)
            .toList();
        String commentText = "";
        if (filteredStatus.isNotEmpty) {
          commentText = filteredStatus.first['TaskComment'] ?? "";
        }
        return TextEditingController(text: commentText);
      });
      for (int i = 0; i < fetchedData.length; i++) {
        final task = fetchedData[i];
        if (task.containsKey('ShiftReturnTaskStatus') &&
            task['ShiftReturnTaskStatus'] is List &&
            task['ShiftReturnTaskStatus'].isNotEmpty &&
            task['ShiftReturnTaskStatus'][0].containsKey('TaskStatus') &&
            task['ShiftReturnTaskStatus'][0]['TaskStatus'] == 'completed') {
          completedTaskCount++;
        }
        totalTaskCount++;
      }

      setState(() {
        this.completedTaskCount = completedTaskCount;
        this.totalTaskCount = totalTaskCount;
      });
      if (completedTaskCount == totalTaskCount) {
        // Navigator.pop(context); // Pop the screen if all tasks are completed
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
              Navigator.pop(context);
            },
          ),
          title: InterMedium(
            text: "Return Shift Task",
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width / width30,
            // vertical: height / height30,
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 60.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: width / width280,
                        child: InterBold(
                          text: "${widget.ShiftName}",
                          fontsize: width / width18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      InterBold(
                        text: '$completedTaskCount/$totalTaskCount',
                        fontsize: width / width18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Assuming your data structure is correct, extract the ShiftTaskEnum for each task
                    ShiftTaskEnum? taskType;
                    String? taskStatu;
                    bool ShiftTaskReturnStatus = false;
                    if (fetchedTasks != null && index < fetchedTasks!.length) {
                      final task = fetchedTasks![index];
                      if (task.containsKey('ShiftTaskQrCodeReq') &&
                          task['ShiftTaskQrCodeReq']) {
                        taskType = ShiftTaskEnum.upload;
                      } else {
                        taskType = ShiftTaskEnum.upload;
                      }
                      final shiftTaskStatus =
                          task['ShiftReturnTaskStatus'] ?? [];
                      final filteredStatus = shiftTaskStatus
                          .where((status) =>
                              status['TaskCompletedById'] == widget.Empid)
                          .toList();
                      print("Task FilteredStatus Status : - ${filteredStatus}");

                      // Extract TaskStatus if document is present
                      if (filteredStatus.isNotEmpty) {
                        taskStatu =
                            filteredStatus.first['TaskStatus'] ?? "unchecked";
                        ShiftTaskReturnStatus =
                            filteredStatus.first['ShiftReturnTaskStatus'] ??
                                false;
                        // print("Task Completion Status : - ${taskStatus}");
                      }
                    }
                    List<String> taskPhotos = [];
                    String commentText = "";
                    if (fetchedTasks?[index]?['ShiftReturnTaskStatus'] !=
                        null) {
                      List taskStatusList =
                          fetchedTasks?[index]?['ShiftReturnTaskStatus'];
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

                    return ShiftTaskReturnTypeWidget(
                      type: taskType ?? ShiftTaskEnum.upload,
                      taskName: fetchedTasks?[index]['ShiftTask'] ?? "",
                      taskId: fetchedTasks?[index]['ShiftTaskId'] ?? "",
                      ShiftId: widget.shiftId ?? "",
                      taskStatus: taskStatu ?? "",
                      EmpID: widget.Empid ?? "",
                      shiftReturnTask: true,
                      refreshDataCallback: _refreshData,
                      EmpName: widget.EmpName,
                      ShiftTaskReturnStatus: ShiftTaskReturnStatus ?? false,
                      taskPhotos: taskPhotos,
                      commentController: commentControllers[
                          index], // Default to upload if taskType is null
                    );
                  },
                  childCount: fetchedTasks?.length ?? 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
