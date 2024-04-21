import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/services/EmailService/EmailJs_fucntion.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:toastification/toastification.dart';
import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import '../../home screens/widgets/icon_text_widget.dart';
import '../widgets/custome_textfield.dart';

FireStoreService fireStoreService = FireStoreService();

class MyPatrolsList extends StatefulWidget {
  final String EmployeeID;
  final String ShiftLocationId;
  final String ShiftId;
  final String EmployeeName;
  final String ShiftDate;

  const MyPatrolsList(
      {required this.ShiftLocationId,
      required this.EmployeeID,
      required this.EmployeeName,
      required this.ShiftId,
      required this.ShiftDate});

  @override
  State<MyPatrolsList> createState() => _MyPatrolsListState();
}

class _MyPatrolsListState extends State<MyPatrolsList> {
  // late Map<String, dynamic> patrolsData = "";
  late List<Patrol> patrolsData = [];
  String _PatrolId = '';
  int totalCount = 0;
  bool buttonClicked = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _refreshData() async {
    _getUserInfo();
  }

  void _getUserInfo() async {
    print("Shift Id : ${widget.ShiftLocationId}");
    var patrolInfoList =
        await fireStoreService.getAllPatrolsByShiftId(widget.ShiftId);

    List<Patrol> patrols = [];
    for (var patrol in patrolInfoList) {
      Map<String, dynamic> data = patrol.data() as Map<String, dynamic>;
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

        int completedCount = getCompletedCount(patrolStatus, widget.EmployeeID);
        setState(() {
          totalCount = completedCount;
        });

        print('Completed count for : $completedCount');
      } else {
        print('Patrol status is null or not a List<dynamic>');
      }

      setState(() {
        _PatrolId = patrolId;
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
                  status['StatusReportedById'] == widget.EmployeeID) ||
              checkPointStatuses.any((status) =>
                  status['Status'] != 'unchecked' &&
                  checkPointStatuses.every(
                      (s) => s['StatusReportedById'] != widget.EmployeeID))) {
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
          PatrolId: _PatrolId,
          EmpId: widget.EmployeeID,
          EmployeeName: widget.EmployeeName,
          PatrolRequiredCount: requiredCount,
          CompletedCount: totalCount,
          Allchecked: allChecked,
          PatrolCompanyID: patrolCompanyId,
          PatrolClientID: patrolClientId, ShiftDate: widget.ShiftDate,
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
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            // physics: const PageScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: height / height30,
                ),
              ),
              SliverAppBar(
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
                    print(
                        "Navigtor debug: ${Navigator.of(context).toString()}");
                  },
                ),
                title: InterRegular(
                  text: 'Patrolling',
                  fontsize: width / width18,
                  color: Colors.white,
                  letterSpacing: -.3,
                ),
                centerTitle: true,
                floating: true, // Makes the app bar float above the content
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Patrol p = patrolsData[index];
                    return PatrollingWidget(p: p, onRefresh: _refreshData);
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
  const PatrollingWidget({super.key, required this.p, required this.onRefresh});

  final Patrol p;
  final VoidCallback onRefresh;

  @override
  State<PatrollingWidget> createState() => _PatrollingWidgetState();
}

class _PatrollingWidgetState extends State<PatrollingWidget> {
  bool _expand = false;

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
      _expand = prefs.getBool('expand') ?? false;
    });
  }

  Future<void> _refreshData() async {
    // Fetch updated data

    setState(() {}); // Update the state to rebuild the widget
  }

  String Result = "";

  Future<void> _refresh() async {
    widget.onRefresh();
  }

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

    void handleStartButton() async {
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
        await fireStoreService.updatePatrolCurrentStatus(
          widget.p.PatrolId,
          "started",
          widget.p.EmpId,
          widget.p.EmployeeName,
        );
        DateTime now = DateTime.now();
        String formattedTime = DateFormat('HH:mm:ss').format(now);
        setState(() {
          StartTime = formattedTime;
          _expand = true;
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
    }

    void showErrorToast(BuildContext context, String message) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: Text(message),
        autoCloseDuration: const Duration(seconds: 2),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: Column(
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
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: WidgetColor,
              borderRadius: BorderRadius.circular(width / width10),
            ),
            constraints: _expand
                ? BoxConstraints(minHeight: height / height200)
                : const BoxConstraints(),
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
                              color: Primarycolor,
                              fontsize: width / width14,
                              maxLine: 1,
                            ),
                          ),
                          CircularPercentIndicator(
                            radius: width / width10,
                            lineWidth: 3,
                            percent: completionPercentage.clamp(0.0, 1.0),
                            progressColor: Primarycolor,
                          ),
                        ],
                      ),
                      SizedBox(height: height / height10),
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
                        icon: Icons.description,
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
                        text:
                            'Total  ${widget.p.PatrolRequiredCount}  Completed ${widget.p.CompletedCount}',
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
                  onPressed: buttonClicked ? handleStartButton : () {},
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
                                        SizedBox(
                                          width: width / width190,
                                          child: InterRegular(
                                            text: category.title,
                                            color: color17,
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
                                        color: Primarycolor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: expand,
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
                                        print(res);
                                        if (res == checkpoint.id) {
                                          await fireStoreService
                                              .updatePatrolsStatus(
                                                  checkpoint.patrolId,
                                                  checkpoint.id,
                                                  widget.p.EmpId);
                                          await fireStoreService.addToLog(
                                              "Checkpoint",
                                              "",
                                              "",
                                              Timestamp.now(),
                                              Timestamp.now(),
                                              widget.p.EmpId,
                                              widget.p.EmployeeName,
                                              widget.p.PatrolCompanyID,
                                              "",
                                              widget.p.PatrolClientID);
                                          showSuccessToast(context,
                                              "${checkpoint.description} scanned ");
                                          _refresh();
                                        } else {
                                          _refresh();

                                          showErrorToast(context,
                                              "${checkpoint.description} scanned unsuccessfull");
                                        }
                                      } else {
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: color2,
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
                                                        : Primarycolor,
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
                                                      color: color17,
                                                      fontsize: width / width18,
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            height / height2),
                                                    InterRegular(
                                                      text: "",
                                                      color: Primarycolor,
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
                                                        color: color18,
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
                                                              title:
                                                                  InterRegular(
                                                                text:
                                                                    'Add Image/Comment',
                                                                color: color2,
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
                                                                                    color: WidgetColor,
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
                                                                              color: WidgetColor,
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
                                                                        Primarycolor,
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
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
                                                                              .id);
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
                                                                      _refresh();
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
                                                        color: Primarycolor,
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
                _expand
                    ? Button1(
                        text: 'END',
                        backgroundcolor: colorRed2,
                        color: Colors.redAccent,
                        borderRadius: 10,
                        onPressed: () async {
                          _refresh();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: InterRegular(
                                  text: 'Add Comment',
                                  color: color2,
                                  fontsize: width / width12,
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomeTextField(
                                      hint: 'Add Comment',
                                      showIcon: false,
                                      controller: CommentController,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                    child: InterRegular(
                                      text: 'Cancel',
                                      color: Primarycolor,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (CommentController.text.isNotEmpty) {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        if (widget.p.CompletedCount ==
                                            widget.p.PatrolRequiredCount - 1) {
                                          print(
                                              "Patrol count == Required COunt");
                                          setState(() {
                                            _expand = false;

                                            prefs.setBool("expand", _expand);
                                          });
                                          //If the count is equal

                                          await fireStoreService
                                              .LastEndPatrolupdatePatrolsStatus(
                                                  widget.p.PatrolId,
                                                  widget.p.EmpId,
                                                  widget.p.EmployeeName);
                                          List<String> emails = [];
                                          var ClientEmail =
                                              await fireStoreService
                                                  .getClientEmail(
                                                      widget.p.PatrolClientID);
                                          var AdminEmail =
                                              await fireStoreService
                                                  .getAdminEmail(
                                                      widget.p.PatrolCompanyID);
                                          var imageUrls = await fireStoreService
                                              .getImageUrlsForPatrol(
                                                  widget.p.PatrolId,
                                                  widget.p.EmpId);

                                          print(imageUrls);
                                          var TestinEmail =
                                              "sutarvaibhav37@gmail.com";
                                          var defaultEmail =
                                              "tacttikofficial@gmail.com";
                                          var testEmail3 =
                                              "Swastikbthiramdas@gmail.com";
                                          emails.add(TestinEmail);
                                          // emails.add(testEmail3);
                                          // emails.add(testEmail3);
                                          emails.add(ClientEmail!);
                                          emails.add(AdminEmail!);
                                          emails.add(defaultEmail!);

                                          DateFormat dateFormat =
                                              DateFormat("yyyy-MM-dd HH:mm:ss");
                                          String formattedStartDate =
                                              dateFormat.format(DateTime.now());
                                          String formattedEndDate =
                                              dateFormat.format(DateTime.now());
                                          String formattedEndTime =
                                              dateFormat.format(DateTime.now());
                                          DateFormat timeformat = DateFormat(
                                              "HH:mm"); // Define the format for time
                                          // if (InTime != null) {
                                          //   String formattedPatrolInTime =
                                          //       timeformat.format(InTime);
                                          // }
                                          String formattedPatrolOutTime =
                                              timeformat.format(DateTime.now());
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(DateTime.now());
                                          DateFormat timeFormat =
                                              DateFormat("HH:mm");

                                          String? InTime =
                                              prefs.getString("StartTime");

                                          DateTime inTime =
                                              DateFormat("HH:mm:ss")
                                                  .parse(InTime ?? "");

                                          Timestamp patrolInTimestamp =
                                              Timestamp.fromDate(inTime);

                                          Timestamp patrolOutTimestamp =
                                              Timestamp.fromDate(
                                                  DateTime.now());
                                          num count =
                                              widget.p.CompletedCount + 1;
                                          await fireStoreService
                                              .fetchAndCreatePatrolLogs(
                                                  widget.p.PatrolId,
                                                  widget.p.EmpId,
                                                  widget.p.EmployeeName,
                                                  widget.p.CompletedCount + 1,
                                                  formattedStartDate,
                                                  patrolInTimestamp,
                                                  patrolOutTimestamp,
                                                  CommentController.text);
                                          List<Map<String, dynamic>>
                                              formattedImageUrls =
                                              imageUrls.map((url) {
                                            return {
                                              'StatusReportedTime':
                                                  formattedEndDate,
                                              'ImageUrls': url['ImageUrls'],
                                              'StatusComment':
                                                  url['StatusComments']
                                            };
                                          }).toList();

                                          await fireStoreService.addToLog(
                                              "PatrolEnded",
                                              "",
                                              "",
                                              Timestamp.now(),
                                              Timestamp.now(),
                                              widget.p.EmpId,
                                              widget.p.EmployeeName,
                                              widget.p.PatrolCompanyID,
                                              "",
                                              widget.p.PatrolClientID);
                                          sendapiEmail(
                                              emails,
                                              "Patrol update for ${widget.p.description} Date:- ${formattedStartDate}",
                                              widget.p.EmployeeName,
                                              "",
                                              'Shift ',
                                              formattedStartDate,
                                              formattedImageUrls,
                                              widget.p.EmployeeName,
                                              InTime,
                                              formattedEndTime,
                                              count.toString(),
                                              widget.p.PatrolRequiredCount
                                                  .toString(),
                                              widget.p.description,
                                              "Completed",
                                              InTime,
                                              formattedPatrolOutTime,
                                              CommentController.text);
                                          _refresh();
                                          // sendFormattedEmail(emailParams);
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreen()));
                                        } else {
                                          //if normal update
                                          setState(() {
                                            _expand = false;
                                            buttonEnabled = false;

                                            prefs.setBool("expand", _expand);
                                          });
                                          await fireStoreService
                                              .EndPatrolupdatePatrolsStatus(
                                                  widget.p.PatrolId,
                                                  widget.p.EmpId,
                                                  widget.p.EmployeeName);
                                          DateFormat dateFormat =
                                              DateFormat("yyyy-MM-dd HH:mm:ss");
                                          String formattedStartDate =
                                              dateFormat.format(DateTime.now());
                                          String formattedEndDate =
                                              dateFormat.format(DateTime.now());
                                          String formattedEndTime =
                                              dateFormat.format(DateTime.now());
                                          DateFormat timeformat = DateFormat(
                                              "HH:mm"); // Define the format for time
                                          // String formattedPatrolInTime =
                                          //     timeformat.format(StartTime);
                                          String formattedPatrolOutTime =
                                              timeformat.format(DateTime.now());
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(DateTime.now());
                                          List<String> emails = [];
                                          var ClientEmail =
                                              await fireStoreService
                                                  .getClientEmail(
                                                      widget.p.PatrolClientID);
                                          var AdminEmail =
                                              await fireStoreService
                                                  .getAdminEmail(
                                                      widget.p.PatrolCompanyID);
                                          var imageUrls = await fireStoreService
                                              .getImageUrlsForPatrol(
                                                  widget.p.PatrolId,
                                                  widget.p.EmpId);

                                          List<Map<String, dynamic>>
                                              formattedImageUrls =
                                              imageUrls.map((url) {
                                            return {
                                              'StatusReportedTime':
                                                  formattedEndDate,
                                              'ImageUrls': url['ImageUrls'],
                                              'StatusComment':
                                                  url['StatusComment']
                                            };
                                          }).toList();
                                          print(imageUrls);
                                          var TestinEmail =
                                              "sutarvaibhav37@gmail.com";
                                          var defaultEmail =
                                              "tacttikofficial@gmail.com";
                                          // var defaultEmail = "tacttikofficial@gmail.com";
                                          var testEmail3 =
                                              "Swastikbthiramdas@gmail.com";
                                          emails.add(TestinEmail);
                                          // emails.add(testEmail3);

                                          emails.add(ClientEmail!);
                                          emails.add(AdminEmail!);
                                          emails.add(defaultEmail!);
                                          String? InTime =
                                              prefs.getString("StartTime");
                                          DateTime inTime =
                                              DateFormat("HH:mm:ss")
                                                  .parse(InTime ?? "");

                                          Timestamp patrolInTimestamp =
                                              Timestamp.fromDate(inTime);
                                          Timestamp patrolOutTimestamp =
                                              Timestamp.fromDate(
                                                  DateTime.now());
                                          await fireStoreService
                                              .fetchAndCreatePatrolLogs(
                                                  widget.p.PatrolId,
                                                  widget.p.EmpId,
                                                  widget.p.EmployeeName,
                                                  widget.p.CompletedCount + 1,
                                                  formattedStartDate,
                                                  patrolInTimestamp,
                                                  patrolOutTimestamp,
                                                  CommentController.text);
                                          await fireStoreService.addToLog(
                                              "PatrolEnded",
                                              "",
                                              "",
                                              Timestamp.now(),
                                              Timestamp.now(),
                                              widget.p.EmpId,
                                              widget.p.EmployeeName,
                                              widget.p.PatrolCompanyID,
                                              "",
                                              widget.p.PatrolClientID);
                                          num newCount =
                                              widget.p.CompletedCount;
                                          sendapiEmail(
                                              emails,
                                              "Patrol update for ${widget.p.description} Date:- ${formattedStartDate}",
                                              widget.p.EmployeeName,
                                              "",
                                              'Shift ',
                                              formattedStartDate,
                                              formattedImageUrls,
                                              widget.p.EmployeeName,
                                              InTime,
                                              formattedEndTime,
                                              newCount.toString(),
                                              widget.p.PatrolRequiredCount
                                                  .toString(),
                                              widget.p.description,
                                              "Completed",
                                              InTime,
                                              formattedPatrolOutTime,
                                              CommentController.text);
                                        }
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen()));
                                      } else {
                                        showErrorToast(
                                            context, "Field cannot be empty");
                                      }
                                    },
                                    child: InterRegular(
                                      text: 'Submit',
                                      fontsize: width / width18,
                                      color: Primarycolor,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                    : const SizedBox(),
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
