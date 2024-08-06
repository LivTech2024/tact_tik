import 'package:bounce/bounce.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
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
import 'edit_profile_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }

  Future<void> _fetchEmployeeData() async {
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () => Navigator.pop(context),
          ),
          title: InterBold(
            text: 'Your Profile',
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240.h,
                width: double.maxFinite,
                color: Colors.transparent,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 54.r,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundImage: _employeeImageUrl != null
                              ? NetworkImage(_employeeImageUrl!)
                              : AssetImage('assets/images/default.png') as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                empId: widget.empId,
                                isClient: widget.isClient,
                                initialData: {
                                  'name': _employeeName,
                                  'phone': _employeePhone,
                                  'imageUrl': _employeeImageUrl,
                                },
                              ),
                            ),
                          ).then((updated) {
                            if (updated == true) {
                              _fetchEmployeeData(); // Refresh the profile data
                            }
                          });
                        },
                        child: PoppinsMedium(
                          text: 'Edit Profile',
                          fontsize: 18.sp,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Card(
                  shadowColor: isDark ? Colors.white : Colors.black,
                  elevation: 3,
                  color: isDark ? Colors.grey[900] : Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileItem('Name', _employeeName ?? ''),
                      Divider(height: 1),
                      _buildProfileItem('Contact No', _employeePhone ?? ''),
                      Divider(height: 1),
                      _buildProfileItem('Email', _employeeEmail ?? ''),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterSemibold(
            text: title,
            fontsize: 16.sp,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
          SizedBox(height: 4.h),
          InterRegular(
            text: content,
            fontsize: 18.sp,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ],
      ),
    );
  }
}
