import 'package:flutter/material.dart';

import '../../../../common/enums/log_type_enums.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../utils/colors.dart';

class LogTypeWidget extends StatelessWidget {
  const LogTypeWidget({super.key, required this.type});

  final LogBookEnum type;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 90,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
                size: 24,
              ),
              SizedBox(width: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterMedium(
                    text: 'Patrolling',
                    fontsize: 14,
                    color: color2,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    child: InterMedium(
                      text: 'Clark Place interior',
                      fontsize: 14,
                      color: color1,
                    ),
                  ),
                  InterBold(
                    text: 'Client: Anas Kumar',
                    fontsize: 14,
                    color: color2,
                  ),
                ],
              ),
            ],
          ),
          InterMedium(
            text: '5:84 pm',
            color: color1,
            fontsize: 14,
          ),
        ],
      ),
    );
  }
}
