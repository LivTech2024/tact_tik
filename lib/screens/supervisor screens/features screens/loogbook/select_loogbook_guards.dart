import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import 's_loogbook_screen.dart';

class SelectLoogBookGuardsScreen extends StatefulWidget {
  final String companyId;

  const SelectLoogBookGuardsScreen({super.key, required this.companyId});

  @override
  State<SelectLoogBookGuardsScreen> createState() => _SelectGuardsScreenState();
}

class _SelectGuardsScreenState extends State<SelectLoogBookGuardsScreen> {
  @override
  void initState() {
    // selectedEvent = events[selectedDay] ?? [];
    _getUserInfo();
    // checkLocation();
    super.initState();
  }

  Future<void> _refreshdata() async {
    // Fetch patrol data from Firestore (assuming your logic exists)

    _getUserInfo();
  }

  List<DocumentSnapshot<Object?>> _guardsInfo = [];

  void _getUserInfo() async {
    FireStoreService fireStoreService = FireStoreService();
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
    if (mounted) {
      if (userInfo != null) {
        String userName = userInfo['EmployeeName'] ?? "";
        String EmployeeId = userInfo['EmployeeId'] ?? "";
        String CompanyId = userInfo['EmployeeCompanyId'] ?? "";
        var guardsInfo =
            await fireStoreService.getGuardForSupervisor(widget.companyId);
        var patrolInfo = await fireStoreService
            .getPatrolsByEmployeeIdFromUserInfo(EmployeeId);
        for (var doc in guardsInfo) {
          print("All Guards : ${doc.data()}");
        }
        // setState(() {
        //   _userName = userName;
        //   _employeeId = EmployeeId;
        //   _CompanyId = CompanyId;
        // });
        if (guardsInfo != null) {
          setState(() {
            _guardsInfo = guardsInfo;
          });
        } else {
          print('GUards Info: ${guardsInfo}');
        }
        print('User Info: ${userInfo.data()}');
      } else {
        print('User info not found');
      }
    }
  }

  String dropdownValue = 'All Guards'; // Initialize default value

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
            text: 'LogBook Guards',
           
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshdata,
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SLogBookScreen(
                                              empId: id,
                                              empName: name,
                                            )));
                              },
                              child: Container(
                                height: 60.h,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                  color: Theme.of(context).cardColor,
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
                                                  color:  Theme.of(context)
                                                            .primaryColor,
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
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
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
                            color:  Theme.of(context).textTheme.bodyMedium!.color,
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
