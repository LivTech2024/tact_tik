import 'package:flutter/material.dart';

import '../../../fonts/poppins_light.dart';
import '../../../fonts/poppis_semibold.dart';
import '../../../utils/colors.dart';

class HomeScreenPart1 extends StatelessWidget {
  const HomeScreenPart1({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PoppinsSemibold(
            text: 'Good Morning,',
            color: Primarycolor,
            letterSpacing: -.5,
            fontsize: 35,
          ),
          SizedBox(height: 10),
          PoppinsLight(
            text: 'Nick Jones',
            color: Primarycolor,
            fontsize: 30,
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
