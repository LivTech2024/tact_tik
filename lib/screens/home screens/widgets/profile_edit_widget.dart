import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

class ProfileEditWidget extends StatelessWidget {
  const ProfileEditWidget({
    Key? key, // Added Key? key parameter
    required this.tittle,
    required this.content,
    required this.onTap,
  }) : super(key: key); // Added super(key: key) to the constructor

  final String tittle;
  final String content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterSemibold(
            text: tittle,
            fontsize: 20.sp,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
          SizedBox(height: 10.h),
          InterRegular(
            text: content,
            fontsize: 16.sp,
            letterSpacing: -.05,
            color: Theme.of(context).textTheme.headlineSmall!.color as Color?,
          ),
        ],
      ),
    );
  }
}
