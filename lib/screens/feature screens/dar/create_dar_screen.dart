import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/common/widgets/customToast.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/Report/create_report_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/patrol_logs.dart';
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
  final VoidCallback? onCallback;

  CreateDarScreen({
    required this.darTiles,
    required this.index,
    required this.EmployeeId,
    required this.EmployeeName,
    required this.onCallback,
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
  String ReportId = "";
  List<dynamic> TilePatrolData = [];
  List<dynamic> TileReportData = [];

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
    // _getUserInfo();  TileReporSearchtId

    if (widget.darTiles[widget.index] != null &&
        widget.darTiles[widget.index]['TileReportSearchId'] != null) {
      setState(() {
        ReportId = widget.darTiles[widget.index]['TileReportSearchId'];
      });
    }
    if (widget.darTiles[widget.index] != null &&
        widget.darTiles[widget.index]['TileReportName'] != null) {
      setState(() {
        // ReportName = widget.darTiles[widget.index]['TileReportName'];
      });
    }
    if (widget.darTiles[widget.index] != null &&
        widget.darTiles[widget.index]['TilePatrol'] != null) {
      print("TIle PatrolData ${widget.darTiles[widget.index]['TilePatrol']}");
      setState(() {
        TilePatrolData = widget.darTiles[widget.index]['TilePatrol'];
      });
    }
    if (widget.darTiles[widget.index] != null &&
        widget.darTiles[widget.index]['TileReport'] != null) {
      print("TIle PatrolData ${widget.darTiles[widget.index]['TileReport']}");
      setState(() {
        TileReportData = widget.darTiles[widget.index]['TileReport'];
      });
    }
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
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 60);
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
      'TileReportSearchId': ReportId.isNotEmpty
          ? ReportId
          : widget.darTiles[widget.index]['TileReportSearchId'] ?? "",
      'TileReport': TileReportData.isNotEmpty
          ? TileReportData
          : widget.darTiles[widget.index]['TileReport'] ?? [],
      'TilePatrol': TilePatrolData.isNotEmpty
          ? TilePatrolData
          : widget.darTiles[widget.index]['TilePatrol'] ?? [],
    };
    print("data $data");
    widget.darTiles.removeAt(widget.index);
    widget.darTiles.insert(widget.index, data);
    localdarTiles.add(data);
    print("Updated ${widget.darTiles}");
    try {
      final user = FirebaseAuth.instance.currentUser;
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
          if (data['EmpDarTile'] != null) {
            isDarlistPresent = true;
          }
          docRef = dar.reference;
        }

        if (docRef != null) {
          await docRef
              .set({'EmpDarTile': widget.darTiles}, SetOptions(merge: true));
        }
        widget.onCallback?.call();
        Navigator.pop(context);
      } else {
        print('No document found with the matching _employeeId.');
      }
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
            letterSpacing: -.3,
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
                      color: Theme.of(context).textTheme.bodySmall!.color,
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
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
                                      margin: EdgeInsets.all(8.sp),
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
                                          size: 20.sp,
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
                                borderRadius: BorderRadius.circular(8.r),
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
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    imageUrls.isNotEmpty
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                            ),
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  /* Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                              ),*/
                                  Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      image: NetworkImage(imageUrls[index]),
                                      fit: BoxFit.cover,
                                    )),
                                  ),
                                  Positioned(
                                    top: -5.h,
                                    right: -5.w,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            _removeImage(index);
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : SizedBox(height: 20.h),
                    TilePatrolData.isNotEmpty
                        ? Column(
                            children: [
                              InterBold(
                                text: 'Patrol',
                                fontsize: 20.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color,
                              ),
                              SizedBox(height: 20.h),
                            ],
                          )
                        : SizedBox(height: 10.h),
                    TilePatrolData.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: TilePatrolData.length,
                            itemBuilder: (context, index) {
                              final patrolData = TilePatrolData[index];
                              print("TIle Patrol Data ${TilePatrolData}");
                              // final hourKey = reportsByHour.keys.toList()[index];
                              // final reportsForHour = reportsByHour[hourKey] ?? [];
                              // var data = reportsByHour;

                              return GestureDetector(
                                onTap: () {
                                  print("TIle Patrol Data ${TilePatrolData}");
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30.h),
                                  height: 70.h,
                                  color: Theme.of(context).cardColor,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 15.w,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                InterBold(
                                                  text: 'Patrol Name',
                                                  fontsize: 12.sp,
                                                  color: Colors.white,
                                                ),
                                                InterBold(
                                                  text: TilePatrolData
                                                          .isNotEmpty
                                                      ? "Patrol Name : ${patrolData['TilePatrolName']}"
                                                      : "",
                                                  fontsize: 12.sp,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                            // Row(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.start,
                                            //   children: [
                                            //     InterBold(
                                            //       text: 'Started',
                                            //       fontsize: 12.sp,
                                            //       color: Colors.white,
                                            //     ),
                                            //     InterBold(
                                            //       text: TilePatrolData
                                            //               .isNotEmpty
                                            //           ? "${patrolData['TilePatrolData']}"
                                            //           : "",
                                            //       fontsize: 12.sp,
                                            //       color: Colors.white,
                                            //     ),
                                            //   ],
                                            // ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                InterBold(
                                                  text: '',
                                                  fontsize: 12.sp,
                                                  color: Colors.white,
                                                ),
                                                InterBold(
                                                  text: TilePatrolData
                                                          .isNotEmpty
                                                      ? "${patrolData['TilePatrolData']}"
                                                      : "",
                                                  fontsize: 12.sp,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : SizedBox(height: 30.h),
                    TileReportData.isNotEmpty
                        ? Column(
                            children: [
                              InterBold(
                                text: 'Reports',
                                fontsize: 20.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color,
                              ),
                              SizedBox(height: 20.h)
                            ],
                          )
                        : SizedBox(height: 10.h),
                    TileReportData.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: TileReportData.length,
                            itemBuilder: (context, index) {
                              final ReportData = TileReportData[index];
                              // final hourKey = reportsByHour.keys.toList()[index];
                              // final reportsForHour = reportsByHour[hourKey] ?? [];
                              // var data = reportsByHour;
                              return GestureDetector(
                                onTap: () {
                                  print('Tile Report Data ${TileReportData}');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CreateReportScreen(
                                          locationId: '',
                                          locationName: '',
                                          companyID: '',
                                          empId: '',
                                          empName: '',
                                          ClientId: '',
                                          reportId: '',
                                          buttonEnable: false,
                                          ShiftId: 'widget.shifID',
                                          SearchId: ReportData[
                                              'TileReportSearchId'], //Need to Work Here
                                        ),
                                      ));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30.h),
                                  height: 30.h,
                                  padding: EdgeInsets.only(right: 10.w),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 15.w,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: InterBold(
                                          text: TileReportData.isNotEmpty
                                              ? "\t\t\t\t # ${ReportData['TileReportSearchId']}  ${ReportData['TileReportName']}"
                                              : "",
                                          fontsize: 12.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : SizedBox(height: 30.h),
                    widget.iseditable
                        ? Button1(
                            height: 60.h,
                            text: _isSubmitting ? 'Submitting...' : 'Submit',
                            color: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .color,
                            onPressed: submitDarTileData,
                            backgroundcolor: Theme.of(context).primaryColor,
                            borderRadius: 10.r,
                          )
                        : SizedBox(),
                    SizedBox(height: 30.h),
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
