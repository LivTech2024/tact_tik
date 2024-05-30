import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';

class BankDetails extends StatefulWidget {
  @override
  State<BankDetails> createState() => _BankDetailsState();
}

class _BankDetailsState extends State<BankDetails> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> uploads = [];
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final TextEditingController AccountNumberController =
        TextEditingController();
    final TextEditingController TransitNumberController =
        TextEditingController();
    final TextEditingController InstitutionNumberController =
        TextEditingController();
    final TextEditingController SINNumberController = TextEditingController();

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

    bool isEditMode = false;
    return Container(
      width: width / width50,
      padding: EdgeInsets.symmetric(
          horizontal: width / width20, vertical: height / height20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterBold(
            text: 'Add Bank Details',
            color: isDark ? DarkColor.Primarycolor : LightColor.color3,
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
                      color: isDark
                          ? Colors.transparent
                          : LightColor.color3.withOpacity(.05),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    )
                  ],
                  color:isDark? DarkColor.WidgetColor:LightColor.WidgetColor,
                  borderRadius: BorderRadius.circular(width / width8)),
              child: Center(
                child: InterBold(
                            text: 'Upload Void Check',
                            color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                            fontsize: width / width20,
                          ),
              ),
            ),
          ),
          SetTextfieldWidget(
            hintText: 'Account Number',
            controller: AccountNumberController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Transit Number',
            controller: TransitNumberController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Institution Number',
            controller: InstitutionNumberController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height30,
          ),
          InterBold(
            text: 'Add SIN Number',
            color: isDark ? DarkColor.Primarycolor : LightColor.color3,
            fontsize: width / width20,
          ),
          SetTextfieldWidget(
            hintText: 'SIN Number',
            controller: SINNumberController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          )
        ],
      ),
    );
  }
}
