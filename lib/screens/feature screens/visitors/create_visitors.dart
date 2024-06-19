import 'dart:math';

import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/visitors.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/widgets/setTimeWidget.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_regular.dart';
import '../../../main.dart';
import '../../../test_screen.dart';
import '../../../utils/colors.dart';
import '../../supervisor screens/home screens/widgets/set_details_widget.dart';
import '../widgets/custome_textfield.dart';

class CreateVisitors extends StatefulWidget {
  final Map<String, dynamic>? visitorData;
  final bool isCompleted;
  final bool showButton;
  CreateVisitors(
      {super.key,
      this.visitorData,
      required this.isCompleted,
      required this.showButton});

  @override
  State<CreateVisitors> createState() => _CreateVisitorsState();
}

class _CreateVisitorsState extends State<CreateVisitors> {
  // FireStoreService fireStoreService = FireStoreService();
  late TextEditingController nameController;
  late TextEditingController EmailController;
  late TextEditingController ContactNoController;
  late TextEditingController AssetHandoverController;
  late DynamicTagController<DynamicTagData> _dynamicTagController;
  late TextEditingController AssetReturnController;
  late TextEditingController LicensePlateNumberController;
  late TextEditingController SetCountdownController;
  late TextEditingController CommentsController;
  late TextEditingController NoOfPersonController;
  late TextEditingController CompanyNameController;
  TextEditingController _AllocateQtController2 = TextEditingController();
  TextEditingController _DescriptionController = TextEditingController();

  // final random = Random();
  List<String> tags = [];
  List<String> options = [];
  List<String> Emptyoptions = [""];

  TimeOfDay? InTime;
  TimeOfDay? OutTime;
  bool _isLoading = false;
  bool showCreate = true;

  String? selectedKeyName;
  String? selectedKeyId;
  List<DocumentSnapshot> keys = [];
  late double _distanceToField;

  // late final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  //     GlobalKey<ScaffoldMessengerState>();

  late UserService _userService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  List<String> convertCommaSeparatedStringToList(String data) {
    return data.split(',').map((e) => e.trim()).toList();
  }

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
    _dynamicTagController = DynamicTagController<DynamicTagData>();
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
      if (widget.visitorData!['VisitorAssetHandover'] != null) {
        // Assuming `DynamicTagController<DynamicTagData<dynamic>>` expects a certain structure
        // String commaSeparatedString =
        //     widget.visitorData!['VisitorAssetHandover'];

        // List<String> tags = commaSeparatedString.split(',');

        // // Convert each tag into a DynamicTagData object
        // List<DynamicTagData> dynamicTags =
        //     tags.map((tag) => DynamicTagData(tag.trim(), "")).toList();

        // // Update the TextFieldTags controller with the new tags
        // for (var tag in tags) {
        //   setState(() {
        //     _dynamicTagController.addTag(DynamicTagData(tag.trim(), ""));
        //   });
        // }
        List<String> opt = convertCommaSeparatedStringToList(
            widget.visitorData!['VisitorAssetHandover']);
        setState(() {
          tags = opt;
        });
      }
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
    _dynamicTagController.dispose();
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
              primary: Theme.of(context).brightness == Brightness.dark
                  ? DarkColor.Primarycolor
                  : LightColor.Secondarycolor,
              secondary: Theme.of(context).primaryColor,
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
        String commaSeparatedTags = _dynamicTagController.getTags!
            .map((dynamicTagData) => dynamicTagData.tag)
            .join(',');
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
            'VisitorAssetHandover': commaSeparatedTags,
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

  List<Color> colors = [
    themeManager.themeMode == ThemeMode.dark
        ? DarkColor.color1
        : LightColor.color3,
    themeManager.themeMode == ThemeMode.dark
        ? DarkColor.color25
        : LightColor.color2,
  ];

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.visitorData != null;

    var isFieldEnabled = widget.visitorData != null;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 30.h),
                          InterBold(
                            text: 'Allocation Date',
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          /*SetTextfieldWidget(
                            hintText: 'Asset Handover',
                            controller: AssetHandoverController,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                          ),*/
                          TextFieldTags<DynamicTagData>(
                            textfieldTagsController: _dynamicTagController,
                            // initialTags: _initialTags,
                            textSeparators: const [' ', ','],
                            letterCase: LetterCase.normal,
                            validator: (DynamicTagData tag) {
                              // if (tag.tag == 'lion') {
                              //   return 'Not envited per tiger request';
                              // } else if (_dynamicTagController.getTags!
                              //     .any((element) => element.tag == tag.tag)) {
                              //   return 'Already in the club';
                              // }
                              return null;
                            },
                            inputFieldBuilder: (context, inputFieldValues) {
                              return Container(
                                constraints: BoxConstraints(
                                  minHeight: 60.h,
                                ),
                                width: double.maxFinite,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Theme.of(context).cardColor,
                                ),
                                margin: EdgeInsets.only(top: 10.h),
                                child: Center(
                                  child: TextField(
                                    onTap: () {
                                      _dynamicTagController.getFocusNode
                                          ?.requestFocus();
                                    },
                                    controller:
                                        inputFieldValues.textEditingController,
                                    focusNode: inputFieldValues.focusNode,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.r),
                                        ),
                                      ),
                                      focusedBorder: InputBorder.none,
                                      hintStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 18.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      counterText: "",
                                      hintText: inputFieldValues.tags.isNotEmpty
                                          ? ''
                                          : "Asset Handover",
                                      errorText: inputFieldValues.error,
                                      prefixIconConstraints: BoxConstraints(
                                          maxWidth: _distanceToField * 0.8),
                                      prefixIcon: inputFieldValues
                                              .tags.isNotEmpty
                                          ? SingleChildScrollView(
                                              controller: inputFieldValues
                                                  .tagScrollController,
                                              scrollDirection: Axis.vertical,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: 8.h,
                                                  bottom: 8.h,
                                                  left: 8.w,
                                                ),
                                                child: Wrap(
                                                    runSpacing: 4.0,
                                                    spacing: 4.0,
                                                    children: inputFieldValues
                                                        .tags
                                                        .map((DynamicTagData
                                                            tag) {
                                                      return Container(
                                                        height: 40.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.r),
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .color,
                                                        ),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    5.w),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.w,
                                                                vertical: 5.h),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            InterRegular(
                                                              text:
                                                                  '${tag.tag}',
                                                              color: Theme.of(context)
                                                                          .brightness ==
                                                                      Brightness
                                                                          .dark
                                                                  ? DarkColor
                                                                      .color27
                                                                  : LightColor
                                                                      .color1,
                                                            ),
                                                            SizedBox(
                                                                width: 4.w),
                                                            InkWell(
                                                              child: Icon(
                                                                Icons.cancel,
                                                                size: 14.sp,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .displayMedium!
                                                                    .color,
                                                              ),
                                                              onTap: () {
                                                                inputFieldValues
                                                                    .onTagRemoved(
                                                                        tag);
                                                              },
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    }).toList()),
                                              ),
                                            )
                                          : null,
                                    ),
                                    cursorColor: Theme.of(context).primaryColor,
                                    onChanged: (value) {
                                      final tagData = DynamicTagData(value, "");
                                      inputFieldValues.onTagChanged(tagData);
                                    },
                                    onSubmitted: (value) {
                                      final tagData = DynamicTagData(value, "");
                                      inputFieldValues.onTagSubmitted(tagData);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Asset Return',
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          /*SetTextfieldWidget(
                            hintText: 'Asset Return',
                            controller: AssetReturnController,
                            enabled: isEditMode,
                            isEditMode: isEditMode,
                          ),*/
                          Content(
                            title: 'Asset Return',
                            child: ChipsChoice<String>.multiple(
                              value: options,
                              placeholder: "asset",
                              onChanged: (val) {
                                setState(() {
                                  options = val;
                                });
                              },
                              choiceItems: C2Choice.listFrom<String, String>(
                                source: options.isEmpty
                                    ? Emptyoptions
                                    : options, // Use an empty list if options is null
                                value: (i, v) => v,
                                label: (i, v) => v,
                                tooltip: (i, v) => v,
                              ),
                              choiceCheckmark: true,
                              choiceStyle: C2ChipStyle.outlined(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'License Plate Number.',
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'License Plate Number ',
                            controller: LicensePlateNumberController,
                            keyboardType: TextInputType.number,
                            enabled: !isEditMode,
                            isEditMode: isEditMode,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Set Countdown',
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 10.h),
                          SetTextfieldWidget(
                            hintText: 'No. Of Person',
                            controller: NoOfPersonController,
                            enabled: !isEditMode,
                            keyboardType: TextInputType.number,
                            isEditMode: isEditMode,
                            maxlength: 3,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Company Name',
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                          widget.showButton == false
                              ? Button1(
                                  text: 'Save',
                                  onPressed: () async {
                                    bool isSuccessful =
                                        await _saveVisitorData();
                                    if (!isSuccessful) {
                                      // Handle the case when saving or updating visitor data fails
                                    }
                                  },
                                  backgroundcolor:
                                      Theme.of(context).primaryColor,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .color,
                                  borderRadius: 10.r,
                                  fontsize: 18.sp,
                                  height: 60.h,
                                )
                              : SizedBox(),
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
