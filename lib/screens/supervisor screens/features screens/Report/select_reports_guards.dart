import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/Report/s_report_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SelectReportsGuardsScreen extends StatefulWidget {
  final String companyId;

  const SelectReportsGuardsScreen({super.key, required this.companyId});

  @override
  State<SelectReportsGuardsScreen> createState() => _SelectGuardsScreenState();
}

class _SelectGuardsScreenState extends State<SelectReportsGuardsScreen> {
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
          onRefresh: _refreshData,
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
                    style: TextStyle(
                      color: color2,
                      fontSize: width / width12,
                    ),
                    borderRadius: BorderRadius.circular(width / width10),
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
                SizedBox(height: height / height20),
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
                        final reportsSnapshot = await FirebaseFirestore
                            .instance
                            .collection('Reports')
                            .where('ReportEmployeeId', isEqualTo: documentId)
                            .get();

                        if (reportsSnapshot.docs.isNotEmpty) {
                          final reportData = reportsSnapshot.docs.first.data();
                          final String locationId = reportData['ReportLocationId'] ?? '';
                          final String locationName = reportData['ReportLocationName'] ?? '';
                          final String companyId = reportData['ReportCompanyId'] ?? '';
                          final String empId = reportData['ReportEmployeeId'] ?? '';
                          final String empName = reportData['ReportEmployeeName'] ?? '';
                          final String clientId = reportData['ReportClientId'] ?? '';

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SReportScreen(
                                locationId: locationId,
                                locationName: locationName,
                                companyId: companyId,
                                empId: empId,
                                empName: empName,
                                clientId: clientId,
                              ),
                            ),
                          );
                        } else {
                          // Show a SnackBar when no reports are found for the selected employee
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No reports found for the selected employee.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: height / height60,
                        decoration: BoxDecoration(
                          color: color19,
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
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(url),
                                            filterQuality:
                                            FilterQuality.high,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width / width20),
                                      InterBold(
                                        text: name,
                                        letterSpacing: -.3,
                                        color: color1,
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
                    color: color2,
                    fontsize: width / width16,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}