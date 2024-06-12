import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';

class PersonalDetails extends StatelessWidget {
   final TextEditingController FirstNameController ;
    final TextEditingController LastNameController;
    final TextEditingController PhoneNumberController ;
    final TextEditingController EmailController ;
    final TextEditingController PasswordController ;
    final TextEditingController RoleController ;
    final TextEditingController PayRateController ;
    final TextEditingController WeekHoursController ;
    final TextEditingController BranchController  ;

  const PersonalDetails({super.key, required this.FirstNameController, required this.LastNameController, required this.PhoneNumberController, required this.EmailController, required this.PasswordController, required this.RoleController, required this.PayRateController, required this.WeekHoursController, required this.BranchController});




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
            controller: FirstNameController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Last Name',
            controller: LastNameController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Phone Number',
            controller: PhoneNumberController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Email',
            controller: EmailController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Password',
            controller: PasswordController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Role',
            controller: RoleController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Pay Rate(hourly)',
            controller: PayRateController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Maximum week Hours',
            controller: WeekHoursController,
            enabled: !isEditMode,
            isEditMode: isEditMode,
          ),
          SizedBox(
            height: height / height5,
          ),
          SetTextfieldWidget(
            hintText: 'Branch(optional)',
            controller: BranchController,
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
