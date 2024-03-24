import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/fonts/poppis_semibold.dart';
import 'package:tact_tik/screens/home%20screens/widgets/home_screen_part1.dart';
import 'package:tact_tik/screens/home%20screens/widgets/homescreen_custom_navigation.dart';
import 'package:tact_tik/screens/home%20screens/widgets/task_screen.dart';
import 'package:tact_tik/utils/colors.dart';
import '../../fonts/poppins_light.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../fonts/roboto_medium.dart';
import '../../utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int ScreenIndex = 0;
  late GoogleMapController mapController;

  final LatLng _center =
      const LatLng(37.7749, -122.4194); // San Francisco coordinates
  final double _zoom = 12.0;

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

  void ChangeScreenIndex(int index) {
    setState(() {
      ScreenIndex = index;
      print(ScreenIndex);
    });
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
          child: CustomScrollView(
            slivers: [
              HomeScreenPart1(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => ChangeScreenIndex(0),
                          child: HomeScreenCustomNavigation(
                            icon: Icons.add_task,
                            color: Primarycolor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ChangeScreenIndex(1),
                          child: HomeScreenCustomNavigation(
                            icon: Icons.grid_view_rounded,
                            color: color4,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ChangeScreenIndex(2),
                          child: HomeScreenCustomNavigation(
                            icon: Icons.calendar_today,
                            color: color4,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ChangeScreenIndex(3),
                          child: HomeScreenCustomNavigation(
                            icon: Icons.chat_bubble_outline,
                            color: color4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30)
                  ],
                ),
              ),
              // ,
              ScreenIndex == 0
                  ? SliverToBoxAdapter(
                      child: TaskScreen(),
                    )
                  : ScreenIndex == 2
                      ? SliverToBoxAdapter(
                          child: Container(
                            height: 470,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.redAccent),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    height: 470,
                                    width: double.maxFinite,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black,
                                          Colors.transparent
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                /*Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: _center,
                                        zoom: _zoom,
                                      ),
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        mapController = controller;
                                      },
                                    ),
                                  ),
                                ),*/
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    height: 45,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 25),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 45,
                                          width: 48,
                                          child: Image.asset(
                                            'assets/images/site_tours.png',
                                            fit: BoxFit.fitHeight,
                                            filterQuality: FilterQuality.high,
                                          ),
                                        ),
                                        InterBold(
                                          text: 'Site Tours',
                                          fontsize: 18,
                                          color: Colors.white,
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.cancel_outlined,
                                            size: 30,
                                          ),
                                          padding: EdgeInsets.zero,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 24),
                                    width: 322,
                                    height: 165,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15.0,
                                      horizontal: 15.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Secondarycolor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 55,
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: color9,
                                                ),
                                                height: 55,
                                                width: 55,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 45,
                                                  width: 45,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      6,
                                                    ),
                                                    color: color9,
                                                    border: Border.all(
                                                        color: Primarycolor,
                                                        width: 1),
                                                  ),
                                                  child: MyNetworkImage(
                                                      'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg'),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  PoppinsBold(
                                                    text: 'Robert D. Vaughn',
                                                    color: Colors.white,
                                                    fontsize: 16,
                                                  ),
                                                  RobotoMedium(
                                                    text:
                                                        '318 Grand St,  New York 10002, US',
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}

/*padding: EdgeInsets.symmetric(
            vertical: 40.0,
            horizontal: 30.0,
          ),*/

/*Row(
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
              ),*/

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
