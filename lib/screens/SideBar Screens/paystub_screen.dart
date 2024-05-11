import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/colors.dart';
import '../../fonts/inter_bold.dart';
import '../../fonts/inter_regular.dart';
import '../../common/widgets/button1.dart';
import '../../common/sizes.dart';

class PayStubScreen extends StatefulWidget {
  const PayStubScreen({Key? key}) : super(key: key);

  @override
  _PayStubScreenState createState() => _PayStubScreenState();
}

class _PayStubScreenState extends State<PayStubScreen> {
  final Stream<QuerySnapshot> _paystubsStream =
      FirebaseFirestore.instance.collection('wages').snapshots();

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return StreamBuilder<QuerySnapshot>(
      stream: _paystubsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return SafeArea(
          child: Scaffold(
            backgroundColor: isLight ? color18 : Secondarycolor,
            appBar: AppBar(
              backgroundColor: isLight ? color1 : AppBarcolor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isLight ? WidgetColor : Colors.white,
                  size: width / width24,
                ),
                padding: EdgeInsets.only(left: width / width20),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: InterRegular(
                text: 'Paystub',
                fontsize: width / width18,
                color: isLight ? WidgetColor : Colors.white,
                letterSpacing: -0.3,
              ),
              centerTitle: true,
            ),
            body: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final document = snapshot.data!.docs[index];
                final name = document['name'];
                final pdfUrl =
                    'https://firebasestorage.googleapis.com/v0/b/security-app-3b156.appspot.com/o/EmploymentLetter%2Fshift_patrol_report%20(1).pdf?alt=media&token=f0283d6c-1375-45b8-88a6-69cb9d93c452';

                return Container(
                  height: height / height260,
                  width: double.maxFinite,
                  margin: EdgeInsets.symmetric(horizontal: width / width30),
                  decoration: BoxDecoration(
                    color: isLight ? color1 : WidgetColor,
                    borderRadius: BorderRadius.circular(width / width12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: height / height20,
                          left: width / width10,
                        ),
                        child: InterBold(
                          text: 'Pay Discrepancy',
                          fontsize: width / width18,
                          color: isLight ? WidgetColor : Primarycolor,
                        ),
                      ),
                      Button1(
                        text: 'Open',
                        color: isLight ? WidgetColor : color1,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewerPage(
                                title: name,
                                pdfUrl: pdfUrl,
                              ),
                            ),
                          );
                        },
                        backgroundcolor: isLight ? color1 : Primarycolorlight,
                        useBorderRadius: true,
                        MyBorderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(width / width12),
                          bottomRight: Radius.circular(width / width12),
                        ),
                      )
                    ],
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

class PDFViewerPage extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PDFViewerPage({
    Key? key,
    required this.title,
    required this.pdfUrl,
  }) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? _localPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    final filename = '${widget.title}.pdf';
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename';
    final file = File(path);

    if (!file.existsSync()) {
      final http = HttpClient();
      final request = await http.getUrl(Uri.parse(widget.pdfUrl));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
    }

    setState(() {
      _localPath = path;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : PDFView(filePath: _localPath!),
    );
  }
}
