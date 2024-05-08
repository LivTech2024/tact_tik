import 'package:flutter/material.dart';

import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

class HomeScreenCustomNavigation extends StatelessWidget {
  const HomeScreenCustomNavigation(
      {super.key, required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      height: height / height74,
      width: width / width74,
      decoration: BoxDecoration(
        color: WidgetColor,
        borderRadius: BorderRadius.circular(width / width13),
      ),
      child: Center(
        child: Icon(
          icon,
          size: width / width24,
          color: color,
        ),
      ),
    );
  }
}
