import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';

import 'package:path_provider/path_provider.dart';
import '../../../../common/sizes.dart';
import '../../../../common/widgets/button1.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../fonts/inter_semibold.dart';
import '../../../../fonts/poppins_medium.dart';
import '../../../../fonts/poppins_regular.dart';
import '../../../../utils/colors.dart';
import '../../../feature screens/widgets/custome_textfield.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class CreateSPostOrder extends StatefulWidget {
  final bool isDisplay;
  final String locationId;
  final String title;
  final String date;

  CreateSPostOrder({
    super.key,
    this.isDisplay = true,
    required this.locationId,
    required this.title,
    required this.date,
  });

  @override
  State<CreateSPostOrder> createState() => _CreatePostOrderState();
}

class _CreatePostOrderState extends State<CreateSPostOrder> {
  final TextEditingController _explainController = TextEditingController();
  List<Map<String, dynamic>> uploads = [];
  List<String> selectedFilePaths = [];
  List<dynamic> postOrderOtherData = [];
  String postOrderPdfUrl = '';
  String postOrderPdfFileName = 'Loading...';
  String postOrderPdfFileSize = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchExistingData();
  }

  Future<void> _fetchExistingData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Locations')
        .doc(widget.locationId)
        .get();

    if (docSnapshot.exists) {
      var postOrder = docSnapshot.data()!['LocationPostOrder'];
      setState(() {
        postOrderOtherData =
            List<dynamic>.from(postOrder['PostOrderOtherData'] ?? []);
        postOrderPdfUrl = postOrder['PostOrderPdf'] ?? '';
      });
      print('postOrder Data : ${postOrder}');
      if (postOrderPdfUrl.isNotEmpty) {
        final metadata = await _fetchFileMetadata(postOrderPdfUrl);
        setState(() {
          postOrderPdfFileName = metadata['name'] ?? 'Unknown';
          postOrderPdfFileSize = metadata['size'] ?? 'Unknown size';
        });
      }
    }
  }

  Future<Map<String, dynamic>> _fetchFileMetadata(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      final metadata = await ref.getMetadata();
      final fileSize = (metadata.size ?? 0) / 1024; // size in KB
      return {
        'name': metadata.name,
        'size': '${fileSize.toStringAsFixed(2)} KB',
      };
    } catch (e) {
      print('Error fetching file metadata: $e');
      return {
        'name': 'Unknown',
        'size': 'Unknown size',
      };
    }
  }

  Future<void> _addImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
    }
  }

  Future<void> _addGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        uploads.add({'type': 'image', 'file': File(pickedFile.path)});
      });
    }
  }

  Future<void> _addVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );
    if (result != null) {
      setState(() {
        uploads.add({'type': 'video', 'file': File(result.files.single.path!)});
      });
    }
  }

  Future<void> _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      List<String> filePaths = result.paths.map((path) => path!).toList();
      for (String filePath in filePaths) {
        setState(() {
          uploads.add({'type': 'pdf', 'file': File(filePath)});
        });
      }
    }
  }

  void _deleteItem(int index) {
    setState(() {
      uploads.removeAt(index);
    });
  }

  void removeButton(int index) {
    setState(() {
      selectedFilePaths.removeAt(index);
    });
  }

  Future<void> _uploadFiles() async {
    List<String> urls = [];
    for (var upload in uploads) {
      String filePath = upload['file'].path;
      String fileName = filePath.split('/').last;
      File file = upload['file'];
      String destination = upload['type'] == 'image'
          ? 'companies/locations/images/$fileName'
          : 'companies/locations/documents/$fileName';
      try {
        final ref = FirebaseStorage.instance.ref(destination);
        await ref.putFile(file);
        String url = await ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        print('Error uploading file: $e');
      }
    }

    // Update Firestore with the new URLs
    final docRef = FirebaseFirestore.instance
        .collection('Locations')
        .doc(widget.locationId);
    await docRef.update({
      'LocationPostOrder.PostOrderOtherData': FieldValue.arrayUnion(urls),
      'LocationPostOrder.PostOrderComment': _explainController.text,
    });

    Navigator.of(context).pop();
  }

  Future<void> _downloadAndOpenPdf(BuildContext context, String url) async {
    final String pdfFileName = url.split('/').last;

    try {
      final firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.refFromURL(url);

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
    }
  }

  @override
  Widget build(BuildContext context) {
    // Combine postOrderPdfUrl and postOrderOtherData for display
    List<String> allUrls = [];
    if (postOrderPdfUrl.isNotEmpty) {
      allUrls.add(postOrderPdfUrl);
    }
    allUrls.addAll(postOrderOtherData.map((data) => data.toString()));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterMedium(
            text: 'Post Order',
          ),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: ListView(
            children: [
              SizedBox(height: 30.h),
              InterSemibold(
                text: widget.date,
                fontsize: 20.sp,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
              SizedBox(height: 30.h),
              CustomeTextField(
                isEnabled: widget.isDisplay,
                hint: widget.title,
                showIcon: false,
              ),
              SizedBox(height: 20.h),
              CustomeTextField(
                isEnabled: !widget.isDisplay,
                hint: 'Comment',
                isExpanded: true,
                controller: _explainController,
              ),
              SizedBox(height: 30.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Row(
                      children: uploads.asMap().entries.map((entry) {
                        final index = entry.key;
                        final upload = entry.value;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 66.h,
                              width: 66.w,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                    10.r,
                                  )),
                              margin: EdgeInsets.all(8.w),
                              child: upload['type'] == 'image'
                                  ? Image.file(
                                      upload['file'],
                                      fit: BoxFit.cover,
                                    )
                                  : SvgPicture.asset(
                                      'assets/images/pdf.svg',
                                      width: 32.w,
                                    ),
                            ),
                            Positioned(
                              top: -5,
                              right: -5,
                              child: IconButton(
                                onPressed: () => _deleteItem(index),
                                icon: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Icon(
                                    Icons.close_sharp,
                                    color: Colors.black,
                                    size: 20.w,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.camera),
                                title: Text('Add Image'),
                                onTap: () {
                                  _addImage();
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.image),
                                title: Text('Add from Gallery'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _addGallery();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.picture_as_pdf),
                                title: Text('Add PDF'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _openFileExplorer();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        height: 66.h,
                        width: 66.w,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 10.r,
                                offset: Offset(0, 5),
                              ),
                            ],
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8.r)),
                        child: Center(
                          child: Icon(Icons.add,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: allUrls.length,
                    itemBuilder: (context, index) {
                      String url = allUrls[index];
                      if (url.contains('.pdf')) {
                        return FutureBuilder<Map<String, dynamic>>(
                          future: _fetchFileMetadata(url),
                          builder: (context, snapshot) {
                            String otherFileName = 'Loading...';
                            String otherFileSize = 'Loading...';

                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              otherFileName = snapshot.data!['name'];
                              otherFileSize = snapshot.data!['size'];
                            }

                            return GestureDetector(
                              onTap: () {
                                _downloadAndOpenPdf(context, url);
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 10.h),
                                width: 200.w,
                                height: 46.h,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      blurRadius: 10.r,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: DarkColor.color1,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                          ),
                                          child: SvgPicture.asset(
                                            'assets/images/pdf.svg',
                                            width: 32.w,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 300.w,
                                              child: PoppinsMedium(
                                                text: otherFileName,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .color,
                                              ),
                                            ),
                                            PoppinsRegular(
                                              text: otherFileSize,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .color,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return SizedBox
                            .shrink(); // Skip non-PDF URLs in the ListView
                      }
                    },
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Number of columns in the grid
                      childAspectRatio: 1.0, // Aspect ratio of the grid items
                    ),
                    itemCount:
                        allUrls.where((url) => !url.contains('.pdf')).length,
                    // Count of non-PDF URLs
                    itemBuilder: (context, index) {
                      String imageUrl = allUrls
                          .where((url) => !url.contains('.pdf'))
                          .toList()[index];
                      return SizedBox(
                        height: 80.h,
                        width: 80.w,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 40.h,
              ),
              Button1(
                text: 'Done',
                onPressed: _uploadFiles,
                backgroundcolor: Theme.of(context).primaryColor,
                color: Colors.white,
                borderRadius: 10.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
