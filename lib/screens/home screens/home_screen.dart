import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tact_tik/fonts/poppis_semibold.dart';
import 'package:tact_tik/screens/home%20screens/widgets/homescreen_custom_navigation.dart';
import 'package:tact_tik/screens/home%20screens/widgets/task_screen.dart';
import 'package:tact_tik/utils/colors.dart';
import '../../fonts/poppins_light.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  // void _shoeDatePicker(BuildContext context) {
  //   showDatePicker(
  //       context: context, firstDate: DateTime(2000), lastDate: DateTime(2025));
  // }

/*  late DateTime selectedDay;
  late List <CleanCalendarEvent> selectedEvent;

  final Map<DateTime,List<CleanCalendarEvent>> events = {
    DateTime (DateTime.now().year,DateTime.now().month,DateTime.now().day):
    [
      CleanCalendarEvent('Event A',
          startTime: DateTime(
              DateTime.now().year,DateTime.now().month,DateTime.now().day,10,0),
          endTime:  DateTime(
              DateTime.now().year,DateTime.now().month,DateTime.now().day,12,0),
          description: 'A special event',
          color: Colors.blue,),
    ],

    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2):
    [
      CleanCalendarEvent('Event B',
          startTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 10, 0),
          endTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 12, 0),
          color: Colors.orange),
      CleanCalendarEvent('Event C',
          startTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 14, 30),
          endTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 17, 0),
          color: Colors.pink),
    ],
  };

  void _handleData(date){
    setState(() {
      selectedDay = date;
      selectedEvent = events[selectedDay] ?? [];
    });
    print(selectedDay);
  }*/
  @override
  void initState() {
    // selectedEvent = events[selectedDay] ?? [];
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 40.0,
            horizontal: 30.0,
          ),
          child: ListView(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HomeScreenCustomNavigation(
                    icon: Icons.add_task,
                    color: Primarycolor,
                  ),
                  HomeScreenCustomNavigation(
                    icon: Icons.grid_view_rounded,
                    color: color4,
                  ),
                  HomeScreenCustomNavigation(
                    icon: Icons.calendar_today,
                    color: color4,
                  ),
                  HomeScreenCustomNavigation(
                    icon: Icons.chat_bubble_outline,
                    color: color4,
                  ),
                ],
              ),

              SizedBox(height: 30),
              TaskScreen(),

            ],
          ),
        ),)
      ,
    );
  }
}

/*InkWell(
                onTap: () => _shoeDatePicker(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  height: 68,
                  color: WidgetColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Primarycolor,
                          )),
                      InterBold(
                        text: '14/03/2024',
                        fontsize: 19,
                        color: Primarycolor,
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Primarycolor,
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                itemCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    color: WidgetColor,
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    height: 242,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 30, left: 30),
                          height: 126,
                          width: 280,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconTextWidget(
                                icon: Icons.location_on,
                                text:
                                    '2972 Westheimer Rd. Santa Ana, Illinois 85486',
                              ),
                              IconTextWidget(
                                icon: Icons.access_time,
                                text: '12:00 am - 12:00 pm',
                              ),
                              IconTextWidget(
                                icon: Icons.qr_code_scanner,
                                text: 'Total 6    Completed 4',
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          height: 56,
                          color: Primarycolor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              PoppinsBold(
                                text: 'Go to shift',
                                color: Colors.white,
                                fontsize: 18,
                                letterSpacing: .03,
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              )*/


/*Container(
            child: Calendar(
              startOnMonday: true,
              selectedColor: Colors.blue,
              todayColor: Colors.red,
              eventColor: Colors.green,
              eventDoneColor: Colors.amber,
              bottomBarColor: Colors.deepOrange,
              onRangeSelected: (range) {
                print('selected Day ${range.from},${range.to}');
              },
              onDateSelected: (date){
                return _handleData(date);
              },
              events: events,
              isExpanded: true,
              dayOfWeekStyle: TextStyle(
                fontSize: 15,
                color: Colors.black12,
                fontWeight: FontWeight.w100,
              ),
              bottomBarTextStyle: TextStyle(
                color: Colors.white,
              ),
              hideBottomBar: false,
              hideArrows: false,
              weekDays: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
            ),
          ),*/