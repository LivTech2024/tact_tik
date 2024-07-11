import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:tact_tik/common/widgets/dialogList.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/client%20screens/patrol/unchecked_patrolss.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/end_checkpoint_screen.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/report_checkpoint_screen.dart';
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
import '../Report/create_report_screen.dart';
import '../widgets/custome_textfield.dart';

FireStoreService fireStoreService = FireStoreService();

bool isPopupVisible = false;

class MyPatrolsList extends StatefulWidget {
  final String EmployeeID;
  final String ShiftLocationId;
  final String ShiftId;
  final String EmployeeName;
  final String ShiftDate;
  final String ShiftName;

  const MyPatrolsList(
      {required this.ShiftLocationId,
      required this.EmployeeID,
      required this.EmployeeName,
      required this.ShiftId,
      required this.ShiftDate,
      required this.ShiftName});

  @override
  State<MyPatrolsList> createState() => _MyPatrolsListState();
}

class _MyPatrolsListState extends State<MyPatrolsList> {
  // late Map<String, dynamic> patrolsData = "";
  late List<Patrol> patrolsData = [];
  String _PatrolId = '';
  int totalCount = 0;
  String CurrentPatrolStatus = "";
  bool buttonClicked = false;
  bool buttonClicked1 = false;
  TextEditingController CommentController = TextEditingController();
  Timestamp? StatusPatrolTime;

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
      Map<String, dynamic> data = patrol as Map<String, dynamic>;
      print("Patrol Data : ${data["PatrolCurrentStatus"]}");
      String patrolCompanyId = data['PatrolCompanyId'];
      String patrolLocationName = data['PatrolLocationName'];
      String patrolName = data['PatrolName'];
      String patrolId = data['PatrolId'];
      String patrolLocationId = data['PatrolLocationId'];

      String patrolClientId = data['PatrolClientId'];
      // String patrolTime = data['PatrolTime'];
      int requiredCount = data['LinkedPatrolReqHitCount'];
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
                  // _isSameDay(
                  //     _parseTimestamp(status['StatusReportedTime']), today)
                  status['StatusShiftId'] == widget.ShiftId)
              .toList();

          int completedCount = filteredStatusList.fold(
              0,
              (sum, status) =>
                  sum + (status['StatusCompletedCount'] as int? ?? 0));

          return completedCount;
        }

        void getCurrentPatrolStatus(
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
                  // _isSameDay(
                  //     _parseTimestamp(status['StatusReportedTime']), today)
                  status['StatusShiftId'] == widget.ShiftId)
              .toList();
          String currentStatus = filteredStatusList
              .map((status) => status['Status'] as String)
              .join(", ");
          List<DateTime> statusTimes = filteredStatusList
              .map((status) => _parseTimestamp(status['StatusReportedTime']))
              .toList();
          Timestamp? statusTime = filteredStatusList
              .map((status) => status['StatusReportedTime'])
              .cast<Timestamp>() // Cast to List<DateTime>
              .firstOrNull; // Get the first element or null if empty
          if (statusTime != null) {
            StatusPatrolTime = statusTime;
          }
          print("Status times: $statusTimes");
          print("========>>>>>>>==========================");
          print("Current Patrol Status ${currentStatus.toString()}");
          print("Current Patrol Time ${statusTime}");
          if (currentStatus.isNotEmpty || currentStatus != null) {
            setState(() {
              CurrentPatrolStatus = currentStatus;
            });
          }
        }

        int completedCount = getCompletedCount(patrolStatus, widget.EmployeeID);
        getCurrentPatrolStatus(patrolStatus, widget.EmployeeID);
        setState(() {
          totalCount = completedCount;
        });

        print('Completed count for  ${_PatrolId}: $completedCount');
      } else {
        print('Patrol status is null or not a List<dynamic>');
      }

      setState(() {
        _PatrolId = patrolId;
      });
      List<Category> categories = [];
      bool allChecked = false;
      String _parseTimestamp(Timestamp timestamp) {
        DateTime dateTime = timestamp.toDate();
        return DateFormat.Hms()
            .format(dateTime); // This will return time in 'HH:mm:ss' format
      }

      for (var checkpoint in data['PatrolCheckPoints']) {
        String checkpointCategory = checkpoint['CheckPointCategory'] ?? "";
        String checkpointId = checkpoint['CheckPointId'];
        String checkpointName = checkpoint['CheckPointName'];
        // String checkpointtimestamp =
        //     checkpoint['StatusReportedTime']?.toString() ?? "";

        String? reportedTime;
        List<CheckPointStatus> checkPointStatuses =
            (checkpoint['CheckPointStatus'] as List<dynamic> ?? [])
                .map((status) {
          List<dynamic> checkPointStatuses =
              checkpoint['CheckPointStatus'] ?? [];

          if (checkPointStatuses == null ||
              checkPointStatuses.isEmpty ||
              checkPointStatuses.any((status) {
                if (status['Status'] == 'unchecked' &&
                    status['StatusReportedById'] == widget.EmployeeID &&
                    status['StatusShiftId'] == widget.ShiftId) {
                  // reportedTime = _parseTimestamp(status['StatusReportedTime']);
                  return true;
                }
                return false;
              })) {
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
          if (checkPointStatuses == null ||
              checkPointStatuses.isEmpty ||
              checkPointStatuses.any((status) {
                if (status['Status'] == 'checked' &&
                    status['StatusReportedById'] == widget.EmployeeID &&
                    status['StatusShiftId'] == widget.ShiftId) {
                  reportedTime = _parseTimestamp(status['StatusReportedTime']);
                  return true;
                }
                return false;
              })) ;

          // ... rest of the code
          // List<Map<String, dynamic>> filteredStatusList = checkpoint
          //     .where(
          //         (status) => status['StatusReportedById'] == widget.EmployeeID)
          //     .toList();
          return CheckPointStatus(
            status: status['Status'],
            StatusCompletedCount: status['StatusCompletedCount'],
            reportedTime: status['StatusReportedTime'],
            reportedById: status['StatusReportedById'],
            reportedByName: status['StatusReportedByName'],
            statusShiftId: status['StatusShiftId'],
          );
        }).toList();
        Category category = categories.firstWhere(
            (element) => element.title == checkpointCategory, orElse: () {
          Category newCategory =
              Category(title: checkpointCategory, checkpoints: []);
          categories.add(newCategory);
          return newCategory;
        });

        category.checkpoints.add(Checkpoint(
          title: checkpointName,
          description: checkpointName,
          id: checkpointId,
          checkPointStatus: checkPointStatuses,
          patrolId: patrolId,
          timestamp: reportedTime?.toString() ?? "",
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
          PatrolClientID: patrolClientId,
          ShiftDate: widget.ShiftDate,
          ShiftId: widget.ShiftId,
          LocationId: patrolLocationId,
          patrolClientId: patrolClientId,
          ShiftName: widget.ShiftName,
          CurrentStatus: CurrentPatrolStatus,
          PatrolStartedTIme: StatusPatrolTime,
        ),
      );
    }

    setState(() {
      patrolsData = patrols;
      patrolsData1 = patrols;
    });
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

  // bool _expand = false;
  // bool _expand2 = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            // physics: const PageScrollPhysics(),
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                  ),
                  padding: EdgeInsets.only(left: width / width20),
                  onPressed: () {
                    Navigator.pop(context);
                    print(
                        "Navigtor debug: ${Navigator.of(context).toString()}");
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
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Patrol p = patrolsData[index];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width30),
                      child: PatrollingWidget(p: p, onRefresh: _refreshData),
                    );
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
  Set<String> _expandedPatrols = {};
  TextEditingController Controller = TextEditingController();
  TextEditingController CommentController = TextEditingController();
  bool buttonClicked = true;
  bool buttonClicked1 = true;

  bool uploadingLoading = false;

  @override
  void initState() {
    super.initState();
    _loadShiftStartedState();
    _expandCategoryMap = {};
    // Initialize expand state for each category
    _expandCategoryMap = Map.fromIterable(widget.p.categories,
        key: (category) => category.title, value: (_) => false);
    print("========================= init State");
    print("PatrolsData ${patrolsData1}");
    for (var patrol in patrolsData1) {
      print("========================= init State2");

      print("IN for loop");
      // _expandCategoryMap[patrol.PatrolId] = patrol.CurrentStatus == 'started';
      // if (widget.p.CurrentStatus == 'started') {
      //   setState(() {
      //     _expandedPatrols.add(widget.p.PatrolId);
      //   });
      // }

      String PatrolStatus = patrol.CurrentStatus;
      print("PatrolStatus ${widget.p.PatrolId}${PatrolStatus}}");
      print("PatrolSet ${widget.p.PatrolId}${_expandedPatrols}}");
    }
  }

  void _updateExpandStatus(String patrolId, bool expanded) {
    setState(() {
      _expandCategoryMap[patrolId] = expanded;
    });
  }

  void _loadShiftStartedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (widget.p.CurrentStatus == "started") {
      setState(() {
        _expand = true;
      });
    }
    setState(() {
      _expand = prefs.getBool('expand') ?? false;
    });
  }

  // void _loadShiftStartedState() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (widget.p.CurrentStatus == "started") {
  //     setState(() {
  //       // _expandCategoryMap[widget.p.CurrentStatus] = true;
  //     });
  //     _updateExpandStatus(widget.p.title, true);
  //   }
  // }

  // void _updateExpandStatus(String categoryTitle, bool expanded) {
  //   setState(() {
  //     _expandCategoryMap[categoryTitle] =
  //         expanded; // Update expand status for the given category
  //   });
  // }

  Future<void> _refreshData() async {
    // Fetch updated data
    initState();
    setState(() {}); // Update the state to rebuild the widget
  }

  List<Map<String, dynamic>> uploads = [];

  void _deleteItem(int index) {
    setState(() {
      uploads.removeAt(index);
    });
    _refresh();
    _refreshData();
  }

  Future<void> _addImage() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      try {
        File file = File(pickedFile.path);
        if (file.existsSync()) {
          File compressedFile = await _compressImage(file);
          setState(() {
            uploads.add({'type': 'image', 'file': file});
          });
        } else {
          print('File does not exist: ${file.path}');
        }
      } catch (e) {
        print('Error adding image: $e');
      }
    } else {
      print('No images selected');
    }
    print("Statis ${uploads}");
    _refresh();
    _refreshData();
  }

  Future<File> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + '_compressed.jpg',
      quality: 30,
    );
    return File(result!.path);
  }

  Future<void> _addGallery() async {
    List<XFile>? pickedFiles = await ImagePicker()
        .pickMultiImage(imageQuality: 30); // image quality 30
    if (pickedFiles != null) {
      for (var pickedFile in pickedFiles) {
        try {
          File file = File(pickedFile.path);
          if (file.existsSync()) {
            File compressedFile = await _compressImage(file);
            setState(() {
              uploads.add({'type': 'image', 'file': file});
            });
          } else {
            print('File does not exist: ${file.path}');
          }
        } catch (e) {
          print('Error adding image: $e');
        }
      }
    } else {
      print('No images selected');
    }
    _refresh();
    _refreshData();
  }

  String Result = "";

  Future<void> _refresh() async {
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    AudioPlayer player = new AudioPlayer();
    bool buttonEnabled = true;
    bool startTimeUpdated = false;
    bool _isLoading = false;
    double completionPercentage =
        widget.p.CompletedCount / widget.p.PatrolRequiredCount;
    String StartTime;
    String CheckPointId = "";
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
      if (buttonEnabled &&
          !_expand &&
          widget.p.CompletedCount < widget.p.PatrolRequiredCount) {
        setState(() {
          buttonEnabled = false; // Disable the button
        });
        print(widget.p.patrolClientId);
        var clientName =
            await fireStoreService.getClientName(widget.p.patrolClientId);

        await fireStoreService.addToLog(
            "patrol_start",
            "",
            clientName ?? "",
            widget.p.EmpId,
            widget.p.EmployeeName,
            widget.p.PatrolCompanyID,
            "",
            widget.p.PatrolClientID,
            widget.p.LocationId,
            widget.p.ShiftName);
        await fireStoreService.updatePatrolCurrentStatusToUnchecked(
            widget.p.PatrolId,
            "started",
            widget.p.EmpId,
            widget.p.EmployeeName,
            widget.p.ShiftId);
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

    void _showPopup(String id) {
      print("Then value of checkpoint id : ${id}");
      setState(() {
        CheckPointId = id;
        isPopupVisible = true;
      });
    }

    @override
    Widget ReportCheckpoint(String chkid) {
      print("Checkpoint id in widget ${chkid}");
      return Container(
        constraints: BoxConstraints(minHeight: 90.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Image/Comment',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodySmall!.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: Controller,
              decoration: InputDecoration(
                hintText: 'Add Comment',
              ),
            ),
            SizedBox(height: 10.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < uploads.length; i++)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 66.h,
                          width: 66.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          margin: EdgeInsets.all(8.sp),
                          child: Image.file(
                            uploads[i]['file'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: IconButton(
                            onPressed: () {
                              _deleteItem(i);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.black,
                              size: 20.sp,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  GestureDetector(
                    onTap: () {
                      _refresh();
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.camera,
                                size: 24.sp,
                              ),
                              title: InterRegular(
                                text: 'Add Image',
                                fontsize: 20.sp,
                              ),
                              onTap: () {
                                _addImage();
                                Navigator.pop(context);
                                _refresh();
                                _refreshData();
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.image,
                                size: 24.sp,
                              ),
                              title: InterRegular(
                                text: 'Add from Gallery',
                                fontsize: 20.sp,
                              ),
                              onTap: () {
                                _addGallery();
                                Navigator.pop(context);
                                _refresh();
                                _refreshData();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      height: 66.h,
                      width: 66.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isPopupVisible = false;
                    });
                  },
                  child: InterRegular(
                    text: 'Cancel',
                    color: Colors.red,
                    fontsize: 20.sp,
                  ),
                ),
                uploadingLoading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      )
                    : Button1(
                        height: 30.h,
                        borderRadius: 10.r,
                        onPressed: () async {
                          _refresh();
                          // Logic to submit the report
                          setState(() {
                            uploadingLoading = true;
                          });
                          print("CheckpointId ${chkid}");
                          if (uploads.isNotEmpty ||
                              Controller.text.isNotEmpty) {
                            await fireStoreService.addImagesToPatrol(
                                uploads,
                                Controller.text,
                                widget.p.PatrolId,
                                widget.p.EmpId,
                                chkid,
                                widget.p.ShiftId);
                            toastification.show(
                              context: context,
                              type: ToastificationType.success,
                              title: Text("Submitted"),
                              autoCloseDuration: const Duration(seconds: 2),
                            );
                            _refresh();
                            setState(() {
                              _isLoading = false;
                            });
                            uploads.clear();
                            Controller.clear();

                            // Navigator.pop(context);
                          } else {
                            showErrorToast(context, "Fields cannot be empty");
                          }
                          setState(() {
                            uploadingLoading = false;
                          });
                        },
                        text: 'Submit',
                        fontsize: 14.sp,
                        backgroundcolor: Theme.of(context).primaryColor,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
              ],
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InterBold(
                text: "Today",
                fontsize: 18.sp,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              SizedBox(height: 30.h),
              AnimatedContainer(
                margin: EdgeInsets.only(bottom: 30.h),
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    )
                  ],
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                constraints: widget.p.CurrentStatus == "started"
                    ? BoxConstraints(minHeight: 200.h)
                    : const BoxConstraints(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 120.w,
                                child: InterBold(
                                  text: 'Patrol   ${widget.p.title}',
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                  fontsize: 14.sp,
                                  maxLine: 1,
                                ),
                              ),
                              CircularPercentIndicator(
                                radius: 10.r,
                                lineWidth: 3,
                                percent: completionPercentage.clamp(0.0, 1.0),
                                progressColor: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          IconTextWidget(
                            iconSize: 24.sp,
                            icon: Icons.location_on,
                            text: widget.p.title,
                            useBold: false,
                            color: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .color as Color,
                            Iconcolor: Theme.of(context).primaryColor,
                          ),
                          SizedBox(height: 16.h),
                          Divider(
                            color: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .color as Color,
                          ),
                          SizedBox(height: 5.h),
                          IconTextWidget(
                            iconSize: 24.sp,
                            icon: Icons.description,
                            text: widget.p.description,
                            useBold: false,
                            color: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .color as Color,
                            Iconcolor: Theme.of(context).primaryColor,
                          ),
                          SizedBox(height: 16.h),
                          Divider(
                            color: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .color as Color,
                          ),
                          SizedBox(height: 5.h),
                          IconTextWidget(
                            iconSize: 24.sp,
                            icon: Icons.qr_code_scanner,
                            text:
                                'Total  ${widget.p.PatrolRequiredCount}  Completed ${widget.p.CompletedCount}',
                            useBold: false,
                            color: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .color as Color,
                            Iconcolor: Theme.of(context).primaryColor,
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                    Button1(
                      text: 'START',
                      backgroundcolor: widget.p.CurrentStatus == "started"
                          ? Theme.of(context).primaryColorLight
                          : Theme.of(context).primaryColor,
                      color: Colors.white,
                      borderRadius: 10.r,
                      onPressed: buttonClicked
                          ? () async {
                              print("ButtonEnabled : ${buttonEnabled}");
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              print(_expandCategoryMap[widget.p.PatrolId]);
                              if (buttonEnabled &&
                                  widget.p.CurrentStatus != "started" &&
                                  widget.p.CompletedCount <
                                      widget.p.PatrolRequiredCount) {
                                setState(() {
                                  buttonEnabled = false; // Disable the button
                                });
                                print(widget.p.patrolClientId);
                                var clientName = await fireStoreService
                                    .getClientName(widget.p.patrolClientId);

                                await fireStoreService.addToLog(
                                    "patrol_start",
                                    "",
                                    clientName ?? "",
                                    widget.p.EmpId,
                                    widget.p.EmployeeName,
                                    widget.p.PatrolCompanyID,
                                    "",
                                    widget.p.PatrolClientID,
                                    widget.p.LocationId,
                                    widget.p.ShiftName);
                                await fireStoreService
                                    .updatePatrolCurrentStatusToUnchecked(
                                        widget.p.PatrolId,
                                        "started",
                                        widget.p.EmpId,
                                        widget.p.EmployeeName,
                                        widget.p.ShiftId);
                                DateTime now = DateTime.now();
                                String formattedTime =
                                    DateFormat('HH:mm:ss').format(now);
                                setState(() {
                                  StartTime = formattedTime;
                                  _expand = true;
                                  prefs.setBool("expand", _expand);
                                  prefs.setString(
                                      "StartTime", StartTime.toString());
                                });
                                _updateExpandStatus(widget.p.PatrolId, true);
                                _refresh();
                                showSuccessToast(context, "Patrol Started");
                              } else if (widget.p.CompletedCount ==
                                  widget.p.PatrolRequiredCount) {
                                setState(() {
                                  buttonEnabled = false;
                                });
                                return null;
                              } else {
                                return null;
                              }
                            }
                          : () {
                              showErrorToast(
                                  context, "Patrol it already completed");
                            },
                    ),
                    Visibility(
                        visible: widget.p.CurrentStatus == "started",
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
                                    print("Clicked");
                                    // Handle tap action to expand checkpoints
                                    // Toggle visibility of checkpoints associated with this category
                                    setState(() {
                                      // if (_expandCategoryMap[category.title] !=
                                      //     null) {
                                      _expandCategoryMap[category.title] =
                                          !_expandCategoryMap[category.title]!;
                                      // }
                                      // _expand2 = !_expand2;
                                    });
                                  },
                                  child: Container(
                                    height: 70.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 11.h,
                                    ),
                                    margin: EdgeInsets.only(top: 10.h),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? DarkColor.color27
                                          : LightColor.WidgetColor,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: 48.h,
                                              width: 48.w,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? DarkColor.WidgetColor
                                                    : LightColor
                                                        .Primarycolorlight,
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                Icons.home_sharp,
                                                size: 24.sp,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            SizedBox(
                                              width: 190.w,
                                              child: InterRegular(
                                                text: category.title,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium!
                                                    .color as Color,
                                                fontsize: 18.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          expand
                                              ? Icons.arrow_circle_up_outlined
                                              : Icons
                                                  .arrow_circle_down_outlined,
                                          size: 24.sp,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .color as Color,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      widget.p.CurrentStatus == 'started' &&
                                          expand,
                                  child: Column(
                                    children:
                                        category.checkpoints.map((checkpoint) {
                                      return GestureDetector(
                                        onTap: () async {
                                          if (widget.p.CurrentStatus !=
                                              "started") {
                                            showErrorToast(context,
                                                "This Patrol has not being started");
                                            return;
                                          }
                                          if (checkpoint.getFirstStatus(
                                                    widget.p.EmpId,
                                                    widget.p.ShiftId,
                                                  ) ==
                                                  'unchecked' ||
                                              checkpoint.getFirstStatus(
                                                    widget.p.EmpId,
                                                    widget.p.ShiftId,
                                                  ) ==
                                                  null) {
                                            var res = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SimpleBarcodeScannerPage(
                                                    isShowFlashIcon: true,
                                                  ),
                                                ));
                                            setState(() {
                                              Result = res;
                                            });
                                            // if (Result) {
                                            // player.play(AssetSource(
                                            //     "../../../../assets/SuccessSound.mpeg"));
                                            print(res);
                                            if (res == checkpoint.id) {
                                              await fireStoreService
                                                  .updatePatrolsStatus(
                                                      checkpoint.patrolId,
                                                      checkpoint.id,
                                                      widget.p.EmpId,
                                                      widget.p.ShiftId);
                                              await fireStoreService.addToLog(
                                                  "check_point",
                                                  "",
                                                  "",
                                                  widget.p.EmpId,
                                                  widget.p.EmployeeName,
                                                  widget.p.PatrolCompanyID,
                                                  "",
                                                  widget.p.PatrolClientID,
                                                  widget.p.LocationId,
                                                  widget.p.ShiftName);
                                              showSuccessToast(context,
                                                  "${checkpoint.description} scanned ");
                                              _refresh();
                                            } else {
                                              _refresh();
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
                                          height: 70.h,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20.w,
                                            vertical: 11.h,
                                          ),
                                          margin: EdgeInsets.only(
                                            top: 10.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? DarkColor.color15
                                                    : LightColor.color1,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 48.h,
                                                    width: 48.w,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? DarkColor.color16
                                                          : LightColor
                                                              .Primarycolorlight,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        10.r,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      height: 30.h,
                                                      width: 30.w,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: checkpoint.getFirstStatus(
                                                                    widget.p
                                                                        .EmpId,
                                                                    widget.p
                                                                        .ShiftId) !=
                                                                'checked'
                                                            ? Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? DarkColor
                                                                    .color16
                                                                : Colors
                                                                    .transparent
                                                            : Colors
                                                                .lightGreenAccent,
                                                      ),
                                                      child: Icon(
                                                        checkpoint.getFirstStatus(
                                                                    widget.p
                                                                        .EmpId,
                                                                    widget.p
                                                                        .ShiftId) ==
                                                                'checked'
                                                            ? Icons.done
                                                            : Icons.qr_code,
                                                        color: checkpoint.getFirstStatus(
                                                                    widget.p
                                                                        .EmpId,
                                                                    widget.p
                                                                        .ShiftId) ==
                                                                'checked'
                                                            ? Colors.green
                                                            : (Theme.of(context)
                                                                .primaryColor),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 20.w,
                                                  ),
                                                  SizedBox(
                                                    width: 140.w,
                                                    child: Column(
                                                      children: [
                                                        InterRegular(
                                                          text:
                                                              checkpoint.title,
                                                          //Subcheckpoint
                                                          color: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .displayMedium!
                                                              .color as Color,
                                                          fontsize: 18.sp,
                                                        ),
                                                        SizedBox(
                                                            height: checkpoint
                                                                        .timestamp !=
                                                                    ''
                                                                ? 2.h
                                                                : 0.h),
                                                        checkpoint.timestamp !=
                                                                ''
                                                            ? InterRegular(
                                                                text: checkpoint
                                                                    .timestamp,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .color as Color,
                                                                fontsize: 12.sp,
                                                              )
                                                            : SizedBox()
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height: 34.h,
                                                      width: 34.w,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? DarkColor.color16
                                                            : LightColor
                                                                .Primarycolorlight,
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
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium!
                                                                            .color),
                                                                  ),
                                                                  content: Text(
                                                                    'The scanned QR code does not work.',
                                                                    style: TextStyle(
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium!
                                                                            .color),
                                                                  ),
                                                                  actions: [
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
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => CreateReportScreen(
                                                                                      locationId: widget.p.LocationId,
                                                                                      locationName: '',
                                                                                      empId: widget.p.EmpId,
                                                                                      companyID: widget.p.PatrolCompanyID,
                                                                                      empName: widget.p.EmployeeName,
                                                                                      ClientId: widget.p.PatrolClientID,
                                                                                      reportId: '',
                                                                                      buttonEnable: true,
                                                                                      ShiftId: widget.p.ShiftId,
                                                                                      SearchId: '',
                                                                                      isRoleGuard: false,
                                                                                      BranchId: "",
                                                                                    )));
                                                                      },
                                                                      child: InterRegular(
                                                                          text:
                                                                              "Report"),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child:
                                                                          InterRegular(
                                                                        text:
                                                                            'Done',
                                                                      ),
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
                                                            color: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? DarkColor
                                                                    .color5
                                                                : LightColor
                                                                    .Primarycolor,
                                                            size: 24.sp,
                                                          ),
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(
                                                      8.sp,
                                                    ),
                                                    child: Container(
                                                      height: 34.h,
                                                      width: 34.w,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? DarkColor.color16
                                                            : LightColor.color1,
                                                      ),
                                                      child: Center(
                                                        child: IconButton(
                                                          onPressed: () {
                                                            if (widget.p
                                                                    .CurrentStatus !=
                                                                "started") {
                                                              showErrorToast(
                                                                  context,
                                                                  "This Patrol has not being started");
                                                              return;
                                                            }
                                                            setState(() {
                                                              CheckPointId =
                                                                  checkpoint.id;
                                                            });

                                                            _refresh();
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ReportCheckpointScreen(
                                                                              CheckpointID: checkpoint.id,
                                                                              PatrolID: widget.p.PatrolId,
                                                                              ShiftId: widget.p.ShiftId,
                                                                              empId: widget.p.EmpId,
                                                                            )));
                                                          },
                                                          icon: Icon(
                                                            Icons.add_circle,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            size: 24.sp,
                                                          ),
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                      ),
                                                    ),
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
                      height: 10.h,
                    ),
                    widget.p.CurrentStatus == 'started'
                        ? Button1(
                            text: 'END',
                            backgroundcolor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? DarkColor.colorRed2
                                    : LightColor.colorRed,
                            color: Colors.redAccent,
                            borderRadius: 10,
                            onPressed: () async {
                              if (widget.p.PatrolStartedTIme == null ||
                                  widget.p.CurrentStatus != "started") {
                                showErrorToast(context,
                                    "This Patrol has not being Started");
                                return;
                              }
                              var status =
                                  await fireStoreService.getuncheckedstatus(
                                      widget.p.PatrolId,
                                      widget.p.ShiftId,
                                      widget.p.EmpId);
                              print("Status of unchecked $status");
                              if (status == true) {
                                showErrorToast(context,
                                    "Complete all the checkpoints ${widget.p.PatrolId}");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UncheckedPatrolScreen(
                                              ShiftId: widget.p.ShiftId,
                                              EmployeeID: widget.p.EmpId,
                                              PatrolID: widget.p.PatrolId,
                                              EmployeeName:
                                                  widget.p.EmployeeName,
                                              CompletedCount:
                                                  widget.p.CompletedCount,
                                              PatrolRequiredCount:
                                                  widget.p.PatrolRequiredCount,
                                              PatrolCompanyID:
                                                  widget.p.PatrolCompanyID,
                                              PatrolClientID:
                                                  widget.p.PatrolClientID,
                                              LocationId: widget.p.LocationId,
                                              description: widget.p.description,
                                              ShiftDate: widget.p.ShiftDate,
                                              PatrolStartedTIme:
                                                  widget.p.PatrolStartedTIme,
                                              ShiftName: widget.p.ShiftName,
                                            )));

                                return;
                              }
                              //check for the checkpoint status if any one is unchecked then dailog box display checked
                              // StatusFailureReason
                              _refresh();
                              print("Patrol Data ${widget.p.Allchecked}");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EndCheckpointScreen(
                                            EmpId: widget.p.EmpId,
                                            PatrolID: widget.p.PatrolId,
                                            ShiftId: widget.p.ShiftId,
                                            EmpName: widget.p.EmployeeName,
                                            CompletedCount:
                                                widget.p.CompletedCount,
                                            PatrolRequiredCount:
                                                widget.p.PatrolRequiredCount,
                                            PatrolCompanyID:
                                                widget.p.PatrolCompanyID,
                                            PatrolClientID:
                                                widget.p.PatrolClientID,
                                            LocationId: widget.p.LocationId,
                                            ShiftName: widget.p.ShiftName,
                                            description: widget.p.description,
                                            ShiftDate: widget.p.ShiftDate,
                                            PatrolStatusTime:
                                                widget.p.PatrolStartedTIme,
                                          )));
                            },
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: _isLoading,
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 10),
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Align(
          alignment: Alignment(0, 0),
          child: Visibility(
            visible: isPopupVisible,
            child: ReportCheckpoint(CheckPointId),
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
  final String ShiftId;
  final String LocationId;
  final String ShiftName;

  final String patrolClientId;
  final String CurrentStatus;
  final Timestamp? PatrolStartedTIme;

  Patrol({
    required this.title,
    required this.PatrolCompanyID,
    required this.PatrolClientID,
    required this.description,
    required this.categories,
    required this.patrolClientId,
    // required this.time,
    required this.PatrolId,
    required this.EmpId,
    required this.EmployeeName,
    required this.PatrolRequiredCount,
    required this.CompletedCount,
    required this.Allchecked,
    required this.ShiftDate,
    required this.ShiftId,
    required this.LocationId,
    required this.ShiftName,
    required this.CurrentStatus,
    required this.PatrolStartedTIme,
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
  final String timestamp;
  final String id;
  final List<CheckPointStatus> checkPointStatus;

  Checkpoint({
    required this.title,
    required this.patrolId,
    required this.description,
    required this.id,
    required this.checkPointStatus,
    required this.timestamp,
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

  String? getFirstStatus(String empId, String ShiftId) {
    if (checkPointStatus.isNotEmpty) {
      for (var status in checkPointStatus) {
        if (status.reportedById == empId &&
            // isSameDay(status.reportedTime, Timestamp.now())
            status.statusShiftId == ShiftId) {
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
  final String? statusShiftId;

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
    this.statusShiftId,
  });
}

late List<Patrol> patrolsData1 = [];
