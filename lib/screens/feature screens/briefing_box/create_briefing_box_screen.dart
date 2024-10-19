import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import '../../../common/sizes.dart';
import '../widgets/custome_textfield.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';

class CreateBriefingBoxScreen extends StatefulWidget {
  final String locationId;
  final String shiftName;
  const CreateBriefingBoxScreen(
      {super.key, required this.locationId, required this.shiftName});

  @override
  State<CreateBriefingBoxScreen> createState() =>
      _CreateBriefingBoxScreenState();
}

class _CreateBriefingBoxScreenState extends State<CreateBriefingBoxScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _explainController = TextEditingController();
  bool _isLoading = false;

  Future<void> createBriefing() async {
    setState(() {
      _isLoading = true;
    });

    final briefingId =
        FirebaseFirestore.instance.collection('BriefingBox').doc().id;
    final briefingData = {
      'BriefingId': briefingId,
      'BriefingDescription': _explainController.text,
      'BriefingLocationId': widget.locationId,
      'BriefingCreatedBy': FirebaseAuth.instance.currentUser?.uid,
      'BriefingCreatedAt': FieldValue.serverTimestamp(),
      'BriefingViewedBy': [],
      'BriefingTitle': _titleController.text,
      'BriefingShiftName': widget.shiftName,
    };

    try {
      await FirebaseFirestore.instance
          .collection('BriefingBox')
          .doc(briefingId)
          .set(briefingData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Briefing created successfully'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating briefing: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterMedium(
            text: 'Briefing Box',
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  children: [
                    SizedBox(height: 30.h),
                    CustomeTextField(
                      hint: 'Title',
                      controller: _titleController,
                    ),
                    SizedBox(height: 20.h),
                    CustomeTextField(
                      hint: 'Explain',
                      isExpanded: true,
                      controller: _explainController,
                    ),
                    SizedBox(height: 20.h),
                    Button1(
                      text: 'Done',
                      color: Colors.white,
                      onPressed: () {
                        if (_titleController.text.isEmpty) {
                          showErrorToast(context, 'Add some title');
                          return;
                        }
                        if (_explainController.text.isEmpty) {
                          showErrorToast(context, 'Add some description');
                          return;
                        }
                        createBriefing();
                      },
                      backgroundcolor: Theme.of(context).primaryColor,
                      borderRadius: 10.r,
                    ),
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
            )
          ],
        ),
      ),
    );
  }
}
