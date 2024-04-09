import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
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
        String userName = userInfo['EmployeeName'];
        String EmployeeId = userInfo['EmployeeId'];
        String CompanyId = userInfo['EmployeeCompanyId'];
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
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
            text: 'Guards',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshdata,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width / width30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height / height30),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    iconSize: width / width24,
                    dropdownColor: WidgetColor,
                    style: TextStyle(color: color2),
                    borderRadius: BorderRadius.circular(10),
                    value: dropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>['All', 'available', 'unavailable'] // Add your options here
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                        .toList(),
                  ),
                ),
                SizedBox(height: height / height20),
                _guardsInfo.length != 0 ? ListView.builder(
                  shrinkWrap: true,
                  physics: PageScrollPhysics(),
                  itemCount: _guardsInfo.length,
                  itemBuilder: (context, index) {
                    var guardInfo = _guardsInfo[index];
                    String name = guardInfo['EmployeeName'];
                    String id = guardInfo['EmployeeId'];
                    String url = guardInfo['EmployeeImg'];

                    print(guardInfo);
                    return GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                            {
                              'name': name,
                              'id': id,
                              'url': url,
                            },
                          );
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: color19,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.only(bottom: 10),
                          width: double.maxFinite,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 48,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: NetworkImage(url),
                                              filterQuality: FilterQuality.high,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        InterBold(
                                          text: name,
                                          letterSpacing: -.3,
                                          color: color1,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 16,
                                      width: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: guardInfo['EmployeeIsAvailable'] ==
                                            "available"
                                            ? Colors.green
                                            : guardInfo['EmployeeIsAvailable'] ==
                                            "on_shift"
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
                ) : Center(
                  child: PoppinsBold(text: 'No Guards Found',color: color2,fontsize: width / width16,),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
