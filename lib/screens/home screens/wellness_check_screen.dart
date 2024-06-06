import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/common/widgets/customToast.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';

import '../../common/sizes.dart';
import '../../fonts/inter_regular.dart';
import '../../utils/colors.dart';

class WellnessCheckScreen extends StatefulWidget {
  final String EmpId;
  final String EmpName;
  const WellnessCheckScreen(
      {super.key, required this.EmpId, required this.EmpName});

  @override
  State<WellnessCheckScreen> createState() => _WellnessCheckScreenState();
}

class _WellnessCheckScreenState extends State<WellnessCheckScreen> {
  List<Map<String, dynamic>> uploads = [];
  TextEditingController _controller = TextEditingController();

  Future<void> _addImage() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });

      // fireStoreService.AddImageToStorage(File(pickedFile.path));
    }
  }

  void _uploadImages() async {
    print("Uploads ${uploads}");
    try {
      await fireStoreService
          .addImagesToShiftGuardWellnessReport(
              uploads, _controller.text, widget.EmpId, widget.EmpName)
          .whenComplete(() {
        Navigator.pop(context);
      });
      uploads.clear();
      _controller.clear();
      showSuccessToast(context, "Uploaded");
      Navigator.pop(context, true);
    } catch (e) {
      showErrorToast(context, "Try Again");
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
    final DateTime date = DateTime.now();
    final String formattedTime = DateFormat('hh:mm a').format(date);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: DarkColor.  AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Wellness Check',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height / height30),
              InterBold(
                text: formattedTime,
                fontsize: width / width18,
                color: DarkColor.Primarycolor,
              ),
              SizedBox(height: height / height30),
              Container(
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
                          Icons.add_a_photo,
                          size: width / width24,
                          color: DarkColor.  Primarycolor,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width / width20,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w300,
                          fontSize: width / width18,
                          color: Colors.white, // Change text color to white
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(width / width10),
                            ),
                          ),
                          focusedBorder: InputBorder.none,
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300,
                            fontSize: width / width18,
                            color: DarkColor.color2, // Change text color to white
                          ),
                          hintText: 'Upload Img / Comment',
                          contentPadding: EdgeInsets.zero, // Remove padding
                        ),
                        cursorColor: DarkColor.Primarycolor,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: height / height10),
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
                                color: DarkColor.WidgetColor,
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
                          color: DarkColor.WidgetColor,
                          borderRadius: BorderRadius.circular(width / width8)),
                      child: Center(
                        child: Icon(Icons.add),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _uploadImages,
          backgroundColor: DarkColor.  Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.check),
        ),
      ),
    );
  }
}
