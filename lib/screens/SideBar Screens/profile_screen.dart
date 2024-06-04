import 'package:bounce/bounce.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'dart:io';

import '../../common/sizes.dart';
import '../../fonts/inter_regular.dart';
import '../../fonts/inter_semibold.dart';
import '../../utils/colors.dart';

import '../../common/widgets/setTextfieldWidget.dart';
import '../home screens/widgets/profile_edit_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _employeeName;
  String? _employeeEmail;
  String? _employeeRole;
  String? _employeePhone;
  String? _employeeImageUrl;
  String? _currentUserUid;
  XFile? _selectedImageFile;
  bool isEdit = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUserUid();
  }

  Future<void> _getCurrentUserUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserUid = user.uid;
      });
      _fetchEmployeeData();
    }
  }

  Future<void> _fetchEmployeeData() async {
    if (_currentUserUid != null) {
      final employeeDoc = await FirebaseFirestore.instance
          .collection('Employees')
          .doc(_currentUserUid)
          .get();
      if (employeeDoc.exists) {
        final employeeData = employeeDoc.data();
        setState(() {
          _employeeName = employeeData?['EmployeeName'];
          _nameController.text = employeeData?['EmployeeName'];
          _employeeEmail = employeeData?['EmployeeEmail'];
          _employeeRole = employeeData?['EmployeeRole'];
          _employeePhone = employeeData?['EmployeePhone'];
          _phoneNoController.text = employeeData?['EmployeePhone'];
          _employeeImageUrl = employeeData?['EmployeeImg'];
        });
      }
    }
  }

  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = pickedFile;
      });
    }
  }

  Future<void> _updateEmployeeData(String newName, String newPhoneNo) async {
    if (_currentUserUid != null) {
      await FirebaseFirestore.instance
          .collection('Employees')
          .doc(_currentUserUid)
          .update({
        'EmployeeName': newName,
        'EmployeePhone': newPhoneNo,
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24.sp,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            text: 'Your Profile',
            fontsize: 18.sp,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isEdit = !isEdit;
                });
                if (isEdit) {
                  final newName = _nameController.text.trim();
                  final newPhoneNo = _phoneNoController.text.trim();

                  if (newName.isNotEmpty && newPhoneNo.isNotEmpty) {
                    _updateEmployeeData(newName, newPhoneNo);
                    setState(() {
                      isEdit = false;
                      _nameController.clear();
                      _phoneNoController.clear();
                    });
                    _getCurrentUserUid();
                  } else if (_selectedImageFile != null && isEdit) {
                    // TODO Upload image code

                    _getCurrentUserUid();
                  }
                }
              },
              icon: Icon(
                isEdit ? Icons.check : Icons.border_color,
                size: 24.sp,
                color: color1,
              ),
            )
          ],
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 340.h,
                width: double.maxFinite,
                decoration: const BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.black,
                      const Color(0xFF9C6400),
                    ],
                    begin: Alignment(0, -1.5),
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _selectImageFromGallery,
                        child: Container(
                          padding: EdgeInsets.all(4.sp),
                          decoration: BoxDecoration(
                            color: _employeeImageUrl != null
                                ? const Color(0xFFAC7310)
                                : Primarycolor,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: SizedBox.fromSize(
                              size: Size.fromRadius(50.r),
                              child: _selectedImageFile != null
                                  ? Image.file(
                                      File(_selectedImageFile!.path),
                                      fit: BoxFit.cover,
                                    )
                                  : _employeeImageUrl != null
                                      ? Image.network(
                                          _employeeImageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset('assets/images/default.png'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      PoppinsMedium(
                        text: _employeeName ?? '',
                        fontsize: 18.sp,
                        color: color1,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 40.h),
                      child: isEdit
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InterSemibold(
                                  text: 'Name',
                                  fontsize: 20.sp,
                                  color: color1,
                                ),
                                SizedBox(height: 5.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SetTextfieldWidget(
                                        hintText: '',
                                        controller: _nameController,
                                        enabled: true,
                                        isEditMode: false,
                                      ),
                                    ),
                                    /*  Bounce(
                                      onTap: () {
                                        final newName =
                                            _nameController.text.trim();
                                        final newPhoneNo =
                                            _phoneNoController.text.trim();

                                        if (newName.isNotEmpty &&
                                            newPhoneNo.isNotEmpty) {
                                          _updateEmployeeData(
                                              newName, newPhoneNo);
                                          setState(() {
                                            isEdit = false;
                                            _nameController.clear();
                                            _phoneNoController.clear();
                                          });
                                        } else {
                                          // shw error
                                        }
                                      },
                                      child: Icon(
                                        Icons.check,
                                        color: color2,
                                        size: width / width30,
                                      ),
                                    )*/
                                  ],
                                ),
                              ],
                            )
                          : ProfileEditWidget(
                              tittle: 'Name',
                              content: _employeeName ?? '',
                              onTap: () {
                                setState(() {
                                  isEdit = true;
                                  _nameController.text = _employeeName ?? '';
                                });
                              },
                            ),
                    ),
                    isEdit
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterSemibold(
                                text: 'Contact No',
                                fontsize: 20.sp,
                                color: color1,
                              ),
                              SizedBox(height: 5.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: SetTextfieldWidget(
                                      maxlength: 11,
                                      keyboardType: TextInputType.number,
                                      hintText: '',
                                      controller: _phoneNoController,
                                      enabled: true,
                                      isEditMode: false,
                                    ),
                                  ),
                                  /*Bounce(
                                    onTap: () {
                                      final newName =
                                          _nameController.text.trim();
                                      final newPhoneNo =
                                          _phoneNoController.text.trim();

                                      if (newName.isNotEmpty &&
                                          newPhoneNo.isNotEmpty) {
                                        _updateEmployeeData(
                                            newName, newPhoneNo);
                                        setState(() {
                                          isEdit = false;
                                          _nameController.clear();
                                          _phoneNoController.clear();
                                        });
                                      } else {
                                        //  show snackbar
                                      }
                                    },
                                    child: Icon(
                                      Icons.check,
                                      color: color2,
                                      size: width / width30,
                                    ),
                                  )*/
                                ],
                              ),
                            ],
                          )
                        : ProfileEditWidget(
                            tittle: 'Contact No',
                            content: _employeePhone ?? '',
                            onTap: () {
                              setState(() {
                                isEdit = true;
                                _phoneNoController.text = _employeePhone ?? '';
                              });
                            },
                          ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 40.h),
                      child: ProfileEditWidget(
                        tittle: 'Email',
                        content: _employeeEmail ?? '',
                        onTap: () {},
                      ),
                    ),
                    ProfileEditWidget(
                      tittle: 'Designation',
                      content: _employeeRole ?? '',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 60.h),
              if (_employeeImageUrl == null &&
                  _employeeRole == null &&
                  _employeeEmail == null &&
                  _employeePhone == null &&
                  _employeeName == null)
                Center(
                  child: PoppinsRegular(
                    text: 'complete your profile !',
                    fontsize: 20.sp,
                    color: color3,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
