import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/visitors.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/widgets/setTimeWidget.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_regular.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../supervisor screens/home screens/widgets/set_details_widget.dart';
import '../widgets/custome_textfield.dart';

class CreateVisitors extends StatefulWidget {
  final Map<String, dynamic>? visitorData;

  CreateVisitors({super.key, this.visitorData});

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
  TextEditingController _AllocateQtController2 = TextEditingController();
  TextEditingController _DescriptionController = TextEditingController();

  TimeOfDay? InTime;
  TimeOfDay? OutTime;
  bool _isLoading = false;
  bool showCreate = true;
  List colors = [
    isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,  isDark ? DarkColor.color25 : LightColor.color2
  ];
  String? selectedKeyName;
  String? selectedKeyId;
  List<DocumentSnapshot> keys = [];

  // late final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  //     GlobalKey<ScaffoldMessengerState>();

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

    // Initialize the controllers with visitor data if available
    if (widget.visitorData != null) {
      nameController.text = widget.visitorData!['VisitorName'] ?? '';
      EmailController.text = widget.visitorData!['VisitorEmail'] ?? '';
      ContactNoController.text =
          widget.visitorData!['VisitorContactNumber'] ?? '';
      AssetHandoverController.text =
          widget.visitorData!['VisitorAssetHandover'] ?? '';
      LicensePlateNumberController.text =
          widget.visitorData!['VisitorLicenseNumber'] ?? '';
      SetCountdownController.text =
          (widget.visitorData!['VisitorAssetDurationInMinute'] ?? '')
              .toString();

      CommentsController.text = widget.visitorData!['VisitorComment'] ?? '';
      NoOfPersonController.text =
          (widget.visitorData!['VisitorNoOfPerson'] ?? '').toString();
      CompanyNameController.text =
          widget.visitorData!['VisitorCompanyName'] ?? '';
      //VisitorCompanyName

      final inTimeTimestamp =
          widget.visitorData!['VisitorInTime'] as Timestamp?;
      final outTimeTimestamp =
          widget.visitorData!['VisitorOutTime'] as Timestamp?;

      InTime = inTimeTimestamp != null
          ? TimeOfDay.fromDateTime(inTimeTimestamp.toDate())
          : null;
      OutTime = outTimeTimestamp != null
          ? TimeOfDay.fromDateTime(outTimeTimestamp.toDate())
          : null;
    }
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
              primary: isDark ? DarkColor.Primarycolor : LightColor.Secondarycolor,
              secondary: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
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

  Future<bool> _saveVisitorData() async {
    if (_validateInputs()) {
      try {
        await _userService.getShiftInfo();
        String? shiftLocationId = _userService.shiftLocationId;
        String? shiftLocation = _userService.shiftLocation;

        // String? employeeId = _userService.employeeId;

        // print("employeekiId : $employeeId");

        FirebaseFirestore firestore = FirebaseFirestore.instance;

        if (widget.visitorData == null) {
          // Create a new visitor document
          DocumentReference docRef = firestore.collection('Visitors').doc();
          String visitorId = docRef.id;
          await firestore.collection('Visitors').add({
            // 'VisitorInTime': InTime != null ? InTime!.format(context) : null,
            'VisitorInTime': Timestamp.now(),
            'VisitorName': nameController.text,
            'VisitorEmail': EmailController.text,
            'VisitorContactNumber': ContactNoController.text,
            'VisitorAssetHandover': AssetHandoverController.text,
            'VisitorLicenseNumber': LicensePlateNumberController.text,
            'VisitorAssetDurationInMinute': SetCountdownController.text,
            'VisitorComment': CommentsController.text,
            'VisitorNoOfPerson': NoOfPersonController.text,
            'VisitorCompanyId': _userService.shiftCompanyId,
            'VisitorCompanyBranchId': _userService.shiftCompanyBranchId,
            'VisitorCompanyName': CompanyNameController.text,
            'VisitorId': visitorId,
            'VisitorCreatedAt': Timestamp.now(),
            'VisitorLocationId': shiftLocationId,
            'VisitorLocationName': shiftLocation,
            'VisitorOutTime': null,
            'VisitorReturnAsset': null,
          });
        } else {
          String visitorId = widget.visitorData!['VisitorId'];
          print("visitors:$visitorId");

          QuerySnapshot querySnapshot = await firestore
              .collection('Visitors')
              .where('VisitorId', isEqualTo: visitorId)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
            await documentSnapshot.reference.update({
              'VisitorOutTime': OutTime != null
                  ? Timestamp.fromDate(DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      OutTime!.hour,
                      OutTime!.minute,
                    ))
                  : null,
              'VisitorReturnAsset': AssetReturnController.text,
            });
            _showSnackbar('Visitor data updated successfully!');
          } else {
            _showSnackbar('Visitor document does not exist!');
          }
        }

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

        // Navigate to the visitor screen after saving or updating visitor data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VisiTorsScreen(
              locationId: '',
            ), // Replace with your visitor screen widget
          ),
        );
        return true;
      } catch (error) {
        _showSnackbar('Error saving visitor data: $error');
        return false;
      }
    }
    return false;
  }

  bool _validateInputs() {
    print('Email Controller = ${EmailController.text}');
    if ((InTime == null && OutTime == null) ||
        nameController.text.isEmpty ||
        EmailController.text.isEmpty ||
        ContactNoController.text.isEmpty ||
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

    bool isEditMode = widget.visitorData != null;

    var isFieldEnabled = widget.visitorData != null;
    return SafeArea(
      child: Scaffold(
        backgroundColor:  isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  shadowColor:  isDark ? DarkColor.color1 : LightColor.color3.withOpacity(.1),
                  backgroundColor:  isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
                  elevation: 5,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color:  isDark ? DarkColor.color1 : LightColor.color3,
                      size: 24.sp,
                    ),
                    padding: EdgeInsets.only(left: 20.w),
                    onPressed: () {
                      Navigator.pop(context);
                      print(
                          "Navigtor debug: ${Navigator.of(context).toString()}");
                    },
                  ),
                  title: InterMedium(
                    text: 'Create Visitors',
                     fontsize: 18.sp,
                    color:  isDark ? DarkColor.color1 : LightColor.color3,
                    letterSpacing: -.3,
                  ),
                  centerTitle: true,
                  floating: true, // Makes the app bar float above the content
                ),
                SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30.h),
                          InterBold(
                            text: 'Add Visitor',
                            color:  isDark ? DarkColor.Primarycolor : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 30.h),
                          InterBold(
                            text: 'Allocation Date',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              SetTimeWidget(
                                hintText: InTime == null
                                    ? 'In Time'
                                    : '${_formatTime(InTime!, true)}',
                                onTap: () => _selectTime(context, true),
                                flex: 2,
                                isEnabled: true,
                                enabled: !isEditMode,
                                isEditMode: isEditMode,
                              ),
                              SizedBox(width: 6.w),
                              SetTimeWidget(
                                hintText: OutTime == null
                                    ? 'Out Time'
                                    : '${_formatTime(OutTime!, false)}',
                                onTap: () => _selectTime(context, false),
                                flex: 2,
                                isEnabled: isEditMode,
                                enabled: isEditMode,
                                isEditMode: isEditMode,
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Name',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'Name',
                            controller: nameController,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Email',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'Email',
                            controller: EmailController,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Contact Number',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'Contact Number',
                            controller: ContactNoController,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter
                                  .digitsOnly, // Allows only digits
                            ],
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Asset Handover',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'Asset Handover',
                            controller: AssetHandoverController,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Asset Return',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'Asset Return',
                            controller: AssetReturnController,
                            enabled: isEditMode,
                            isEditMode: isEditMode,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'License Plate Number.',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'License Plate Number ',
                            controller: LicensePlateNumberController,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Set Countdown',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'Set Countdown',
                            controller: SetCountdownController,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Comments',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'Comments ',
                            controller: CommentsController,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'No. of Person',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'No. Of Person',
                            controller: NoOfPersonController,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Company Name',
                            color: isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'Company Name',
                            controller: CompanyNameController,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          Button1(
                            text: 'Save',
                            onPressed: () async {
                              bool isSuccessful = await _saveVisitorData();
                              if (!isSuccessful) {
                                // Handle the case when saving or updating visitor data fails
                              }
                            },
                            backgroundcolor:  isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
                            color:  isDark ? DarkColor.color22 : LightColor.color3,
                            borderRadius: 10.r,
                            fontsize: 18.sp,
                            height: 60.h,
                          ),
                        ],
                      )),
                )
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: Visibility(
                visible: _isLoading,
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time, bool isStartTime) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour}:${minute} ${period}';
  }
}
