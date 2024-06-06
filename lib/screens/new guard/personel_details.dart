import 'package:flutter/cupertino.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/setTextfieldWidget.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';

class PersonalDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final TextEditingController FirstNameController = TextEditingController();
    final TextEditingController LastNameController = TextEditingController();
    final TextEditingController PhoneNumberController = TextEditingController();
    final TextEditingController EmailController = TextEditingController();
    final TextEditingController PasswordController = TextEditingController();
    final TextEditingController RoleController = TextEditingController();
    final TextEditingController PayRateController = TextEditingController();
    final TextEditingController WeekHoursController = TextEditingController();
    final TextEditingController BranchController = TextEditingController();
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
            color: isDark ? DarkColor.Primarycolor : LightColor.color3,
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
