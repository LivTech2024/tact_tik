import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/utils/colors.dart';
import '../../../fonts/inter_regular.dart';
import '../widgets/custome_textfield.dart';


class CreateDarScreen extends StatefulWidget {
  const CreateDarScreen({super.key});

  @override
  State<CreateDarScreen> createState() => _CreateDarScreenState();
}

class _CreateDarScreenState extends State<CreateDarScreen> {
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

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width / width30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height / height30),
                InterBold(
                  text: 'Today',
                  fontsize: width / width20,
                  color: Primarycolor,
                ),
                SizedBox(height: height / height30),
                const CustomeTextField(
                  hint: 'Tittle',
                  isExpanded: true,
                ),
                SizedBox(height: height / height20),
                const CustomeTextField(
                  hint: 'Write your DAR here...',
                  isExpanded: true,
                ),
                SizedBox(height: height / height20),
                Row(
                  children: [
                    Row(
                      children: uploads.asMap().entries.map(
                        (entry) {
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
                        },
                      ).toList(),
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
                              ListTile(
                                leading: Icon(
                                  Icons.video_collection,
                                  size: width / width20,
                                ),
                                title: InterRegular(
                                  text: 'Add Video',
                                  fontsize: width / width14,
                                ),
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
                          borderRadius: BorderRadius.circular(width / width8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: width / width20,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                /*SizedBox(height: height / height30),
                InterBold(
                  text: 'Reports',
                  fontsize: width / width20,
                  color: Primarycolor,
                ),
                SizedBox(height: height / height20),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 10, // Provide the number of items
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(
                        bottom: height / height10,
                      ),
                      height: height / height35,
                      child: Stack(
                        children: [
                          Container(
                            height: height / height35,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: WidgetColor,
                              borderRadius:
                                  BorderRadius.circular(width / width10),
                            ),
                          ),
                          Container(
                            height: height / height35,
                            width: width / width16,
                            decoration: BoxDecoration(
                              color: colorRed3,
                              borderRadius:
                                  BorderRadius.circular(width / width10),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),*/
                SizedBox(height: height / height30),
                Button1(
                  text: 'Submit',
                  onPressed: () {},
                  backgroundcolor: Primarycolor,
                  borderRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
