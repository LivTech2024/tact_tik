import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';

class AddressDetails extends StatefulWidget {
  final TextEditingController AddressController ;
    final TextEditingController cityController ;
    final TextEditingController PostalCodeController ;
    final TextEditingController ProvinceController ;
  final Function(File) onFileSelected;

  const AddressDetails({super.key, required this.AddressController, required this.cityController, required this.PostalCodeController, required this.ProvinceController, required  this.onFileSelected});
  @override
  State<AddressDetails> createState() => _AddressDetailsState();
}

class _AddressDetailsState extends State<AddressDetails> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> uploads = [];
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    

    Future<void> _addImage() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          uploads.add({'type': 'image', 'file': File(pickedFile.path)});
          widget.onFileSelected(File(pickedFile.path));
        });
      }
    }

    Future<void> _addGallery() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          uploads.add({'type': 'image', 'file': File(pickedFile.path)});
          widget.onFileSelected(File(pickedFile.path));
        });
      }
    }

    bool isEditMode = false;
    return SingleChildScrollView(
      child: Container(
        width: 50.w,
        padding: EdgeInsets.symmetric(
            horizontal: width / width20, vertical: height / height20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InterBold(
              text: 'Add Address Details',
              color:  Theme.of(context).textTheme.bodySmall!.color,
              fontsize: width / width20,
            ),
            SetTextfieldWidget(
              hintText: 'Address',
              controller: widget.AddressController,
              enabled: !isEditMode,
              isEditMode: isEditMode,
            ),
            SizedBox(
              height: height / height5,
            ),
            SetTextfieldWidget(
              hintText: 'Postal Code',
              controller:widget. PostalCodeController,
              enabled: !isEditMode,
              isEditMode: isEditMode,
            ),
            SizedBox(
              height: height / height5,
            ),
            SetTextfieldWidget(
              hintText: 'City',
              controller:widget. cityController,
              enabled: !isEditMode,
              isEditMode: isEditMode,
            ),
            SizedBox(
              height: height / height5,
            ),
            SetTextfieldWidget(
              hintText: 'Province',
              controller:widget. ProvinceController,
              enabled: !isEditMode,
              isEditMode: isEditMode,
            ),
            SizedBox(
              height: height / height25,
            ),
            InterBold(
              text: 'Add Profile Photo',
              color:  Theme.of(context).textTheme.bodySmall!.color,
              fontsize: width / width20,
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.camera),
                        title: Text('Add Image'),
                        onTap: () {
                          _addImage();
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.image),
                        title: Text('Add from Gallery'),
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
                height: height / height60,
                // width: width - width / width10,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color:Theme.of(context).shadowColor,
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      )
                    ],
                    color:
                        Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(width / width8)),
                child: Center(
                  child: InterBold(
                    text: 'Upload Profile Photo',
                    color:  Theme.of(context).textTheme.bodySmall!.color,
                    fontsize: width / width20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
