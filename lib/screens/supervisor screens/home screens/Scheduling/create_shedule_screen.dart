import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/Scheduling/select_guards_screen.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import '../widgets/set_details_widget.dart';

class CreateSheduleScreen extends StatefulWidget {
  final String GuardId;
  final String GuardName;
  final String GuardImg;
  final String CompanyId;

  CreateSheduleScreen(
      {super.key,
      required this.GuardId,
      required this.GuardName,
      required this.GuardImg,
      required this.CompanyId});

  @override
  State<CreateSheduleScreen> createState() => _CreateSheduleScreenState();
}

class _CreateSheduleScreenState extends State<CreateSheduleScreen> {
  List colors = [Primarycolor, color25];
  List selectedGuards = [];
  String compId = "";
  @override
  void initState() {
    super.initState();
    // Add the initial guard data to selectedGuards if not already present
    if (!selectedGuards.any((guard) => guard['GuardId'] == widget.GuardId)) {
      setState(() {
        selectedGuards.add({
          'GuardId': widget.GuardId,
          'GuardName': widget.GuardName,
          'GuardImg': widget.GuardImg
        });
        compId = widget.CompanyId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Create Schedule',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        backgroundColor: Secondarycolor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 65,
                width: double.maxFinite,
                color: color24,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Shift',
                              color: colors[0],
                              fontsize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Primarycolor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Patrol',
                              color: colors[1],
                              fontsize: 18,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InterBold(
                          text: 'Select Guards',
                          fontsize: 16,
                          color: color1,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectGuardsScreen(
                                          companyId: widget.CompanyId,
                                        ))).then((value) => {
                                  if (value != null)
                                    {
                                      print("Value: ${value}"),
                                      setState(() {
                                        selectedGuards.add({
                                          'GuardId': value['id'],
                                          'GuardName': value['name'],
                                          'GuardImg': value['url']
                                        });
                                      }),
                                    }
                                });
                          },
                          child: InterBold(
                            text: 'view all',
                            fontsize: 14,
                            color: color1,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 24),
                    Container(
                      height: height / height64,
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width10),
                      decoration: BoxDecoration(
                        color: WidgetColor,
                        borderRadius: BorderRadius.circular(width / width13),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300,
                                fontSize: width / width18,
                                color:
                                    Colors.white, // Change text color to white
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(width / width10),
                                  ),
                                ),
                                focusedBorder: InputBorder.none,
                                hintStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300,
                                  fontSize: width / width18,
                                  color: color2, // Change text color to white
                                ),
                                hintText: 'Search Guard',
                                contentPadding:
                                    EdgeInsets.zero, // Remove padding
                              ),
                              cursorColor: Primarycolor,
                            ),
                          ),
                          Container(
                            height: height / height44,
                            width: width / width44,
                            decoration: BoxDecoration(
                              color: Primarycolor,
                              borderRadius:
                                  BorderRadius.circular(width / width10),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.search,
                                size: width / width20,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      // Guards
                      margin: EdgeInsets.only(top: 20),
                      height: 80,
                      width: double.maxFinite,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedGuards.length,
                        itemBuilder: (context, index) {
                          String guardId = selectedGuards[index]['GuardId'];
                          String guardName = selectedGuards[index]['GuardName'];
                          String guardImg = selectedGuards[index]['GuardImg'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(guardImg),
                                            fit: BoxFit.fitWidth),
                                      ),
                                    ),
                                    Positioned(
                                      top: -1,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedGuards.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color1),
                                          child: Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 8,
                                              color: Secondarycolor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 8),
                                InterBold(
                                  text: guardName,
                                  fontsize: 14,
                                  color: color26,
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    InterBold(
                      text: 'Set Details',
                      fontsize: 16,
                      color: color1,
                    ),
                    SizedBox(height: 10),
                    SetDetailsWidget(
                      hintText: 'Clint Name',
                      icon: Icons.account_circle_outlined,
                    ),
                    SetDetailsWidget(
                      hintText: 'Location',
                      icon: Icons.location_on,
                    ),
                    SetDetailsWidget(
                      hintText: 'Date',
                      icon: Icons.date_range,
                      featureIndex: 1,
                    ),
                    SetDetailsWidget(
                      hintText: 'Time',
                      icon: Icons.access_time_rounded,
                      featureIndex: 2,
                    ),
                    SizedBox(height: 50),
                    Button1(
                      text: 'Done',
                      onPressed: () {},
                      backgroundcolor: Primarycolor,
                      color: color22,
                      borderRadius: 10,
                      fontsize: 18,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
