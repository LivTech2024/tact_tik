import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/common/widgets/customToast.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:tact_tik/utils/utils_functions.dart';

import '../../../../fonts/inter_regular.dart';
import '../../../feature screens/widgets/custome_textfield.dart';


class SCreateDarScreen extends StatefulWidget {
  final List<dynamic> darTiles;
  final String? DarId;
  final int index;
  final String EmployeeId;
  final String EmployeeName;

  const SCreateDarScreen({

    required this.darTiles,
    required this.index,
    required this.EmployeeId,
    required this.EmployeeName,
    this.DarId,
  });

  @override
  State<SCreateDarScreen> createState() => _CreateDarScreenState();
}

class _CreateDarScreenState extends State<SCreateDarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final TextEditingController _titleController;
  late final TextEditingController _darController;
  bool _isLoading = false;
  List<String> imageUrls = [];
  bool _isSubmitting = false;
  String _userName = '';
  String _employeeId = '';
  String _empEmail = 'ys146228@gmail.com';
  String _employeeImg = '';
  List<dynamic> localdarTiles = [];
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _darController = TextEditingController();

    if (widget.darTiles != null &&
        widget.darTiles[widget.index] != null &&
        widget.darTiles[widget.index]['TileLocation'] != null) {
      _titleController.text = widget.darTiles[widget.index]['TileLocation'];
      _darController.text = widget.darTiles[widget.index]['TileContent'];
    }

    if (widget.darTiles != null &&
        widget.darTiles[widget.index] != null &&
        widget.darTiles[widget.index]['TileImages'] != null) {
      imageUrls =
          List<String>.from(widget.darTiles[widget.index]['TileImages']);
    }
    // _getUserInfo();
  }

  FireStoreService fireStoreService = FireStoreService();
  List<Map<String, dynamic>> uploads = [];

  Future<void> _getUserInfo() async {
    try {
      var userInfo = await _firestore
          .collection('Employees')
          .where(
            'EmployeeId',
            isEqualTo: widget.EmployeeId,
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
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
    }
  }

  Future<void> _uploadImages() async {
    print("Uploads Images  $uploads");
    try {
      for (var image in uploads) {
        final im = await fireStoreService.addImageToDarStorage(image['file']);
        print('Image url = ${im}');
        imageUrls.add(im);
      }
      uploads.clear();
      showSuccessToast(context, "Image Successfully");
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

  void _removeImage(int index) {
    setState(() {
      imageUrls.removeAt(index);
    });
  }

  // void submitDarTileData() async {
  //   final date = widget.darTiles[widget.index]['TileTime'];
  //   await _uploadImages();
  //   final data = {
  //     'TileTime': date,
  //     'TileContent': _darController.text,
  //     'TileImages': imageUrls,
  //     'TileLocation': _titleController.text,
  //   };
  //   print("data ${data}");
  //   widget.darTiles.removeAt(widget.index);
  //   widget.darTiles.insert(widget.index, data);
  //   localdarTiles.add(data);
  //   print("Updated ${widget.darTiles}");
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     // if (user != null) {
  //     // await _getUserInfo();
  //     final String employeeId = _employeeId;
  //     print("employeeId: $employeeId");

  //     final CollectionReference employeesDARCollection =
  //         FirebaseFirestore.instance.collection('EmployeesDAR');

  //     final QuerySnapshot querySnapshot = await employeesDARCollection
  //         .where('EmpDarEmpId', isEqualTo: widget.EmployeeId)
  //         .get();
  //     print(querySnapshot.docs);
  //     if (querySnapshot.docs.isNotEmpty) {
  //       DocumentReference? docRef;
  //       final date = DateTime.now();
  //       bool isDarlistPresent = false;

  //       for (var dar in querySnapshot.docs) {
  //         final data = dar.data() as Map<String, dynamic>;
  //         print("data ${data}");
  //         final date2 = UtilsFuctions.convertDate(data['EmpDarCreatedAt']);
  //         if (date2[0] == date.day &&
  //             date2[1] == date.month &&
  //             date2[2] == date.year) {
  //           if (data['EmpDarTile'] != null) {
  //             isDarlistPresent = true;
  //           }
  //         }
  //         docRef = dar.reference;
  //       }

  //       if (docRef != null) {
  //         await docRef
  //             .set({'EmpDarTile': widget.darTiles}, SetOptions(merge: true));
  //       }
  //     } else {
  //       print('No document found with the matching _employeeId.');
  //     }
  //     // } else {
  //     //   print('User is not logged in.');
  //     // }
  //   } catch (e) {
  //     print('Error creating blank DAR cards: $e');
  //   }
  // }

  void submitDarTileData() async {
    setState(() {
      _isSubmitting = true;
      _isLoading = true;
    });
    final date = widget.darTiles[widget.index]['TileTime'];
    await _uploadImages();
    final data = {
      'TileTime': date,
      'TileContent': _darController.text,
      'TileImages': imageUrls,
      'TileLocation': _titleController.text,
    };
    print("data ${data}");
    widget.darTiles.removeAt(widget.index);
    widget.darTiles.insert(widget.index, data);
    localdarTiles.add(data);
    print("Updated ${widget.darTiles}");
    try {
      final user = FirebaseAuth.instance.currentUser;
      // if (user != null) {
      // await _getUserInfo();
      final String employeeId = _employeeId;
      print("employeeId: $employeeId");

      final CollectionReference employeesDARCollection =
          FirebaseFirestore.instance.collection('EmployeesDAR');

      final QuerySnapshot querySnapshot = await employeesDARCollection
          .where('EmpDarEmpId', isEqualTo: widget.EmployeeId)
          .where("EmpDarId", isEqualTo: widget.DarId)
          .get();
      print(querySnapshot.docs);
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference? docRef;
        final date = DateTime.now();
        bool isDarlistPresent = false;

        for (var dar in querySnapshot.docs) {
          final data = dar.data() as Map<String, dynamic>;
          print("data ${data}");
          final date2 = UtilsFuctions.convertDate(data['EmpDarCreatedAt']);
          // if (date2[0] == date.day &&
          //     date2[1] == date.month &&
          //     date2[2] == date.year) {
          if (data['EmpDarTile'] != null) {
            isDarlistPresent = true;
          }
          // }
          docRef = dar.reference;
        }

        if (docRef != null) {
          await docRef
              .set({'EmpDarTile': widget.darTiles}, SetOptions(merge: true));
        }
        Navigator.pop(context);
      } else {
        print('No document found with the matching _employeeId.');
      }
      // } else {
      //   print('User is not logged in.');
      // }
      setState(() {
        _isLoading = false;
        _isSubmitting = true;
      });
    } catch (e) {
      print('Error creating blank DAR cards: $e');
    }
    setState(() {
      _isSubmitting = false;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _darController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   

    return SafeArea(
      child: Scaffold(
        
        appBar: AppBar(
          
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'DAR',
           
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    InterBold(
                      text: widget.darTiles[widget.index]['TileTime'],
                      fontsize: 20.sp,
                      color: DarkColor. Primarycolor,
                    ),
                    SizedBox(height: 30.h),
                    CustomeTextField(
                      controller: _titleController,
                      hint: 'Spot',
                      isExpanded: true,
                    ),
                    SizedBox(height: 20.h),
                    CustomeTextField(
                      controller: _darController,
                      hint: 'Write your DAR here...',
                      isExpanded: true,
                    ),
                    SizedBox(height: 20.h),
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
                                    height: 66.h,
                                    width: 66.w,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(
                                        10.r,
                                      ),
                                    ),
                                    margin: EdgeInsets.all(8.r),
                                    child: upload['type'] == 'image'
                                        ? Image.file(
                                            upload['file'],
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            Icons.videocam,
                                            size: 20.sp,
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
                                        size: 20.w,
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
                                      size: 20.sp,
                                    ),
                                    title: InterRegular(
                                      text: 'Add Image',
                                      fontsize: 14.sp,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _addImage();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.image,
                                      size: 20.sp,
                                    ),
                                    title: InterRegular(
                                      text: 'Add from Gallery',
                                      fontsize: 14.sp,
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
                            height: 66.h,
                            width: 66.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius:
                                  BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (imageUrls.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _removeImage(index);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    SizedBox(height: 30.h),
                    Button1(
                      text: _isSubmitting ? 'Submitting...' : 'Submit',
                      onPressed: submitDarTileData,
                      backgroundcolor: DarkColor. Primarycolor,
                      borderRadius: 20,
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
