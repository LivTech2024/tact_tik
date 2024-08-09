import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'dart:io';

import 'package:tact_tik/common/widgets/customToast.dart';

class EditProfileScreen extends StatefulWidget {
  final String empId;
  final bool isClient;
  final Map<String, dynamic> initialData;

  EditProfileScreen({
    Key? key,
    required this.empId,
    required this.isClient,
    required this.initialData,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  XFile? _selectedImageFile;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name']);
    _phoneController = TextEditingController(text: widget.initialData['phone']);
    _currentImageUrl = widget.initialData['imageUrl'];
  }

  Future<void> updateProfile() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
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
          'ClientPhone': _phoneController.text,
        });
        if (_selectedImageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('clients/images/${widget.empId}_profile.jpg');
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
          'EmployeePhone': _phoneController.text,
        });
        if (_selectedImageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('employees/images/${widget.empId}_profile.jpg');
          await storageRef.putFile(File(_selectedImageFile!.path));
          final downloadUrl = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('Employees')
              .doc(widget.empId)
              .update({'EmployeeImg': downloadUrl});
        }
      }
      setState(() {
        _selectedImageFile = null;
      });
      showSuccessToast(context, "Profile updated successfully", duration: const Duration(seconds: 4));
      Navigator.pop(context, true);
    } catch (e) {
      print('Error updating profile: $e');
      showErrorToast(context, "Failed to update profile");
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Edit Profile',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.white
            )
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 60.r,
                    child: CircleAvatar(
                      radius: 56.r,
                      backgroundImage: _selectedImageFile != null
                          ? FileImage(File(_selectedImageFile!.path))
                          : (_currentImageUrl != null
                          ? NetworkImage(_currentImageUrl!)
                          : AssetImage('assets/images/default.png')) as ImageProvider,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: Icon(Icons.add_a_photo, color: Colors.white),
                        onPressed: _selectImageFromGallery,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            _buildTextField('Name', _nameController),
            SizedBox(height: 20.h),
            _buildTextField('Contact No', _phoneController),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: updateProfile,
                child: Text('Save',
                    style: GoogleFonts.poppins(
                        fontSize: 18.sp, fontWeight: FontWeight.w500, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(300.w, 50.h),
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 20.sp,
        color: Theme.of(context).textTheme.bodyMedium!.color,
      ),
      controller: controller,
      decoration: InputDecoration(
        focusColor: Theme.of(context).primaryColor,
        labelText: label,
        hintStyle: GoogleFonts.poppins(
          fontSize: 20.sp,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 20.sp,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        hintText: label,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      cursorColor: Theme.of(context).primaryColor,
      keyboardType: label == 'Contact No' ? TextInputType.phone : TextInputType.text,
    );
  }
}