import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_medium.dart';

class Content extends StatefulWidget {
  final String title;
  final Widget child;

  const Content({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  ContentState createState() => ContentState();
}

class ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color:Theme.of(context).shadowColor,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
        borderRadius: BorderRadius.circular(10.r),
        color: Theme.of(context).cardColor,
      ),
      margin: EdgeInsets.only(top: 10.h),
      // clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          /*Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.sp),
            // color: Colors.blueGrey[50],
            child: InterMedium(
              text: widget.title,
              color: Theme.of(context).textTheme.bodyMedium!.color,
              fontsize: 18.sp,
            ),
          ),*/
          Flexible(fit: FlexFit.loose, child: widget.child),
        ],
      ),
    );
  }
}
