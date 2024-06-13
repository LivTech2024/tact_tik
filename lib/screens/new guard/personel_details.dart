import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';

class PersonalDetails extends StatefulWidget {
  final TextEditingController FirstNameController;
  final TextEditingController LastNameController;
  final TextEditingController PhoneNumberController;
  final TextEditingController EmailController;
  final TextEditingController PasswordController;
  String SelectedRole;
  final TextEditingController PayRateController;
  final TextEditingController WeekHoursController;
  final TextEditingController BranchController;
  final String CompanyId;
  PersonalDetails(
      {super.key,
      required this.FirstNameController,
      required this.LastNameController,
      required this.PhoneNumberController,
      required this.EmailController,
      required this.PasswordController,
      required this.SelectedRole,
      required this.PayRateController,
      required this.WeekHoursController,
      required this.BranchController,
      required this.CompanyId});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

List<String> PositionValues = [];
FireStoreService fireStoreService = FireStoreService();

class _PersonalDetailsState extends State<PersonalDetails> {
  @override
  String? selectedPosition;
  void initState() {
    getEmployeeRoles();
    super.initState();
  }

  void getEmployeeRoles() async {
    List<String> roles =
        await fireStoreService.getEmployeeRoles(widget.CompanyId);
    if (roles.isNotEmpty) {
      setState(() {
        PositionValues.addAll(roles);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    bool isEditMode = false;
    return Container(
      width: width / width50,
      padding: EdgeInsets.symmetric(
          horizontal: width / width20, vertical: height / height20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterBold(
            text: 'Add Personal Details',
            color: Theme.of(context).textTheme.bodySmall!.color,
            fontsize: width / width20,
          ),
          SetTextfieldWidget(
            hintText: 'First Name',
            controller: widget.FirstNameController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Last Name',
            controller: widget.LastNameController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Phone Number',
            controller: widget.PhoneNumberController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Email',
            controller: widget.EmailController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Password',
            controller: widget.PasswordController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              // color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10.r),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? DarkColor.color19
                      : LightColor.color3,
                ),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                iconSize: 24.w,
                icon: Icon(Icons.arrow_drop_down),
                iconEnabledColor: Theme.of(context).textTheme.bodyMedium!.color,
                // Set icon color for enabled state
                dropdownColor: Theme.of(context).cardColor,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color),
                value: selectedPosition,
                hint: Text("Select Roles"),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPosition = newValue;
                    widget.SelectedRole = newValue ?? '';
                  });
                },
                items: PositionValues.map<DropdownMenuItem<String>>(
                    (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        selectedPosition == value
                            ? Icon(Icons.control_camera,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color)
                            : Icon(Icons.control_camera,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color),
                        // Conditional icon color based on selection
                        SizedBox(width: 10.w),
                        InterRegular(
                            text: value,
                            color: selectedPosition == value
                                ? Theme.of(context).textTheme.bodyMedium!.color
                                : Theme.of(context).textTheme.bodyLarge!.color),
                        // Conditional text color based on selection
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Pay Rate(hourly)',
            controller: widget.PayRateController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Maximum week Hours',
            controller: widget.WeekHoursController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Branch(optional)',
            controller: widget.BranchController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
        ],
      ),
    );
  }
}
