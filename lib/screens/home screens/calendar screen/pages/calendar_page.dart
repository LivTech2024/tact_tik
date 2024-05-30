import 'dart:core';

import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/screens/home%20screens/calendar%20screen/utills/extensions.dart';

import '../../../../common/sizes.dart';
import '../res/colors.dart';
import '../utills/constants.dart';
import '../widgets/create_event_dialog.dart';
import '../widgets/date_picker_title_widget.dart';
import '../widgets/day_events_bottom_sheet.dart';
import '../widgets/day_item_widget.dart';
import '../widgets/event_widget.dart';
import '../widgets/picker_day_item_widget.dart';
import '../widgets/week_days_widget.dart';

/// Main calendar page.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  final _currentDate = DateTime.now();
  final _appbarTitleNotifier = ValueNotifier<String>('');
  final _monthNameNotifier = ValueNotifier<String>('');

  DateTime? _beginDate;
  DateTime? _endDate;

  String _rangeButtonText = 'Select date';

  late CrCalendarController _calendarController;

  @override
  void initState() {

    _setTexts(_currentDate.year, _currentDate.month);
    _createExampleEvents();


    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _appbarTitleNotifier.dispose();
    _monthNameNotifier.dispose();
    super.dispose();
  }


  /// Parse selected date to readable format.
  String _parseDateRange(DateTime begin, DateTime end) {
    if (begin.isAtSameMomentAs(end)) {
      return begin.format(kDateRangeFormat);
    } else {
      return '${begin.format(kDateRangeFormat)} - ${end.format(kDateRangeFormat)}';
    }
  }
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: false,
        title: ValueListenableBuilder(
          valueListenable: _appbarTitleNotifier,
          builder: (ctx, value, child) => Text(value),
        ),
        actions: [
          IconButton(
            tooltip: 'Go to current date',
            icon: Icon(Icons.calendar_today , size: width / width24,),
            onPressed: _showRangePicker,
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _addEvent,
      //   child: const Icon(Icons.add),
      // ),
      body: Column(
        children: [
          /// Calendar control row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  _changeCalendarPage(showNext: false);
                },
              ),
              ValueListenableBuilder(
                valueListenable: _monthNameNotifier,
                builder: (ctx, value, child) => Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, color: violet, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  _changeCalendarPage(showNext: true);
                },
              ),
            ],
          ),

          /// Calendar view.
          Expanded(
            child: CrCalendar(
              firstDayOfWeek: WeekDay.monday,
              eventsTopPadding: height / height30,
              initialDate: _currentDate,
              maxEventLines: 3,
              controller: _calendarController,
              forceSixWeek: true,
              dayItemBuilder: (builderArgument) =>
                  DayItemWidget(properties: builderArgument),
              weekDaysBuilder: (day) => WeekDaysWidget(day: day),
              eventBuilder: (drawer) => EventWidget(drawer: drawer),
              onDayClicked: _showDayEventsInModalSheet,
              minDate: DateTime.now().subtract(const Duration(days: 1000)),
              maxDate: DateTime.now().add(const Duration(days: 180)),
            ),
          ),
        ],
      ),
    );
  }

  /// Control calendar with arrow buttons.
  void _changeCalendarPage({required bool showNext}) => showNext
      ? _calendarController.swipeToNextMonth()
      : _calendarController.swipeToPreviousPage();

  void _onCalendarPageChanged(int year, int month) {
    _setTexts(year, month);
  }

  /// Set app bar text and month name over calendar.
  void _setTexts(int year, int month) {
    final date = DateTime(year, month);
    _appbarTitleNotifier.value = date.format(kAppBarDateFormat);
    _monthNameNotifier.value = date.format(kMonthFormat);
  }

  /// Show current month page.
  void _showCurrentMonth() {
    _calendarController.goToDate(_currentDate);
  }

  /// Show [CreateEventDialog] with settings for new event.
  Future<void> _addEvent() async {
    final event = await showDialog(
        context: context, builder: (context) => const CreateEventDialog());
    if (event != null) {
      _calendarController.addEvent(event);
    }
  }
  void _setRangeData(DateTime? begin, DateTime? end) {
    if (begin == null || end == null) {
      return;
    }
    setState(() {
      _beginDate = begin;
      _endDate = end;
      _rangeButtonText = _parseDateRange(begin, end);
    });
  }

  /// Show calendar in pop up dialog for selecting date range for calendar event.
  void _showRangePicker() {
    FocusScope.of(context).unfocus();
    showCrDatePicker(
      context,
      properties: DatePickerProperties(
        onDateRangeSelected: _setRangeData,
        dayItemBuilder: (properties) =>
            PickerDayItemWidget(properties: properties),
        weekDaysBuilder: (day) => WeekDaysWidget(day: day),
        initialPickerDate: _beginDate ?? DateTime.now(),
        pickerTitleBuilder: (date) => DatePickerTitle(date: date),
        yearPickerItemBuilder: (year, isPicked) => Container(
          height: 24,
          width: 54,
          decoration: BoxDecoration(
            color: isPicked ? violet : Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Center(
            child: Text(year.toString(),
                style: TextStyle(
                    color: isPicked ? Colors.white : violet, fontSize: 16)),
          ),
        ),
        controlBarTitleBuilder: (date) => Text(
          DateFormat(kAppBarDateFormat).format(date),
          style: const TextStyle(
            fontSize: 16,
            color: violet,
            fontWeight: FontWeight.normal,
          ),
        ),
        okButtonBuilder: (onPress) => ElevatedButton(
          onPressed: () => onPress?.call(),
          child: const Text('OK'),
        ),
        cancelButtonBuilder: (onPress) => OutlinedButton(
          onPressed: () => onPress?.call(),
          child: const Text('CANCEL'),
        ),
      ),
    );
  }

  void _createExampleEvents() {
    final now = _currentDate;
    _calendarController = CrCalendarController(
      onSwipe: _onCalendarPageChanged,
      events: [
        CalendarEventModel(
          name: '1 event',
          begin: DateTime(now.year, now.month, (now.day).clamp(1, 28)),
          end: DateTime(now.year, now.month, (now.day).clamp(1, 28)),
          eventColor: eventColors[0],
        ),
        CalendarEventModel(
          name: '2 event',
          begin: DateTime(now.year, now.month - 1, (now.day - 2).clamp(1, 28)),
          end: DateTime(now.year, now.month, (now.day + 2).clamp(1, 28)),
          eventColor: eventColors[1],
        ),
        CalendarEventModel(
          name: '3 event',
          begin: DateTime(now.year, now.month, (now.day - 3).clamp(1, 28)),
          end: DateTime(now.year, now.month + 1, (now.day + 4).clamp(1, 28)),
          eventColor: eventColors[2],
        ),
        CalendarEventModel(
          name: '4 event',
          begin: DateTime(now.year, now.month - 1, (now.day).clamp(1, 28)),
          end: DateTime(now.year, now.month + 1, (now.day + 5).clamp(1, 28)),
          eventColor: eventColors[3],
        ),
        CalendarEventModel(
          name: '5 event',
          begin: DateTime(now.year, now.month + 1, (now.day + 1).clamp(1, 28)),
          end: DateTime(now.year, now.month + 2, (now.day + 7).clamp(1, 28)),
          eventColor: eventColors[4],
        ),
        CalendarEventModel(
          name: '6 event',
          begin: DateTime(now.year, now.month - 1, (now.day -2 ).clamp(1, 28)),
          end: DateTime(now.year, now.month + 2, (now.day + 7).clamp(1, 28)),
          eventColor: eventColors[2],
        ),
      ],
    );
  }

  void _showDayEventsInModalSheet(
      List<CalendarEventModel> events, DateTime day) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        isScrollControlled: true,
        context: context,
        builder: (context) => DayEventsBottomSheet(
              events: events,
              day: day,
              screenHeight: MediaQuery.of(context).size.height,
            ));
  }
}
