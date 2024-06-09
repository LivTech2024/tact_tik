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
import 'package:tact_tik/screens/feature%20screens/widgets/custome_textfield.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
// import '../widgets/custome_textfield.dart';

class CreateDiscrepancyScreen extends StatefulWidget {
  

  CreateDiscrepancyScreen({
    Key? key,
  
  }) : super(key: key);

  @override
  State<CreateDiscrepancyScreen> createState() => _CreateDiscrepancyScreenState();
}

class _CreateDiscrepancyScreenState extends State<CreateDiscrepancyScreen> {
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
      quality: 10,
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
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Create Discrepancy',
           
          ),
          centerTitle: true,
        ),
        bottomSheet: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical:10,
          ),
          color: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor  ,
          child: Button1(
                        text: 'Done',
                        onPressed: (){},
                        backgroundcolor: isDark? DarkColor.Primarycolor:LightColor.Primarycolor,
                        borderRadius: width / width10,
                      ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height / height30),
                    InterBold(
                      text: '11/02/2024',
                      fontsize: width / width20,
                      color:
                          isDark ? DarkColor.Primarycolor : LightColor.color3,
                      letterSpacing: -.3,
                    ),
                    SizedBox(height: height / height30),
                    CustomeTextField(
                      hint: 'Title',
                      controller: titleController,
                      isEnabled: 
                           true,
                           showIcon: false,
                    ),
                    
                    
                    SizedBox(height: height / height20),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.transparent
                                : LightColor.color3.withOpacity(.05),
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
            
                   
                    SizedBox(height: height / height20),
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
                                context: context,
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.video_collection,
                                        size: width / width20,
                                      ),
                                      title: InterRegular(
                                        text: 'Add Image from Camera',
                                        fontsize: width / width14,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _addImageFromCamera();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.photo,
                                        size: width / width20,
                                      ),
                                      title: InterRegular(
                                        text: 'Add Image',
                                        fontsize: width / width14,
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
                              height: 66.w,
                              width: 66.w,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? DarkColor.WidgetColor
                                    : LightColor.Primarycolor,
                                borderRadius:
                                    BorderRadius.circular(width / width8),
                              ),
                              child: Center(
                                child: Icon(
                                  color: isDark
                                      ? DarkColor.color1
                                      : LightColor.color3,
                                  Icons.add,
                                  size: width / width20,
                                ),
                              ),
                            ),
                          )
                        ],
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
                          return Stack(
                            children: [
                              Image.network(
                                DisplayIMage[index]['url'],
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // IconButton(
                                    //   onPressed: () {
                                    //     _removeImage(index);
                                    //   },
                                    //   icon: const Icon(
                                    //     Icons.delete,
                                    //     color: Colors.white,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    SizedBox(height: height / height60),
                    Visibility(
                      visible: shouldShowButton,
                      child: Button1(
                        text: 'Submit',
                        onPressed: () async {
                          
                          
                            
                           
                        },
                        backgroundcolor: isDark
                            ? DarkColor.Primarycolor
                            : LightColor.Primarycolor,
                        borderRadius: width / width10,
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
