import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

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
  }) : super(key: key);

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  bool shouldShowButton = false;
  List<String> imageUrls = [];
  List<Map<String, dynamic>> DisplayIMage = [];

  FireStoreService fireStoreService = FireStoreService();
  List<String> tittles = [];
  Map<String, dynamic> reportData = {};
  final TextEditingController explainController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();
  bool isChecked = false;
  String dropdownValue = 'Incident';
  bool dropdownShoe = false;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    getAllTitles();
    getAllReports();
    super.initState();
    shouldShowButton = widget.buttonEnable;
    print("Shift Id at Create Report ${widget.ShiftId}");
  }

  void getAllTitles() async {
    List<String> data = await fireStoreService.getReportTitles();
    if (data.isNotEmpty) {
      setState(() {
        tittles = [...data];
      });
    }
    print("Report Titles : $data");
    print("Getting all titles");
  }

  void getAllReports() async {
    if (widget.SearchId.isNotEmpty) {
      Map<String, dynamic>? data =
          (await fireStoreService.getReportWithSearchId(widget.SearchId));
      if (data != null) {
        setState(() {
          reportData = data;
          isChecked = reportData['ReportIsFollowUpRequired'];
          titleController.text = reportData['ReportName'];
          explainController.text = reportData['ReportData'];
          dropdownValue = reportData['ReportCategoryName'];
          // uploads.add(reportData['ReportImage']);
        });
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
        print(reportData['ReportIsFollowUpRequired']);
      }
    } else {
      Map<String, dynamic>? data =
          (await fireStoreService.getReportWithId(widget.reportId));
      if (data != null) {
        setState(() {
          reportData = data;
          isChecked = reportData['ReportIsFollowUpRequired'];
          titleController.text = reportData['ReportName'];
          explainController.text = reportData['ReportData'];
          dropdownValue = reportData['ReportCategoryName'];
          // uploads.add(reportData['ReportImage']);
        });
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
        print(reportData['ReportIsFollowUpRequired']);
      } else {
        setState(() {
          shouldShowButton = true;
        });
      }
    }
    print("Report Data for ${widget.reportId} $reportData");
  }

  List<Map<String, dynamic>> uploads = [];

  Future<void> _addImage() async {
    List<XFile>? pickedFiles =
        await ImagePicker().pickMultiImage(imageQuality: 30);
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
                      color:  Theme.of(context).textTheme.bodySmall!.color,
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
                        color:  Theme.of(context).cardColor,
                         borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          iconSize: 24.sp,
                          dropdownColor:  Theme.of(context).cardColor,
                          style: TextStyle(color:  Theme.of(context).textTheme.bodyLarge!.color),
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
                              color:Theme.of(context).shadowColor,
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
                        color:  Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.follow_the_signs,
                                color:  Theme.of(context).textTheme.bodyMedium!.color,
                                size: 24.sp,
                              ),
                              SizedBox(width: 6.w),
                              InterMedium(
                                text: 'Follow-Up Required ?',
                                color: Theme.of(context).textTheme.labelSmall!.color,
                                fontsize:16.sp,
                                letterSpacing: -.3,
                              )
                            ],
                          ),
                          Checkbox(
                            activeColor: DarkColor.Primarycolor,
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
                                        text: 'Add Image',
                                        fontsize: 14.sp,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _addImage();
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
                                color: isDark? DarkColor.WidgetColor : LightColor.Primarycolor,
                              borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Icon(
                                  color: Theme.of(context).textTheme.bodyMedium!.color,
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
                    SizedBox(height: 60.h),
                    Visibility(
                      visible: shouldShowButton,
                      child: Button1(
                        height: 50.h,
                        text: 'Submit',
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
                            await fireStoreService.createReport(
                                locationId: widget.locationId,
                                locationName: widget.locationName,
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
                                clientId: widget.ClientId,
                                followedUpId: widget.reportId,
                                image: imageUrls,
                                createdAt: Timestamp.now(),
                                shiftId: widget.ShiftId);
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
                            await fireStoreService.createReport(
                                locationId: widget.locationId,
                                locationName: widget.locationName,
                                isFollowUpRequired: isChecked,
                                companyId: widget.companyID,
                                employeeId: widget.empId,
                                employeeName: widget.empName,
                                reportName: titleController.text,
                                categoryName: newCategoryController.text,
                                categoryId: newId ?? "",
                                data: explainController.text,
                                status: "pending",
                                clientId: widget.ClientId,
                                image: imageUrls,
                                createdAt: Timestamp.now(),
                                shiftId: widget.ShiftId);
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
                            await fireStoreService.createReport(
                                locationId: widget.locationId,
                                locationName: widget.locationName,
                                isFollowUpRequired: isChecked,
                                companyId: widget.companyID,
                                employeeId: widget.empId,
                                employeeName: widget.empName,
                                reportName: titleController.text,
                                categoryName: dropdownValue,
                                categoryId: id ?? "",
                                data: explainController.text,
                                status: "pending",
                                clientId: widget.ClientId,
                                image: imageUrls,
                                createdAt: Timestamp.now(),
                                shiftId: widget.ShiftId);
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
                        backgroundcolor: isDark
                            ? DarkColor.Primarycolor
                            : LightColor.Primarycolor,
                         borderRadius: 10.r,
                      ),
                    ),
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
