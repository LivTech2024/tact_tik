import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/new%20guard/personel_details.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SelectGuardsScreen extends StatefulWidget {
  final String companyId;

  const SelectGuardsScreen({super.key, required this.companyId});

  @override
  State<SelectGuardsScreen> createState() => _SelectGuardsScreenState();
}

class _SelectGuardsScreenState extends State<SelectGuardsScreen> {
  bool isAssigned = false;
  bool loading = true;
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
  Future<void> _checkShiftStatus(String empid) async {
    // String empId = guardsInfo['EmployeeId'];
    bool result =
        await fireStoreService.checkShiftsForEmployee(DateTime.now(), empid);
    print("result of status ${result}");
    setState(() {
      isAssigned = result;
      loading = false;
    });
  }

  void _getUserInfo() async {
    FireStoreService fireStoreService = FireStoreService();
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
    if (mounted) {
      if (userInfo != null) {
        String userName = userInfo['EmployeeName'] ?? "";
        String EmployeeId = userInfo['EmployeeId'] ?? "";
        String CompanyId = userInfo['EmployeeCompanyId'] ?? "";

        var guardsInfo =
            await fireStoreService.getGuardForSupervisor(EmployeeId);
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
                  // DropdownButtonHideUnderline(
                  //   child: DropdownButton<String>(
                  //     iconSize: 24.w,
                  //     dropdownColor: Theme.of(context).cardColor,
                  //     style: TextStyle(
                  //         color: Theme.of(context).textTheme.bodyLarge!.color),
                  //     borderRadius: BorderRadius.circular(10.r),
                  //     value: dropdownValue,
                  //     onChanged: (String? newValue) {
                  //       setState(() {
                  //         dropdownValue = newValue!;
                  //       });
                  //     },
                  //     items: <String>[
                  //       'All',
                  //       'available',
                  //       'unavailable'
                  //     ] // Add your options here
                  //         .map<DropdownMenuItem<String>>((String value) {
                  //       return DropdownMenuItem<String>(
                  //         value: value,
                  //         child: Text(value),
                  //       );
                  //     }).toList(),
                  //   ),
                  // ),
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
                            String role = guardInfo['EmployeeRole'] ?? "";

                            // Create a Future to check shifts
                            Future<bool> hasShiftFuture = fireStoreService
                                .checkShiftsForEmployee(DateTime.now(), id);

                            return FutureBuilder<bool>(
                              future: hasShiftFuture,
                              builder: (context, snapshot) {
                                Color statusColor;

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  statusColor = Colors
                                      .grey; // Display a loading color while checking status
                                } else if (snapshot.hasError) {
                                  statusColor = Colors
                                      .red; // Display red if there is an error
                                } else {
                                  isAssigned = snapshot.data ?? false;
                                  statusColor = isAssigned
                                      ? Colors
                                          .red // Display red if the employee is assigned to a shift
                                      : guardInfo['EmployeeIsAvailable'] ==
                                              "available"
                                          ? Colors.green
                                          : guardInfo['EmployeeIsAvailable'] ==
                                                  "on_shift"
                                              ? Colors.orange
                                              : Colors.red;
                                }

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(
                                      context,
                                      {
                                        'name': name,
                                        'id': id,
                                        'url': url,
                                        'role': role
                                      },
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).shadowColor,
                                          blurRadius: 5,
                                          spreadRadius: 2,
                                          offset: Offset(0, 3),
                                        )
                                      ],
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? DarkColor.WidgetColor
                                          : LightColor.WidgetColor,
                                      borderRadius: BorderRadius.circular(12.h),
                                    ),
                                    height: 60.h,
                                    margin: EdgeInsets.only(bottom: 10.h),
                                    width: double.maxFinite,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                    decoration: url != ""
                                                        ? BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  NetworkImage(
                                                                      url ??
                                                                          ""),
                                                              filterQuality:
                                                                  FilterQuality
                                                                      .high,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
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
                                                  SizedBox(width: 20.w),
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
                                                  color: statusColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : Center(
                          child: PoppinsBold(
                            text: 'No Guards Found',
                            color: DarkColor.color2,
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
