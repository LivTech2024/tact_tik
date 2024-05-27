import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/sizes.dart';
import '../../../../common/widgets/button1.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../fonts/inter_semibold.dart';
import '../../../../fonts/poppins_medium.dart';
import '../../../../fonts/poppins_regular.dart';
import '../../../../utils/colors.dart';
import '../../../feature screens/widgets/custome_textfield.dart';

class CreateSPostOrder extends StatefulWidget {
  final bool isDisplay;
  final String locationId;
  final String title;
  final String date;
  CreateSPostOrder(
      {super.key,
        this.isDisplay = true,
        required this.locationId,
        required this.title,
        required this.date});

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
        postOrderOtherData = List<dynamic>.from(postOrder['PostOrderOtherData'] ?? []);
        postOrderPdfUrl = postOrder['PostOrderPdf'] ?? '';
      });

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
    final docRef = FirebaseFirestore.instance.collection('Locations').doc(widget.locationId);
    docRef.update({
      'LocationPostOrder.PostOrderOtherData': FieldValue.arrayUnion(urls),
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(

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
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            text: 'Post Order',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        backgroundColor: Secondarycolor,
        body: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: ListView(
            children: [
              SizedBox(height: height / height30),
              InterSemibold(
                text: widget.date,
                fontsize: width / width20,
                color: Primarycolor,
              ),
              SizedBox(height: height / height30),
              CustomeTextField(
                isEnabled: widget.isDisplay,
                hint: widget.title,
                showIcon: false,
              ),
              SizedBox(height: height / height20),
              CustomeTextField(
                isEnabled: !widget.isDisplay,
                hint: 'Comment',
                isExpanded: true,
                controller: _explainController,
              ),
              SizedBox(height: height / height30),
              if (postOrderPdfUrl.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: height / height10),
                  width: width / width200,
                  height: height / height46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width / width10),
                    color: color1,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width / width6,
                            ),
                            child: SvgPicture.asset('assets/images/pdf.svg',
                                width: width / width32),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PoppinsMedium(
                                text: postOrderPdfFileName,
                                color: color15,
                              ),
                              PoppinsRegular(
                                text: postOrderPdfFileSize,
                                color: color16,
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                              height: height / height66,
                              width: width / width66,
                              decoration: BoxDecoration(
                                  color: WidgetColor,
                                  borderRadius: BorderRadius.circular(
                                    width / width10,
                                  )),
                              margin: EdgeInsets.all(width / width8),
                              child: upload['type'] == 'image'
                                  ? Image.file(
                                upload['file'],
                                fit: BoxFit.cover,
                              )
                                  : SvgPicture.asset(
                                'assets/images/pdf.svg',
                                width: width / width32,
                              ),
                            ),
                            Positioned(
                              top: -5,
                              right: -5,
                              child: IconButton(
                                onPressed: () => _deleteItem(index),
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.black,
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
                        height: height / height66,
                        width: width / width66,
                        decoration: BoxDecoration(
                            color: WidgetColor,
                            borderRadius:
                            BorderRadius.circular(width / width8)),
                        child: Center(
                          child: Icon(Icons.add),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height / height30),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: postOrderOtherData.length,
                itemBuilder: (context, index) {
                  String url = postOrderOtherData[index];
                  if (url.contains('.pdf')) {
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _fetchFileMetadata(url),
                      builder: (context, snapshot) {
                        String otherFileName = 'Loading...';
                        String otherFileSize = 'Loading...';

                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          otherFileName = snapshot.data!['name'];
                          otherFileSize = snapshot.data!['size'];
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: height / height10),
                          width: width / width200,
                          height: height / height46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width / width10),
                            color: color1,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width / width6,
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/images/pdf.svg',
                                      width: width / width32,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      PoppinsMedium(
                                        text: otherFileName,
                                        color: color15,
                                      ),
                                      PoppinsRegular(
                                        text: otherFileSize,
                                        color: color16,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return SizedBox(
                      height: height / height20,
                      width: width / width20,
                      child: Image.network(url),
                    );
                  }
                },
              ),
              Button1(
                text: 'Done',
                onPressed: _uploadFiles,
                backgroundcolor: Primarycolor,
                borderRadius: width / width10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
