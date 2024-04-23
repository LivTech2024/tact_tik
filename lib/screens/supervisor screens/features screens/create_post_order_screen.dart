import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../feature screens/widgets/custome_textfield.dart';
import '../home screens/Scheduling/select_guards_screen.dart';

class CreatePostOrderScreen extends StatefulWidget {
  const CreatePostOrderScreen({super.key});

  @override
  State<CreatePostOrderScreen> createState() => _CreatePostOrderScreenState();
}

class _CreatePostOrderScreenState extends State<CreatePostOrderScreen> {
  List selectedGuards = [];
  List<Map<String, dynamic>> uploads = [];

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

  /*void _uploadImages() async {
    if (uploads.isEmpty ||
        widget.ShiftId.isEmpty ||
        widget.taskId.isEmpty ||
        widget.EmpID.isEmpty) {
      showErrorToast(context, "No Images found or missing data");
      print('No images to upload or missing data.');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    print("Uploads Images  $uploads");
    try {
      print("Task Id : ${widget.taskId}");
      await fireStoreService.addImagesToShiftTasks(
        uploads,
        widget.taskId,
        widget.ShiftId,
        widget.EmpID,
        widget.EmpName,
        widget.shiftReturnTask,
      );
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
  }*/

  void _deleteItem(int index) {
    setState(() {
      uploads.removeAt(index);
    });
    // widget.refreshDataCallback();
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
            text: "Post Order",
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        backgroundColor: Secondarycolor,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width / width30),
            child: Column(
              children: [
                SizedBox(height: height / height30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InterBold(
                      text: 'Select Guards',
                      fontsize: width / width16,
                      color: color1,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectGuardsScreen(
                                      companyId: 'widget.CompanyId',
                                    ))).then((value) => {
                              if (value != null)
                                {
                                  print("Value: ${value}"),
                                  setState(() {
                                    selectedGuards.add({
                                      'GuardId': value['id'],
                                      'GuardName': value['name'],
                                      'GuardImg': value['url']
                                    });
                                  }),
                                }
                            });
                      },
                      child: InterBold(
                        text: 'view all',
                        fontsize: width / width14,
                        color: color1,
                      ),
                    )
                  ],
                ),
                SizedBox(height: height / height24),
                Container(
                  height: height / height64,
                  padding: EdgeInsets.symmetric(horizontal: width / width10),
                  decoration: BoxDecoration(
                    color: WidgetColor,
                    borderRadius: BorderRadius.circular(width / width13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300,
                            fontSize: width / width18,
                            color: Colors.white,
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
                              color: color2, // Change text color to white
                            ),
                            hintText: 'Search Guard',
                            contentPadding: EdgeInsets.zero, // Remove padding
                          ),
                          cursorColor: Primarycolor,
                        ),
                      ),
                      Container(
                        height: height / height44,
                        width: width / width44,
                        decoration: BoxDecoration(
                          color: Primarycolor,
                          borderRadius: BorderRadius.circular(width / width10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.search,
                            size: width / width20,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: height / height20),
                  height: height / height80,
                  width: double.maxFinite,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedGuards.length,
                    itemBuilder: (context, index) {
                      String guardId = selectedGuards[index]['GuardId'];
                      String guardName = selectedGuards[index]['GuardName'];
                      String guardImg = selectedGuards[index]['GuardImg'];
                      return Padding(
                        padding: EdgeInsets.only(right: height / height20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: height / height50,
                                  width: width / width50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(guardImg),
                                        fit: BoxFit.fitWidth),
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedGuards.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      height: height / height20,
                                      width: width / width20,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color1),
                                      child: Center(
                                        child: Icon(
                                          Icons.close,
                                          size: 8,
                                          color: Secondarycolor,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: height / height8),
                            InterBold(
                              text: guardName,
                              fontsize: width / width14,
                              color: color26,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: height / height30,
                ),
                CustomeTextField(
                  hint: 'Tittle',
                  isExpanded: true,
                ),
                SizedBox(
                  height: height / height20,
                ),
                CustomeTextField(
                  hint: 'Post Orders',
                  isExpanded: true,
                ),
                SizedBox(
                  height: height / height20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                            child: Icon(
                              Icons.add,
                              size: width / width24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height / height60,),
                Button1(
                  text: 'Done',
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
