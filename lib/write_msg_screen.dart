
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/widgets/custome_textfield.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';


class WriteMsgScreen extends StatefulWidget {
 

  WriteMsgScreen({
    Key? key,
    
  }) : super(key: key);

  @override
  State<WriteMsgScreen> createState() => _WriteMsgScreenState();
}

class _WriteMsgScreenState extends State<WriteMsgScreen> {
  bool shouldShowButton = false;
  List<String> imageUrls = [];
  List<Map<String, dynamic>> DisplayIMage = [];

  FireStoreService fireStoreService = FireStoreService();
  List<String> tittles = [];
  Map<String, dynamic> reportData = {};
  final TextEditingController explainController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();
  bool isChecked = false;
  String dropdownValue = 'Incident';
  bool dropdownShoe = false;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    
    super.initState();
    
  }

  
  // Initialize default value
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
         
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Write Message',
            
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height / height30),
                    InterBold(
                      text: 'Employee',
                      fontsize: width / width20,
                      color:
                           Theme.of(context).textTheme.bodySmall!.color,
                      letterSpacing: -.3,
                    ),
                    SizedBox(height: height / height30),
                    CustomeTextField(
                      hint: 'Select',
                      controller: titleController,
                      isEnabled: 
                           true,
                           showIcon: false,
                    ),
                    
                  
                    
                    SizedBox(height: height / height20),
                    Container(
                      height: height / height60,
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor,
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          )
                        ],
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(width / width10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InterMedium(
                            text: 'Send To Admin',
                            color:  Theme.of(context).textTheme.labelSmall!.color,
                            fontsize: width / width16,
                            letterSpacing: -.3,
                          ),
                          Checkbox(
                            activeColor: Theme.of(context).primaryColor,
                            checkColor: DarkColor.color1,
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height / height20),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color:Theme.of(context).shadowColor,
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: CustomeTextField(
                        hint: 'Write Your Message',
                        isExpanded: true,
                        controller: explainController,
                        isEnabled:  true,
                        showIcon: false,
                      ),
                    ),
                  
                    
                    
                    SizedBox(height: height / height60),
                    Button1(
                      text: 'Submit',
                      onPressed: () async {
                        
                      },
                      color: Theme.of(context).textTheme.headlineMedium!.color,
                      backgroundcolor: Theme.of(context).primaryColor,
                      borderRadius: 10.r,
                    ),
                  ],
                ),
              ),
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
}
