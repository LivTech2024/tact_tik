import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/screens/home%20screens/guard_notification_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../screens/home screens/widgets/icon_text_widget.dart';
import '../../../common/widgets/customToast.dart';

class ShiftOfferWidget extends StatelessWidget {
  final String notiId;
  final String message;
  final DateTime createdAt;
  final ShiftOfferData? offerData;
  final VoidCallback onRefresh;
  final String currentEmpid;

  const ShiftOfferWidget({
    Key? key,
    required this.notiId,
    required this.message,
    required this.createdAt,
    required this.offerData,
    required this.onRefresh,
    required this.currentEmpid,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(date);
  }

  Widget _buildProfileImage(BuildContext context) {
    return Container(
      height: Platform.isIOS ? 41.h : 44.h,
      width: Platform.isIOS ? 41.w : 44.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor,
        image: DecorationImage(
          image: AssetImage('assets/images/default.png'),
          filterQuality: FilterQuality.high,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 100.h),
      margin: EdgeInsets.only(bottom: 10.h),
      padding:
          EdgeInsets.only(left: 24.w, top: 10.h, bottom: 10.h, right: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: InterSemibold(
          text: 'GUARD  •  OFFER  •  ${_formatDate(createdAt)}',
          fontsize: Platform.isIOS ? 10.sp : 12.sp,
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterMedium(
                    text: 'OFFER: ',
                    fontsize: Platform.isIOS ? 14.sp : 16.sp,
                  ),
                  Flexible(
                    child: InterMedium(
                      text: message,
                      fontsize: Platform.isIOS ? 14.sp : 16.sp,
                      maxLines: 2,
                      letterSpacing: -.3,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Platform.isIOS ? 26.sp : 20.sp),
              Row(
                children: [
                  _buildProfileImage(context),
                  SizedBox(width: Platform.isIOS ? 8.w : 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InterBold(
                        text: offerData?.offerShiftRequestedName ??
                            'Employee Name',
                        fontsize: Platform.isIOS ? 18.sp : 20.sp,
                      ),
                      SizedBox(height: 5.h),
                      SizedBox(
                        height: Platform.isIOS ? 20.h : 22.h,
                        child: Row(
                          children: [
                            IconTextWidget(
                              icon: Icons.location_on,
                              text: offerData?.offerShiftLocation ??
                                  'Unknown Location',
                              space: 3.w,
                              iconSize: Platform.isIOS ? 20.w : 24.w,
                              Iconcolor: Colors.white,
                            ),
                            SizedBox(width: 10.w),
                            VerticalDivider(width: 1),
                            SizedBox(width: 10.w),
                            InterMedium(
                              text:
                                  '${offerData?.offerShiftTime ?? 'Unknown Time'}',
                              fontsize: Platform.isIOS ? 14.sp : 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Button1(
                height: 41.h,
                borderRadius: 5.r,
                backgroundcolor: Theme.of(context).primaryColor,
                text: 'Accept',
                onPressed: () async {
                  final fireStoreService = FireStoreService();

                  bool status = await fireStoreService.checkOfferAcceptedId(
                    offerData!.offerShiftId,
                  );
                  if (status) {
                    await fireStoreService.checkAndUpdateOfferStatus(
                      offerData!.offerShiftId,
                      currentEmpid,
                    );
                    showSuccessToast(context, "Shift Offer applied");
                  } else {
                    showSuccessToast(
                        context, "Shift Offer has already been accepted");
                  }
                  onRefresh();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
