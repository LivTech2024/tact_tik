import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_regular.dart';

/// Widget of day item cell for calendar
class DayItemWidget extends StatelessWidget {
  const DayItemWidget({
    required this.properties,
    super.key,
  });

  final DayItemProperties properties;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .color
                  ?.withOpacity(0.3) as Color,
              width: 0.3)),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 4),
            alignment: Alignment.topCenter,
            child: Container(
              height: 18,
              width: 18,
              decoration: BoxDecoration(
                color: properties.isCurrentDay
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: InterRegular(
                  text: '${properties.dayNumber}',
                  color: properties.isCurrentDay
                      ? Colors.white
                      : (properties.isInMonth
                          ? Theme.of(context).textTheme.bodyMedium!.color
                          : Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color
                              ?.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          if (properties.notFittedEventsCount > 0)
            Container(
              padding: EdgeInsets.only(right: 2, top: 2),
              alignment: Alignment.topRight,
              child: InterRegular(
                text: '+${properties.notFittedEventsCount}',
                fontsize: 10,
                color: properties.isInMonth
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor?.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }
}
