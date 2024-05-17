import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class ReportCheckpointScreen extends StatefulWidget {
  const ReportCheckpointScreen({super.key});

  @override
  State<ReportCheckpointScreen> createState() => _ReportCheckpointScreenState();
}

class _ReportCheckpointScreenState extends State<ReportCheckpointScreen> {
  bool _expand = false;
  late Map<String, bool> _expandCategoryMap;
  TextEditingController Controller = TextEditingController();

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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
    }
    print("Statis ${uploads}");
  }

  Future<void> _addGallery() async {
    List<XFile>? pickedFiles =
        await ImagePicker().pickMultiImage(imageQuality: 30);
    if (pickedFiles != null) {
      for (var pickedFile in pickedFiles) {
        File file = File(pickedFile.path);
        // await fireStoreService
        //     .addImageToStorageShiftTask(File(pickedFile.path));
        setState(() {
          uploads.add({'type': 'image', 'file': file});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
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
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            text: 'Report Checkpoint',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height / height30),
                  Text(
                    'Add Image/Comment',
                    style: TextStyle(
                      fontSize: width / width14,
                      color: Primarycolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height / height10),
                  TextField(
                    controller: Controller,
                    decoration: InputDecoration(
                      hintText: 'Add Comment',
                    ),
                  ),
                  SizedBox(height: height / height10),
                  GestureDetector(
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
                    child: SizedBox(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.add,
                          size: width / width24,
                          color: Primarycolor,
                        ),
                        SizedBox(
                          width: width / width6,
                        ),
                        InterMedium(
                          text: 'Add Images',
                          color: Primarycolor,
                          fontsize: width / width14,
                        )
                      ],
                    )),
                  ),
                  SizedBox(height: height / height20),
                  Expanded(
                    child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          // crossAxisSpacing: 20,
                          // mainAxisSpacing: 20,
                          crossAxisCount: 3,
                        ),
                        itemCount: uploads.length,
                        itemBuilder: (context, index) {
                          // if (index == null) {

                          // }
                          return SizedBox(
                            height: height / height30,
                            width: width / width30,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: height / height66,
                                  width: width / width66,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.5),
                                    borderRadius:
                                        BorderRadius.circular(width / width10),
                                  ),
                                  margin: EdgeInsets.all(width / width8),
                                  child: Image.file(
                                    uploads[index]['file'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -5,
                                  right: -5,
                                  child: IconButton(
                                    onPressed: () {
                                      _deleteItem(index);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: width / width20,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  )
                ],
              ),
              Align(
                // bottom: 10,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button1(
                      text: 'Submit',
                      onPressed: () {},
                      color: Colors.white,
                      borderRadius: width / width20,
                      backgroundcolor: Primarycolor,
                    ),
                    SizedBox(
                      height: height / height20,
                    )
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
