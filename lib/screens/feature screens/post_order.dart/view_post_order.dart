import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/main.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../fonts/poppins_medium.dart';
import '../../../fonts/poppins_regular.dart';
import '../../../utils/colors.dart';
import '../widgets/custome_textfield.dart';

class CreatePostOrder extends StatefulWidget {
  CreatePostOrder({super.key, this.isDisplay = true});

  final bool isDisplay;

  @override
  State<CreatePostOrder> createState() => _CreatePostOrderState();
}

class _CreatePostOrderState extends State<CreatePostOrder> {
  final TextEditingController _tittleController = TextEditingController();

  final TextEditingController _explainController = TextEditingController();

  List<Map<String, dynamic>> uploads = [];

  List<String> selectedFilePaths = [];

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
    // print("Statis ${widget.taskStatus}");
  }

  Future<void> _addGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // await fireStoreService
      //     .addImageToStorageShiftTask(File(pickedFile.path));
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
    }
    // print("Statis ${widget.taskStatus}");
  }

/*  void _uploadfromGallery() async {
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
  }*/

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
    // widget.refreshDataCallback();
  }

  Future<void> _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      // Extract the selected file paths
      List<String> filePaths =
          result.paths.map((path) => path! as String).toList();

      // Do something with the selected file paths
      for (String filePath in filePaths) {
        print('Selected file path: $filePath');
        // Add the file path to the list
        selectedFilePaths.add(filePath);
      }

      // Optionally, you can perform additional operations with the list of file paths
      // For example, display them in a list, upload them to a server, etc.
    } else {
      // User canceled the file picker
      print('User canceled file picker');
    }
    setState(() {});
  }

  void removeButton(int index) {
    setState(() {
      selectedFilePaths.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? DarkColor.color1 : LightColor.color3,
              size: width / width24,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            text: 'Post Order',
            fontsize: width / width18,
            color: isDark ? DarkColor.color1 : LightColor.color3,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        backgroundColor:
            isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        body: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: ListView(
            children: [
              SizedBox(height: height / height30),
              InterSemibold(
                text: '11/02/2024',
                fontsize: width / width20,
                color: isDark ? DarkColor.Primarycolor : LightColor.color3,
              ),
              SizedBox(height: height / height30),
              CustomeTextField(
                isEnabled: !widget.isDisplay,
                hint: 'Title',
                // controller: _titleController,
              ),
              SizedBox(height: height / height20),
              CustomeTextField(
                isEnabled: !widget.isDisplay,
                hint: 'Comment',
                isExpanded: true,
                controller: _explainController,
              ),
              SizedBox(height: height / height30),
              widget.isDisplay
                  ? SizedBox(
                      height: height / height70,
                      width: double.maxFinite,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 20,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: EdgeInsets.only(right: width / width10),
                            height: height / height66,
                            width: width / width66,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(width / width10),
                              image: DecorationImage(
                                image: NetworkImage(
                                    'https://letsenhance.io/static/73136da51c245e80edc6ccfe44888a99/1015f/MainBefore.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : SingleChildScrollView(
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
                                        color: isDark
                                            ? DarkColor.WidgetColor
                                            : LightColor.WidgetColor,
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
                                        color: isDark
                                            ? DarkColor.color15
                                            : LightColor.color1,
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
                                    ListTile(
                                      leading: Icon(Icons.image),
                                      title: Text('Add from Gallery'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _addGallery();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.picture_as_pdf),
                                      title: Text('Add PDF'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _openFileExplorer();
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
                                  color: isDark
                                      ? DarkColor.WidgetColor
                                      : LightColor.WidgetColor,
                                  borderRadius:
                                      BorderRadius.circular(width / width8)),
                              child: Center(
                                child: Icon(Icons.add),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              SizedBox(height: height / height30),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: selectedFilePaths.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: height / height10),
                    width: width / width200,
                    height: height / height46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width / width10),
                      color: DarkColor.  color1,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: width / width6,
                              ),
                              child: SvgPicture.asset('assets/images/pdf.svg',
                                  width: width / width32),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PoppinsMedium(
                                  text: 'PDFNAME.pdf',
                                  color: DarkColor.  color15,
                                ),
                                PoppinsRegular(
                                  text: '329 KB',
                                  color: DarkColor.  color16,
                                )
                              ],
                            ),
                          ],
                        ),
                        widget.isDisplay ? SizedBox() :IconButton(
                          onPressed: () {
                            removeButton(index);
                          },
                          icon: Icon(
                            Icons.close,
                            color: DarkColor.  color19,
                            size: width / width30,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
              widget.isDisplay?SizedBox() :Button1(
                text: 'Done',
                onPressed: () {},
                backgroundcolor: DarkColor.  Primarycolor,
                borderRadius: width / width10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
