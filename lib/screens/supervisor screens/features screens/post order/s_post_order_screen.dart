import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/post%20order/create_post_order.dart';
// import 'package:workmanager/workmanager.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import '../../../feature screens/post_order.dart/view_post_order.dart';

class SPostOrder extends StatefulWidget {
  final String locationId;
  const SPostOrder({super.key, required this.locationId});

  @override
  State<SPostOrder> createState() => _SPostOrderState();
}

class _SPostOrderState extends State<SPostOrder> {
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
    return SafeArea(
      child: Scaffold(
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
            print('LocationData ${locationData}');
            List<String> sortedDates = locationData.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                    ),
                    padding: EdgeInsets.only(left: 20.w),
                    onPressed: () {
                      Navigator.pop(context);
                      print(
                          "Navigator debug: ${Navigator.of(context).toString()}");
                    },
                  ),
                  title: InterMedium(
                    text: 'Post Orders',
                  ),
                  centerTitle: true,
                  floating: true,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      String date = sortedDates[index];
                      List<Map<String, dynamic>> posts = locationData[date]!;
                      // String locationID = locationData[index]['LocationId'];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w, vertical: 30.h),
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
                            String locationId = postOrder['LocationId'] ??
                                'Unknown Location ID';
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
                                        builder: (context) => CreateSPostOrder(
                                          isDisplay: false,
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
                                                  blurRadius: 10.r,
                                                  offset: Offset(0, 5),
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.w),
                                                  child: SvgPicture.asset(
                                                      'assets/images/pdf.svg',
                                                      width: 32.w),
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
                                                          .titleMedium!
                                                          .color,
                                                      fontsize: 14.sp,
                                                    ),
                                                    PoppinsRegular(
                                                      text: fileSize,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .color,
                                                      fontsize: 14.sp,
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
                                                postOrderOtherData.length < 3
                                                    ? postOrderOtherData.length
                                                    : 3,
                                            itemBuilder: (context, index) {
                                              String url =
                                                  postOrderOtherData[index];
                                              /*if (url.contains('.pdf')) {
                                                return FutureBuilder<Map<String, dynamic>>(
                                                  future: _fetchFileMetadata(url),
                                                  builder: (context, snapshot) {
                                                    String otherFileName = 'Loading...';
                                                    String otherFileSize = 'Loading...';

                                                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                                      otherFileName = snapshot.data!['name'];
                                                      otherFileSize = snapshot.data!['size'];
                                                    }

                                                    return Container(
                                                      width: width / width200,
                                                      height: height / height46,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(width / width10),
                                                        color: DarkColor. color1,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: width / width6),
                                                            child: SvgPicture.asset(
                                                                'assets/images/pdf.svg',
                                                                width: width / width32),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              PoppinsMedium(
                                                                text: otherFileName,
                                                                color: DarkColor
                                                                    . color15,
                                                              ),
                                                              PoppinsRegular(
                                                                text: otherFileSize,
                                                                color: DarkColor
                                                                    .color16,
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {*/
                                              return SizedBox(
                                                height: 20.h,
                                                width: 20.w,
                                                child: Image.network(url),
                                              );
                                              // }
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
