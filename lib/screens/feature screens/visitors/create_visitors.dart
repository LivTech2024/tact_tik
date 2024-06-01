import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/visitors.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/widgets/setTimeWidget.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_regular.dart';
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
  List colors = [Primarycolor, color25];
  String? selectedKeyName;
  String? selectedKeyId;
  List<DocumentSnapshot> keys = [];

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
              primary: Primarycolor,
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    bool isEditMode = widget.visitorData != null;

    var isFieldEnabled = widget.visitorData != null;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: Stack(
          children: [
            CustomScrollView(
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
                      print(
                          "Navigtor debug: ${Navigator.of(context).toString()}");
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
                  child: Column(
                    children: [
                      Container(
                        height: 65.h,
                        width: double.maxFinite,
                        color: color24,
                        padding:
                            EdgeInsets.symmetric(vertical: 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showCreate = true;
                                    colors[0] = Primarycolor;
                                    colors[1] = color25;
                                  });
                                },
                                child: SizedBox(
                                  child: Center(
                                    child: InterBold(
                                      text: 'Create visitor',
                                      color: colors[0],
                                      fontsize: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            VerticalDivider(
                              color: Primarycolor,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showCreate = false;
                                    colors[0] = color25;
                                    colors[1] = Primarycolor;
                                  });
                                },
                                child: SizedBox(
                                  child: Center(
                                    child: InterBold(
                                      text: 'Create Key',
                                      color: colors[1],
                                      fontsize: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: showCreate
                        ? Column(
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
                                    hintText: InTime == null
                                        ? 'In Time'
                                        : '${_formatTime(InTime!, true)}',
                                    onTap: () => _selectTime(context, true),
                                    flex: 2,
                                    isEnabled: true,
                                    enabled: !isEditMode,
                                    isEditMode: isEditMode,
                                  ),
                                  SizedBox(width: width / width6),
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
                              SizedBox(height: height / height20),
                              SetTextfieldWidget(
                                hintText: 'Name',
                                controller: nameController,
                                enabled: !isEditMode,
                                isEditMode: isEditMode,
                              ),
                              SizedBox(height: height / height20),
                              SetTextfieldWidget(
                                hintText: 'Email',
                                controller: EmailController,
                                enabled: !isEditMode,
                                isEditMode: isEditMode,
                              ),
                              SizedBox(height: height / height20),
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
                              SizedBox(height: height / height20),
                              SetTextfieldWidget(
                                hintText: 'Asset Handover',
                                controller: AssetHandoverController,
                                enabled: !isEditMode,
                                isEditMode: isEditMode,
                              ),
                              SizedBox(height: height / height20),
                              SetTextfieldWidget(
                                hintText: 'Asset Return',
                                controller: AssetReturnController,
                                enabled: isEditMode,
                                isEditMode: isEditMode,
                              ),
                              SizedBox(height: height / height20),
                              SetTextfieldWidget(
                                hintText: 'License Plate Number ',
                                controller: LicensePlateNumberController,
                                enabled: !isEditMode,
                                isEditMode: isEditMode,
                              ),
                              SizedBox(height: height / height20),
                              SetTextfieldWidget(
                                hintText: 'Set Countdown',
                                controller: SetCountdownController,
                                enabled: !isEditMode,
                                isEditMode: isEditMode,
                              ),
                              SizedBox(height: height / height20),
                              SetTextfieldWidget(
                                hintText: 'Comments ',
                                controller: CommentsController,
                                enabled: !isEditMode,
                                isEditMode: isEditMode,
                              ),
                              SizedBox(height: height / height20),
                              SetTextfieldWidget(
                                hintText: 'No. Of Person',
                                controller: NoOfPersonController,
                                enabled: !isEditMode,
                                isEditMode: isEditMode,
                              ),
                              SizedBox(height: height / height20),
                              SetTextfieldWidget(
                                hintText: 'Company Name',
                                controller: CompanyNameController,
                                enabled: !isEditMode,
                                isEditMode: isEditMode,
                              ),
                              SizedBox(
                                height: height / height30,
                              ),
                              Button1(
                                text: 'Save',
                                onPressed: () async {
                                  bool isSuccessful = await _saveVisitorData();
                                  if (!isSuccessful) {
                                    // Handle the case when saving or updating visitor data fails
                                  }
                                },
                                backgroundcolor: Primarycolor,
                                color: color22,
                                borderRadius: width / width10,
                                fontsize: width / width18,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterBold(
                                text: 'Key Name',
                                fontsize: 16.sp,
                                color: color1,
                              ),
                              SizedBox(height: 10.h),
                              DropdownButtonFormField<String>(
                                value: selectedKeyName,
                                items: keys.map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  return DropdownMenuItem<String>(
                                    value: data['KeyName'],
                                    child: Text(data['KeyName']),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedKeyName = newValue;
                                    selectedKeyId = keys
                                        .firstWhere((document) =>
                                            (document.data() as Map<String,
                                                dynamic>)['KeyName'] ==
                                            newValue)
                                        .id;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.r),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 60.h,
                                  ),
                                  hintText: 'Select Key Name',
                                  hintStyle: TextStyle(color: color2),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              InterBold(
                                text: 'Allocate Qt.',
                                fontsize: 16.sp,
                                color: color1,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: '0',
                                controller: _AllocateQtController2,
                                showIcon: false,
                                textInputType: TextInputType.number,
                              ),
                              SizedBox(height: height / height10),
                              InterBold(
                                text: 'Description',
                                fontsize: 16.sp,
                                color: color1,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: 'Write something...',
                                controller: _DescriptionController,
                                showIcon: true,
                                isExpanded: true,
                              ),
                              SizedBox(height: 100.h),
                            ],
                          ),
                  ),
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
