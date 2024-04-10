import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import '../widgets/custome_textfield.dart';

class CreateReportScreen extends StatefulWidget {
  CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  String dropdownValue = 'Select';

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

  // Initialize default value
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        appBar: AppBar(
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
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Report',
            fontsize: width / width18,
            color: Colors.white,
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
                  color: Primarycolor,
                  letterSpacing: -.3,
                ),
                SizedBox(height: height / height30),
                CustomeTextField(
                  hint: 'Tittle',
                ),
                SizedBox(height: height / height30),
                InterBold(
                  text: 'Category',
                  fontsize: width / width20,
                  color: Primarycolor,
                  letterSpacing: -.3,
                ),
                SizedBox(height: height / height20),
                Container(
                  height: height / height60,
                  padding: EdgeInsets.symmetric(horizontal: width / width20),
                  decoration: BoxDecoration(
                    color: WidgetColor,
                    borderRadius: BorderRadius.circular(width / width10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      iconSize: width / width24,
                      dropdownColor: WidgetColor,
                      style: TextStyle(color: color2),
                      borderRadius: BorderRadius.circular(10),
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: <String?>[
                        'Select',
                        'All',
                        'available',
                        'unavailable'
                      ] // Add your options here
                          .map<DropdownMenuItem<String>>((String? value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value ?? ''),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: height / height30),
                CustomeTextField(
                  hint: 'Explain',
                  isExpanded: true,
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
                SizedBox(height: height / height60),
                Button1(
                  text: 'Submit',
                  onPressed: () {},
                  backgroundcolor: Primarycolor,
                  borderRadius: width / width10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
