import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/common/widgets/customToast.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:tact_tik/utils/utils_functions.dart';
import '../../../fonts/inter_regular.dart';
import '../widgets/custome_textfield.dart';

class CreateDarScreen extends StatefulWidget {
  final List<dynamic> darTiles;
  final String? DarId;
  final int index;
  final String EmployeeId;
  final String EmployeeName;
  bool iseditable;
  CreateDarScreen({
    required this.darTiles,
    required this.index,
    required this.EmployeeId,
    required this.EmployeeName,
    this.DarId,
    this.iseditable = true,
  });

  @override
  State<CreateDarScreen> createState() => _CreateDarScreenState();
}

class _CreateDarScreenState extends State<CreateDarScreen> {
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
    print("Status ${uploads}");
  }

  Future<void> _addGallery() async {
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

  Future<File> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + '_compressed.jpg',
      quality: 30,
    );
    return File(result!.path);
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
                      text: widget.darTiles[widget.index]['TileTime'],
                      fontsize: width / width20,
                      color: Primarycolor,
                    ),
                    SizedBox(height: height / height30),
                    CustomeTextField(
                      controller: _titleController,
                      hint: 'Spot',
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
                              borderRadius:
                                  BorderRadius.circular(width / width8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: width / width20,
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
                    SizedBox(height: height / height30),
                    widget.iseditable
                        ? Button1(
                            text: _isSubmitting ? 'Submitting...' : 'Submit',
                            onPressed: submitDarTileData,
                            backgroundcolor: Primarycolor,
                            borderRadius: 20,
                          )
                        : SizedBox(),
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
