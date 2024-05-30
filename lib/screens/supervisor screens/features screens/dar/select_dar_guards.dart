import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/dar/s_dar_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SelectDARGuardsScreen extends StatefulWidget {
  final String companyId;

  const SelectDARGuardsScreen({super.key, required this.companyId});

  @override
  State<SelectDARGuardsScreen> createState() => _SelectGuardsScreenState();
}

class _SelectGuardsScreenState extends State<SelectDARGuardsScreen> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _guardsInfo = [];

  @override
  void initState() {
    super.initState();
    _getEmployeesByCompanyId();
  }

  Future<void> _refreshData() async {
    _getEmployeesByCompanyId();
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

  String dropdownValue = 'All'; // Initialize default value

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor:  isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        appBar: AppBar(
          backgroundColor:  isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
          elevation: 5,
          shadowColor:  isDark ? Colors.transparent: LightColor.color3.withOpacity(.1),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color:  isDark ? DarkColor.color1 : LightColor.color3,
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
            color:  isDark ? DarkColor.color1 : LightColor.color3,
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
                  _guardsInfo.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: PageScrollPhysics(),
                    itemCount: _guardsInfo.length,
                    itemBuilder: (context, index) {
                      final guardInfo = _guardsInfo[index].data();
                      final String name = guardInfo['EmployeeName'] ?? "";
                      final String id = guardInfo['EmployeeId'] ?? "";
                      final String url = guardInfo['EmployeeImg'] ?? "";
                      final String documentId = _guardsInfo[index].id;
            
                      return GestureDetector(
                        onTap: () async {
                          final darSnapshot = await FirebaseFirestore
                              .instance
                              .collection('EmployeesDAR')
                              .where('EmpDarEmpId', isEqualTo: documentId)
                              .get();
            
                          if (darSnapshot.docs.isNotEmpty) {
                            final darData = darSnapshot.docs.first.data();
                            final String empId = darData['EmpDarEmpId'] ?? '';
                            final String companyId = darData['EmpDarCompanyId'] ?? '';
                            final String companyBranchId = darData['EmpDarCompanyBranchId'] ?? '';
                            final String shiftId = darData['EmpDarShiftId'] ?? '';
                            final String clientId = darData['EmpDarClientId'] ?? '';
                            final String empName = darData['EmpDarEmpName'] ?? '';
            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SDarDisplayScreen(
                                  EmpEmail: '',
                                  EmpID: empId,
                                  EmpDarCompanyId: companyId,
                                  EmpDarCompanyBranchId: companyBranchId,
                                  EmpDarShiftID: shiftId,
                                  EmpDarClientID: clientId,
                                  Username: empName,
                                ),
                              ),
                            );
                          } else {
                            // Show a SnackBar when no DAR data is found for the selected employee
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('No DAR data found for the selected employee.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: height / height60,
                          decoration: BoxDecoration(
                            color: DarkColor. color19,
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
                                            color:  isDark
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
                                          color: DarkColor.color1,
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
                      color:  isDark
                                ? DarkColor.color2
                                : LightColor.color2,
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