import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/common/widgets/customToast.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';

import '../../../common/enums/shift_task_enums.dart';
import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

final today = DateUtils.dateOnly(DateTime.now());

class ShiftTaskReturnTypeWidget extends StatefulWidget {
  final Function refreshDataCallback;
  ShiftTaskReturnTypeWidget({
    Key? key,
    required this.type,
    required this.taskName,
    required this.taskId,
    required this.ShiftId,
    required this.taskStatus,
    required this.EmpID,
    required this.shiftReturnTask,
    required this.refreshDataCallback,
    required this.EmpName,
    required this.ShiftTaskReturnStatus,
    required this.taskPhotos,
    required this.commentController,
  }) : super(key: key);

  final ShiftTaskEnum type;
  final String taskStatus;
  final String taskName;
  final String taskId;
  final bool ShiftTaskReturnStatus;
  final String ShiftId;
  final String EmpID;
  final String EmpName;
  final bool shiftReturnTask;
  final List<String> taskPhotos;
  final TextEditingController commentController;

  @override
  State<ShiftTaskReturnTypeWidget> createState() =>
      _ShiftTaskReturnTypeWidgetState();
}

class _ShiftTaskReturnTypeWidgetState extends State<ShiftTaskReturnTypeWidget> {
  List<Map<String, dynamic>> uploads = [];
  bool _isLoading = false;
  Future<void> _addImage() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: Platform.isIOS ? 40 : 50);
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
    print("Status ${uploads}");
  }

  Future<void> _addGallery() async {
    List<XFile>? pickedFiles = await ImagePicker()
        .pickMultiImage(imageQuality: Platform.isIOS ? 40 : 50);
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

  Future<File> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + '_compressed.jpg',
      quality: 30,
    );
    return File(result!.path);
  }

  void _uploadImages() async {
    // if (uploads.isEmpty ||
    //     widget.ShiftId.isEmpty ||
    //     widget.taskId.isEmpty ||
    //     widget.EmpID.isEmpty) {
    //   showErrorToast(context, "No Images found or missing data");
    //   print('No images to upload or missing data.');
    //   return;
    // }
    if (uploads.isNotEmpty || widget.commentController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      print("Uploads Images  $uploads");
      try {
        print("Task Id : ${widget.taskId}");
        await fireStoreService.addImagesToShiftReturnTasks(
            uploads,
            widget.taskId,
            widget.ShiftId,
            widget.EmpID,
            widget.EmpName,
            widget.shiftReturnTask,
            widget.commentController.text);
        uploads.clear();
        showSuccessToast(context, "Uploaded Successfully");
        widget.refreshDataCallback();
      } catch (e) {
        showErrorToast(context, "$e");
        print('Error uploading images: $e');
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      showErrorToast(context, "No Images found or missing data");
    }
  }

  void _uploadfromGallery() async {
    if (uploads.isNotEmpty ||
        widget.ShiftId.isNotEmpty ||
        widget.taskId.isNotEmpty ||
        widget.EmpID.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      print("Uploads Images  ${uploads}");
      try {
        print("Task Id : ${widget.taskId}");
        await fireStoreService.addImagesToShiftReturnTasks(
            uploads,
            widget.taskId ?? "",
            widget.ShiftId ?? "",
            widget.EmpID ?? "",
            widget.EmpName,
            widget.shiftReturnTask,
            widget.commentController.text);
        uploads.clear();
        showSuccessToast(context, "Uploaded Successfully");
        widget.refreshDataCallback();
        // widget.refreshDataCallback();

        // Navigator.pop(context);
      } catch (e) {
        showErrorToast(context, "${e}");
        print('Error uploading images: $e');
      }
      setState(() {
        _isLoading = false;
      });
      widget.refreshDataCallback();
    } else {
      widget.refreshDataCallback();
      showErrorToast(context, "No Images found");
      print('No images to upload.');
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
    widget.refreshDataCallback();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (uploads[index].containsKey('isSelected')) {
        uploads[index].remove('isSelected');
      } else {
        uploads[index]['isSelected'] = true;
      }
    });
    // widget.refreshDataCallback();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    String Result = "";
    return widget.type == ShiftTaskEnum.scan
        ? Container(
            height: height / height70,
            padding: EdgeInsets.symmetric(
              horizontal: width / width20,
              vertical: height / height11,
            ),
            margin: EdgeInsets.only(top: height / height10),
            decoration: BoxDecoration(
              color: DarkColor.color15,
              borderRadius: BorderRadius.circular(width / width10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: height / height48,
                      width: width / width48,
                      decoration: BoxDecoration(
                        color: DarkColor.color16,
                        borderRadius: BorderRadius.circular(width / width10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: width / width24,
                          color: DarkColor.Primarycolor,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width / width20,
                    ),
                    InterRegular(
                      text: widget.taskName,
                      color: DarkColor.color17,
                      fontsize: width / width18,
                    ),
                  ],
                ),
                Container(
                  height: height / height34,
                  width: width / width34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DarkColor.color16,
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Report Qr',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                'The scanned QR code does work.',
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // fireStoreService.updatePatrolsReport(
                                    //     movie
                                    //         .PatrolAssignedGuardId,
                                    //     movie
                                    //         .patrolId,
                                    //     checkpoint[
                                    //         'CheckPointId']);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Submit'),
                                ),
                              ],
                            );
                          },
                        );
                        print("Info Icon Pressed");
                        widget.refreshDataCallback();
                      },
                      icon: Icon(
                        Icons.info,
                        color: DarkColor.color18,
                        size: width / width24,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                )
              ],
            ),
          )
        : widget.type ==
                ShiftTaskEnum.upload //this will be used for both Scan and qr
            ? Column(
                children: [
                  GestureDetector(
                    onTap: () async {
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
                      // showSuccessToast(context, "Scanned Id ${res}");
                      // showSuccessToast(context, "Task Id ${widget.taskId}");

                      if (Result.toString() == widget.taskId.toString()) {
                        await fireStoreService.updateShiftReturnTaskStatus(
                            widget.taskId,
                            widget.EmpID,
                            widget.ShiftId,
                            widget.EmpName);

                        //Update in firebase and change the color of icon
                        // showCustomDialog(context, "Task Scan",
                        //     "Task Scan SuccessFull for ${widget.taskName}");
                        showSuccessToast(context,
                            "Task Scan SuccessFull for ${widget.taskId}");
                        print("${Result} ${widget.taskId}");
                        widget.refreshDataCallback();
                        // showSuccessToast(context, "${widget.}")
                      } else {
                        // showCustomDialog(context, "Task Scan",
                        //     "Shift Task Scan UnsuccessFull for ${widget.taskName}");
                        showErrorToast(context,
                            "Task Scan Unsuccessfull for ${widget.taskId}");
                        print("UNcessfull Scan");
                        widget.refreshDataCallback();
                      }
                    },
                    child: Container(
                      height: height / height70,
                      padding: EdgeInsets.symmetric(
                        horizontal: width / width20,
                        vertical: height / height11,
                      ),
                      margin: EdgeInsets.only(top: height / height10),
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
                        borderRadius: BorderRadius.circular(width / width10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: height / height48,
                                width: width / width48,
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
                                  borderRadius:
                                      BorderRadius.circular(width / width10),
                                ),
                                child: Center(
                                  child: Icon(
                                    // widget.shiftReturnTask == true
                                    // ? widget.ShiftTaskReturnStatus == true
                                    //     ? Icons.done
                                    //     : Icons.add_a_photo
                                    widget.taskStatus == "completed" ||
                                            widget.ShiftTaskReturnStatus == true
                                        ? Icons.done
                                        : Icons.add_a_photo,
                                    size: width / width24,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width / width20,
                              ),
                              SizedBox(
                                width: 220.w,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: InterRegular(
                                    text: widget.taskName,
                                    color: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .color,
                                    fontsize: 18.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: height / height34,
                            width: width / width34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Theme.of(context).textTheme.titleLarge!.color,
                            ),
                            child: Center(
                              child: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Report Qr',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: Text(
                                          'The scanned QR code does work.',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // fireStoreService.updatePatrolsReport(
                                              //     movie
                                              //         .PatrolAssignedGuardId,
                                              //     movie
                                              //         .patrolId,
                                              //     checkpoint[
                                              //         'CheckPointId']);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Submit'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  print("Info Icon Pressed");
                                  widget.refreshDataCallback();
                                },
                                icon: Icon(
                                  Icons.info,
                                  color: DarkColor.color18,
                                  size: width / width24,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height / height10),
                  TextField(
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 20.sp,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .color, // Change text color to white
                    ),
                    controller: widget.commentController,
                    decoration: InputDecoration(
                      focusColor: Theme.of(context).primaryColor,
                      labelText: 'Add Comment',
                      hintStyle: GoogleFonts.poppins(
                        // fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color, // Change text color to white
                      ),
                      labelStyle: GoogleFonts.poppins(
                        // fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color, // Change text color to white
                      ),
                      hintText: 'Add Comment',
                      /*enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),*/
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: height / height10),
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
                                  height: height / height66,
                                  width: width / width66,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(
                                        width / width10,
                                      )),
                                  margin: EdgeInsets.all(width / width8),
                                  child: upload['type'] == 'image'
                                      ? Image.file(
                                          upload['file'],
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(Icons.videocam),
                                ),
                                Positioned(
                                  top: -5,
                                  right: -5,
                                  child: IconButton(
                                    onPressed: () => _deleteItem(index),
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        GestureDetector(
                          onTap: () async {
                            bool showGallery = await fireStoreService
                                .showGalleryOption(widget.EmpID);

                            print("showGallery ${showGallery}");
                            // _addImage();
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
                                  if (showGallery)
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
                          child: Container(
                            height: height / height66,
                            width: width / width66,
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius:
                                    BorderRadius.circular(width / width8)),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: _uploadImages,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.cloud_upload,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  if (widget.taskPhotos.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.taskPhotos.map((photoUrl) {
                          return Container(
                            height: height / height66,
                            width: width / width66,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius:
                                  BorderRadius.circular(width / width10),
                            ),
                            margin: EdgeInsets.all(width / width8),
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  if (_isLoading)
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: height / height10),
                      child: CircularProgressIndicator(),
                    ),
                ],
              )
            : SizedBox();
  }
}
