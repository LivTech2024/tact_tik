import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import '../../../common/sizes.dart';
import '../../../common/widgets/setTextfieldWidget.dart';
import '../../../fonts/inter_regular.dart';
import '../widgets/custome_textfield.dart';

class TaskFeatureCreateScreen extends StatefulWidget {
  const TaskFeatureCreateScreen({super.key});

  @override
  State<TaskFeatureCreateScreen> createState() =>
      _TaskFeatureCreateScreenState();
}

class _TaskFeatureCreateScreenState extends State<TaskFeatureCreateScreen> {
  final TextEditingController _tittleController = TextEditingController();
  final TextEditingController _explainController = TextEditingController();
  bool _isLoading = false;

  Future<void> saveTaskToFirestore() async {
    final _userService = UserService(firestoreService: FireStoreService());
    await _userService.getShiftInfo();

    // Debugging statement to check if userService is null
    if (_userService == null) {
      print("userService is null");
      return;
    }

    final taskId =
        FirebaseFirestore.instance.collection('TasksCollection').doc().id;
    final taskData = {
      'TaskId': taskId,
      'TaskDescription': _explainController.text,
      'TaskStartDate': FieldValue.serverTimestamp(),
      'TaskForDays': 1,
      'TaskAllotedLocationId': _userService.shiftLocationId,
      'TaskAllotedToEmpIds': FirebaseAuth.instance.currentUser?.uid,
      'TaskIsAllotedToAllEmps': false,
      'TaskCreatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('TasksCollection')
          .doc(taskId)
          .set(taskData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task saved successfully'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving task: $e'),
        ),
      );
    }
  }

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
              Navigator.pop(context);
            },
          ),
          title: InterMedium(
            text: 'Task',
           
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  children: [
                    SizedBox(height: height / height30),
                    CustomeTextField(
                      hint: 'Tittle',
                      controller: _tittleController,
                    ),
                    SizedBox(height: height / height20),
                    CustomeTextField(
                      hint: 'Explain',
                      isExpanded: true,
                      controller: _explainController,
                    ),
                    SizedBox(height: height / height20),
                    Button1(
                      text: 'Done',
                      onPressed: saveTaskToFirestore,
                      backgroundcolor: isDark? DarkColor.Primarycolor:LightColor.Primarycolor,
                      borderRadius: width / width10,
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
            )
          ],
        ),
      ),
    );
  }
}
