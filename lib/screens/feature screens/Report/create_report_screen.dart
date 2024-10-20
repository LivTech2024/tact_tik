import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/common/widgets/video_grid.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/services/textToSpeech/text_To_Speech_config.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import '../widgets/custome_textfield.dart';

class CreateReportScreen extends StatefulWidget {
  final String locationId;
  final String locationName;
  final String companyID;
  final String empId;
  final String ClientId;
  final String ShiftId;
  final String empName;
  final String reportId;
  bool buttonEnable;
  final String SearchId;
  final bool isRoleGuard;
  final String BranchId;

  CreateReportScreen({
    Key? key,
    required this.locationId,
    required this.locationName,
    required this.companyID,
    required this.empId,
    required this.empName,
    required this.ClientId,
    required this.reportId,
    required this.buttonEnable,
    required this.ShiftId,
    required this.SearchId,
    required this.isRoleGuard,
    required this.BranchId,
  }) : super(key: key);

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  bool shouldShowButton = false;
  List<String> imageUrls = [];
  List<String> videoUrls = [];

  List<Map<String, dynamic>> DisplayIMage = [];
  List<Map<String, dynamic>> DisplayVideo = [];

  FireStoreService fireStoreService = FireStoreService();

  // List<String> ClintValues = ['Client'];
  String? selectedClint = 'Client';
  String? selectedClientName;

  // String? selectedClientId;
  String? selectedClientId = 'Client';

  // List<String> LocationValues = ['Select Location'];
  List<String> tittles = [];
  Map<String, dynamic> reportData = {};
  final TextEditingController explainController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();
  bool isChecked = false;
  String dropdownValue = 'Incident';
  String dropdownValueGuard = 'All Guards';

  // String dropdownValueLocation = 'Select Location';
  String? selectedLocationName;
  String? selectedLocationId = '';

  bool dropdownShoe = false;
  bool _isLoading = false;
  DateTime? StartDate;
  DateTime? SelectedDate;
  DateTime? EndDate;
  Map<String, String> clientMap = {};
  Map<String, String> locationMap = {};
  TextToSpeechConfig textToSpeechConfig = TextToSpeechConfig();

  @override
  void initState() {
    // TODO: implement initState
    textToSpeechConfig.checkMic();
    getAllTitles();
    getAllReports();
    getAllClientNames();
    getAllLocationNames();
    super.initState();
    shouldShowButton = widget.buttonEnable;
    print("Shift Id at Create Report ${widget.ShiftId}");
    print("Shift Id at Create Report ${widget.companyID}");
    print("Shift Id at Client Report ${widget.ClientId}");
  }

  void getAllTitles() async {
    try {
      List<String> data = await fireStoreService.getReportTitles();
      if (data.isNotEmpty) {
        setState(() {
          tittles = [...data];
        });
      }
      print("Report Titles : $data");
      print("Getting all titles");
    } catch (e) {}
  }

  void getAllClientNames() async {
    Map<String, String> clients =
        await fireStoreService.getAllClientsNameAndID(widget.companyID);
    if (clients.isNotEmpty) {
      setState(() {
        clientMap = clients;
        // ClintValues.addAll(
        //     clients.values.toList()); // Update ClintValues if needed
      });
    }
  }

  void getAllLocationNames() async {
    Map<String, String> locations =
        await fireStoreService.getAllLocationsWithId(widget.companyID);
    if (locations.isNotEmpty) {
      setState(() {
        locationMap = locations;
      });
    }
  }

  void updateSelectedClient(String clientId) {
    setState(() {
      selectedClientId = clientId;
      selectedClientName = clientMap[clientId];
    });
  }

  void getAllReports() async {
    if (widget.SearchId.isNotEmpty) {
      // getAllClientNames();
      // getAllLocationNames();
      Map<String, dynamic>? data =
          (await fireStoreService.getReportWithSearchId(widget.SearchId));
      if (data != null) {
        setState(() {
          reportData = data;
          isChecked = reportData['ReportIsFollowUpRequired'];
          titleController.text = reportData['ReportName'];
          explainController.text = reportData['ReportData'];
          dropdownValue = reportData['ReportCategoryName'];
          // Timestamp reportCreatedAt = reportData['ReportCreatedAt'];
          SelectedDate = reportData['ReportCreatedAt'].toDate();
          selectedLocationName = reportData['ReportLocationName'];
          selectedLocationId = reportData['ReportLocationId'];
          selectedClientId = reportData['ReportClientId'];
          // selectedClientName = clientMap[selectedClientId];
          // uploads.add(reportData['ReportImage']);
        });
        if (selectedClientId != null) {
          String? ClientName =
              await fireStoreService.getClientName(selectedClientId);
          setState(() {
            selectedClientName = ClientName;
          });
        }
        if (reportData['ReportIsFollowUpRequired'] == false) {
          setState(() {
            shouldShowButton = false;
          });
        } else {
          setState(() {
            shouldShowButton = true;
          });
        }
        if (reportData['ReportImage'] != null) {
          // Add existing report images URLs to uploads list
          for (var imageUrl in reportData['ReportImage']) {
            setState(() {
              DisplayIMage.add({'type': 'image', 'url': imageUrl});
            });
          }
        }
        if (reportData['ReportVideo'] != null) {
          // Add existing report images URLs to uploads list
          for (var imageUrl in reportData['ReportVideo']) {
            print("ReportVideo1 ${imageUrl}");
            setState(() {
              DisplayVideo.add({'type': 'video', 'url': imageUrl});
            });
          }
        } else {
          print("ReportVideo is null");
        }
        print(reportData['ReportIsFollowUpRequired']);
      }
    } else {
      // getAllClientNames();
      // getAllLocationNames();
      if (widget.reportId.isNotEmpty) {
        Map<String, dynamic>? data =
            (await fireStoreService.getReportWithId(widget.reportId));
        if (data != null) {
          setState(() {
            reportData = data;
            isChecked = reportData['ReportIsFollowUpRequired'];
            titleController.text = reportData['ReportName'];
            explainController.text = reportData['ReportData'];
            dropdownValue = reportData['ReportCategoryName'];
            SelectedDate = reportData['ReportCreatedAt'].toDate();
            selectedLocationName = reportData['ReportLocationName'];
            selectedLocationId = reportData['ReportLocationId'];
            selectedClientId = reportData['ReportClientId'];
            // selectedClientName = clientMap[selectedClientId];
            // uploads.add(reportData['ReportImage']);
          });
          if (selectedClientId != null) {
            String? ClientName =
                await fireStoreService.getClientName(selectedClientId);
            setState(() {
              selectedClientName = ClientName;
            });
          }
          if (reportData['ReportIsFollowUpRequired'] == false) {
            setState(() {
              shouldShowButton = false;
            });
          } else {
            setState(() {
              shouldShowButton = true;
            });
          }
          if (reportData['ReportImage'] != null) {
            // Add existing report images URLs to uploads list
            for (var imageUrl in reportData['ReportImage']) {
              setState(() {
                DisplayIMage.add({'type': 'image', 'url': imageUrl});
              });
            }
          }
          if (reportData['ReportVideo'] != null) {
            // Add existing report images URLs to uploads list
            for (var imageUrl in reportData['ReportVideo']) {
              print("ReportVideo1 ${imageUrl}");
              setState(() {
                DisplayVideo.add({'type': 'video', 'url': imageUrl});
              });
            }
          } else {
            print("ReportVideo is null");
          }
          print(reportData['ReportIsFollowUpRequired']);
        } else {
          setState(() {
            shouldShowButton = true;
          });
        }
      }
    }
    print("Report Data for ${widget.reportId} $reportData");
  }

  List<Map<String, dynamic>> uploads = [];
  List<Map<String, dynamic>> videouploads = [];

  Future<void> _addImage() async {
    List<XFile>? pickedFiles =
        await ImagePicker().pickMultiImage(imageQuality: 30); //quality was 30
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
  }

  Future<void> _addImageFromCamera() async {
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 30);
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
  }

  Future<void> _addVideoFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      try {
        File file = File(pickedFile.path);
        if (file.existsSync()) {
          setState(() {
            videouploads.add({'type': 'video', 'file': file});
          });
        } else {
          print('File does not exist: ${file.path}');
        }
      } catch (e) {
        print('Error adding video: $e');
      }
    } else {
      print('No video selected');
    }
  }

  Future<void> _addVideoFromGallery() async {
    try {
      // Pick a video from the gallery
      XFile? pickedFile =
          await ImagePicker().pickVideo(source: ImageSource.gallery);

      // Check if a file was picked
      if (pickedFile != null) {
        print('Video picked: ${pickedFile.path}');

        // Create a File object from the picked file
        File file = File(pickedFile.path);

        // Check if the file exists
        if (file.existsSync()) {
          print('File exists: ${file.path}');

          // Add the video to the list and update the state
          setState(() {
            videouploads.add({'type': 'video', 'file': file});
            print(
                'Video added to videouploads list. Total videos: ${videouploads.length}');
          });
        } else {
          print('File does not exist: ${file.path}');
        }
      } else {
        print('No video selected');
      }
    } catch (e) {
      // Print any error that occurs
      print('Error adding video: $e');
    }
  }

  Future<File> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + '_compressed.jpg',
      quality: 30,
    );
    return File(result!.path);
  }

  Future<void> onSubmit() async {
    try {
      //add to storage get its download links
    } catch (e) {
      print("Error $e");
    }
  }

  void _addVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        uploads.add({'type': 'video', 'file': File(result.files.single.path!)});
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      DisplayIMage.removeAt(index);
    });
  }

  void _deleteItem(int index) {
    setState(() {
      uploads.removeAt(index);
    });
  }

  void _handleDelete(int index) {
    setState(() {
      videouploads.removeAt(index); // Remove the video from the list
    });
  }

  Future<void> _selectDate(
      BuildContext context, bool isStart, bool isDate) async {
    final DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (dateTime != null) {
      setState(() {
        if (isStart) {
          StartDate = dateTime;
        } else if (isDate) {
          SelectedDate = dateTime;
        } else {
          EndDate = dateTime;
        }
      });
    }
  }

  // Initialize default value
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: reportData.isNotEmpty &&
                    reportData['ReportIsFollowUpRequired'] == true
                ? 'FollowUp for ${reportData['ReportName']} '
                : 'Report',
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    InterBold(
                      text: 'New Report',
                      fontsize: 20.sp,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                      letterSpacing: -.3,
                    ),
                    SizedBox(height: 30.h),
                    CustomeTextField(
                      hint: 'Title',
                      controller: titleController,
                      isEnabled: reportData.isNotEmpty &&
                              reportData['ReportIsFollowUpRequired'] == false
                          ? false
                          : true,
                    ),
                    SizedBox(height: 30.h),
                    InterBold(
                      text: 'Category',
                      fontsize: 20.sp,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                      letterSpacing: -.3,
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      height: 60.h,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          iconSize: 24.sp,
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                          borderRadius: BorderRadius.circular(10),
                          value: dropdownValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                              if (dropdownValue == 'Other') {
                                dropdownShoe = true;
                              } else {
                                dropdownShoe = false;
                              }
                              print('$dropdownValue selected');
                            });
                          },
                          items: <String?>[...tittles]
                              .map<DropdownMenuItem<String>>((String? value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value ?? ''),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    if (dropdownShoe) SizedBox(height: 20.h),
                    if (dropdownShoe)
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CustomeTextField(
                          hint: 'Create category',
                          isExpanded: true,
                          showIcon: false,
                          controller: newCategoryController,
                        ),
                      ),
                    SizedBox(height: 20.h),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor,
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: CustomeTextField(
                        hint: 'Explain',
                        isExpanded: true,
                        controller: explainController,
                        isEnabled: reportData.isNotEmpty &&
                                reportData['ReportIsFollowUpRequired'] == false
                            ? false
                            : true,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () async {
                        _selectDate(context, false, true);
                        // DateTime? dateTime =
                        //     await showOmniDateTimePicker(
                        //         context: context);
                      },
                      child: Container(
                        height: 60.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              blurRadius: 5,
                              spreadRadius: 2,
                              offset: Offset(0, 3),
                            )
                          ],
                          borderRadius: BorderRadius.circular(10.r),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InterMedium(
                              text: SelectedDate != null
                                  ? DateFormat('yyyy-MM-dd – kk:mm')
                                      .format(SelectedDate!)
                                  : 'Report Time',
                              fontsize: 16.w,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                            SvgPicture.asset(
                              'assets/images/calendar_clock.svg',
                              width: 20.w,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    !widget.isRoleGuard
                        ? Container(
                            height: 60.h,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: Offset(0, 3),
                                )
                              ],
                              borderRadius: BorderRadius.circular(10.r),
                              color: Theme.of(context).cardColor,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                iconSize: 24.w,
                                hint: InterMedium(
                                  text: "Select Client",
                                  fontsize: 16.w,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                ),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                  size: 24.sp,
                                ),
                                iconEnabledColor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                // Set icon color for enabled state
                                dropdownColor: Theme.of(context).cardColor,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color),
                                value: selectedClientName,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedClientName = newValue!;
                                    selectedClientId = clientMap.entries
                                        .firstWhere(
                                            (entry) => entry.value == newValue)
                                        .key;
                                    print(
                                        '$selectedClientName selected with ID: $selectedClientId');
                                  });
                                },
                                items: clientMap.entries
                                    .map<DropdownMenuItem<String>>((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.value,
                                    child: Row(
                                      children: [
                                        selectedClientName == entry.value
                                            ? Icon(
                                                Icons.account_circle_outlined,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color)
                                            : Icon(
                                                Icons.account_circle_outlined,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color),
                                        // Conditional icon color based on selection
                                        SizedBox(width: 10.w),
                                        InterRegular(
                                            text: entry.value,
                                            color: selectedClientName ==
                                                    entry.value
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color),
                                        // Conditional text color based on selection
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        : SizedBox(),
                    SizedBox(height: widget.isRoleGuard ? 0 : 20.h),
                    !widget.isRoleGuard
                        ? Container(
                            height: 60.h,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: Offset(0, 3),
                                )
                              ],
                              borderRadius: BorderRadius.circular(10.r),
                              color: Theme.of(context).cardColor,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: InterMedium(
                                  text: "Select Location",
                                  fontsize: 16.w,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                ),
                                iconSize: 24.w,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                  size: 24.sp,
                                ),
                                iconEnabledColor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                dropdownColor: Theme.of(context).cardColor,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color),
                                value: selectedLocationName,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedLocationName = newValue!;
                                    selectedLocationId = locationMap.entries
                                        .firstWhere(
                                            (entry) => entry.value == newValue)
                                        .key;
                                    print(
                                        '$selectedLocationName selected with ID: $selectedLocationId');
                                  });
                                },
                                items: locationMap.entries
                                    .map<DropdownMenuItem<String>>((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.value,
                                    child: Row(
                                      children: [
                                        selectedLocationName == entry.value
                                            ? Icon(Icons.location_on_outlined,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color)
                                            : Icon(Icons.location_on_outlined,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color),
                                        SizedBox(width: 10.w),
                                        SizedBox(
                                          width: 280.w,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: InterRegular(
                                                text: entry.value,
                                                color: selectedLocationName ==
                                                        entry.value
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color
                                                    : Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .color),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        : SizedBox(),
                    SizedBox(height: widget.isRoleGuard ? 0 : 20.h),
                    Container(
                      height: 60.h,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.follow_the_signs,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                size: 24.sp,
                              ),
                              SizedBox(width: 6.w),
                              InterMedium(
                                text: 'Follow-Up Required ?',
                                color: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .color,
                                fontsize: 16.sp,
                                letterSpacing: -.3,
                              )
                            ],
                          ),
                          Checkbox(
                            activeColor: Theme.of(context).primaryColor,
                            checkColor: DarkColor.color1,
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = !isChecked;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Row(
                            children: uploads.asMap().entries.map((entry) {
                              final index = entry.key;
                              final upload = entry.value;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    height: 66.h,
                                    width: 66.w,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    margin: EdgeInsets.all(8.sp),
                                    child: upload['type'] == 'image'
                                        ? Image.file(
                                            upload['file'],
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            Icons.videocam,
                                            size: 20.sp,
                                          ),
                                  ),
                                  Positioned(
                                    top: -5,
                                    right: -5,
                                    child: IconButton(
                                      onPressed: () => _deleteItem(index),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                        size: 20.sp,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.video_collection,
                                        size: 20.sp,
                                      ),
                                      title: InterRegular(
                                        text: 'Add Image from Camera',
                                        fontsize: 14.sp,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _addImageFromCamera();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.photo,
                                        size: 20.sp,
                                      ),
                                      title: InterRegular(
                                        text: 'Add Image from Gallery',
                                        fontsize: 14.sp,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _addImage();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.videocam,
                                        size: 20.sp,
                                      ),
                                      title: InterRegular(
                                        text: 'Add Video from Camera',
                                        fontsize: 14.sp,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _addVideoFromCamera();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.video_library,
                                        size: 20.sp,
                                      ),
                                      title: InterRegular(
                                        text: 'Add Video from Gallery',
                                        fontsize: 14.sp,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _addVideoFromGallery();
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
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? DarkColor.WidgetColor
                                    : LightColor.Primarycolor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Icon(
                                  color: Colors.white,
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
                    if (videouploads.isNotEmpty)
                      SizedBox(
                        height: 120.h,
                        // Set a suitable height for the grid
                        child: VideoGrid(
                          displayVideo: videouploads,
                          onDelete: (int) {
                            print("Delete CLicked");
                            _handleDelete(int);
                          },
                        ),
                      ),

                    if (DisplayIMage.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                        itemCount: DisplayIMage.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(DisplayIMage[index]['url']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    // if (DisplayVideo.isNotEmpty)
                    //   VideoGrid(
                    //     displayVideo: DisplayVideo,
                    //     onDelete: (int) {},
                    //   ),
                    // VideoGrid.builder(
                    //   shrinkWrap: true,
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 3,
                    //     mainAxisSpacing: 8.0,
                    //     crossAxisSpacing: 8.0,
                    //   ),
                    //   itemCount: DisplayVideo.length,
                    //   itemBuilder: (context, index) {
                    //     return Container(
                    //       decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //           image: NetworkImage(DisplayVideo[index]['url']),
                    //           fit: BoxFit.cover,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                    SizedBox(height: 60.h),
                    Visibility(
                      visible: shouldShowButton,
                      child: Button1(
                        height: 50.h,
                        text: reportData.isNotEmpty &&
                                reportData['ReportIsFollowUpRequired'] == true
                            ? 'Submit Followup'
                            : 'Submit',
                        color: Colors.white,
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          if (reportData['ReportIsFollowUpRequired'] == true) {
                            final newTItle = titleController.text.trim();
                            print("New Title ${titleController.text}");
                            print("New Data ${explainController.text}");
                            print("New Category ${dropdownValue}");
                            print("Checked $isChecked");
                            var id = await fireStoreService.getReportCategoryId(
                                dropdownValue, widget.companyID);
                            List<Map<String, dynamic>> imageList =
                                await Future.wait(
                              uploads.map(
                                (upload) async {
                                  if (upload['type'] == 'image') {
                                    // Upload the image and get its download URL
                                    List<Map<String, dynamic>> urls =
                                        await fireStoreService
                                            .addImageToReportStorage(
                                                upload['file']);
                                    // Add the download URL to the list of image URLs
                                    imageUrls.add(urls[0]['downloadURL']);
                                  }
                                  return {'type': upload['type']};
                                },
                              ),
                            );
                            List<Map<String, dynamic>> videoList =
                                await Future.wait(
                              videouploads.map(
                                (upload) async {
                                  if (upload['type'] == 'video') {
                                    // Upload the image and get its download URL
                                    List<Map<String, dynamic>> urls =
                                        await fireStoreService
                                            .addVideoToReportStorage(
                                                upload['file']);
                                    // Add the download URL to the list of image URLs
                                    videoUrls.add(urls[0]['downloadURL']);
                                  }
                                  return {'type': upload['type']};
                                },
                              ),
                            );
                            print("Video URls ${videoUrls}");
                            await fireStoreService.createReport(
                                locationId: !widget.isRoleGuard
                                    ? selectedLocationId ?? ""
                                    : widget.locationId,
                                locationName: !widget.isRoleGuard
                                    ? selectedLocationName ?? ""
                                    : widget.locationName,
                                isFollowUpRequired: isChecked,
                                companyId: widget.companyID,
                                employeeId: widget.empId,
                                employeeName: widget.empName,
                                reportName: titleController.text,
                                // Use existing report name
                                categoryName: dropdownValue,
                                // Use existing category name
                                categoryId: id ?? "",
                                data: explainController.text,
                                status: "completed",
                                clientId: !widget.isRoleGuard
                                    ? selectedClientId ?? ""
                                    : widget.ClientId,
                                followedUpId: widget.reportId,
                                image: imageUrls,
                                video: videoUrls,
                                createdAt: SelectedDate,
                                shiftId: widget.ShiftId,
                                companyBranchId: widget.BranchId);
                            if (isChecked == false) {
                              await fireStoreService
                                  .updateFollowUp(reportData['ReportId']);
                            }
                            setState(() {
                              _isLoading = false; // Set loading state
                            });
                            Navigator.pop(context, true);
                          } else if (dropdownValue == "Other") {
                            setState(() {
                              _isLoading = true; // Set loading state
                            });
                            var newId =
                                await fireStoreService.createReportCategoryId(
                                    newCategoryController.text,
                                    widget.companyID);
                            List<Map<String, dynamic>> imageList =
                                await Future.wait(uploads.map((upload) async {
                              if (upload['type'] == 'image') {
                                // Upload the image and get its download URL
                                List<Map<String, dynamic>> urls =
                                    await fireStoreService
                                        .addImageToReportStorage(
                                            upload['file']);
                                // Add the download URL to the list of image URLs
                                imageUrls.add(urls[0]['downloadURL']);
                              }
                              return {'type': upload['type']};
                            }));
                            List<Map<String, dynamic>> videoList =
                                await Future.wait(
                              videouploads.map(
                                (upload) async {
                                  if (upload['type'] == 'video') {
                                    // Upload the image and get its download URL
                                    List<Map<String, dynamic>> urls =
                                        await fireStoreService
                                            .addVideoToReportStorage(
                                                upload['file']);
                                    // Add the download URL to the list of image URLs
                                    videoUrls.add(urls[0]['downloadURL']);
                                  }
                                  return {'type': upload['type']};
                                },
                              ),
                            );
                            print("Video URls ${videoUrls}");
                            await fireStoreService.createReport(
                                locationId: !widget.isRoleGuard
                                    ? selectedLocationId ?? ""
                                    : widget.locationId,
                                locationName: !widget.isRoleGuard
                                    ? selectedLocationName ?? ""
                                    : widget.locationName,
                                isFollowUpRequired: isChecked,
                                companyId: widget.companyID,
                                employeeId: widget.empId,
                                employeeName: widget.empName,
                                reportName: titleController.text,
                                categoryName: newCategoryController.text,
                                categoryId: newId ?? "",
                                data: explainController.text,
                                status: "pending",
                                clientId: !widget.isRoleGuard
                                    ? selectedClientId ?? ""
                                    : widget.ClientId,
                                image: imageUrls,
                                video: videoUrls,
                                createdAt: SelectedDate,
                                shiftId: widget.ShiftId,
                                companyBranchId: widget.BranchId ?? "");
                            Navigator.pop(context, true);
                            setState(() {
                              _isLoading = false; // Set loading state
                            });
                            //create a new catergory and add its return its id
                          } else {
                            setState(() {
                              _isLoading = true; // Set loading state
                            });
                            // if (reportData['ReportIsFollowUpRequired'] == true) {
                            //   final newTItle = titleController.text.trim();
                            //   print("Dropdown value $dropdownValue");
                            //   // reportData['ReportCategoryName'] = dropdownValue;
                            //   // reportData['ReportName'] = titleController.text;
                            //   // reportData['ReportName'] = explainController.text;
                            //   // var id = await fireStoreService.getReportCategoryId(
                            //   //     dropdownValue, widget.companyID);
                            //   // await fireStoreService.createReport(
                            //   //     locationId: widget.locationId,
                            //   //     locationName: widget.locationName,
                            //   //     isFollowUpRequired: isChecked,
                            //   //     companyId: widget.companyID,
                            //   //     employeeId: widget.empId,
                            //   //     employeeName: widget.empName,
                            //   //     reportName: titleController
                            //   //         .text, // Use existing report name
                            //   //     categoryName: reportData[
                            //   //         'ReportCategoryName'], // Use existing category name
                            //   //     categoryId: id ?? "",
                            //   //     data: explainController.text,
                            //   //     status: "started",
                            //   //     clientId: widget.ClientId,
                            //   //     followedUpId: widget.reportId,
                            //   //     createdAt: Timestamp.now());
                            //   print('Report created on follow up');
                            // } else {
                            var id = await fireStoreService.getReportCategoryId(
                                dropdownValue, widget.companyID);
                            List<Map<String, dynamic>> imageList =
                                await Future.wait(uploads.map((upload) async {
                              if (upload['type'] == 'image') {
                                // Upload the image and get its download URL
                                List<Map<String, dynamic>> urls =
                                    await fireStoreService
                                        .addImageToReportStorage(
                                            upload['file']);
                                // Add the download URL to the list of image URLs
                                imageUrls.add(urls[0]['downloadURL']);
                              }
                              return {'type': upload['type']};
                            }));
                            List<Map<String, dynamic>> videoList =
                                await Future.wait(
                              videouploads.map(
                                (upload) async {
                                  if (upload['type'] == 'video') {
                                    // Upload the image and get its download URL
                                    List<Map<String, dynamic>> urls =
                                        await fireStoreService
                                            .addVideoToReportStorage(
                                                upload['file']);
                                    // Add the download URL to the list of image URLs
                                    videoUrls.add(urls[0]['downloadURL']);
                                  }
                                  return {'type': upload['type']};
                                },
                              ),
                            );
                            print("Video URls ${videoUrls}");
                            await fireStoreService.createReport(
                                locationId: !widget.isRoleGuard
                                    ? selectedLocationId ?? ""
                                    : widget.locationId,
                                locationName: !widget.isRoleGuard
                                    ? selectedLocationName ?? ""
                                    : widget.locationName,
                                isFollowUpRequired: isChecked,
                                companyId: widget.companyID,
                                employeeId: widget.empId,
                                employeeName: widget.empName,
                                reportName: titleController.text,
                                categoryName: dropdownValue,
                                categoryId: id ?? "",
                                data: explainController.text,
                                status: "pending",
                                clientId: !widget.isRoleGuard
                                    ? selectedClientId ?? ""
                                    : widget.ClientId,
                                image: imageUrls,
                                video: videoUrls,
                                createdAt: SelectedDate,
                                shiftId: widget.ShiftId,
                                companyBranchId: widget.BranchId);
                            // }
                            Navigator.pop(context, true);
                            setState(() {
                              _isLoading = false; // Set loading state
                            });
                            // Navigator.pop(context);
                          }
                          setState(() {
                            _isLoading = false; // Set loading state
                          });
                        },
                        backgroundcolor: Theme.of(context).primaryColor,
                        borderRadius: 10.r,
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Visibility(
                visible: _isLoading,
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
