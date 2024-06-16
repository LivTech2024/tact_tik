import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SelectClientGuardsScreen extends StatefulWidget {
  final String companyId;
  final Function(String) onGuardSelected;

  const SelectClientGuardsScreen({super.key, required this.companyId, required this.onGuardSelected});

  @override
  State<SelectClientGuardsScreen> createState() => _SelectGuardsScreenState();
}

class _SelectGuardsScreenState extends State<SelectClientGuardsScreen> {
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

  String dropdownValue = 'All'; // Initialize default value

  @override
  Widget build(BuildContext context) {
    final bool isDark =
    Theme.of(context).brightness == Brightness.dark ? true : false;

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
            text: 'Guards',
            
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
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      iconSize: 24.w,
                      dropdownColor:  Theme.of(context).cardColor,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
                      
                      borderRadius: BorderRadius.circular(10.r),
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: <String>[
                        'All',
                        'available',
                        'unavailable'
                      ] // Add your options here
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _guardsInfo.length != 0
                      ? ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _guardsInfo.length,
                          itemBuilder: (context, index) {
                            var guardInfo = _guardsInfo[index];
                            String name = guardInfo['EmployeeName'] ?? "";
                            String id = guardInfo['EmployeeId'] ?? "";
                            String url = guardInfo['EmployeeImg'] ?? "";
                            print(guardInfo);
                            return GestureDetector(
                                onTap: () {
                                  widget.onGuardSelected(id);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  // height: 60,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? DarkColor.color19
                                        : LightColor.WidgetColor,
                                    borderRadius: BorderRadius.circular(12.h),
                                  ),
                                  // margin: EdgeInsets.only(bottom: 10),
                                  height: 60.h,
                                  // decoration: BoxDecoration(
                                  //   color: color19,
                                  //   borderRadius:
                                  //       BorderRadius.circular(width / width12),
                                  // ),
                                  margin: EdgeInsets.only(
                                      bottom: 10.h),
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        // height: 48,
                                        // padding:
                                        //     EdgeInsets.symmetric(horizontal: 20),
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
                                                  decoration: url != ""
                                                      ? BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                url ?? ""),
                                                            filterQuality:
                                                                FilterQuality
                                                                    .high,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: isDark
                                                              ? DarkColor
                                                                  .Primarycolor
                                                              : LightColor
                                                                  .Primarycolor,
                                                          image:
                                                              DecorationImage(
                                                            image: AssetImage(
                                                                'assets/images/default.png'),
                                                            filterQuality:
                                                                FilterQuality
                                                                    .high,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                ),
                                                SizedBox(
                                                    width: 20.w),
                                                InterBold(
                                                  text: name,
                                                  letterSpacing: -.3,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color,
                                                  fontsize: 12.sp,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 16.h,
                                              width: 16.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: guardInfo[
                                                            'EmployeeIsAvailable'] ==
                                                        "available"
                                                    ? Colors.green
                                                    : guardInfo['EmployeeIsAvailable'] ==
                                                            "on_shift" //need to update this logic
                                                        ? Colors.orange
                                                        : Colors.red,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                          },
                        )
                      : Center(
                          child: PoppinsBold(
                            text: 'No Guards Found',
                            color: Theme.of(context).textTheme.bodyLarge!.color,
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
