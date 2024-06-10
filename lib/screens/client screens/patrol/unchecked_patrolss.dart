import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';

class UncheckedPatrolScreen extends StatefulWidget {
  const UncheckedPatrolScreen({super.key});

  @override
  State<UncheckedPatrolScreen> createState() => _UncheckedPatrolScreenState();
}

class _UncheckedPatrolScreenState extends State<UncheckedPatrolScreen> {
  @override
  void initState() {
    super.initState();
    //fethh the unchecked patrol checkpoints and take there inputs
  }

  Widget checkReason() {
    return Container(
      height: 46.h,
      width: double.maxFinite,
      decoration: BoxDecoration(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            InterSemibold(
                text: 'Let us know why you have missed?', fontsize: 14.sp),
            SizedBox(height: 10.h),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) => Container(),
            )
          ],
        ),
      ),
    ));
  }
}
