import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:toastification/toastification.dart';

import '../../common/sizes.dart';
import '../../fonts/inter_bold.dart';
import '../../fonts/inter_regular.dart';
import '../../services/EmailService/EmailJs_fucntion.dart';
import '../../utils/colors.dart';
import '../feature screens/widgets/custome_textfield.dart';
import '../home screens/widgets/icon_text_widget.dart';

class PatrollLogsScreen extends StatefulWidget {
  const PatrollLogsScreen({super.key});

  @override
  State<PatrollLogsScreen> createState() => _PatrollLogsScreenState();
}

class _PatrollLogsScreenState extends State<PatrollLogsScreen> {
  String dropdownValue = 'PatrolLogStatus';
  late List<Patrol> patrolsData = [];
  final TextEditingController PatrollId = TextEditingController();
  final TextEditingController PatrolLogCreateAt = TextEditingController();
  final TextEditingController PatrolLogEndedAt = TextEditingController();
  final TextEditingController PatrolLogFeedbackComment =
      TextEditingController();
  final TextEditingController PatrolLogGuardId = TextEditingController();
  final TextEditingController PatrolLogGuardName = TextEditingController();
  final TextEditingController PatrolLogId = TextEditingController();
  final TextEditingController PatrolLogPatrolCount = TextEditingController();
  final TextEditingController PatrolLogStartedAt = TextEditingController();
  void _getUserInfo() async {
    // print("Shift Id : ${widget.ShiftLocationId}");
    var patrolInfoList =
        await fireStoreService.getAllPatrolsByShiftId("TsuGzh56RZWYhFsmvmUU");

    List<Patrol> patrols = [];
    for (var patrol in patrolInfoList) {
      Map<String, dynamic> data = patrol as Map<String, dynamic>;
      String patrolCompanyId = data['PatrolCompanyId'];
      String patrolLocationName = data['PatrolLocationName'];
      String patrolName = data['PatrolName'];
      String patrolId = data['PatrolId'];
      String patrolClientId = data['PatrolClientId'];
      // String patrolTime = data['PatrolTime'];
      int requiredCount = data['PatrolRequiredCount'];
      List<dynamic>? patrolStatusDynamic =
          data['PatrolCurrentStatus'] is List<dynamic>
              ? data['PatrolCurrentStatus'] as List<dynamic>?
              : null;
      if (patrolStatusDynamic != null) {
        List<Map<String, dynamic>> patrolStatus =
            patrolStatusDynamic.cast<Map<String, dynamic>>();

        int getCompletedCount(
            List<Map<String, dynamic>> patrolCurrentStatus, String emplid) {
          List<Map<String, dynamic>> statusList =
              patrolCurrentStatus.cast<Map<String, dynamic>>();

          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);

          bool _isSameDay(DateTime date1, DateTime date2) {
            return date1.year == date2.year &&
                date1.month == date2.month &&
                date1.day == date2.day;
          }

          DateTime _parseTimestamp(Timestamp timestamp) {
            return timestamp.toDate();
          }

          List<Map<String, dynamic>> filteredStatusList = patrolCurrentStatus
              .where((status) =>
                  status['StatusReportedById'] == emplid &&
                  status['StatusReportedTime'] != null &&
                  _isSameDay(
                      _parseTimestamp(status['StatusReportedTime']), today))
              .toList();

          int completedCount = filteredStatusList.fold(
              0,
              (sum, status) =>
                  sum + (status['StatusCompletedCount'] as int? ?? 0));
          return completedCount;
        }

        int completedCount = getCompletedCount(patrolStatus, "");
        setState(() {
          // totalCount = completedCount;
        });

        print('Completed count for : $completedCount');
      } else {
        print('Patrol status is null or not a List<dynamic>');
      }

      setState(() {
        // _PatrolId = patrolId;
      });
      List<Category> categories = [];
      bool allChecked = false;
      for (var checkpoint in data['PatrolCheckPoints']) {
        String checkpointCategory = checkpoint['CheckPointCategory'] ?? "";
        String checkpointId = checkpoint['CheckPointId'];
        String checkpointName = checkpoint['CheckPointName'];

        List<CheckPointStatus> checkPointStatuses =
            (checkpoint['CheckPointStatus'] as List<dynamic> ?? [])
                .map((status) {
          List<dynamic> checkPointStatuses =
              checkpoint['CheckPointStatus'] ?? [];
          if (checkPointStatuses == null ||
              checkPointStatuses.isEmpty ||
              checkPointStatuses.any((status) =>
                  status['Status'] == 'unchecked' &&
                  status['StatusReportedById'] == "") ||
              checkPointStatuses.any((status) =>
                  status['Status'] != 'unchecked' &&
                  checkPointStatuses
                      .every((s) => s['StatusReportedById'] != ""))) {
            setState(() {
              allChecked =
                  false; // At least one checkpoint is not checked or does not have the specified 'empid'
            });
          } else {
            setState(() {
              allChecked =
                  true; // All checkpoints have at least one status and all statuses are checked
            });
          }
          // ... rest of the code
          //  List<Map<String, dynamic>> filteredStatusList = statusList
          // .where((status) => status['StatusReportedById'] == emplid)
          // .toList();
          return CheckPointStatus(
            status: status['Status'],
            StatusCompletedCount: status['StatusCompletedCount'],
            reportedTime: status['StatusReportedTime'],
            reportedById: status['StatusReportedById'],
            reportedByName: status['StatusReportedByName'],
          );
        }).toList();
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
          checkPointStatus: checkPointStatuses,
          patrolId: patrolId,
        ));
      }

      patrols.add(
        Patrol(
          title: patrolName,
          description: patrolLocationName,
          categories: categories,
          // time: patrolTime,
          PatrolId: patrolId,
          EmpId: "",
          EmployeeName: "",
          PatrolRequiredCount: requiredCount,
          CompletedCount: 0,
          Allchecked: allChecked,
          PatrolCompanyID: patrolCompanyId,
          PatrolClientID: patrolClientId,
          ShiftDate: "",
          // ShiftId: widget.ShiftId,
        ),
      );
    }

    setState(() {
      patrolsData = patrols;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
             
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  
                ),
                padding: EdgeInsets.only(left: width / width20),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigtor debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterMedium(
                text: 'Patrolling',
             
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: height / height30,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  children: [
                    CustomeTextField(
                      hint: 'Patroll ID',
                      controller: PatrollId,
                    ),
                    Button1(
                      backgroundcolor: isDark?DarkColor.Primarycolor:LightColor.Primarycolor,
                      color: isDark?DarkColor.color1:LightColor.color1,
                      text: "Submit", onPressed: _getUserInfo,),
                    SizedBox(height: height / height10),

                    CustomeTextField(
                      hint: 'PatrolLogCreateAt',
                      controller: PatrolLogCreateAt,
                    ),
                    SizedBox(height: height / height10),
                    CustomeTextField(
                      hint: 'PatrolLogEndedAt',
                      controller: PatrolLogEndedAt,
                    ),
                    SizedBox(height: height / height10),
                    CustomeTextField(
                      hint: 'PatrolLogFeedbackComment',
                      controller: PatrolLogFeedbackComment,
                    ),
                    SizedBox(height: height / height10),
                    CustomeTextField(
                      hint: 'PatrolLogGuardId',
                      controller: PatrolLogGuardId,
                    ),
                    SizedBox(height: height / height10),
                    CustomeTextField(
                      hint: 'PatrolLogGuardName',
                      controller: PatrolLogGuardName,
                    ),
                    SizedBox(height: height / height10),
                    CustomeTextField(
                      hint: 'PatrolLogId',
                      controller: PatrolLogId,
                    ),
                    SizedBox(height: height / height10),
                    CustomeTextField(
                      hint: 'PatrolLogPatrolCount',
                      controller: PatrolLogPatrolCount,
                    ),
                    SizedBox(height: height / height10),
                    CustomeTextField(
                      hint: 'PatrolLogStartedAt',
                      controller: PatrolLogStartedAt,
                    ),
                    SizedBox(height: height / height10),
                    Container(
                      height: height / height60,
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(width / width10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          iconSize: width / width24,
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(color: isDark?DarkColor.color2:LightColor.color3, fontSize: width / width20),
                          borderRadius: BorderRadius.circular(10),
                          value: dropdownValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                              // if (dropdownValue == 'Other') {
                              //   dropdownShoe = true;
                              // }  else{
                              //   dropdownShoe = false;
                              // }
                              // if (newValue == 'Other') {
                              // Perform any action needed when 'Other' is selected
                              // For example, show a dialog, navigate to another screen, etc.
                              // Here, we'll just print a debug message
                              print('Other selected');
                            });
                          },
                          items: <String?>[
                            'PatrolLogStatus',
                            'Completed',
                            'Started',
                          ].map<DropdownMenuItem<String>>((String? value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value ?? ''),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    // CustomeTextField(hint: 'PatrolLogStatus',),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  Patrol p = patrolsData[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / width30),
                    child: PatrollingWidget(p: p),
                  );
                },
                childCount: patrolsData.length,
              ),
            ),
          ],
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
  // bool _expand2 = false;
  late Map<String, bool> _expandCategoryMap;
  TextEditingController Controller = TextEditingController();
  TextEditingController CommentController = TextEditingController();
  bool buttonClicked = true;

  @override
  void initState() {
    super.initState();
    _loadShiftStartedState();
    // Initialize expand state for each category
    _expandCategoryMap = Map.fromIterable(widget.p.categories,
        key: (category) => category.title, value: (_) => false);
  }

  void _loadShiftStartedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // _expand = prefs.getBool('expand') ?? false;
    });
  }

  Future<void> _refreshData() async {
    // Fetch updated data

    setState(() {}); // Update the state to rebuild the widget
  }

  String Result = "";

  // Future<void> _refresh() async {
  //   widget.onRefresh();
  // }

  List<Map<String, dynamic>> uploads = [];

  void _deleteItem(int index) {
    uploads.removeAt(index);
  }

  Future<void> _addImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
    }
    print("Statis ${uploads}");
  }

  Future<void> _addGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // await fireStoreService
      //     .addImageToStorageShiftTask(File(pickedFile.path));
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AudioPlayer player = new AudioPlayer();
    bool buttonEnabled = true;
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    bool startTimeUpdated = false;
    bool _isLoading = false;
    double completionPercentage =
        widget.p.CompletedCount / widget.p.PatrolRequiredCount;
    String StartTime;
    void showSuccessToast(BuildContext context, String message) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        title: Text(message),
        autoCloseDuration: const Duration(seconds: 2),
      );
    }

/*    void handleStartButton() async {
      print("ButtonEnabled : ${buttonEnabled}");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // setState(() {
      //   StartTime = DateTime.now();
      //   _expand = true;
      //   prefs.setBool("expand", _expand);
      // });
      if (buttonEnabled &&
          !_expand &&
          widget.p.CompletedCount < widget.p.PatrolRequiredCount) {
        setState(() {
          buttonEnabled = false; // Disable the button
        });
        await fireStoreService.addToLog(
            "PatrolStarted",
            "",
            "",
            Timestamp.now(),
            Timestamp.now(),
            widget.p.EmpId,
            widget.p.EmployeeName,
            widget.p.PatrolCompanyID,
            "",
            widget.p.PatrolClientID);
        await fireStoreService.updatePatrolCurrentStatusToUnchecked(
          widget.p.PatrolId,
          "started",
          widget.p.EmpId,
          widget.p.EmployeeName,
        );
        DateTime now = DateTime.now();
        String formattedTime = DateFormat('HH:mm:ss').format(now);
        setState(() {
          StartTime = formattedTime;
          // _expand = true;
          prefs.setBool("expand", _expand);
          prefs.setString("StartTime", StartTime.toString());
        });

        _refresh();
        showSuccessToast(context, "Patrol Started");
      } else if (widget.p.CompletedCount == widget.p.PatrolRequiredCount) {
        setState(() {
          buttonEnabled = false;
        });
        return null;
      } else {
        return null;
      }
    }*/

    void showErrorToast(BuildContext context, String message) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: Text(message),
        autoCloseDuration: const Duration(seconds: 2),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterBold(
            text: "Today",
            fontsize: width / width18,
            color: isDark?DarkColor.color1:LightColor.color3, 
          ),
          SizedBox(height: height / height30),
          AnimatedContainer(
            margin: EdgeInsets.only(bottom: height / height30),
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(width / width10),
            ),
            constraints: BoxConstraints(),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width / width120,
                            child: InterBold(
                              text: 'Patrol   ${widget.p.title}',
                              color:  isDark?DarkColor.  Primarycolor:LightColor.color3,
                              fontsize: width / width14,
                              maxLine: 1,
                            ),
                          ),
                          CircularPercentIndicator(
                            radius: width / width10,
                            lineWidth: 3,
                            percent: completionPercentage.clamp(0.0, 1.0),
                            progressColor: isDark
                                ? DarkColor.Primarycolor
                                : LightColor.Primarycolor,
                          ),
                        ],
                      ),
                      SizedBox(height: height / height10),
                      IconTextWidget(
                        iconSize: width / width24,
                        icon: Icons.location_on,
                        text: widget.p.title,
                        useBold: false,
                        color:  Theme.of(context).textTheme.headlineMedium!.color as Color,
                      ),
                      SizedBox(height: height / height16),
                      Divider(
                        color: isDark
                            ? DarkColor.Primarycolor
                            : LightColor.Primarycolor,
                      ),
                      SizedBox(height: height / height5),
                      IconTextWidget(
                        iconSize: width / width24,
                        icon: Icons.description,
                        text: widget.p.description,
                        useBold: false,
                        color: Theme.of(context).textTheme.headlineMedium!.color as Color,
                      ),
                      SizedBox(height: height / height16),
                      Divider(
                        color: isDark
                            ? DarkColor.Primarycolor
                            : LightColor.Primarycolor,
                      ),
                      SizedBox(height: height / height5),
                      IconTextWidget(
                        iconSize: width / width24,
                        icon: Icons.qr_code_scanner,
                        text:
                            'Total  ${widget.p.PatrolRequiredCount}  Completed ${widget.p.CompletedCount}',
                        useBold: false,
                        color: Theme.of(context).textTheme.headlineMedium!.color as Color,
                      ),
                      SizedBox(height: height / height20),
                    ],
                  ),
                ),
                Visibility(
                    visible: true,
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
                                  color: isDark
                                      ? DarkColor.color15
                                      : LightColor.color1,
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
                                            color: isDark
                                                ? DarkColor.Primarycolorlight
                                                : LightColor.Primarycolorlight,
                                            borderRadius: BorderRadius.circular(
                                                width / width10),
                                          ),
                                          child: Icon(
                                            Icons.home_sharp,
                                            size: width / width24,
                                            color: isDark
                                                ? DarkColor.Primarycolor
                                                : LightColor.Primarycolor,
                                          ),
                                        ),
                                        SizedBox(
                                          width: width / width20,
                                        ),
                                        SizedBox(
                                          width: width / width190,
                                          child: InterRegular(
                                            text: category.title,
                                            color:  Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .color,
                                            fontsize: width / width18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _expandCategoryMap[category.title] !=
                                              _expandCategoryMap[
                                                  category.title];
                                        });
                                      },
                                      icon: Icon(
                                        expand
                                            ? Icons.arrow_circle_up_outlined
                                            : Icons.arrow_circle_down_outlined,
                                        size: width / width24,
                                        color: isDark
                                            ? DarkColor.Primarycolor
                                            : LightColor.Primarycolor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: true,
                              child: Column(
                                children:
                                    category.checkpoints.map((checkpoint) {
                                  return GestureDetector(
                                    onTap: () async {
                                      if (checkpoint.getFirstStatus(
                                                  widget.p.EmpId) ==
                                              'unchecked' ||
                                          checkpoint.getFirstStatus(
                                                  widget.p.EmpId) ==
                                              null) {
                                        var res = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SimpleBarcodeScannerPage(),
                                            ));
                                        setState(() {
                                          Result = res;
                                        });
                                        // if (Result) {
                                        player.play(AssetSource(
                                            "../../../../assets/SuccessSound.mpeg"));
                                        print(res);
                                        if (res == checkpoint.id) {
                                          await fireStoreService
                                              .updatePatrolsStatus(
                                                  checkpoint.patrolId,
                                                  checkpoint.id,
                                                  widget.p.EmpId,
                                                  widget.p.PatrolId);
                                          // await fireStoreService.addToLog(
                                          //     "check_point",
                                          //     "",
                                          //     "",
                                          //     widget.p.EmpId,
                                          //     widget.p.EmployeeName,
                                          //     widget.p.PatrolCompanyID,
                                          //     "",
                                          //     widget.p.PatrolClientID);
                                          showSuccessToast(context,
                                              "${checkpoint.description} scanned ");
                                          // _refresh();
                                        } else {
                                          // _refresh();
                                          // player.play(AssetSource(
                                          //     "../../../../assets/ErrorSound.mp3"));
                                          showErrorToast(context,
                                              "${checkpoint.description} scanned unsuccessfull");
                                        }
                                      } else {
                                        // player.play(AssetSource(
                                        //     "../../../../assets/ErrorSound.mp3"));
                                        showErrorToast(
                                            context, "Already Scanned");
                                      }
                                      // }
                                    },
                                    child: Container(
                                      height: height / height70,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width / width20,
                                        vertical: height / height11,
                                      ),
                                      margin: EdgeInsets.only(
                                          top: height / height10),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? DarkColor.color15
                                            : LightColor.WidgetColor,
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
                                                  color: isDark
                                                      ? DarkColor.color16
                                                      : LightColor.color1,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          width / width10),
                                                ),
                                                child: Container(
                                                  height: height / height30,
                                                  width: width / width30,
                                                  decoration:
                                                       BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:  Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .color,
                                                  ),
                                                  child: Icon(
                                                    checkpoint.getFirstStatus(
                                                                widget
                                                                    .p.EmpId) ==
                                                            'checked'
                                                        ? Icons.done
                                                        : Icons.qr_code,
                                                    color: checkpoint
                                                                .getFirstStatus(
                                                                    widget.p
                                                                        .EmpId) ==
                                                            'checked'
                                                        ? Colors.green
                                                        : DarkColor
                                                            . Primarycolor,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: width / width20,
                                              ),
                                              SizedBox(
                                                width: width / width140,
                                                child: Column(
                                                  children: [
                                                    InterRegular(
                                                      text: checkpoint.title,
                                                      //Subcheckpoint
                                                      color:  Theme.of(context)
                                                          .textTheme
                                                          .displayMedium!
                                                          .color,
                                                      fontsize: width / width18,
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            height / height2),
                                                    InterRegular(
                                                      text: "",
                                                      color: isDark
                                                          ? DarkColor.Primarycolor
                                                          : LightColor.Primarycolor,
                                                      fontsize: width / width12,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  height: height / height34,
                                                  width: width / width34,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: DarkColor.color16,
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
                                                                'The scanned QR code does not work.',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
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
                                                                    setState(
                                                                        () {});
                                                                    /*Navigator.of(
                                                                              context)
                                                                          .pop();*/
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
                                                        color: DarkColor.color18,
                                                        size: width / width24,
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                  width / width8,
                                                ),
                                                child: Container(
                                                  height: height / height34,
                                                  width: width / width34,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: DarkColor.color16,
                                                  ),
                                                  child: Center(
                                                    child: IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title:
                                                                  InterRegular(
                                                                text:
                                                                    'Add Image/Comment',
                                                                color: DarkColor
                                                                    . color2,
                                                                fontsize:
                                                                    width /
                                                                        width12,
                                                              ),
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  CustomeTextField(
                                                                    hint:
                                                                        'Add Comment',
                                                                    showIcon:
                                                                        false,
                                                                    controller:
                                                                        Controller,
                                                                  ),
                                                                  SizedBox(
                                                                      height: height /
                                                                          height10),
                                                                  SingleChildScrollView(
                                                                    // Wrap the Row with SingleChildScrollView
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    // Set scroll direction to horizontal
                                                                    child: Row(
                                                                      children: [
                                                                        Row(
                                                                          children: uploads
                                                                              .asMap()
                                                                              .entries
                                                                              .map((entry) {
                                                                            final index =
                                                                                entry.key;
                                                                            final upload =
                                                                                entry.value;
                                                                            return Stack(
                                                                              clipBehavior: Clip.none,
                                                                              children: [
                                                                                Container(
                                                                                  height: height / height66,
                                                                                  width: width / width66,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Theme.of(context).cardColor,
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      width / width10,
                                                                                    ),
                                                                                  ),
                                                                                  margin: EdgeInsets.all(width / width8),
                                                                                  child: upload['type'] == 'image'
                                                                                      ? Image.file(
                                                                                          upload['file'],
                                                                                          fit: BoxFit.cover,
                                                                                        )
                                                                                      : Icon(
                                                                                          Icons.videocam,
                                                                                          size: width / width20,
                                                                                        ),
                                                                                ),
                                                                                Positioned(
                                                                                  top: -5,
                                                                                  right: -5,
                                                                                  child: IconButton(
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        _deleteItem(index);
                                                                                      });
                                                                                    },
                                                                                    icon: Icon(
                                                                                      Icons.delete,
                                                                                      color: Colors.black,
                                                                                      size: width / width20,
                                                                                    ),
                                                                                    padding: EdgeInsets.zero,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          }).toList(),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            print("Patrol Checkpoint Status ${widget.p.Allchecked}");
                                                                            Navigator.pop(context);
                                                                            showModalBottomSheet(
                                                                              context: context,
                                                                              builder: (context) => Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  ListTile(
                                                                                    leading: Icon(Icons.camera),
                                                                                    title: Text('Add Image'),
                                                                                    onTap: () {
                                                                                      _addImage();
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                  ),
                                                                                  ListTile(
                                                                                    leading: Icon(Icons.image),
                                                                                    title: Text('Add from Gallery'),
                                                                                    onTap: () {
                                                                                      Navigator.pop(context);
                                                                                      _addGallery();
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                height / height66,
                                                                            width:
                                                                                width / width66,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Theme.of(context).cardColor,
                                                                              borderRadius: BorderRadius.circular(width / width8),
                                                                            ),
                                                                            child:
                                                                                Center(
                                                                              child: Icon(
                                                                                Icons.add,
                                                                                size: width / width20,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      InterRegular(
                                                                    text:
                                                                        'Cancel',
                                                                    color:
                                                                       DarkColor
                                                                        . Primarycolor,
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      _isLoading =
                                                                          true;
                                                                    });
                                                                    // Logic to submit the report
                                                                    if (uploads
                                                                            .isNotEmpty ||
                                                                        Controller
                                                                            .text
                                                                            .isNotEmpty) {
                                                                      await fireStoreService.addImagesToPatrol(
                                                                          uploads,
                                                                          Controller
                                                                              .text,
                                                                          widget
                                                                              .p
                                                                              .PatrolId,
                                                                          widget
                                                                              .p
                                                                              .EmpId,
                                                                          checkpoint
                                                                              .id,
                                                                          widget
                                                                              .p
                                                                              .PatrolId);
                                                                      toastification
                                                                          .show(
                                                                        context:
                                                                            context,
                                                                        type: ToastificationType
                                                                            .success,
                                                                        title: Text(
                                                                            "Submitted"),
                                                                        autoCloseDuration:
                                                                            const Duration(seconds: 2),
                                                                      );
                                                                      // _refresh();
                                                                      setState(
                                                                          () {
                                                                        _isLoading =
                                                                            false;
                                                                      });
                                                                      uploads
                                                                          .clear();
                                                                      Controller
                                                                          .clear();

                                                                      Navigator.pop(
                                                                          context);
                                                                    } else {
                                                                      showErrorToast(
                                                                          context,
                                                                          "Fields cannot be empty");
                                                                    }
                                                                  },
                                                                  child: InterRegular(
                                                                      text:
                                                                          'Submit'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.add_circle,
                                                        color: DarkColor
                                                            . Primarycolor,
                                                        size: width / width24,
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (_isLoading)
                                                Container(
                                                  alignment: Alignment.center,
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                            ],
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Define your data classes here
class Patrol {
  final String title;
  final String description;

  // final String time;
  final String PatrolId;
  final String EmpId;
  final String PatrolCompanyID;
  final String PatrolClientID;

  final String EmployeeName;

  final int PatrolRequiredCount;
  final int CompletedCount;
  final bool Allchecked;
  final List<Category> categories;
  final String ShiftDate;

  Patrol({
    required this.title,
    required this.PatrolCompanyID,
    required this.PatrolClientID,
    required this.description,
    required this.categories,

    // required this.time,
    required this.PatrolId,
    required this.EmpId,
    required this.EmployeeName,
    required this.PatrolRequiredCount,
    required this.CompletedCount,
    required this.Allchecked,
    required this.ShiftDate,
  });
}

class Category {
  final String title;
  final List<Checkpoint> checkpoints;

  Category({required this.title, required this.checkpoints});
}

class Checkpoint {
  final String patrolId;
  final String title;
  final String description;
  final String id;
  final List<CheckPointStatus> checkPointStatus;

  Checkpoint({
    required this.title,
    required this.patrolId,
    required this.description,
    required this.id,
    required this.checkPointStatus,
  });

  bool isSameDay(Timestamp? timestamp1, Timestamp timestamp2) {
    if (timestamp1 == null) {
      return false; // or handle the case when timestamp1 is null
    }
    DateTime dateTime1 = timestamp1.toDate();
    DateTime dateTime2 = timestamp2.toDate();
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day;
  }

  String? getFirstStatus(String empId) {
    if (checkPointStatus.isNotEmpty) {
      for (var status in checkPointStatus) {
        if (status.reportedById == empId &&
            isSameDay(status.reportedTime, Timestamp.now())) {
          return status.status;
        }
      }
    }
    return null;
  }
}

class CheckPointStatus {
  final String status;
  final String? reportedById;
  final String? reportedByName;
  final Timestamp? reportedTime;
  final String? failureReason;
  final int? StatusCompletedCount;

  CheckPointStatus({
    required this.status,
    this.reportedById,
    this.reportedByName,
    this.reportedTime,
    this.failureReason,
    this.StatusCompletedCount,
  });
}

final List<Patrol> patrolsData = [];
