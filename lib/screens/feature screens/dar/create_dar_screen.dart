import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/common/widgets/customToast.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import '../../../fonts/inter_regular.dart';
import '../widgets/custome_textfield.dart';

class CreateDarScreen extends StatefulWidget {
  final String EmpEmail;
  final String EmpId;
  final String EmpDarCompanyId;
  final String EmpDarCompanyBranchId;
  final String EmpShiftId;
  final String EmpClientID;

  const CreateDarScreen(
      {super.key,
      required this.EmpEmail,
      required this.EmpId,
      required this.EmpDarCompanyId,
      required this.EmpDarCompanyBranchId,
      required this.EmpShiftId,
      required this.EmpClientID});

  @override
  State<CreateDarScreen> createState() => _CreateDarScreenState();
}

class _CreateDarScreenState extends State<CreateDarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final TextEditingController _titleController;
  late final TextEditingController _darController;
  bool _isSubmitting = false;
  String _userName = '';
  String _employeeId = '';
  String _empEmail = 'ys146228@gmail.com';
  String _employeeImg = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _darController = TextEditingController();
    _getUserInfo();
  }

  FireStoreService fireStoreService = FireStoreService();
  List<Map<String, dynamic>> uploads = [];

  Future<void> _getUserInfo() async {
    try {
      var userInfo = await _firestore
          .collection('Employees')
          .where(
            'EmployeeId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
          )
          .limit(1)
          .get();
      if (userInfo.docs.isNotEmpty) {
        String userName = userInfo.docs.first['EmployeeName'];
        String employeeId = userInfo.docs.first['EmployeeId'];
        String empEmail = userInfo.docs.first['EmployeeEmail'];
        String empImage = userInfo.docs.first['EmployeeImg'];

        setState(() {
          _userName = userName;
          _employeeId = employeeId;
          _empEmail = empEmail;
          _employeeImg = empImage;
        });

        print('User Info: ${userInfo.docs.first.data()}');
      } else {
        print('User information not found.');
      }
    } catch (e) {
      print('Error getting user information: $e');
    }
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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // await fireStoreService
      //     .addImageToStorageShiftTask(File(pickedFile.path));
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
    }
  }

  void _uploadImages() async {
    print("Uploads Images  $uploads");
    try {
      // await fireStoreService.addImageToDarStorage(uploads);
      uploads.clear();
      showSuccessToast(context, "Uploaded Successfully");
    } catch (e) {
      showErrorToast(context, "$e");
      print('Error uploading images: $e');
    }
  }

  void _deleteItem(int index) {
    setState(() {
      uploads.removeAt(index);
    });
  }

  //keep this code in firebase_function file  and handle its errors here
  Future<void> _submitDAR() async {
    if (_isSubmitting) return;

    final title = _titleController.text.trim();
    final darContent = _darController.text.trim();

    if (title.isNotEmpty && darContent.isNotEmpty) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        List<String> imageUrls = [];
        for (var upload in uploads) {
          if (upload['type'] == 'image') {
            File file = upload['file'];
            // Upload the image file and get the download URL
            List<Map<String, dynamic>> downloadURLs =
                await fireStoreService.addImageToDarStorage(file);
            // Add the image URLs to the list
            for (var urlMap in downloadURLs) {
              if (urlMap.containsKey('downloadURL')) {
                imageUrls.add(urlMap['downloadURL'] as String);
              }
            }
          }
        }
        var docRef = await _firestore.collection('EmployeesDAR').add({
          'EmpDarTitle': title,
          'EmpDarData': darContent,
          'EmpDarShiftId': darContent,
          'EmpDarDate': FieldValue.serverTimestamp(),
          'EmpDarCreatedAt': FieldValue.serverTimestamp(),
          'EmpDarEmpName': _userName,
          'EmpDarEmpId': _employeeId,
          'EmpDarCompanyId': widget.EmpDarCompanyId ?? "",
          'EmpDarCompanyBranchId': widget.EmpDarCompanyBranchId ?? "",
          'EmpDarClientId': widget.EmpClientID ?? '',
          'EmpDarImages': imageUrls ?? "",
        });
        await docRef.update({'EmpDarId': docRef.id});
        _titleController.clear();
        _darController.clear();

        showCustomSnackbar(context, 'DAR saved successfully');
        Navigator.pop(context);
      } catch (e) {
        showCustomSnackbar(context, 'Error saving DAR: $e');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      showCustomSnackbar(context, 'Please fill in the title and DAR content');
    }
  }

  void showCustomSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  //use the toast notification here instead of this
  @override
  void dispose() {
    _titleController.dispose();
    _darController.dispose();
    super.dispose();
  }

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
            text: 'DAR',
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
                  text: 'Today',
                  fontsize: width / width20,
                  color: Primarycolor,
                ),
                SizedBox(height: height / height30),
                CustomeTextField(
                  controller: _titleController,
                  hint: 'Tittle',
                  isExpanded: true,
                ),
                SizedBox(height: height / height20),
                CustomeTextField(
                  controller: _darController,
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
                                  Icons.image,
                                  size: width / width20,
                                ),
                                title: InterRegular(
                                  text: 'Add from Gallery',
                                  fontsize: width / width14,
                                ),
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
                          borderRadius: BorderRadius.circular(width / width8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: width / width20,
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(),
                    // GestureDetector(
                    //   onTap: () {},
                    //   child: Container(
                    //     height: height / height66,
                    //     width: width / width66,
                    //     decoration: BoxDecoration(
                    //       color: WidgetColor,
                    //       borderRadius: BorderRadius.circular(width / width8),
                    //     ),
                    //     child: Center(
                    //       child: Icon(
                    //         Icons.upload,
                    //         size: width / width20,
                    //       ),
                    //     ),
                    //   ),
                    // )
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
                  text: _isSubmitting ? 'Submitting...' : 'Submit',
                  onPressed: _submitDAR,
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
