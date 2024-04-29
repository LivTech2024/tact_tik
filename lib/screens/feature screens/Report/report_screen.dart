import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/screens/feature%20screens/Report/create_report_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class ReportScreen extends StatefulWidget {
  final String locationId;
  final String locationName;
  final String companyId;
  final String empId;
  final String empName;
  final String clientId;
  const ReportScreen(
      {super.key,
      required this.locationId,
      required this.locationName,
      required this.companyId,
      required this.empId,
      required this.empName,
      required this.clientId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int currentIndex = 0;
  FireStoreService fireStoreService = FireStoreService();
  List<String> tittles = [];
  @override
  void initState() {
    super.initState();
    getAllTitles();
  }

  void getAllTitles() async {
    List<String> data = await fireStoreService.getReportTitles();
    if (data.isNotEmpty) {
      setState(() {
        tittles = ["All", ...data];
      });
    }
    print("Report Titles : $data");
    print("Getting all titles");
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
              size: width / width24,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Report',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        backgroundColor: Secondarycolor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateReportScreen(
                          locationId: widget.locationId,
                          companyID: widget.companyId,
                          locationName: widget.locationName,
                          empId: widget.empId,
                          empName: widget.empName,
                          ClientId: widget.clientId,
                        )));
          },
          backgroundColor: Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: Column(
            children: [
              SizedBox(height: height / height30),
              SizedBox(
                height: height / height40,
                child: ListView.builder(
                  itemCount: tittles.length,
                  // shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        margin: EdgeInsets.only(right: width / width10),
                        padding:
                            EdgeInsets.symmetric(horizontal: width / width20),
                        constraints: BoxConstraints(
                          minWidth: width / width70,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width / width20),
                          color: currentIndex == index
                              ? Primarycolor
                              : WidgetColor,
                        ),
                        duration: const Duration(microseconds: 500),
                        child: Center(
                          child: InterRegular(
                            text: tittles[index],
                            fontsize: width / width16,
                            color: color18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: height / height20),
              Expanded(
                child: ListView.builder(
                  // physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: tittles.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(height: height / height20,),
                        InterBold(
                          text: 'Today',
                          color: Primarycolor,
                          fontsize: width / width20,
                        ),
                        SizedBox(
                          height: height / height10,
                        ),
                        Column(
                          children: tittles
                              .map(
                                (title) => Container(
                                  margin: EdgeInsets.only(
                                    bottom: height / height10,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width / width20,
                                  ),
                                  height: height / height100,
                                  decoration: BoxDecoration(
                                    color: WidgetColor,
                                    borderRadius:
                                        BorderRadius.circular(width / width10),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          // left: width / width24,
                                          right: width / width20,
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/images/report_icon.svg',
                                          height: height / height24,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: width / width280,
                                              child: Text(
                                                'Clark Place - Lost & Found Item Report',
                                                style: TextStyle(
                                                  fontSize: width / width20,
                                                  color: color2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: height / height10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    InterMedium(
                                                      text: 'CATEGORY: ',
                                                      fontsize: width / width14,
                                                      color: color32,
                                                    ),
                                                    InterRegular(
                                                      text: title,
                                                      fontsize: width / width14,
                                                      color: color26,
                                                    ),
                                                  ],
                                                ),
                                                InterRegular(
                                                  text: '11.36pm',
                                                  color: color26,
                                                  fontsize: width / width14,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        SizedBox(
                          height: height / height20,
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
