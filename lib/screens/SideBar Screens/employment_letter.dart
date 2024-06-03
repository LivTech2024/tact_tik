import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class EmploymentLetterScreen extends StatelessWidget {
  const EmploymentLetterScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    Future<void> _downloadAndOpenPdf(BuildContext context) async {
      final String pdfFileName = 'shift_patrol_report (1).pdf';

      try {
        final firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('EmploymentLetter')
            .child(pdfFileName);

        final Directory tempDir = await getTemporaryDirectory();
        final File file = File('${tempDir.path}/$pdfFileName');

        await ref.writeToFile(file);

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
      } catch (e) {
        print('Error downloading PDF: $e');
        // Handle error appropriately, e.g., show a snackbar or alert dialog
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        appBar: AppBar(
          shadowColor: isDark ? DarkColor.color3.withOpacity(.1) : LightColor.color3.withOpacity(0.1),
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
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            text: 'Employment Letter',
            fontsize: width / width18,
            color: isDark ? DarkColor.color1 : LightColor.color3,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            height: height / height500,
            width: double.maxFinite,
            margin: EdgeInsets.symmetric(horizontal: width / width30),
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
              color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
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
                    text: '',
                    fontsize: width / width18,
                    color: isDark
                        ? DarkColor.Primarycolor
                        : LightColor.Primarycolor,
                  ),
                ),
                Center(
                  child: SvgPicture.asset(
                    isDark? 'assets/images/folder_dark.svg':
                    'assets/images/folder.svg',
                    width: width / width190,
                  ),
                ),
                Button1(
                  text: 'text',
                  useWidget: true,
                  MyWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_for_offline,
                        color: DarkColor.  color1,
                        size: width / width24,
                      ),
                      SizedBox(
                        width: width / width10,
                      ),
                      InterSemibold(
                        text: 'Download',
                        color: DarkColor.color1,
                        fontsize: width / width16,
                      )
                    ],
                  ),
                  onPressed: () => _downloadAndOpenPdf(context),
                  backgroundcolor: isDark ? DarkColor.Primarycolorlight : LightColor.Primarycolorlight,
                  useBorderRadius: true,
                  MyBorderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(width / width12),
                    bottomRight: Radius.circular(width / width12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
