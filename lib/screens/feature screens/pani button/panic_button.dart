import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'package:tact_tik/fonts/roboto_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/sizes.dart';

class PanicAlertDialog extends StatelessWidget {
  final Map<String, String> emergencyContacts = {
    'Ambulance': '102',
    'Police': '100',
    'Doctor': '1234567890',
    'Fire Department': '911'
  };

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: Colors.black.withOpacity(0.5),
          width: double.infinity,
          height: double.infinity,
        ),
        Container(
          margin: EdgeInsets.only(bottom: width / width30),
          padding: EdgeInsets.all(width / width16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(width / width16),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              PoppinsMedium(
                text: 'Are you in panic?',
                fontsize: width / width18,
                color: DarkColor. colorRed3,
              ),
              SizedBox(height: height / height8),
              PoppinsRegular(
                text:
                    'If yes, then your supervisor and admin will get notified!',
                textAlign: TextAlign.center,
                color: DarkColor. color16,
              ),
              SizedBox(height: height / height16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: RobotoMedium(
                      text: 'No',
                      color: DarkColor.color27,
                      fontsize: width / width18,
                    ),
                  ),
                  SizedBox(width: width / width16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSupervisorDialog(context);
                    },
                    child: RobotoMedium(
                      text: 'Yes',
                      color: DarkColor. color27,
                      fontsize: width / width18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSupervisorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double height = MediaQuery.of(context).size.height;
        final double width = MediaQuery.of(context).size.width;

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              margin: EdgeInsets.only(bottom: height / height30),
              padding: EdgeInsets.all(width / width16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(width / width16),
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
                    text: 'Supervisors & Admin Informed',
                    fontsize: width / width16,
                  ),
                  SizedBox(height: height / height16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: width / width24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              showModalBottomSheet(
                                backgroundColor: isDark?DarkColor.WidgetColor:LightColor.WidgetColor,
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
                                            size: width / width20,
                                          ),
                                          title: InterMedium(
                                            text: contactName,
                                            fontsize: width / width12,
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
                              fontsize: width / width18,
                              color: DarkColor. colorRed3,
                            ),
                          ),
                          SizedBox(width: width / width10),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: RobotoMedium(
                              text: 'OK',
                              fontsize: width / width18,
                              color: isDark ? DarkColor.color27 : LightColor.color3,
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
