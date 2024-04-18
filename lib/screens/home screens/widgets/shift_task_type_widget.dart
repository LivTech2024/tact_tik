import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class ShiftTaskTypeWidget extends StatefulWidget {
  final Function refreshDataCallback;
  ShiftTaskTypeWidget({
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

  @override
  State<ShiftTaskTypeWidget> createState() => _ShiftTaskTypeWidgetState();
}

class _ShiftTaskTypeWidgetState extends State<ShiftTaskTypeWidget> {
  List<Map<String, dynamic>> uploads = [];
  bool _isLoading = false;
  Future<void> _addImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // await fireStoreService
      //     .addImageToStorageShiftTask(File(pickedFile.path));
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
    }
    print("Statis ${widget.taskStatus}");
  }

  void _uploadImages() async {
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
        await fireStoreService.addImagesToShiftTasks(
          uploads,
          widget.taskId ?? "",
          widget.ShiftId ?? "",
          widget.EmpID ?? "",
          widget.EmpName,
          widget.shiftReturnTask,
        );
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
              color: color15,
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
                        color: color16,
                        borderRadius: BorderRadius.circular(width / width10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: width / width24,
                          color: Primarycolor,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width / width20,
                    ),
                    InterRegular(
                      text: widget.taskName,
                      color: color17,
                      fontsize: width / width18,
                    ),
                  ],
                ),
                Container(
                  height: height / height34,
                  width: width / width34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color16,
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
                        color: color18,
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
                                const SimpleBarcodeScannerPage(),
                          ));
                      setState(() {
                        Result = res;
                      });
                      if (Result == widget.taskId) {
                        await fireStoreService.updateShiftTaskStatus(
                            widget.taskId, widget.EmpID, widget.EmpName);
                        //Update in firebase and change the color of icon
                        // showCustomDialog(context, "Task Scan",
                        //     "Task Scan SuccessFull for ${widget.taskName}");
                        showSuccessToast(context,
                            "Task Scan SuccessFull for ${widget.taskName}");
                        print("${Result} ${widget.taskId}");
                        widget.refreshDataCallback();
                        // showSuccessToast(context, "${widget.}")
                      } else {
                        // showCustomDialog(context, "Task Scan",
                        //     "Shift Task Scan UnsuccessFull for ${widget.taskName}");
                        showErrorToast(context,
                            "Task Scan Unsuccessfull for ${widget.taskName}");
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
                        color: color15,
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
                                  color: color16,
                                  borderRadius:
                                      BorderRadius.circular(width / width10),
                                ),
                                child: Center(
                                  child: Icon(
                                    widget.shiftReturnTask == true
                                        ? widget.ShiftTaskReturnStatus == true
                                            ? Icons.done
                                            : Icons.add_a_photo
                                        : widget.taskStatus == "completed" ||
                                                widget.ShiftTaskReturnStatus ==
                                                    true
                                            ? Icons.done
                                            : Icons.add_a_photo,
                                    size: width / width24,
                                    color: Primarycolor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width / width20,
                              ),
                              InterRegular(
                                text: widget.taskName,
                                color: color17,
                                fontsize: width / width18,
                              ),
                            ],
                          ),
                          Container(
                            height: height / height34,
                            width: width / width34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color16,
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
                                  color: color18,
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
                  SizedBox(height: 10),
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
                                    color: WidgetColor,
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
                        onTap: () {
                          _addImage();
                          // showModalBottomSheet(
                          //   context: context,
                          //   builder: (context) => Column(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       ListTile(
                          //         leading: Icon(Icons.camera),
                          //         title: Text('Add Image'),
                          //         onTap: () {
                          //           Navigator.pop(context);
                          //         },
                          //       ),
                          //       // ListTile(
                          //       //   leading: Icon(Icons.video_collection),
                          //       //   title: Text('Add Video'),
                          //       //   onTap: () {
                          //       //     Navigator.pop(context);
                          //       //     _addVideo();
                          //       //   },
                          //       // ),
                          //     ],
                          //   ),
                          // );
                        },
                        child: Container(
                          height: height / height66,
                          width: width / width66,
                          decoration: BoxDecoration(
                              color: WidgetColor,
                              borderRadius:
                                  BorderRadius.circular(width / width8)),
                          child: Center(
                            child: Icon(Icons.add),
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        onPressed: _uploadImages,
                        backgroundColor: Primarycolor,
                        shape: CircleBorder(),
                        child: Icon(Icons.cloud_upload),
                      )
                    ],
                  ),
                  if (_isLoading)
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 10),
                      child: CircularProgressIndicator(),
                    ),
                ],
              )
            : SizedBox();
  }
}
