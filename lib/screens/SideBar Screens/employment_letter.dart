import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
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
            text: 'Employment Letter',
            
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            height: 500.h,
            width: double.maxFinite,
            margin: EdgeInsets.symmetric(horizontal: width / width30),
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
              borderRadius: BorderRadius.circular(12.w),
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
                    text: '',
                    fontsize: 18.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Center(
                  child: SvgPicture.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/images/folder_dark.svg':
                    'assets/images/folder.svg',
                    width: 190.w,
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
                        color: Theme.of(context).iconTheme.color,
                        size: 24.sp,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      InterSemibold(
                        text: 'Download',
                        color: Colors.white,
                        fontsize: 16.sp,
                      )
                    ],
                  ),
                  onPressed: () => _downloadAndOpenPdf(context),
                  backgroundcolor: Theme.of(context).primaryColor,
                  useBorderRadius: true,
                  MyBorderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.w),
                    bottomRight: Radius.circular(12.w),
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
