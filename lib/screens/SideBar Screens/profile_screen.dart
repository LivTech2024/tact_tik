import 'package:bounce/bounce.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'package:tact_tik/main.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../common/sizes.dart';
import '../../common/widgets/contact_widget.dart';
import '../../fonts/inter_regular.dart';
import '../../fonts/inter_semibold.dart';
import '../../utils/colors.dart';

import '../../common/widgets/setTextfieldWidget.dart';
import '../home screens/widgets/profile_edit_widget.dart';

class ProfileScreen extends StatefulWidget {
  bool isClient;
  final String empId;

  ProfileScreen({Key? key, required this.empId, this.isClient = false})
      : super(key: key);

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
    print("CLIENT KA EMPLOYEE ID: ${widget.empId}");
    _fetchEmployeeData();
  }

  Future<void> _fetchEmployeeData() async {
    // print("CLIENT KA EMPLOYEE ID: ${widget.empId}");
    if (widget.isClient) {
      final clientSnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .where('ClientId', isEqualTo: widget.empId)
          .get();
      if (clientSnapshot.docs.isNotEmpty) {
        final clientData = clientSnapshot.docs.first.data();
        setState(() {
          _employeeName = clientData['ClientName'];
          _employeeEmail = clientData['ClientEmail'];
          _employeeRole = "Client";
          _employeePhone = clientData['ClientPhone'];
          _employeeImageUrl = clientData['ClientHomePageBgImg'];
          _nameController.text = _employeeName ?? '';
          _phoneNoController.text = _employeePhone ?? '';
        });
      }
    } else {
      final employeeSnapshot = await FirebaseFirestore.instance
          .collection('Employees')
          .where('EmployeeId', isEqualTo: widget.empId)
          .get();
      if (employeeSnapshot.docs.isNotEmpty) {
        final employeeData = employeeSnapshot.docs.first.data();
        setState(() {
          _employeeName = employeeData['EmployeeName'];
          _employeeEmail = employeeData['EmployeeEmail'];
          _employeeRole = employeeData['EmployeeRole'];
          _employeePhone = employeeData['EmployeePhone'];
          _employeeImageUrl = employeeData['EmployeeImg'];
          _nameController.text = _employeeName ?? '';
          _phoneNoController.text = _employeePhone ?? '';
        });
      }
    }
  }

  Future<void> updateProfile() async {
    if (_nameController.text.isEmpty || _phoneNoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both Name and Contact No')),
      );
      return;
    }
    try {
      if (widget.isClient) {
        await FirebaseFirestore.instance
            .collection('Clients')
            .doc(widget.empId)
            .update({
          'ClientName': _nameController.text,
          'ClientPhone': _phoneNoController.text,
        });
        if (_selectedImageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('clients/images/${_selectedImageFile!.name}');
          await storageRef.putFile(File(_selectedImageFile!.path));
          final downloadUrl = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('Clients')
              .doc(widget.empId)
              .update({'ClientHomePageBgImg': downloadUrl});
        }
      } else {
        await FirebaseFirestore.instance
            .collection('Employees')
            .doc(widget.empId)
            .update({
          'EmployeeName': _nameController.text,
          'EmployeePhone': _phoneNoController.text,
        });
        if (_selectedImageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('employees/images/${_selectedImageFile!.name}');
          await storageRef.putFile(File(_selectedImageFile!.path));
          final downloadUrl = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('Employees')
              .doc(widget.empId)
              .update({'EmployeeImg': downloadUrl});
        }
      }
      _fetchEmployeeData();
      setState(() {
        isEdit = false;
        _selectedImageFile = null;
      });
    } catch (e) {
      print('Error updating profile: $e');
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              isEdit ? Icons.close : Icons.arrow_back_ios,
              color: DarkColor.color5,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              if (isEdit) {
                setState(() {
                  isEdit = !isEdit;
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: InterMedium(
            text: 'Your Profile',
            color: DarkColor.color5,
          ),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () {
                if (isEdit) {
                  if (_nameController.text.isEmpty ||
                      _phoneNoController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Please fill in both Name and Contact No')),
                    );
                    return;
                  }
                  updateProfile();
                }
                setState(() {
                  isEdit = !isEdit;
                });
              },
              icon: Icon(
                isEdit ? Icons.check : Icons.border_color,
                color: DarkColor.color5,
              ),
            ),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF9C6400)
                          : LightColor.Primarycolor,
                    ],
                    begin: Alignment(0, -1.5),
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: _employeeImageUrl != null
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: isEdit
                            ? Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipOval(
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
                                              : Image.asset(
                                                  'assets/images/default.png'),
                                    ),
                                  ),
                                  Positioned(
                                    right: -10.w,
                                    bottom: -4.h,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () =>
                                          _selectImageFromGallery(),
                                      icon: Icon(
                                        Icons.add_a_photo,
                                        size: 24.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : ClipOval(
                                child: SizedBox.fromSize(
                                  size: Size.fromRadius(50.r),
                                  child: _employeeImageUrl != null
                                      ? Image.network(
                                          _employeeImageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/default.png'),
                                ),
                              ),
                      ),
                      SizedBox(height: 20.h),
                      PoppinsMedium(
                        text: _employeeName ?? '',
                        fontsize: 18.sp,
                        color: DarkColor.color1,
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
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: isEdit
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InterSemibold(
                                  text: 'Name',
                                  fontsize: 20.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
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
                                  ],
                                ),
                              ],
                            )
                          : ProfileEditWidget(
                              tittle: 'Name',
                              content: _employeeName ?? '',
                              onTap: () {},
                            ),
                    ),
                    isEdit
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterSemibold(
                                text: 'Contact No',
                                fontsize: 20.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                              SizedBox(height: 5.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: ContactWidget(
                                      controller: _phoneNoController,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : ProfileEditWidget(
                            tittle: 'Contact No',
                            content: _employeePhone ?? '',
                            onTap: () {},
                          ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
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
              if (_employeeImageUrl == null ||
                  _employeeRole == null ||
                  _employeeEmail == null ||
                  _employeePhone == null ||
                  _employeeName == null)
                Center(
                  child: PoppinsRegular(
                    text: 'Complete your profile!',
                    fontsize: 20.sp,
                    color: Theme.of(context).textTheme.headlineSmall!.color,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
