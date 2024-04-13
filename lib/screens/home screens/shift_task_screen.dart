import 'package:flutter/material.dart';
import 'package:tact_tik/common/enums/shift_task_enums.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
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
  const ShiftTaskScreen(
      {super.key,
      required this.shiftId,
      required this.Name,
      required this.EmpId});

  @override
  State<ShiftTaskScreen> createState() => _ShiftTaskScreenState();
}

class _ShiftTaskScreenState extends State<ShiftTaskScreen> {
  FireStoreService fireStoreService = FireStoreService();
  void initState() {
    fetchData();
  }

  int completedTaskCount = 0;
  int totalTaskCount = 0;
  List<Map<String, dynamic>>? fetchedTasks = [];
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
    // Fetch patrol data from Firestore (assuming your logic exists)
    // var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
    // ... (existing data fetching logic based on user ID)

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
            text: "${widget.Name}",
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
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
                          text: '',
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
                        // Filter ShiftTaskStatus by TaskCompletedById
                        final shiftTaskStatus = task['ShiftTaskStatus'] ?? [];
                        final filteredStatus = shiftTaskStatus
                            .where((status) =>
                                status['TaskCompletedById'] == widget.EmpId)
                            .toList();
                        print(
                            "Task FilteredStatus Status : - ${filteredStatus}");

                        // Extract TaskStatus if document is present
                        if (filteredStatus.isNotEmpty) {
                          taskStatu = filteredStatus.first['TaskStatus'];

                          // print("Task Completion Status : - ${taskStatus}");
                        }
                        print("Task Completion Status : - ${taskStatu}");

                        // print("Task Completion Status : - ${taskStatu}");
                      }

                      return ShiftTaskTypeWidget(
                        type: taskType ?? ShiftTaskEnum.upload,
                        taskName: fetchedTasks?[index]['ShiftTask'] ?? "",
                        taskId: fetchedTasks?[index]['ShiftTaskId'] ?? "",
                        ShiftId: widget.shiftId ?? "",
                        taskStatus: taskStatu ?? "",
                        EmpID: widget.EmpId,
                        shiftReturnTask:
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
      ),
    );
  }
}
