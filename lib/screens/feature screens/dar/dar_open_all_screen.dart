import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/screens/feature%20screens/dar/create_dar_screen.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../utils/colors.dart';

class DarOpenAllScreen extends StatefulWidget {
  const DarOpenAllScreen({super.key});

  @override
  State<DarOpenAllScreen> createState() => _DarOpenAllScreenState();
}

class _DarOpenAllScreenState extends State<DarOpenAllScreen> {
  List colors = [Primarycolor, color25];
  bool showDARS = true;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: height / height65,
                width: double.maxFinite,
                color: color24,
                padding: EdgeInsets.symmetric(vertical: height / height16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showDARS = true;
                            colors[0] = Primarycolor;
                            colors[1] = color25;
                          });
                        },
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Edit',
                              color: colors[0],
                              fontsize: width / width18,
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
                        onTap: () {
                          setState(() {
                            showDARS = false;
                            colors[0] = color25;
                            colors[1] = Primarycolor;
                          });
                        },
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Reports',
                              color: colors[1],
                              fontsize: width / width18,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: height / height20),
              showDARS
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width30),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              InterRegular(
                                text: 'Client :',
                                fontsize: width / width20,
                                color: color17,
                              ),
                              SizedBox(
                                width: width / width6,
                              ),
                              Flexible(
                                child: InterRegular(
                                  text: 'Clark Place - Unknown person',
                                  color: Primarycolor,
                                  fontsize: width / width20,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / height10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterRegular(
                                text: 'Location :',
                                fontsize: width / width20,
                                color: color17,
                              ),
                              SizedBox(
                                width: width / width6,
                              ),
                              Flexible(
                                child: InterRegular(
                                  text:
                                      'Clark Place - Lost & Found Item Report',
                                  color: Primarycolor,
                                  fontsize: width / width20,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / height20),
                          Column(
                            children: List.generate(
                              10,
                              (index) => Container(
                                margin:
                                    EdgeInsets.only(bottom: height / height10),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  color: WidgetColor,
                                  borderRadius:
                                      BorderRadius.circular(width / width10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: height / height20,
                                    horizontal: width / width20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InterMedium(
                                      text: '10.30 pm - 11.30pm ',
                                      color: color21,
                                    ),
                                    SizedBox(height: height / height10),
                                    InterRegular(
                                      text:
                                          'Lorem Ipsum is simply dummy text of the printing and typesetting industry....',
                                      fontsize: width / width16,
                                      color: color26,
                                      maxLines: 5,
                                    ),
                                    SizedBox(height: height / height20),
                                    Row(
                                      children: List.generate(
                                        4,
                                        (index) => GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateDarScreen(
                                                  EmpEmail: "",
                                                  EmpId: '',
                                                  EmpDarCompanyId: "",
                                                  EmpDarCompanyBranchId: '',
                                                  EmpShiftId: '',
                                                  EmpClientID: '',
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                right: height / height10),
                                            height: height / height50,
                                            width: width / width50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      width / width10),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  'https://img.freepik.com/free-photo/painting-mountain-lake-with-mountain-background_188544-9126.jpg',
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InterBold(
                            text: 'Reports',
                            fontsize: width / width20,
                            color: Primarycolor,
                          ),
                          SizedBox(height: height / height10),
                          Column(
                            children: List.generate(
                              20,
                              (index) => Container(
                                margin: EdgeInsets.only(
                                  bottom: height / height10,
                                ),
                                height: height / height35,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: height / height35,
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                        color: WidgetColor,
                                        borderRadius: BorderRadius.circular(
                                            width / width10),
                                      ),
                                    ),
                                    Container(
                                      height: height / height35,
                                      width: width / width16,
                                      decoration: BoxDecoration(
                                        color: colorRed3,
                                        borderRadius: BorderRadius.circular(
                                            width / width10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
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
