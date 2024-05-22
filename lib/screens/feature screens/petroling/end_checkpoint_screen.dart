import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:toastification/toastification.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class EndCheckpointScreen extends StatefulWidget {
  final String CheckpointID;
  final String PatrolID;
  final String ShiftId;
  final String empId;

  const EndCheckpointScreen(
      {super.key,
      required this.CheckpointID,
      required this.PatrolID,
      required this.ShiftId,
      required this.empId});

  @override
  State<EndCheckpointScreen> createState() => _ReportCheckpointScreenState();
}

FireStoreService fireStoreService = FireStoreService();

class _ReportCheckpointScreenState extends State<EndCheckpointScreen> {
  bool _expand = false;
  late Map<String, bool> _expandCategoryMap;
  TextEditingController Controller = TextEditingController();
  bool _isLoading = false;
  String selectedOption = 'Normal';

  @override
  void initState() {
    super.initState();
    _loadShiftStartedState();
    // // Initialize expand state for each category
    // _expandCategoryMap = Map.fromIterable(widget.p.categories,
    //     key: (category) => category.title, value: (_) => false);
  }

  void _loadShiftStartedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _expand = prefs.getBool('expand') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarcolor,
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
            text: 'Report Checkpoint',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height / height30),
                    Text(
                      'Add Note',
                      style: TextStyle(
                        fontSize: width / width14,
                        color: Primarycolor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height / height10),
                    Row(
                      children: [
                        Radio(
                          activeColor: Primarycolor,
                          value: 'Emergency',
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                        InterRegular(
                          text: 'Emergency',
                          fontsize: width / width16,
                          color: color1,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          activeColor: Primarycolor,
                          value: 'Normal',
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                        InterRegular(
                          text: 'Normal',
                          fontsize: width / width16,
                          color: color1,
                        )
                      ],
                    ),
                    SizedBox(height: height / height10),
                    TextField(
                      controller: Controller,
                      decoration: InputDecoration(
                        hintText: 'Add Comment',
                      ),
                    ),
                    SizedBox(height: height / height100)
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Primarycolor,
                    ),
                  ),
                ),
              Align(
                // bottom: 10,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button1(
                      text: 'Submit',
                      onPressed: () async {
                        /*   setState(() {
                          _isLoading = true;
                        });
                        if (uploads.isNotEmpty || Controller.text.isNotEmpty) {
                          await fireStoreService.addImagesToPatrol(
                              uploads,
                               Controller.text,
                              widget.PatrolID,
                              widget.empId,
                              widget.CheckpointID,
                              widget.ShiftId);
                          toastification.show(
                            context: context,
                            type: ToastificationType.success,
                            title: Text("Submitted"),
                            autoCloseDuration: const Duration(seconds: 2),
                          );

                          uploads.clear();
                          Controller.clear();
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                        } else {
                          showErrorToast(context, "Fields cannot be empty");
                          setState(() {
                            _isLoading = false;
                          });
                        }*/
                      },
                      color: Colors.white,
                      borderRadius: width / width20,
                      backgroundcolor: Primarycolor,
                    ),
                    SizedBox(
                      height: height / height20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
