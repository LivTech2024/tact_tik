import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  final String empName;
  final String reportId;

  CreateReportScreen(
      {super.key,
      required this.locationId,
      required this.locationName,
      required this.companyID,
      required this.empId,
      required this.empName,
      required this.ClientId,
      required this.reportId});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  bool shouldShowButton = true;
  List<String> imageUrls = [];
  FireStoreService fireStoreService = FireStoreService();
  List<String> tittles = [];
  Map<String, dynamic> reportData = {};
  final TextEditingController explainController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();
  bool isChecked = false;
  String dropdownValue = 'Other';
  bool dropdownShoe = false;

  @override
  void initState() {
    // TODO: implement initState
    getAllTitles();
    getAllReports();
    super.initState();
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
    Map<String, dynamic>? data =
        (await fireStoreService.getReportWithId(widget.reportId))!;
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
      }
      // if (reportData['ReportImage'] is List<dynamic>) {
      //   // Add existing report images URLs to uploads list
      //   for (var imageUrl in reportData['ReportImage']) {
      //     setState(() {
      //       uploads.add({'type': 'image', 'url': imageUrl});
      //     });
      //   }
      // }
      print(reportData['ReportIsFollowUpRequired']);
    }
    print("Report Data for ${widget.reportId} $reportData");
  }

  List<Map<String, dynamic>> uploads = [];

  Future<void> _addImage() async {
    List<XFile>? pickedFiles =
        await ImagePicker().pickMultiImage(imageQuality: 50);
    if (pickedFiles != null) {
      for (var pickedFile in pickedFiles) {
        File file = File(pickedFile.path);
        File compressedFile = await _compressImage(file);
        setState(() {
          uploads.add({'type': 'image', 'file': file});
        });
      }
    }
  }

  Future<File> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + '_compressed.jpg',
      quality: 50,
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

  Future<void> _addVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );
    if (result != null) {
      setState(() {
        uploads.add({'type': 'video', 'file': File(result.files.single.path!)});
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      uploads.removeAt(index);
    });
  }

  // Initialize default value
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    bool _isLoading = false;
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        appBar: AppBar(
          backgroundColor:
              isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? DarkColor.color1 : LightColor.color3,
              size: width / width24,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: reportData.isNotEmpty &&
                    reportData['ReportIsFollowUpRequired'] == true
                ? 'FollowUp for ${reportData['ReportName']} '
                : 'Report',
            fontsize: width / width18,
            color: isDark ? DarkColor.color1 : LightColor.color3,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width / width30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height / height30),
                InterBold(
                  text: 'New Report',
                  fontsize: width / width20,
                  color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                  letterSpacing: -.3,
                ),
                SizedBox(height: height / height30),
                CustomeTextField(
                  hint: 'Tittle',
                  controller: titleController,
                  isEnabled: reportData.isNotEmpty &&
                          reportData['ReportIsFollowUpRequired'] == false
                      ? false
                      : true,
                ),
                SizedBox(height: height / height30),
                InterBold(
                  text: 'Category',
                  fontsize: width / width20,
                  color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                  letterSpacing: -.3,
                ),
                SizedBox(height: height / height20),
                Container(
                  height: height / height60,
                  padding: EdgeInsets.symmetric(horizontal: width / width20),
                  decoration: BoxDecoration(
                    color:
                        isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                    borderRadius: BorderRadius.circular(width / width10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      iconSize: width / width24,
                      dropdownColor: isDark
                          ? DarkColor.WidgetColor
                          : LightColor.WidgetColor,
                      style: TextStyle(
                          color: isDark ? DarkColor.color2 : LightColor.color3),
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
                if (dropdownShoe) SizedBox(height: height / height20),
                if (dropdownShoe)
                  CustomeTextField(
                    hint: 'Create category',
                    isExpanded: true,
                    showIcon: false,
                    controller: newCategoryController,
                  ),
                SizedBox(height: height / height20),
                CustomeTextField(
                  hint: 'Explain',
                  isExpanded: true,
                  controller: explainController,
                  isEnabled: reportData.isNotEmpty &&
                          reportData['ReportIsFollowUpRequired'] == false
                      ? false
                      : true,
                ),
                SizedBox(height: height / height20),
                Container(
                  height: height / height60,
                  padding: EdgeInsets.symmetric(horizontal: width / width20),
                  decoration: BoxDecoration(
                    color:
                        isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                    borderRadius: BorderRadius.circular(width / width10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.follow_the_signs,
                            color: isDark
                                ? DarkColor.color2
                                : LightColor.Primarycolor,
                            size: width / width24,
                          ),
                          SizedBox(width: width / width6),
                          InterMedium(
                            text: 'Follow-Up Required ?',
                            color:
                                isDark ? DarkColor.color8 : LightColor.color3,
                            fontsize: width / width16,
                            letterSpacing: -.3,
                          )
                        ],
                      ),
                      Checkbox(
                        activeColor: isDark
                            ? DarkColor.Primarycolor
                            : LightColor.Primarycolor,
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
                SizedBox(height: height / height20),
                Row(
                  children: [
                    Row(
                      children: uploads.asMap().entries.map((entry) {
                        final index = entry.key;
                        final upload = entry.value;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: height / height66,
                              width: width / width66,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? DarkColor.WidgetColor
                                    : LightColor.WidgetColor,
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
                                onPressed: () => _deleteItem(index),
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
                      onTap: () {
                        showModalBottomSheet(
                          backgroundColor: isDark
                              ? DarkColor.Secondarycolor
                              : LightColor.Secondarycolor,
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.photo,
                                  size: width / width20,
                                ),
                                title: InterRegular(
                                  color: isDark
                                      ? DarkColor.color1
                                      : LightColor.color3,
                                  text: 'Add Image',
                                  fontsize: width / width14,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _addImage();
                                },
                              ),
                              // ListTile(
                              //   leading: Icon(
                              //     Icons.video_collection,
                              //     size: width / width20,
                              //   ),
                              //   title: InterRegular(
                              //     text: 'Add Video',
                              //     fontsize: width / width14,
                              //   ),
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     _addVideo();
                              //   },
                              // ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        height: height / height66,
                        width: width / width66,
                        decoration: BoxDecoration(
                          color: isDark
                              ? DarkColor.WidgetColor
                              : LightColor.WidgetColor,
                          borderRadius: BorderRadius.circular(width / width8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: width / width20,
                            color:
                                isDark ? DarkColor.color1 : LightColor.color3,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: height / height60),
                Visibility(
                  visible: shouldShowButton,
                  child: Button1(
                    text: 'Submit',
                    onPressed: () async {
                      if (reportData['ReportIsFollowUpRequired'] == true) {
                        setState(() {
                          _isLoading = true;
                        });
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
                                    .addImageToReportStorage(upload['file']);
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
                            reportName: titleController
                                .text, // Use existing report name
                            categoryName: dropdownValue,
                            // Use existing category name
                            categoryId: id ?? "",
                            data: explainController.text,
                            status: "completed",
                            clientId: widget.ClientId,
                            followedUpId: widget.reportId,
                            image: imageUrls,
                            createdAt: Timestamp.now());
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
                                newCategoryController.text, widget.companyID);
                        List<Map<String, dynamic>> imageList =
                            await Future.wait(uploads.map((upload) async {
                          if (upload['type'] == 'image') {
                            // Upload the image and get its download URL
                            List<Map<String, dynamic>> urls =
                                await fireStoreService
                                    .addImageToReportStorage(upload['file']);
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
                            status: "started",
                            clientId: widget.ClientId,
                            image: imageUrls,
                            createdAt: Timestamp.now());
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
                                    .addImageToReportStorage(upload['file']);
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
                            status: "started",
                            clientId: widget.ClientId,
                            image: imageUrls,
                            createdAt: Timestamp.now());
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
                    borderRadius: width / width10,
                    color: isDark ? DarkColor.color1 : LightColor.color1,
                  ),
                ),
                if (_isLoading)
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: height / height10),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
