import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:toastification/toastification.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class ReportCheckpointScreen extends StatefulWidget {
  final String CheckpointID;
  final String PatrolID;
  final String ShiftId;
  final String empId;

  const ReportCheckpointScreen(
      {super.key,
      required this.CheckpointID,
      required this.PatrolID,
      required this.ShiftId,
      required this.empId});

  @override
  State<ReportCheckpointScreen> createState() => _ReportCheckpointScreenState();
}

FireStoreService fireStoreService = FireStoreService();

class _ReportCheckpointScreenState extends State<ReportCheckpointScreen> {
  bool _expand = false;
  late Map<String, bool> _expandCategoryMap;
  TextEditingController Controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadShiftStartedState();
    // // Initialize expand state for each category
    // _expandCategoryMap = Map.fromIterable(widget.p.categories,
    //     key: (category) => category.title, value: (_) => false);
  }

  void _loadShiftStartedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _expand = prefs.getBool('expand') ?? false;
    });
  }

  List<Map<String, dynamic>> uploads = [];

  void _deleteItem(int index) {
    setState(() {
      uploads.removeAt(index);
    });
  }

  Future<void> _addImage() async {
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 40);
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
    List<XFile>? pickedFiles =
        await ImagePicker().pickMultiImage(imageQuality: 40);
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

  // Future<File> _compressImage(File file) async {
  //   final result = await FlutterImageCompress.compressAndGetFile(
  //     file.absolute.path,
  //     file.absolute.path + '_compressed.jpg',
  //     quality: 1,
  //   );
  //   return File(result!.path);
  // }

  Future<File> _compressImage(File file) async {
    int quality = 90; // Starting quality
    int minWidth = 800; // Minimum width to reduce resolution step by step
    int minHeight = 800; // Minimum height to reduce resolution step by step
    XFile? result;
    do {
      result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        file.absolute.path + '_compressed.jpg',
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );

      if (result != null && File(result.path).lengthSync() <= 100 * 1024) {
        break;
      }

      quality -= 10;
      minWidth = (minWidth * 0.9).toInt(); // Reduce resolution by 10%
      minHeight = (minHeight * 0.9).toInt();

      if (quality <= 0 || minWidth <= 0 || minHeight <= 0) {
        break; // Stop if quality or resolution goes to 0
      }
    } while (result == null || File(result.path).lengthSync() > 100 * 1024);

    if (result == null || File(result.path).lengthSync() > 100 * 1024) {
      throw Exception('Could not compress image to under 100 KB.');
    }

    return File(result.path);
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
         
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
             
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterMedium(
            text: 'Report Checkpoint',
        
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height / height30),
                    Text(
                      'Add Image/Comment',
                      style: TextStyle(
                        fontSize: width / width14,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height / height10),
                    // Row(
                    //   children: [
                    //     Radio(
                    //       activeColor: Primarycolor,
                    //       value: 'Emergency',
                    //       groupValue: selectedOption,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           selectedOption = value!;
                    //         });
                    //       },
                    //     ),
                    //     InterRegular(
                    //       text: 'Emergency',
                    //       fontsize: width / width16,
                    //       color: color1,
                    //     )
                    //   ],
                    // ),
                    // Row(
                    //   children: [
                    //     Radio(
                    //       activeColor: Primarycolor,
                    //       value: 'Normal',
                    //       groupValue: selectedOption,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           selectedOption = value!;
                    //         });
                    //       },
                    //     ),
                    //     InterRegular(
                    //       text: 'Normal',
                    //       fontsize: width / width16,
                    //       color: color1,
                    //     )
                    //   ],
                    // ),
                    SizedBox(height: height / height10),
                    TextField(
                      controller: Controller,
                      decoration: InputDecoration(
                        hintText: 'Add Comment',
                      ),
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                    SizedBox(height: height / height20),
                    GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: width / width10,
                        mainAxisSpacing: height / height10,
                        crossAxisCount: 3,
                      ),
                      itemCount: uploads.length + 1,
                      itemBuilder: (context, index) {
                        if (index == uploads.length) {
                          return GestureDetector(
                            onTap: () {
                              // _refresh();
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
                                        _addGallery();
                                        Navigator.pop(context);
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
                                color: Colors.grey.withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.circular(width / width10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: width / width20,
                                    color: Theme.of(context).textTheme.bodyMedium!.color,
                                  ),
                                  SizedBox(height: height / height10),
                                  InterMedium(
                                    text: 'Add Image',
                                    fontsize: width / width16,
                                    color: DarkColor.color1,
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          final upload = uploads[index];
                          return Container(
                            height: height / height66,
                            width: width / width66,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius:
                                  BorderRadius.circular(width / width10),
                            ),
                            // margin: EdgeInsets.all(width / width8),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.file(
                                    upload['file'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    onPressed: () {
                                      _deleteItem(index - 1);
                                    },
                                    icon: Icon(Icons.cancel),
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: height / height100)
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: DarkColor.Primarycolor,
                    ),
                  ),
                ),
              Align(
                // bottom: 10,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button1(
                      text: 'Submit',
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        if (uploads.isNotEmpty || Controller.text.isNotEmpty) {
                          await fireStoreService.addImagesToPatrol(
                              uploads,
                              Controller.text,
                              widget.PatrolID,
                              widget.empId,
                              widget.CheckpointID,
                              widget.ShiftId);
                          toastification.show(
                            context: context,
                            type: ToastificationType.success,
                            title: Text("Submitted"),
                            autoCloseDuration: const Duration(seconds: 2),
                          );

                          uploads.clear();
                          Controller.clear();
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                        } else {
                          showErrorToast(context, "Fields cannot be empty");
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      color: Colors.white,
                      borderRadius: width / width20,
                      backgroundcolor: Theme.of(context).primaryColor,
                    ),
                    SizedBox(
                      height: height / height20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
