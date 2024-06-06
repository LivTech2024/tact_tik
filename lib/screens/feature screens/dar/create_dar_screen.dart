import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  String ReportName = "";

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
        ReportName = widget.darTiles[widget.index]['TileReportName'];
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
      'TileReportName': ReportName.isNotEmpty
          ? ReportName
          : widget.darTiles[widget.index]['TileReportName'] ?? "",
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        appBar: AppBar(
          shadowColor: isDark ? Colors.transparent : LightColor.color3.withOpacity(.1),
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
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'DAR',
            fontsize: width / width18,
            color: isDark ? DarkColor.color1 : LightColor.color3,
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
                      color: isDark ? DarkColor.Primarycolor : LightColor.color3,
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
                                      color: DarkColor. WidgetColor,
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
                              color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
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
                    SizedBox(
                      height: 20.h,
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
                             /* Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                              ),*/
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(image: NetworkImage(imageUrls[index]),fit: BoxFit.cover,)
                                ),
                              ),
                              Positioned(
                                top: - 5.h,
                                right: - 5.w,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _removeImage(index);
                                      },
                                      icon:  Icon(
                                        Icons.delete,
                                        color: isDark
                                            ? DarkColor.color1
                                            : LightColor.color3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    SizedBox(height: 20.h),
                    ReportId.isNotEmpty
                        ? Column(
                            children: [
                              InterBold(
                                text: 'Patrol Reports',
                                fontsize: 20.sp,
                                color: isDark
                                    ? DarkColor.Primarycolor
                                    : LightColor.color3,
                              ),
                              SizedBox(height: 20.h),
                            ],
                          )
                        : SizedBox(height: 10.h),
                    ReportId.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              // final hourKey = reportsByHour.keys.toList()[index];
                              // final reportsForHour = reportsByHour[hourKey] ?? [];
                              // var data = reportsByHour;
                              return GestureDetector(
                                onTap: () {
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
                                          SearchId:
                                              ReportId, //Need to Work Here
                                        ),
                                      ));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      bottom: 30.h),
                                height: 35.h,
                                  color: isDark
                                      ? DarkColor.WidgetColor
                                      : LightColor.WidgetColor,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 15.w,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Expanded(
                                        child: InterBold(
                                          text: ReportId.isNotEmpty
                                              ? "# $ReportId  ${ReportName}"
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
                    ReportId.isNotEmpty
                        ? Column(
                            children: [
                              InterBold(
                                text: 'Reports',
                                fontsize: 20.sp,
                                color: isDark?DarkColor.Primarycolor:LightColor.color3,
                              ),
                              SizedBox(height: 20.h)
                            ],
                          )
                        : SizedBox(height: 10.h),
                    ReportId.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              // final hourKey = reportsByHour.keys.toList()[index];
                              // final reportsForHour = reportsByHour[hourKey] ?? [];
                              // var data = reportsByHour;
                              return GestureDetector(
                                onTap: () {
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
                                          SearchId:
                                              ReportId, //Need to Work Here
                                        ),
                                      ));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom: 30.h,
                                  ),
                                  height: 35.h,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? DarkColor.WidgetColor
                                        : LightColor.WidgetColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 15.w,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                          BorderRadius.circular(10.r),
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Expanded(
                                        child: InterBold(
                                          text: ReportId.isNotEmpty
                                              ? "# $ReportId  ${ReportName}"
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
                            onPressed: submitDarTileData,
                            backgroundcolor:isDark?DarkColor.Primarycolor:LightColor.Primarycolor ,
                            borderRadius: 10.r,
                          )
                        : SizedBox(),
                    SizedBox(height: 40.h),
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
