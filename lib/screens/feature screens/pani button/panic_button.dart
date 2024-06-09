import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'package:tact_tik/fonts/roboto_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/sizes.dart';

class PanicAlertDialog extends StatefulWidget {
  final String EmpId;
  final String CompanyId;
  final String Username;

  const PanicAlertDialog(
      {super.key,
      required this.EmpId,
      required this.CompanyId,
      required this.Username});

  @override
  State<PanicAlertDialog> createState() => _PanicAlertDialogState();
}

class _PanicAlertDialogState extends State<PanicAlertDialog> {
  final Map<String, String> emergencyContacts = {
    'Ambulance': '102',
    'Police': '100',
    'Doctor': '1234567890',
    'Fire Department': '911'
  };

  @override
  Widget build(BuildContext context) {
    bool _isLoading = false;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: Colors.black.withOpacity(0.5),
          width: double.infinity,
          height: double.infinity,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 30.w),
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          width: 344.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PoppinsMedium(
                text: 'Are you in panic?',
                fontsize: 18.sp,
                color: DarkColor.colorRed3,
              ),
              SizedBox(height: 8.h),
              PoppinsRegular(
                text:
                'If yes, then your supervisor and admin will get notified!',
                textAlign: TextAlign.center,
                color: isDark ? DarkColor.color1 : LightColor.color4,
                fontsize: 18.sp,
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: RobotoMedium(
                      text: 'No',
                      color: isDark ? DarkColor.color3 : LightColor.color4,
                      fontsize: 18.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  TextButton(
                    onPressed: () async {
                      //fetch supervisor admins
                      List<String> receiversId = [];
                      String? adminId =
                      await fireStoreService.getAdminID(widget.CompanyId);
                      List<String>? supervisorID =
                      await fireStoreService.getSupervisorIDs(widget.EmpId);

                      if (adminId != null) {
                        receiversId.add(adminId);
                      }

                      if (supervisorID != null) {
                        receiversId.addAll(supervisorID);
                      }
                      print(" CompanyId ${widget.CompanyId}");
                      print(adminId);

                      print(supervisorID);
                      print(receiversId);

                      String Data =
                          "Panic Button pressed by ${widget.Username}";
                      setState(() {
                        _isLoading = true;
                      });
                      await fireStoreService.SendMessage(widget.CompanyId,
                          widget.Username, Data, receiversId, widget.EmpId);
                      setState(() {
                        _isLoading = false;
                      });
                      _showSupervisorDialog(context);
                      // Navigator.pop(context);
                    },
                    child: RobotoMedium(
                      text: 'Yes',
                      color: isDark ? DarkColor.color1 : LightColor.color3,
                      fontsize: 18.sp,
                    ),
                  ),
                ],
              ),
            ],
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
    );
  }

  void _showSupervisorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 30.h),
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  PoppinsMedium(
                    color: isDark ? DarkColor.color1 : LightColor.color3,
                    text: 'Supervisors & Admin Informed',
                    fontsize: 16.sp,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24.sp,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              showModalBottomSheet(
                                backgroundColor: Theme.of(context).cardColor,
                                context: context,
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: emergencyContacts.length,
                                      itemBuilder: (context, index) {
                                        final contactName = emergencyContacts
                                            .keys
                                            .toList()[index];
                                        final phoneNumber =
                                        emergencyContacts[contactName];
                                        return ListTile(
                                          leading: Icon(
                                            Icons.call,
                                            color: isDark
                                                ? DarkColor.Primarycolor
                                                : LightColor.Primarycolor,
                                            size: 20.sp,
                                          ),
                                          title: InterMedium(
                                            text: contactName,
                                            fontsize: 12.sp,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                          ),
                                          onTap: () async {
                                            final url = 'tel://$phoneNumber';
                                            if (await canLaunchUrl(
                                                Uri.parse(url))) {
                                              await launchUrl(Uri.parse(url));
                                            } else {
                                              print('Cannot launch $url');
                                            }
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: RobotoMedium(
                              text: 'Call',
                              fontsize: 18.sp,
                              color: DarkColor.colorRed3,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            },
                            child: RobotoMedium(
                              text: 'OK',
                              fontsize: 18.sp,
                              color:
                              isDark ? DarkColor.color1 : LightColor.color3,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

}
