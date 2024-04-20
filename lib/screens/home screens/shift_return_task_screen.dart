import 'package:flutter/material.dart';
import 'package:tact_tik/common/enums/shift_task_enums.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
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
  void initState() {
    fetchData();
  }

  int completedTaskCount = 0;
  int totalTaskCount = 0;
  List<Map<String, dynamic>>? fetchedTasks = [];
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
            },
          ),
          title: InterRegular(
            text: "Return Shift Task",
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
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
                  height: height / height60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InterBold(
                        text: "${widget.ShiftName}",
                        fontsize: width / width18,
                        color: Primarycolor,
                      ),
                      InterBold(
                        text: '$completedTaskCount/$totalTaskCount',
                        fontsize: width / width18,
                        color: Primarycolor,
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
                      final shiftTaskStatus = task['ShiftTaskStatus'] ?? [];
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
                            filteredStatus.first['ShiftTaskReturnStatus'] ??
                                false;
                        // print("Task Completion Status : - ${taskStatus}");
                      }
                    }

                    return ShiftTaskTypeWidget(
                      type: taskType ?? ShiftTaskEnum.upload,
                      taskName: fetchedTasks?[index]['ShiftTask'] ?? "",
                      taskId: fetchedTasks?[index]['ShiftTaskId'] ?? "",
                      ShiftId: widget.shiftId ?? "",
                      taskStatus: taskStatu ?? "",
                      EmpID: widget.Empid ?? "",
                      shiftReturnTask: true,
                      refreshDataCallback: _refreshData,
                      EmpName: widget.EmpName,
                      ShiftTaskReturnStatus: ShiftTaskReturnStatus ??
                          false, // Default to upload if taskType is null
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
