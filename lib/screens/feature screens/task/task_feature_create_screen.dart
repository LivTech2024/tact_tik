import 'package:flutter/material.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/setTextfieldWidget.dart';
import '../../../fonts/inter_regular.dart';
import '../widgets/custome_textfield.dart';

class TaskFeatureCreateScreen extends StatelessWidget {
  TaskFeatureCreateScreen({super.key});

  final TextEditingController _tittleController = TextEditingController();
  final TextEditingController _explainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery
        .of(context)
        .size
        .height;
    final double width = MediaQuery
        .of(context)
        .size
        .width;


    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
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
            },
          ),
          title: InterRegular(
            text: 'Task',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width / width30),
            child: Column(
              children: [
                SizedBox(height: height / height30),
                CustomeTextField(
                  hint: 'Tittle', controller: _tittleController,),
                SizedBox(height: height / height20),
                CustomeTextField(hint: 'Explain',
                  isExpanded: true,
                  controller: _explainController,),
                SizedBox(height: height / height20),
                Button1(text: 'Done',
                  onPressed: () {},
                  backgroundcolor: Primarycolor,
                  borderRadius: width / width10,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
