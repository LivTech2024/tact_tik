import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../common/widgets/setTextfieldWidget.dart';
import '../../../services/Userservice.dart';
import '../../../services/firebaseFunctions/firebase_function.dart';
import '../../../utils/colors.dart';
import '../visitors/widgets/setTimeWidget.dart';

class ViewKeysScreen extends StatefulWidget {
  final String startDate;
  final String endDate;
  final String keyId;
  final String keyAllocationId;
  final String time;

  ViewKeysScreen(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.keyAllocationId,
      required this.time,
      required this.keyId,
      this.visitorData});
  final Map<String, dynamic>? visitorData;

  @override
  State<ViewKeysScreen> createState() => _ViewAssetsScreenState();
}

class _ViewAssetsScreenState extends State<ViewKeysScreen> {
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

  // late final GlobalKey<ScaffoldMessengerState> _scaffoldKeyKey = GlobalKey<ScaffoldMessengerState>();
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
              primary: DarkColor. Primarycolor,
              secondary: DarkColor. Primarycolor,
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
    }
  }

  Future<void> _saveVisitorData() async {
    final keyAllocationData = {
      'KeyAllocationInTime':
          InTime != null ? '${InTime!.hour}:${InTime!.minute}' : '',
      'KeyAllocationOutTime':
          OutTime != null ? '${OutTime!.hour}:${OutTime!.minute}' : '',
      'KeyAllocationName': nameController.text.trim(),
      'KeyAllocationEmail': EmailController.text.trim(),
      'KeyAllocationContactNumber': ContactNoController.text.trim(),
      'KeyAllocationAssetHandover': AssetHandoverController.text.trim(),
      'KeyAllocationAssetReturn': AssetReturnController.text.trim(),
      'KeyAllocationLicensePlateNumber':
          LicensePlateNumberController.text.trim(),
      'KeyAllocationSetCountdown': SetCountdownController.text.trim(),
      'KeyAllocationComments': CommentsController.text.trim(),
      'KeyAllocationNoOfPerson': NoOfPersonController.text.trim(),
      'KeyAllocationCompanyName': CompanyNameController.text.trim(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('KeyAllocations')
          .doc(widget.keyAllocationId)
          .set(keyAllocationData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    bool isEditMode = widget.visitorData != null;
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height / height30),
              InterBold(
                text: 'Allocation Date',
                color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                fontsize: width / width20,
              ),
              SizedBox(height: height / height30),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: height / height60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width / width10),
                        color: isDark
                            ? DarkColor.WidgetColor
                            : LightColor.WidgetColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InterMedium(text: widget.startDate, fontsize: width / width16, color: isDark
                                  ? DarkColor.color2
                                  : LightColor.color2),
                          SvgPicture.asset('assets/images/calendar_clock.svg', width: width / width20)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: width / width6),
                  Expanded(
                    child: Container(
                      height: height / height60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width / width10),
                        color: isDark
                            ? DarkColor.WidgetColor
                            : LightColor.WidgetColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InterMedium(text: widget.endDate, fontsize: width / width16, color: isDark
                                  ? DarkColor.color2
                                  : LightColor.color2),
                          SvgPicture.asset('assets/images/calendar_clock.svg', width: width / width20)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height / height30),
              InterBold(text: 'Key', color: isDark ? DarkColor.color1 : LightColor.color3, fontsize: width / width16),
              Container(
                height: width / width60,
                width: double.maxFinite,
                margin: EdgeInsets.only(bottom: height / height10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width / width10),
                  color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: height / height44,
                          width: width / width44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width / width10),
                            color: isDark
                                ? DarkColor.Primarycolorlight
                                : LightColor.Primarycolorlight,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.home_repair_service,
                              color: isDark
                                  ? DarkColor.Primarycolor
                                  : LightColor.Primarycolor,
                              size: width / width24,
                            ),
                          ),
                        ),
                        SizedBox(width: width / width20),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Keys')
                              .where('KeyId', isEqualTo: widget.keyId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            String keyName = 'Key Not Available';
                            if (snapshot.hasData) {
                              final documents = snapshot.data!.docs;
                              keyName = documents.isNotEmpty
                                  ? (documents.first.data()
                                          as Map<String, dynamic>)['KeyName'] ??
                                      'Key Not Available'
                                  : 'Key Not Available';
                            }
                            return InterMedium(
                              text: keyName,
                              fontsize: width / width16,
                              color: isDark
                                  ? DarkColor.color1
                                  : LightColor.color3,
                            );
                          },
                        ),
                      ],
                    ),
                    InterMedium(
                      text: widget.time,
                      color: isDark
                          ? DarkColor.color17
                          : LightColor.color2,
                      fontsize: width / width16,
                    ),
                    SizedBox(width: width / width20),
                  ],
                ),
              ),
              SizedBox(height: height / height30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height / height30),
                  InterBold(
                    text: 'Add Visitor',
                    color: isDark ? DarkColor.Primarycolor : LightColor.color3,
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
                  SizedBox(height: height / height30),
                  Button1(
                    text: 'Save',
                    onPressed: () async {
                      await _saveVisitorData();
                    },
                    backgroundcolor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
                    color: isDark ? DarkColor.color22 : LightColor.color1,
                    borderRadius: width / width10,
                    fontsize: width / width18,
                  ),
                ],
              ),
            ],
          ),
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
