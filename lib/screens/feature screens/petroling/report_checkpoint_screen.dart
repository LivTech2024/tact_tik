import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/widgets/custome_textfield.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:toastification/toastification.dart';
import 'package:image/image.dart' as img;

import 'package:intl/intl.dart';
import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class ReportCheckpointScreen extends StatefulWidget {
  final String CheckpointID;
  final String PatrolID;
  final String ShiftId;
  final String empId;

  const ReportCheckpointScreen(
      {super.key,
      required this.CheckpointID,
      required this.PatrolID,
      required this.ShiftId,
      required this.empId});

  @override
  State<ReportCheckpointScreen> createState() => _ReportCheckpointScreenState();
}

FireStoreService fireStoreService = FireStoreService();

class _ReportCheckpointScreenState extends State<ReportCheckpointScreen> {
  bool _expand = false;
  late Map<String, bool> _expandCategoryMap;
  TextEditingController Controller = TextEditingController();
  bool _isLoading = false;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadShiftStartedState();
    fetchImages();
    // // Initialize expand state for each category
    // _expandCategoryMap = Map.fromIterable(widget.p.categories,
    //     key: (category) => category.title, value: (_) => false);
  }

  void _loadShiftStartedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _expand = prefs.getBool('expand') ?? false;
    });
  }

  void fetchImages() async {
    try {
      List<String> img = await fireStoreService.getCheckpointImages(
          widget.PatrolID, widget.CheckpointID, widget.empId, widget.ShiftId);
      if (img.isNotEmpty) {
        setState(() {
          imageUrls = img;
        });
      }
      print("checkpoint IMages ${img}");
    } catch (e) {}
  }

  List<Map<String, dynamic>> uploads = [];

  void _deleteItem(int index) {
    setState(() {
      uploads.removeAt(index);
    });
    fetchImages();
  }

  Future<void> _addImage() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: Platform.isIOS ? 30 : 50);

    if (pickedFile != null) {
      try {
        final originalFile = File(pickedFile.path);
        if (originalFile.existsSync()) {
          // Add timestamp logic here:
          final timestampedFile = await _addTimestampToImage(originalFile);

          // Option 1: Directly add the timestamped file to uploads
          setState(() {
            uploads.add({'type': 'image', 'file': timestampedFile});
          });

          // Option 2: Compress and then add the timestamped file (optional)
          // final compressedFile = await _compressImage(timestampedFile);
          // setState(() {
          //   uploads.add({'type': 'image', 'file': compressedFile});
          // });
        } else {
          print('File does not exist: ${originalFile.path}');
        }
      } catch (e) {
        print('Error adding image: $e');
      }
    } else {
      print('No images selected');
    }

    print("Status ${uploads}");
  }

  Future<File> _addTimestampToImage(File originalFile) async {
    final originalImage = img.decodeImage(originalFile.readAsBytesSync());
    if (originalImage == null) return originalFile; // Handle decoding errors

    final now = DateTime.now();
    final formatter =
        DateFormat('yyyy-MM-dd HH:mm:ss'); // Customize format as needed
    final timestamp = formatter.format(now);

    final watermarkedImage = img.copyResize(originalImage,
        width: originalImage.width, height: originalImage.height);

    // Create a color object directly
    final textColor = img.ColorFloat16; // White color

    final fontSize = 20;
    final imageHeight = originalImage.height;
    final timestampPosition =
        Offset(45, imageHeight - fontSize - 45); // Customize placement

    // Use named arguments for drawString
    img.drawString(
      watermarkedImage,
      timestamp,
      x: timestampPosition.dx.toInt(),
      y: timestampPosition.dy.toInt(),
      font: img.arial48,
    );

    // Save the watermarked image with timestamp
    final timestampedImagePath = '${originalFile.path}_with_timestamp.jpg';
    final timestampedFile = File(timestampedImagePath);
    timestampedFile.writeAsBytesSync(img.encodeJpg(watermarkedImage));

    return timestampedFile;
  }

  // Future<void> _addGallery() async {
  //   List<XFile>? pickedFiles = await ImagePicker()
  //       .pickMultiImage(imageQuality: Platform.isIOS ? 30 : 50);
  //   if (pickedFiles != null) {
  //     for (var pickedFile in pickedFiles) {
  //       try {
  //         File file = File(pickedFile.path);
  //         if (file.existsSync()) {
  //           File compressedFile = await _compressImage(file);
  //           setState(() {
  //             uploads.add({'type': 'image', 'file': file});
  //           });
  //         } else {
  //           print('File does not exist: ${file.path}');
  //         }
  //       } catch (e) {
  //         print('Error adding image: $e');
  //       }
  //     }
  //   } else {
  //     print('No images selected');
  //   }
  // }
  Future<void> _addGallery() async {
    List<XFile>? pickedFiles = await ImagePicker()
        .pickMultiImage(imageQuality: Platform.isIOS ? 30 : 50);
    if (pickedFiles != null) {
      for (var pickedFile in pickedFiles) {
        try {
          File file = File(pickedFile.path);
          if (file.existsSync()) {
            // Add timestamp logic
            final timestampedFile = await _addTimestampToImage(file);

            // Add the timestamped file to uploads
            setState(() {
              uploads.add({'type': 'image', 'file': timestampedFile});
            });
          } else {
            print('File does not exist: ${file.path}');
          }
        } catch (e) {
          print('Error adding image: $e');
        }
      }
    } else {
      print('No images selected');
    }
  }

  // Future<File> _compressImage(File file) async {
  //   final result = await FlutterImageCompress.compressAndGetFile(
  //     file.absolute.path,
  //     file.absolute.path + '_compressed.jpg',
  //     quality: 1,
  //   );
  //   return File(result!.path);
  // }

  Future<File> _compressImage(File file) async {
    int quality = 90; // Starting quality
    int minWidth = 800; // Minimum width to reduce resolution step by step
    int minHeight = 800; // Minimum height to reduce resolution step by step
    XFile? result;
    do {
      result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        file.absolute.path + '_compressed.jpg',
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );

      if (result != null && File(result.path).lengthSync() <= 100 * 1024) {
        break;
      }

      quality -= 10;
      minWidth = (minWidth * 0.9).toInt(); // Reduce resolution by 10%
      minHeight = (minHeight * 0.9).toInt();

      if (quality <= 0 || minWidth <= 0 || minHeight <= 0) {
        break; // Stop if quality or resolution goes to 0
      }
    } while (result == null || File(result.path).lengthSync() > 100 * 1024);

    if (result == null || File(result.path).lengthSync() > 100 * 1024) {
      throw Exception('Could not compress image to under 100 KB.');
    }

    return File(result.path);
  }

  void _removeImage(int index) {
    setState(() {
      imageUrls.removeAt(index);
    });
  }

  void _showFullscreenImage(BuildContext context, dynamic image) {
    if (image is String) {
      // Handle image URL
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullscreenImage(imageUrl: image),
        ),
      );
    } else if (image is File) {
      // Handle File object
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullscreenImage(imageFile: image),
        ),
      );
    } else {
      // Handle other data types (optional: show error or handle differently)
      print('Unsupported image data type: ${image.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

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
            text: 'Report Checkpoint',
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    Text(
                      'Add Image/Comment',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // SizedBox(height: 10.h),
                    // Row(
                    //   children: [
                    //     Radio(
                    //       activeColor: Primarycolor,
                    //       value: 'Emergency',
                    //       groupValue: selectedOption,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           selectedOption = value!;
                    //         });
                    //       },
                    //     ),
                    //     InterRegular(
                    //       text: 'Emergency',
                    //       fontsize: width / width16,
                    //       color: color1,
                    //     )
                    //   ],
                    // ),
                    // Row(
                    //   children: [
                    //     Radio(
                    //       activeColor: Primarycolor,
                    //       value: 'Normal',
                    //       groupValue: selectedOption,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           selectedOption = value!;
                    //         });
                    //       },
                    //     ),
                    //     InterRegular(
                    //       text: 'Normal',
                    //       fontsize: width / width16,
                    //       color: color1,
                    //     )
                    //   ],
                    // ),
                    SizedBox(height: 10.h),
                    // TextField(
                    //   controller: Controller,
                    //   decoration: InputDecoration(
                    //       hintText: 'Add Comment',
                    //       hintStyle: TextStyle(
                    //           color: Theme.of(context)
                    //               .textTheme
                    //               .bodyMedium!
                    //               .color)),
                    //   style: TextStyle(
                    //       color: Theme.of(context).textTheme.bodyMedium!.color),
                    // ),
                    CustomeTextField(
                      hint: 'Add Comment',
                      controller: Controller,
                      isEnabled: true,
                    ),
                    SizedBox(height: 20.h),
                    GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: width / width10,
                        mainAxisSpacing: height / height10,
                        crossAxisCount: 3,
                      ),
                      itemCount: uploads.length + 1,
                      itemBuilder: (context, index) {
                        if (index == uploads.length) {
                          return GestureDetector(
                            onTap: () async {
                              // _refresh();
                              bool showGallery = await fireStoreService
                                  .showGalleryOption(widget.empId);
                              print("showGallery ${showGallery}");
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.camera),
                                      title: Text('Add Image from Camera'),
                                      onTap: () {
                                        _addImage();
                                        Navigator.pop(context);
                                      },
                                    ),
                                    if (showGallery)
                                      ListTile(
                                        leading: Icon(Icons.image),
                                        title: Text('Add Image from Gallery'),
                                        onTap: () {
                                          _addGallery();
                                          Navigator.pop(context);
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
                                color: Colors.grey.withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.circular(width / width10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: width / width30,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                  SizedBox(height: height / height10),
                                  InterMedium(
                                    text: 'Add Image',
                                    fontsize: width / width16,
                                    color: DarkColor.color1,
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          final upload = uploads[index];
                          return GestureDetector(
                            onTap: () => _showFullscreenImage(context, upload),
                            child: Container(
                              height: height / height66,
                              width: width / width66,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.circular(width / width10),
                              ),
                              // margin: EdgeInsets.all(width / width8),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.file(
                                      upload['file'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      onPressed: () {
                                        _deleteItem(index - 1);
                                      },
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.black,
                                        size: width / width30,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20.h),
                    imageUrls.isNotEmpty
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                            ),
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _showFullscreenImage(
                                    context, imageUrls[index]),
                                child: Stack(
                                  children: [
                                    /* Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                ),*/
                                    Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image: NetworkImage(imageUrls[index]),
                                        fit: BoxFit.cover,
                                      )),
                                    ),
                                    Positioned(
                                      top: -5.h,
                                      right: -5.w,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              _removeImage(index);
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : SizedBox(),
                    SizedBox(height: 100.h)
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: DarkColor.Primarycolor,
                  ),
                ),
              ),
            Align(
              // bottom: 10,
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button1(
                      text: 'Submit',
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final combinedMaps = <Map<String, dynamic>>[];

                        // Extract URLs from uploads
                        combinedMaps.addAll(uploads
                            .map((upload) => {'imageUrl': upload['imageUrl']})
                            .toList());

                        // Add new URL map
                        combinedMaps.add({'imageUrl': Controller.text.trim()});

                        // List<String> imageUrls = []; This stores the previously uploaded images
                        if (uploads.isNotEmpty || Controller.text.isNotEmpty) {
                          await fireStoreService.addImagesToPatrol(
                              uploads,
                              Controller.text,
                              widget.PatrolID,
                              widget.empId,
                              widget.CheckpointID,
                              widget.ShiftId,
                              imageUrls);
                          toastification.show(
                            context: context,
                            type: ToastificationType.success,
                            title: Text("Submitted"),
                            autoCloseDuration: const Duration(seconds: 2),
                          );

                          uploads.clear();
                          Controller.clear();
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                        } else {
                          showErrorToast(context, "Fields cannot be empty");
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      color: Theme.of(context).textTheme.headlineMedium!.color,
                      borderRadius: 20.r,
                      backgroundcolor: Theme.of(context).primaryColor,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FullscreenImage extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;

  const FullscreenImage({Key? key, this.imageFile, this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: imageFile != null
              ? InteractiveViewer(
                  child: Image.file(imageFile!, fit: BoxFit.contain),
                )
              : (imageUrl != null)
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Center(child: Text('Error loading image')),
                    )
                  : Container(), // Handle cases where both imageFile and imageUrl are null (optional)
        ),
      ),
    );
  }
}
