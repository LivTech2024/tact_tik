import 'package:flutter/material.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/setTextfieldWidget.dart';
import '../widgets/custome_textfield.dart';

class TaskFeatureCreateScreen extends StatelessWidget {
  const TaskFeatureCreateScreen({super.key});
  final TextEditingController _tittleController = TextEditingController();
  final TextEditingController _explainController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;


    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              CustomeTextField(hint: 'Tittle',controller: _tittleController,),
              SizedBox(height: height / height20),
              CustomeTextField(hint: 'Explain',isExpanded: true , controller: _explainController,),
              Button1(text: 'Done', onPressed: (){} , backgroundcolor: Primarycolor,borderRadius: width / width10,)
            ],
          ),
        ),
      ),
    );
  }
}
