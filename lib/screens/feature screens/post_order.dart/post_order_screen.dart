import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
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

  @override
  void initState() {
    super.initState();
    _locationDataFuture = _fetchLocationData();
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

  @override
  Widget build(BuildContext context) {
    // final double height = MediaQuery.of(context).size.height;
    // final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Post Orders',
          ),
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
              return Center(child: Text('No data available'));
            }

            Map<String, List<Map<String, dynamic>>> locationData =
                snapshot.data!;

            List<String> sortedDates = locationData.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return CustomScrollView(
              slivers: [
                // SliverAppBar(
                //   backgroundColor: AppBarcolor,
                //   elevation: 0,
                //   leading: IconButton(
                //     icon: Icon(
                //       Icons.arrow_back_ios,
                //       color: Colors.white,
                //       size: width / width24,
                //     ),
                //     padding: EdgeInsets.only(left: width / width20),
                //     onPressed: () {
                //       Navigator.pop(context);
                //       print("Navigator debug: ${Navigator.of(context).toString()}");
                //     },
                //   ),
                //   title: InterRegular(
                //     text: 'Post Order',
                //     fontsize: width / width18,
                //     color: Colors.white,
                //     letterSpacing: -.3,
                //   ),
                //   centerTitle: true,
                //   floating: true,
                // ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      String date = sortedDates[index];
                      List<Map<String, dynamic>> posts = locationData[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w, vertical: 40.h),
                            child: InterSemibold(
                              text: date,
                              fontsize: 20.sp,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                          ...posts.map((postOrder) {
                            String postOrderTitle = postOrder['PostOrderTitle'];
                            String postOrderPdf = postOrder['PostOrderPdf'];
                            List<dynamic> postOrderOtherData =
                                postOrder['PostOrderOtherData'] ?? [];

                            return FutureBuilder<Map<String, dynamic>>(
                              future: _fetchFileMetadata(postOrderPdf),
                              builder: (context, snapshot) {
                                String fileName = 'Loading...';
                                String fileSize = 'Loading...';

                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  fileName = snapshot.data!['name'];
                                  fileSize = snapshot.data!['size'];
                                }

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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30.w),
                                    child: Container(
                                      
                                      constraints: BoxConstraints(
                                        minHeight: 250.h,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 10.h,
                                      ),
                                      width: double.maxFinite,
                                      margin: EdgeInsets.only(bottom: 10.h),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Theme.of(context).shadowColor,
                                            blurRadius: 5,
                                            spreadRadius: 2,
                                            offset: Offset(0, 3),
                                          )
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        color: Theme.of(context).cardColor,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InterBold(
                                            text: postOrderTitle,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                            fontsize: 14.sp,
                                          ),
                                          SizedBox(
                                            height: 16.h,
                                          ),
                                          Container(
                                            constraints:
                                                BoxConstraints(minWidth: 200.w),
                                            height: 46.h,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .shadowColor,
                                                  blurRadius: 5,
                                                  spreadRadius: 2,
                                                  offset: Offset(0, 3),
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              color: Colors.white,
                                            ),
                                            child: Row(
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
                                                    PoppinsMedium(
                                                      text: fileName,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .color,
                                                      fontsize: 12.sp,
                                                    ),
                                                    PoppinsRegular(
                                                      text: fileSize,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium!
                                                          .color,
                                                      fontsize: 12.sp,
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 10.0,
                                              mainAxisSpacing: 10.0,
                                            ),
                                            itemCount:
                                                postOrderOtherData.length > 3
                                                    ? 3
                                                    : postOrderOtherData.length,
                                            itemBuilder: (context, index) {
                                              String url =
                                                  postOrderOtherData[index];
                                              if (url.contains('.pdf')) {
                                                return FutureBuilder<
                                                    Map<String, dynamic>>(
                                                  future:
                                                      _fetchFileMetadata(url),
                                                  builder: (context, snapshot) {
                                                    String otherFileName =
                                                        'Loading...';
                                                    String otherFileSize =
                                                        'Loading...';

                                                    if (snapshot.connectionState ==
                                                            ConnectionState
                                                                .done &&
                                                        snapshot.hasData) {
                                                      otherFileName = snapshot
                                                          .data!['name'];
                                                      otherFileSize = snapshot
                                                          .data!['size'];
                                                    }

                                                    return Container(
                                                      width: 200.w,
                                                      height: 46.h,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Theme.of(
                                                                    context)
                                                                .shadowColor,
                                                            blurRadius: 5,
                                                            spreadRadius: 2,
                                                            offset: Offset(0, 3),
                                                          )
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.r),
                                                        color: Theme.of(context)
                                                            .cardColor,
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    6.w),
                                                        child: SvgPicture
                                                            .asset(
                                                          'assets/images/pdf.svg',
                                                          width: 32.sp,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                return SizedBox(
                                                  height: 20.h,
                                                  width: 20.w,
                                                  child: Image.network(url),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ],
                      );
                    },
                    childCount: sortedDates.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
