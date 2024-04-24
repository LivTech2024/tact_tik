import 'package:bounce/bounce.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'dart:io';

import '../../common/sizes.dart';
import '../../fonts/inter_regular.dart';
import '../../fonts/inter_semibold.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';
import '../feature screens/visitors/widgets/setTextfieldWidget.dart';
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

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
              size: width / width24,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            text: 'Your Profile',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isEdit = !isEdit;
                });
              },
              icon: Icon(
                isEdit ? Icons.close : Icons.border_color,
                size: width / width24,
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
                height: 340,
                width: double.maxFinite,
                decoration: BoxDecoration(
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
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFFAC7310),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: SizedBox.fromSize(
                              size: Size.fromRadius(50),
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
                                      : Icon(Icons.person, size: 100),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height / height20),
                      PoppinsMedium(
                        text: _employeeName ?? '',
                        fontsize: width / width18,
                        color: color1,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: height / height40),
                      child: isEdit
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InterSemibold(
                                  text: 'Name',
                                  fontsize: width / width20,
                                  color: color1,
                                ),
                                SizedBox(height: height / height5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SetTextfieldWidget(
                                        hintText: '',
                                        controller: _nameController,
                                      ),
                                    ),
                                    SizedBox(width: width / width6),
                                    Bounce(
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
                                    )
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
                                fontsize: width / width20,
                                color: color1,
                              ),
                              SizedBox(height: height / height5),
                              Row(
                                children: [
                                  Expanded(
                                    child: SetTextfieldWidget(
                                      hintText: '',
                                      controller: _phoneNoController,
                                    ),
                                  ),
                                  SizedBox(width: width / width6),
                                  Bounce(
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
                                  )
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
                          EdgeInsets.symmetric(vertical: height / height40),
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
              SizedBox(height: height / height60),
              Center(
                child: PoppinsRegular(
                  text: 'complete your profile !',
                  fontsize: width / width20,
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
