import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/assets/s_assets_view_screen.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SelectAssetsGuardsScreen extends StatefulWidget {
  final String companyId;

  const SelectAssetsGuardsScreen({super.key, required this.companyId});

  @override
  State<SelectAssetsGuardsScreen> createState() => _SelectGuardsScreenState();
}

class _SelectGuardsScreenState extends State<SelectAssetsGuardsScreen> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _guardsInfo = [];

  @override
  void initState() {
    super.initState();
    _getEmployeesByCompanyId();
  }

  Future<void> _refreshData() async {
    setState(() {
      _guardsInfo = [];
    });
    await _getEmployeesByCompanyId();
  }

  Future<void> _getEmployeesByCompanyId() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Employees')
        .where('EmployeeCompanyId', isEqualTo: widget.companyId)
        .where('EmployeeRole', isEqualTo: "GUARD")
        .get();

    setState(() {
      _guardsInfo = querySnapshot.docs;
    });
  }

  String dropdownValue = 'All Guards';

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        appBar: AppBar(
          shadowColor: isDark ? Colors.transparent : LightColor.color3.withOpacity(.1),
          backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
          elevation: 5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? DarkColor.color1 : LightColor.color3,
              size: width / width24,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Assets Guards',
            fontsize: width / width18,
            color: isDark ? DarkColor.color1 : LightColor.color3,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width / width30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height / height30),
                  _guardsInfo.length != 0
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: PageScrollPhysics(),
                    itemCount: _guardsInfo.length,
                    itemBuilder: (context, index) {
                      var guardInfo = _guardsInfo[index];
                      String name = guardInfo['EmployeeName'] ?? "";
                      String id = guardInfo['EmployeeId'] ?? "";
                      String url = guardInfo['EmployeeImg'] ?? "";

                      print(guardInfo);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SAssetsViewScreen(
                                    companyId: widget.companyId,
                                     empId: id,
                                  )));
                        },
                        child: Container(
                          height: height / height60,
                          decoration: BoxDecoration(
                            color: isDark
                                      ? DarkColor.color19
                                      : LightColor.WidgetColor,
                            borderRadius:
                            BorderRadius.circular(width / width12),
                          ),
                          margin:
                          EdgeInsets.only(bottom: height / height10),
                          width: double.maxFinite,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: height / height48,
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / width20),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: height / height50,
                                          width: width / width50,
                                          decoration: guardInfo['EmployeeImg'] != null
                                              ? BoxDecoration(
                                            shape: BoxShape.circle,
                                            // color: Primarycolor,
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  url) ,
                                              filterQuality: FilterQuality.high,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                              : BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isDark
                                                            ? DarkColor
                                                                .Primarycolor
                                                            : LightColor
                                                                .Primarycolor,
                                            image: DecorationImage(
                                              image:  AssetImage(
                                                  'assets/images/default.png'),
                                              filterQuality: FilterQuality.high,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: width / width20),
                                        InterBold(
                                          text: name,
                                          letterSpacing: -.3,
                                          color: isDark
                                                    ? DarkColor.color1
                                                    : LightColor.color3,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: height / height14,
                                      width: width / width24,
                                      child: SvgPicture.asset(
                                        'assets/images/arrow.svg',
                                        fit: BoxFit.fitWidth,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                      : Center(
                    child: PoppinsBold(
                      text: 'No Guards Found',
                      color: isDark ? DarkColor.color2 : LightColor.color3,
                      fontsize: width / width16,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}