import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/screens/SideBar%20Screens/pay_discrepancy_display.dart';
import '../../utils/colors.dart';
import '../../fonts/inter_bold.dart';
import '../../fonts/inter_regular.dart';
import '../../common/widgets/button1.dart';
import '../../common/sizes.dart';
import 'package:http/http.dart' as http;

class PayStubScreen extends StatefulWidget {
  final empId;
  const PayStubScreen({Key? key, this.empId}) : super(key: key);

  @override
  _PayStubScreenState createState() => _PayStubScreenState();
}

class _PayStubScreenState extends State<PayStubScreen> {
  Future<String> generatePaystubPDF(
      String PayStubStartDate,
      String PayStubEndDate,
      String EmpName,
      List<Map<String, dynamic>> PayStubEarnings,
      List<Map<String, dynamic>> PayStubDeductions,
      Map<String, dynamic> PayStubNetPay,
      ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Generating PDF..."),
              ],
            ),
          ),
        );
      },
    );

    String generateEarningsRows(List<Map<String, dynamic>> earnings) {
      String rows = '';
      for (var earning in earnings) {
        rows += """
        <tr>
          <td>${earning['Income']}</td>
          <td>${earning['Type']}</td>
          <td>${earning['Quantity']}</td>
          <td>${earning['Rate']}</td>
          <td>${earning['CurrentAmount']}</td>
          <td>${earning['YTDAmount']}</td>
        </tr>
      """;
      }
      return rows;
    }

    String generateDeductionsRows(List<Map<String, dynamic>> deductions) {
      String rows = '';
      for (var deduction in deductions) {
        rows += """
        <tr>
          <td>${deduction['Deduction']}</td>
          <td>${deduction['OtherDeduction']}</td>
          <td>${deduction['Percentage']}%</td>
          <td>${deduction['Amount']}</td>
          <td>${deduction['YearToDateAmt']}</td>
        </tr>
      """;
      }
      return rows;
    }

    final htmlContent = """
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Pay Stub</title>
      <style>
          body {
              font-family: Arial, sans-serif;
              margin: 0;
              padding: 0;
              box-sizing: border-box;
              background-color: #f4f4f4;
          }
          .paystub-container {
              max-width: 800px;
              margin: 20px auto;
              background: white;
              padding: 20px;
              box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
          }
          table {
              width: 100%;
              border-collapse: collapse;
              margin-bottom: 20px;
          }
          th, td {
              border: 1px solid #ddd;
              padding: 8px;
              text-align: left;
          }
          th {
              background-color: #f4b400;
              color: white;
          }
          .paystub-header {
              text-align: center;
              margin-bottom: 20px;
          }
      </style>
  </head>
  <body>
      <div class="paystub-container">
          <div class="paystub-header">
              <h1>Pay Stub</h1>
              <p>Employee Name: $EmpName</p>
              <p>Pay Period: $PayStubStartDate - $PayStubEndDate</p>
          </div>
          
          <h2>Earnings</h2>
          <table>
              <tr>
                  <th>Income</th>
                  <th>Type</th>
                  <th>Quantity</th>
                  <th>Rate</th>
                  <th>Current Amount</th>
                  <th>YTD Amount</th>
              </tr>
              ${generateEarningsRows(PayStubEarnings)}
          </table>
          
          <h2>Deductions</h2>
          <table>
              <tr>
                  <th>Deduction</th>
                  <th>Other Deduction</th>
                  <th>Percentage</th>
                  <th>Amount</th>
                  <th>Year To Date Amount</th>
              </tr>
              ${generateDeductionsRows(PayStubDeductions)}
          </table>
          
          <h2>Net Pay</h2>
          <table>
              <tr>
                  <th>Amount</th>
                  <th>Year To Date Amount</th>
              </tr>
              <tr>
                  <td>${PayStubNetPay['Amount']}</td>
                  <td>${PayStubNetPay['YearToDateAmt']}</td>
              </tr>
          </table>
      </div>
  </body>
  </html>
  """;

    // Generate the PDF
    final pdfResponse = await http.post(
      Uri.parse('https://backend-sceurity-app.onrender.com/api/html_to_pdf'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'html': htmlContent,
        'file_name': 'paystub.pdf',
      }),
    );

    if (pdfResponse.statusCode == 200) {
      print('PDF generated successfully');
      Navigator.of(context).pop();
      final pdfBase64 = base64Encode(pdfResponse.bodyBytes);
      final file = await savePdfLocally(
          pdfBase64, 'paystub_${Timestamp.now().toString()}.pdf');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('PDF Viewer')),
            body: PDFView(
              filePath: file.path,
            ),
          ),
        ),
      );
      return pdfBase64;
    } else {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to generate PDF"),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print('Failed to generate PDF. Status code: ${pdfResponse.statusCode}');
      throw Exception('Failed to generate PDF');
    }
  }

  Future<File> savePdfLocally(String pdfBase64, String fileName) async {
    final pdfBytes = base64Decode(pdfBase64);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    final Stream<QuerySnapshot> _paystubsStream = FirebaseFirestore.instance
        .collection('PayStubs')
        .where('PayStubEmpId', isEqualTo: widget.empId)
        .where('PayStubIsPublished', isEqualTo: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _paystubsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return SafeArea(
              child: Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                      ),
                      padding: EdgeInsets.only(left: width / width20),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: InterMedium(
                      text: 'Paystub',
                    ),
                    centerTitle: true,
                  ),
                  body: Text('Something went wrong'),
              )
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                  ),
                  padding: EdgeInsets.only(left: width / width20),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: InterMedium(
                  text: 'Paystub',
                ),
                centerTitle: true,
              ),
              body: Center(
            child: Text('No Data Available'),
              )
            )
          );
        }

        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
                padding: EdgeInsets.only(left: width / width20),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: InterMedium(
                text: 'Paystub',
              ),
              centerTitle: true,
            ),
            body: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final document = snapshot.data!.docs[index];
                final name = document['PayStubEmpName'];
                final startDateTime = (document['PayStubPayPeriodStartDate'] as Timestamp).toDate();
                final endDateTime = (document['PayStubPayPeriodEndDate'] as Timestamp).toDate();
                final dateFormatter = DateFormat('MM/dd/yyyy');
                final startDate = dateFormatter.format(startDateTime);
                final endDate = dateFormatter.format(endDateTime);
                final netPay = Map<String, dynamic>.from(document['PayStubNetPay']);
                final earnings = List<Map<String, dynamic>>.from(
                    document['PayStubEarnings'].map((item) => Map<String, dynamic>.from(item))
                );
                final deductions = List<Map<String, dynamic>>.from(
                    document['PayStubDeductions'].map((item) => Map<String, dynamic>.from(item))
                );

                return GestureDetector(
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PayDiscrepancyDisplay()));
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 16.h ,0, 0),
                    child: Container(
                      height: 260.h,
                      width: double.maxFinite,
                      margin: EdgeInsets.symmetric(horizontal: 30.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 20.h,
                              left: 10.w,
                            ),
                            child: InterBold(
                              text: 'Pay Discrepancy',
                              fontsize: 18.sp,
                              color: DarkColor.Primarycolor,
                            ),
                          ),
                          Button1(
                            text: 'Open',
                            color:
                                Theme.of(context).textTheme.headlineMedium!.color,
                            onPressed: () {
                              generatePaystubPDF(
                                  startDate,
                                  endDate,
                                  name,
                                  earnings,
                                  deductions,
                                  netPay,
                              );
                            },
                            backgroundcolor: Theme.of(context).primaryColor,
                            useBorderRadius: true,
                            MyBorderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12.r),
                              bottomRight: Radius.circular(12.r),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
