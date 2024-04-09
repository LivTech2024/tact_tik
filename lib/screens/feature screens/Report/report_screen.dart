import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_medium.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int currentIndex = 0;

  List<String> tittles = [
    'All',
    'General concern',
    'Incident',
    'Incident',
    'Incident',
    'Incident',
  ];

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
            text: 'Report',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        backgroundColor: Secondarycolor,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width / width30),
            child: Column(
              children: [
                SizedBox(height: height / height30),
                SizedBox(
                  height: 40,
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
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          constraints: BoxConstraints(
                            minWidth: 70,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(width / width20),
                            color: currentIndex == index
                                ? Primarycolor
                                : WidgetColor,
                          ),
                          duration: Duration(microseconds: 500),
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
                ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      height: height / height100,
                      decoration: BoxDecoration(
                        color: WidgetColor,
                        borderRadius: BorderRadius.circular(width / width10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf),
                          Column(
                            children: [
                              InterMedium(
                                text: 'Clark Place - Lost & Found Item Report',
                                fontsize: width / width20,
                                color: color2,
                              ),
                              Row(
                                children: [
                                  InterMedium(
                                    text: 'CATEGORY:',
                                    fontsize: width / width14,
                                    color: color32,
                                  ),
                                  InterRegular(
                                    text: tittles[index],
                                    fontsize: width / width14,
                                    color: color26,
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
