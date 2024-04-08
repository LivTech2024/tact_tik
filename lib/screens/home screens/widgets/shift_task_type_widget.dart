import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../common/enums/shift_task_enums.dart';
import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

final today = DateUtils.dateOnly(DateTime.now());

class ShiftTaskTypeWidget extends StatefulWidget {
  ShiftTaskTypeWidget({super.key, required this.type});

  final ShiftTaskEnum type;

  @override
  State<ShiftTaskTypeWidget> createState() => _ShiftTaskTypeWidgetState();
}

class _ShiftTaskTypeWidgetState extends State<ShiftTaskTypeWidget> {
  List<Map<String, dynamic>> uploads = [];

  Future<void> _addImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
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
  void _toggleSelection(int index) {
    setState(() {
      if (uploads[index].containsKey('isSelected')) {
        uploads[index].remove('isSelected');
      } else {
        uploads[index]['isSelected'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

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
                      text: 'Keys',
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
        : widget.type == ShiftTaskEnum.upload
            ? Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.photo),
                              title: Text('Add Image'),
                              onTap: () {
                                Navigator.pop(context);
                                _addImage();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.video_collection),
                              title: Text('Add Video'),
                              onTap: () {
                                Navigator.pop(context);
                                _addVideo();
                              },
                            ),
                          ],
                        ),
                      );
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
                                    Icons.add_a_photo,
                                    size: width / width24,
                                    color: Primarycolor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width / width20,
                              ),
                              InterRegular(
                                text: 'Car Image',
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
                                      onPressed: () =>  _deleteItem(index),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              );
  })
                            .toList(),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.photo),
                                  title: Text('Add Image'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _addImage();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.video_collection),
                                  title: Text('Add Video'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _addVideo();
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
                              color: WidgetColor,
                              borderRadius:
                                  BorderRadius.circular(width / width8)),
                          child: Center(
                            child: Icon(Icons.add),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              )
            : SizedBox();
  }
}