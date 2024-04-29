import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/widgets/setTimeWidget.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import '../../supervisor screens/home screens/widgets/set_details_widget.dart';

class CreateVisitors extends StatefulWidget {
  CreateVisitors({super.key});

  @override
  State<CreateVisitors> createState() => _CreateVisitorsState();
}

class _CreateVisitorsState extends State<CreateVisitors> {
  // FireStoreService fireStoreService = FireStoreService();
  late TextEditingController nameController;
  late TextEditingController EmailController;
  late TextEditingController ContactNoController;
  late TextEditingController AssetHandoverController;
  late TextEditingController AssetReturnController;
  late TextEditingController LicensePlateNumberController;
  late TextEditingController SetCountdownController;
  late TextEditingController CommentsController;
  late TextEditingController NoOfPersonController;
  late TextEditingController CompanyNameController;

  TimeOfDay? InTime;
  TimeOfDay? OutTime;

  late final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = UserService(firestoreService: FireStoreService());
    nameController = TextEditingController();
    EmailController = TextEditingController();
    ContactNoController = TextEditingController();
    AssetHandoverController = TextEditingController();
    AssetReturnController = TextEditingController();
    LicensePlateNumberController = TextEditingController();
    SetCountdownController = TextEditingController();
    CommentsController = TextEditingController();
    NoOfPersonController = TextEditingController();
    CompanyNameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    EmailController.dispose();
    ContactNoController.dispose();
    AssetHandoverController.dispose();
    AssetReturnController.dispose();
    LicensePlateNumberController.dispose();
    SetCountdownController.dispose();
    CommentsController.dispose();
    NoOfPersonController.dispose();
    CompanyNameController.dispose();
    super.dispose();
  }

  Future<TimeOfDay?> showCustomTimePicker(BuildContext context) async {
    TimeOfDay? selectedTime;

    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Primarycolor, // Change primary color to red
              secondary: Primarycolor,
            ),
          ),
          child: child!,
        );
      },
    );

    return selectedTime;
  }

  void _selectTime(BuildContext context, bool isStartTime) async {
    final selectedTime = await showCustomTimePicker(context);
    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          InTime = selectedTime;
        } else {
          OutTime = selectedTime;
        }
      });
      print('InTime: $InTime');
      print('OutTime: $OutTime');
    }
  }

  void _saveVisitorData() async {
    if (_validateInputs()) {
      try {
        await _userService.getShiftInfo();
        String? shiftLocationId = _userService.shiftLocationId;

        print("Shiftlocation : $shiftLocationId");

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('Visitors').add({
          'VisitorInTime': InTime != null ? InTime!.format(context) : null,
          'VisitorName': nameController.text,
          'VisitorEmail': EmailController.text,
          'VisitorContactNumber': ContactNoController.text,
          'VisitorAssetHandover': AssetHandoverController.text,
          'VisitorLicenseNumber': LicensePlateNumberController.text,
          'VisitorAssetDurationInMinute': SetCountdownController.text,
          'VisitorComment': CommentsController.text,
          'VisitorNoOfPerson': NoOfPersonController.text,
          'VisitorCompanyId': CompanyNameController.text,
          'VisitorCreatedAt': Timestamp.now(),
          'VisitorLocationId': shiftLocationId,
          'VisitorOutTime': null,
          'VisitorReturnAsset': null,
        });
        _showSnackbar('Visitor data saved successfully!');

        // Clear all the controllers
        nameController.clear();
        EmailController.clear();
        ContactNoController.clear();
        AssetHandoverController.clear();
        LicensePlateNumberController.clear();
        SetCountdownController.clear();
        CommentsController.clear();
        NoOfPersonController.clear();
        CompanyNameController.clear();
        setState(() {
          InTime = null;
          OutTime = null;
        });
      } catch (error) {
        _showSnackbar('Error saving visitor data: $error');
      }
    }
  }

  // (InTime == null && OutTime != null) ||
  //       (InTime != null && OutTime == null)

  // 1 both null
  // intime != null outTime == null

  bool _validateInputs() {
    print('Email Controller = ${EmailController.text}');
    if ((InTime == null && OutTime == null) ||
        nameController.text.isEmpty ||
        EmailController.text.isEmpty ||
        ContactNoController.text.isEmpty ||
        AssetHandoverController.text.isEmpty ||
        LicensePlateNumberController.text.isEmpty ||
        SetCountdownController.text.isEmpty ||
        CommentsController.text.isEmpty ||
        NoOfPersonController.text.isEmpty ||
        CompanyNameController.text.isEmpty) {
      _showSnackbar('Please fill in all fields correctly');
      return false;
    }
    return true;
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    var isFieldEnabled = false;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
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
                  print("Navigtor debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterRegular(
                text: 'Create Visitors',
                fontsize: width / width18,
                color: Colors.white,
                letterSpacing: -.3,
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height / height30),
                    InterBold(
                      text: 'Add Visitor',
                      color: Primarycolor,
                      fontsize: width / width20,
                    ),
                    SizedBox(height: height / height30),
                    Row(
                      children: [
                        SetTimeWidget(
                          hintText: InTime == null ? 'In Time' : '${InTime}',
                          onTap: () => _selectTime(context, true),
                          flex: 2,
                          isEnabled: true,
                        ),
                        SizedBox(width: width / width6),
                        SetTimeWidget(
                          hintText: OutTime == null ? 'Out Time' : '${OutTime}',
                          onTap: () => _selectTime(context, false),
                          flex: 2,
                          isEnabled: false,
                        ),
                      ],
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Name',
                      controller: nameController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Email',
                      controller: EmailController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Contact Number',
                      controller: ContactNoController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Asset Handover',
                      controller: AssetHandoverController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Asset Return',
                      controller: AssetReturnController,
                      isEnabled: isFieldEnabled,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'License Plate Number ',
                      controller: LicensePlateNumberController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Set Countdown',
                      controller: SetCountdownController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Comments ',
                      controller: CommentsController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'No. Of Person',
                      controller: NoOfPersonController,
                    ),
                    SizedBox(height: height / height20),
                    SetTextfieldWidget(
                      hintText: 'Company Name',
                      controller: CompanyNameController,
                    ),
                    SizedBox(
                      height: height / height30,
                    ),
                    Button1(
                      text: 'Save',
                      onPressed: _saveVisitorData,
                      backgroundcolor: Primarycolor,
                      color: color22,
                      borderRadius: width / width10,
                      fontsize: width / width18,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
