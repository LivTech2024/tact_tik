import 'package:flutter/material.dart';

import '../../../../common/enums/log_type_enums.dart';
import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../utils/colors.dart';

class LogTypeWidget extends StatelessWidget {
  const LogTypeWidget({super.key, required this.type});

  final LogBookEnum type;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(top: height / height10),
      padding: EdgeInsets.symmetric(horizontal: width / width20),
      height: height / height90,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width / width10),
        color: WidgetColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                type == LogBookEnum.shift
                    ? Icons.directions_walk_rounded
                    : type == LogBookEnum.end
                    ? Icons.directions_walk_rounded
                    : type == LogBookEnum.patrolCount
                    ? Icons.apartment_outlined
                    : Icons.error,
                color: Primarycolor,
                size: width / width24,
              ),
              SizedBox(width: width / width30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterMedium(
                    text: 'Patrolling',
                    fontsize: width / width14,
                    color: color2,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: height / height4),
                    child: InterMedium(
                      text: 'Clark Place interior',
                      fontsize: width / width14,
                      color: color1,
                    ),
                  ),
                  InterBold(
                    text: 'Client: Anas Kumar',
                    fontsize: width / width14,
                    color: color2,
                  ),
                ],
              ),
            ],
          ),
          InterMedium(
            text: '5:84 pm',
            color: color1,
            fontsize: width / width14,
          ),
        ],
      ),
    );
  }
}