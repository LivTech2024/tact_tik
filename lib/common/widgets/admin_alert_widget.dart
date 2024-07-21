import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/common/widgets/customToast.dart';
import 'package:tact_tik/screens/home%20screens/guard_notification_screen.dart';
import 'package:tact_tik/screens/new%20guard/personel_details.dart';

import '../../fonts/inter_regular.dart';
import '../../fonts/inter_bold.dart';
import '../../fonts/inter_medium.dart';
import '../../fonts/inter_semibold.dart';
import '../../screens/home screens/widgets/icon_text_widget.dart';
import '../enums/guard_alert_enums.dart';
import 'button1.dart';

class SupervisorAlertWidget extends StatefulWidget {
  const SupervisorAlertWidget({
    super.key,
    this.Enum,
    this.isRejected = false,
    required this.message,
    required this.type,
    required this.createdAt,
    this.shiftOfferData,
    this.shiftExchangeData,
    required this.notiId,
    required this.status,
    required this.refresh,
  });

  final String message;
  final String type;
  final String notiId;
  final String status;
  final bool isRejected;
  final DateTime createdAt;
  final GuardAlertEnum? Enum; // Use GuardAlertEnum type
  final ShiftOfferData? shiftOfferData;
  final ShiftExchangeData? shiftExchangeData;
  final VoidCallback refresh;
  @override
  State<SupervisorAlertWidget> createState() => _GuardAlertWidgetState();
}

class _GuardAlertWidgetState extends State<SupervisorAlertWidget> {
  GuardAlertEnum get _alertType => widget.type.toEnum();

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(date);
  }

  Widget _buildProfileImage() {
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

  Widget _buildAlertDetails(String prefix, String action, String message,
      {ShiftOfferData? offerData, ShiftExchangeData? exchangeData}) {
    String location = offerData?.offerShiftLocation ??
        exchangeData?.exchangeShiftLocation ??
        'Unknown Location';
    String time = offerData?.offerShiftTime ??
        exchangeData?.exchangeShiftTime ??
        'Unknown Time';
    return Container(
      constraints: BoxConstraints(minHeight: 150.h),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterSemibold(
            text:
                '${prefix}  •  ${action}  •  ${_formatDate(widget.createdAt)}',
            fontsize: Platform.isIOS ? 10.sp : 12.sp,
          ),
          SizedBox(height: Platform.isIOS ? 13.h : 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InterMedium(
                text: '$action: ',
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
              _buildProfileImage(),
              SizedBox(width: Platform.isIOS ? 8.w : 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterBold(
                    text: exchangeData?.exchangeShiftRequestedName ??
                        offerData?.offerShiftRequestedName ??
                        'Employee Name', // Replace with dynamic name if available
                    fontsize: Platform.isIOS ? 18.sp : 20.sp,
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    height: Platform.isIOS ? 20.h : 22.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (offerData != null) ...[
                          Container(
                            constraints:
                                BoxConstraints(minWidth: 80.w, maxWidth: 140.w),
                            child: IconTextWidget(
                              icon: Icons.location_on,
                              text: offerData.offerShiftLocation ??
                                  'Unknown Location',
                              space: 3.w,
                              iconSize: Platform.isIOS ? 20.w : 24.w,
                              Iconcolor: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          VerticalDivider(width: 1),
                          SizedBox(width: 10.w),
                          InterMedium(
                            text:
                                '${offerData.offerShiftTime ?? 'Unknown Time'}',
                            fontsize: Platform.isIOS ? 14.sp : 16.sp,
                          ),
                        ] else if (exchangeData != null) ...[
                          Container(
                            constraints:
                                BoxConstraints(minWidth: 80.w, maxWidth: 140.w),
                            child: IconTextWidget(
                              icon: Icons.location_on,
                              text: exchangeData.exchangeShiftLocation ??
                                  'Unknown Location',
                              space: 3.w,
                              iconSize: Platform.isIOS ? 20.w : 24.w,
                              Iconcolor: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          VerticalDivider(width: 1),
                          SizedBox(width: 10.w),
                          InterMedium(
                            text:
                                '${exchangeData.exchangeShiftTime ?? 'Unknown Time'}',
                            fontsize: Platform.isIOS ? 14.sp : 16.sp,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Visibility(
            visible: true, // TODO Add condition of visibility
            child: Column(
              children: [
                SizedBox(height: 20.h),
                widget.status == "pending"
                    ? Button1(
                        height: 41.h,
                        borderRadius: 5.r,
                        backgroundcolor: Theme.of(context).primaryColor,
                        text: 'Accept',
                        onPressed: widget.status != "pending"
                            ? () {
                                showErrorToast(context, "Already accepted");
                              }
                            : () async {
                                // var id = ShiftExchangeData
                                await fireStoreService.UpdateExchangeNotiStatus(
                                    widget.notiId, "completed");
                                if (ShiftExchangeData != null) {
                                  await fireStoreService.UpdateExchangeStatus(
                                      exchangeData!.exchangeShiftRequestedId,
                                      "completed");
                                }
                                print("Id ${widget.notiId}");
                                showSuccessToast(context, "${widget.notiId}");
                                showSuccessToast(context,
                                    "${exchangeData!.exchangeShiftRequestedId}");
                              },
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_alertType) {
      case GuardAlertEnum.newOffer:
        return _buildAlertDetails(
          'GUARD',
          'OFFER',
          widget.message,
          offerData: widget.shiftOfferData,
        );
      case GuardAlertEnum.newExchange:
        return _buildAlertDetails(
          'GUARD',
          'EXCHANGE',
          widget.message,
          exchangeData: widget.shiftExchangeData,
        );
      case GuardAlertEnum.ShiftStatusNotification:
        return Container(
          height: 100.h,
          width: double.maxFinite,
          margin: EdgeInsets.only(bottom: 10.h),
          padding:
              EdgeInsets.only(left: 24.w, top: 10.h, bottom: 10.h, right: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: widget.isRejected ? Color(0x66E74C3C) : Color(0x8C33A652),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.message,
                size: 24.sp,
                color: Colors.white,
              ),
              SizedBox(width: 20.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterSemibold(
                    text: 'SUPERVISOR  •  ${_formatDate(widget.createdAt)}',
                    fontsize: Platform.isIOS ? 10.sp : 12.sp,
                    letterSpacing: -.25,
                  ),
                  InterRegular(
                    text: 'New Message',
                    fontsize: Platform.isIOS ? 14.sp : 16.sp,
                  ),
                  InterRegular(
                    text: widget.message,
                    fontsize: 12.sp,
                  ),
                ],
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }
}

extension ConvertMessage on String {
  GuardAlertEnum toEnum() {
    switch (this) {
      case 'Notification':
        return GuardAlertEnum.ShiftStatusNotification;
      case 'SHIFTEXCHANGE':
        return GuardAlertEnum.newExchange;
      case 'SHIFTOFFER':
        return GuardAlertEnum.newOffer;
      default:
        return GuardAlertEnum.ShiftStatusNotification;
    }
  }
}
