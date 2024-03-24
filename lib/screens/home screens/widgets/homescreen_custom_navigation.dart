import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class HomeScreenCustomNavigation extends StatelessWidget {
  const HomeScreenCustomNavigation({super.key, required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      width: 74,
      decoration: BoxDecoration(
        color: WidgetColor,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 24,
          color: color,
        ),
      ),
    );
  }
}
