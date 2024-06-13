import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';

class PersonalDetails extends StatefulWidget {
  final TextEditingController FirstNameController;
  final TextEditingController LastNameController;
  final TextEditingController PhoneNumberController;
  final TextEditingController EmailController;
  final TextEditingController PasswordController;
  final TextEditingController RoleController;
  final TextEditingController PayRateController;
  final TextEditingController WeekHoursController;
  final TextEditingController BranchController;

  const PersonalDetails(
      {super.key,
      required this.FirstNameController,
      required this.LastNameController,
      required this.PhoneNumberController,
      required this.EmailController,
      required this.PasswordController,
      required this.RoleController,
      required this.PayRateController,
      required this.WeekHoursController,
      required this.BranchController});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  @override
  Widget build(BuildContext context) {
    String dropdownValue = 'Guard';
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
            height: 15.h,
          ),
          Container(
            height: 60.h,
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                iconSize: 24.w,
                dropdownColor: Theme.of(context).cardColor,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color),
                borderRadius: BorderRadius.circular(10.r),
                value: dropdownValue, // Ensure this matches one of the items
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>['Guard', 'client', 'supervisor']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
