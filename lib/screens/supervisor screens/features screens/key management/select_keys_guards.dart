import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import 's_key_managment_view_screen.dart';

class SelectKeysGuardsScreen extends StatefulWidget {
  final String companyId;

  const SelectKeysGuardsScreen({super.key, required this.companyId});

  @override
  State<SelectKeysGuardsScreen> createState() => _SelectGuardsScreenState();
}

class _SelectGuardsScreenState extends State<SelectKeysGuardsScreen> {
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


    return SafeArea(
      child: Scaffold(
      
        appBar: AppBar(
         
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
             
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Keys Guards',
           
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30.h),
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
                         /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SKeyManagementViewScreen(
                                     companyId: '',
                                  )));*/
                        },
                        child: Container(
                          height: 60.h,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.transparent
                                    : LightColor.color3.withOpacity(.05),
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset: Offset(0, 3),
                              )
                            ],
                            color: isDark
                                      ? DarkColor.color19
                                      : LightColor.WidgetColor,
                            borderRadius:
                            BorderRadius.circular(12.r),
                          ),
                          margin:
                          EdgeInsets.only(bottom: 10.h),
                          width: double.maxFinite,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 48.h,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 50.h,
                                          width: 50.w,
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
                                                            ? DarkColor.Primarycolor
                                                            : LightColor.Primarycolor,
                                            image: DecorationImage(
                                              image:  AssetImage(
                                                  'assets/images/default.png'),
                                              filterQuality: FilterQuality.high,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20.w),
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
                                      height: 14.h,
                                      width: 24.w,
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
                      fontsize: 16.sp,
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