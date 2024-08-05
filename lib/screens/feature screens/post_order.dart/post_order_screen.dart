import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'package:tact_tik/main.dart';

// import 'package:workmanager/workmanager.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/post%20order/create_post_order.dart';
// import 'package:workmanager/workmanager.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import 'view_post_order.dart';

class PostOrder extends StatefulWidget {
  final String locationId;

  const PostOrder({super.key, required this.locationId});

  @override
  State<PostOrder> createState() => _PostOrderState();
}

class _PostOrderState extends State<PostOrder> {
  late Future<Map<String, List<Map<String, dynamic>>>> _locationDataFuture;
  late Future<String> _locationAddressFuture;

  @override
  void initState() {
    super.initState();
    _locationDataFuture = _fetchLocationData();
    _locationAddressFuture = _fetchLocationAddress();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchLocationData() async {
    final locationData = await FirebaseFirestore.instance
        .collection('Locations')
        .where('LocationId', isEqualTo: widget.locationId)
        .get();

    Map<String, List<Map<String, dynamic>>> organizedData = {};

    for (var doc in locationData.docs) {
      Timestamp timestamp = doc['LocationCreatedAt'];
      DateTime createdAt = timestamp.toDate();
      String formattedDate = DateFormat('yyyy-MM-dd').format(createdAt);

      var postOrder = doc['LocationPostOrder'];

      if (!organizedData.containsKey(formattedDate)) {
        organizedData[formattedDate] = [];
      }

      organizedData[formattedDate]?.add(postOrder);
    }

    return organizedData;
  }

  Future<String> _fetchLocationAddress() async {
    final locationDoc = await FirebaseFirestore.instance
        .collection('Locations')
        .doc(widget.locationId)
        .get();

    return locationDoc['LocationAddress'] ?? 'Address not found';
  }

  Future<Map<String, dynamic>> _fetchFileMetadata(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      final metadata = await ref.getMetadata();
      final fileSize = (metadata.size ?? 0) / 1024;
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(text: 'Post Orders'),
          centerTitle: true,
        ),
        body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
          future: _locationDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error fetching data'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 300.h,
                      child: SvgPicture.asset(isDark
                          ? 'assets/images/no_data_dark.svg'
                          : 'assets/images/no_data.svg'),
                    ),
                    InterSemibold(
                      text: 'Nothing to preview',
                      fontsize: 16.sp,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    )
                  ],
                ),
              );
            }

            Map<String, List<Map<String, dynamic>>> locationData = snapshot.data!;
            List<String> sortedDates = locationData.keys.toList()..sort((a, b) => b.compareTo(a));

            return ListView.builder(
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                String date = sortedDates[index];
                List<Map<String, dynamic>> posts = locationData[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 40.h),
                      child: InterSemibold(
                        text: date,
                        fontsize: 20.sp,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                    ...posts.map((postOrder) => _buildPostOrderCard(context, postOrder, date)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostOrderCard(BuildContext context, Map<String, dynamic> postOrder, String date) {
    String postOrderTitle = postOrder['PostOrderTitle'];
    String postOrderPdf = postOrder['PostOrderPdf'];
    List<dynamic> postOrderOtherData = postOrder['PostOrderOtherData'] ?? [];
    List imageUrls = postOrderOtherData.where((url) => !url.contains('.pdf')).toList();
    List<String> pdfUrls = [postOrderPdf, ...postOrderOtherData.where((url) => url.contains('.pdf'))];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePostOrder(
              isDisplay: true,
              locationId: widget.locationId,
              title: postOrderTitle,
              date: date,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Container(
          constraints: BoxConstraints(minHeight: 250.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          width: double.maxFinite,
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 3),
              )
            ],
            borderRadius: BorderRadius.circular(10.r),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InterBold(
                text: postOrderTitle,
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontsize: 20.sp,
              ),
              _buildImageGrid(imageUrls),
              SizedBox(height: 16.h),
              _buildLocationWidget(),
              SizedBox(height: 16.h),
              _buildPdfList(pdfUrls),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfList(List<String> pdfUrls) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: pdfUrls.length,
      itemBuilder: (context, index) {
        return _buildPdfWidget(pdfUrls[index]);
      },
    );
  }

  Widget _buildPdfWidget(String pdfUrl) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchFileMetadata(pdfUrl),
      builder: (context, snapshot) {
        String fileName = 'Loading...';
        String fileSize = 'Loading...';

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          fileName = snapshot.data!['name'];
          fileSize = snapshot.data!['size'];
        }

        return Container(
          constraints: BoxConstraints(minWidth: 200.w),
          height: 70.h,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 3),
              )
            ],
            borderRadius: BorderRadius.circular(10.r),
            color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1F1E1E) : LightColor.Secondarycolor,
          ),
          child: Row(
            children: [
              Container(
                height: 48.h,
                width: 48.w,
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                padding: EdgeInsets.all(14.sp),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF393939) : Color(0xFFAE7CFE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: SvgPicture.asset(
                  'assets/images/pdf_new.svg',
                  width: 20.w,
                  color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PoppinsMedium(
                      text: fileName,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontsize: 12.sp,
                    ),
                    PoppinsRegular(
                      text: fileSize,
                      color: Theme.of(context).textTheme.headlineSmall!.color,
                      fontsize: 12.sp,
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _downloadAndOpenPdf(context, pdfUrl);
                },
                icon: Icon(
                  Icons.download,
                  color: Theme.of(context).primaryColor,
                  size: 24.sp,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationWidget() {
    return FutureBuilder<String>(
      future: _locationAddressFuture,
      builder: (context, snapshot) {
        String address = 'Loading...';

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            address = 'Error fetching address';
          } else {
            address = snapshot.data ?? 'Address not found';
          }
        }

        return Container(
          constraints: BoxConstraints(minWidth: 200.w),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 3),
              )
            ],
            borderRadius: BorderRadius.circular(10.r),
            color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1F1E1E) : LightColor.Secondarycolor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48.h,
                width: 48.w,
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.all(14.sp),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF393939) : Color(0xFFAE7CFE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: SvgPicture.asset(
                  'assets/images/location_icon.svg',
                  width: 20.w,
                  color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PoppinsBold(
                      text: "Location",
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontsize: 14.sp,
                    ),
                    SizedBox(height: 4.h),
                    PoppinsRegular(
                      text: address,
                      color: Theme.of(context).textTheme.headlineSmall!.color,
                      fontsize: 12.sp,
                      maxline: null,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageGrid(List imageUrls) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Image.network(
          imageUrls[index],
          fit: BoxFit.cover,
        );
      },
    );
  }
}
