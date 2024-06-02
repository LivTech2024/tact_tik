import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_regular.dart';

/// Custom event widget with rounded borders
class EventWidget extends StatelessWidget {
  const EventWidget({
    required this.drawer,
    super.key,
  });

  final EventProperties drawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: drawer.backgroundColor,
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        alignment: Alignment.centerLeft,
        child: InterRegular(
          text: drawer.name,
          color: Colors.white,
        ),
      ),
    );
  }
}
