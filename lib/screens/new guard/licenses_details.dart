import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';

class LicensesDetails extends StatefulWidget {
  final TextEditingController DrivingLicenseController ;
      final TextEditingController SecurityLicensesController ;

  const LicensesDetails({super.key, required this.DrivingLicenseController, required this.SecurityLicensesController});
  @override
  State<LicensesDetails> createState() => _LicensesDetailsState();
}

class _LicensesDetailsState extends State<LicensesDetails> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> uploads = [];
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    
    DateTime? SecurityLicensesExpireDate;
    DateTime? DrivingLicensesExpireDate;
    

    Future<void> _addImage() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          uploads.add({'type': 'image', 'file': File(pickedFile.path)});
        });
      }
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

    Future<void> _openFileExplorer() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        List<String> filePaths = result.paths.map((path) => path!).toList();
        for (String filePath in filePaths) {
          setState(() {
            uploads.add({'type': 'pdf', 'file': File(filePath)});
          });
        }
      }
    }

    Future<void> _selectSecurityLicensesExpireDate(BuildContext context, bool isStart) async {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2015, 8),
          lastDate: DateTime(2101));
      setState(() {
        SecurityLicensesExpireDate = picked;
      });
    }
    Future<void> _selectDrivingLicensesExpireDate(BuildContext context, bool isStart) async {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2015, 8),
          lastDate: DateTime(2101));
      setState(() {
        DrivingLicensesExpireDate = picked;
      });
    }

    bool isEditMode = false;
    return Container(
      width: width / width50,
      padding: EdgeInsets.symmetric(
          horizontal: width / width20, vertical: height / height20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterBold(
            text: 'Add Licenses',
            color: Theme.of(context).textTheme.bodySmall!.color,
            fontsize: width / width20,
          ),
          SizedBox(
            height: height / height20,
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
                    ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text('Add PDF'),
                      onTap: () {
                        Navigator.pop(context);
                        _openFileExplorer();
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
                      color:Theme.of(context).cardColor,
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
                  text: 'Upload Security Licenses',
                  color:  Theme.of(context).textTheme.bodySmall!.color,
                  fontsize: width / width20,
                ),
              ),
            ),
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Security Licenses Number',
            controller:widget. SecurityLicensesController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          
          SizedBox(
            height: height / height5,
          ),
          GestureDetector(
            onTap: () {
              _selectSecurityLicensesExpireDate(context, true);
            },
            child: Container(
              height: height / height60,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  )
                ],
                borderRadius: BorderRadius.circular(width / width10),
                color: Theme.of(context).cardColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InterMedium(
                    text: SecurityLicensesExpireDate != null
                        ? '${SecurityLicensesExpireDate!.toLocal()}'
                            .split(' ')[0]
                        : 'Expired Time',
                    fontsize: width / width16,
                    color:  Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  SvgPicture.asset(
                    'assets/images/calendar_clock.svg',
                    width: width / width20,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: height / height30,
          ),
          InterBold(
            text: 'Add Driving Licenses',
            color:  Theme.of(context).textTheme.bodySmall!.color,
            fontsize: width / width20,
          ),
          SizedBox(
            height: height / height20,
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
                    ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text('Add PDF'),
                      onTap: () {
                        Navigator.pop(context);
                        _openFileExplorer();
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
                      color: Theme.of(context).shadowColor,
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
                  text: 'Upload Driving Licenses',
                  color:  Theme.of(context).textTheme.bodySmall!.color,
                  fontsize: width / width20,
                ),
              ),
            ),
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Driving License Number',
            controller:widget. DrivingLicenseController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          GestureDetector(
            onTap: () {
              _selectDrivingLicensesExpireDate(context, true);
            },
            child: Container(
              height: height / height60,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color:Theme.of(context).shadowColor,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  )
                ],
                borderRadius: BorderRadius.circular(width / width10),
                color: Theme.of(context).cardColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InterMedium(
                    text: DrivingLicensesExpireDate != null
                        ? '${DrivingLicensesExpireDate!.toLocal()}'
                            .split(' ')[0]
                        : 'Expired Time',
                    fontsize: width / width16,
                    color:  Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  SvgPicture.asset(
                    'assets/images/calendar_clock.svg',
                    width: width / width20,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
