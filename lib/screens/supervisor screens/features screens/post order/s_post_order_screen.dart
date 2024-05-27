import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/post%20order/create_post_order.dart';
// import 'package:workmanager/workmanager.dart';

import '../../../../common/sizes.dart';
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

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
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
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Post Orders',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
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

            Map<String, List<Map<String, dynamic>>> locationData = snapshot.data!;

            List<String> sortedDates = locationData.keys.toList()..sort((a, b) => b.compareTo(a));

            return CustomScrollView(
              slivers: [
                SliverAppBar(
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
                      print("Navigator debug: ${Navigator.of(context).toString()}");
                    },
                  ),
                  title: InterRegular(
                    text: 'Post Order',
                    fontsize: width / width18,
                    color: Colors.white,
                    letterSpacing: -.3,
                  ),
                  centerTitle: true,
                  floating: true,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      String date = sortedDates[index];
                      List<Map<String, dynamic>> posts = locationData[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width / width30, vertical: height / height40),
                            child: InterSemibold(
                              text: date,
                              fontsize: width / width20,
                              color: Primarycolor,
                            ),
                          ),
                          ...posts.map((postOrder) {
                            String postOrderTitle = postOrder['PostOrderTitle'];
                            String postOrderPdf = postOrder['PostOrderPdf'];
                            List<dynamic> postOrderOtherData = postOrder['PostOrderOtherData'] ?? [];

                            return FutureBuilder<Map<String, dynamic>>(
                              future: _fetchFileMetadata(postOrderPdf),
                              builder: (context, snapshot) {
                                String fileName = 'Loading...';
                                String fileSize = 'Loading...';

                                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
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
                                    padding: EdgeInsets.symmetric(horizontal: width / width30),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        minHeight: height / height250,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width / width20,
                                        vertical: height / height10,
                                      ),
                                      width: double.maxFinite,
                                      margin: EdgeInsets.only(bottom: height / height10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(width / width10),
                                        color: WidgetColor,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          InterBold(
                                            text: postOrderTitle,
                                            color: color2,
                                            fontsize: width / width14,
                                          ),
                                          SizedBox(
                                            height: height / height16,
                                          ),
                                          Container(
                                            width: width / width200,
                                            height: height / height46,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(width / width10),
                                              color: color1,
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
                                                      text: fileName,
                                                      color: color15,
                                                    ),
                                                    PoppinsRegular(
                                                      text: fileSize,
                                                      color: color16,
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: height / height20,
                                          ),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 10.0,
                                              mainAxisSpacing: 10.0,
                                            ),
                                            itemCount: postOrderOtherData.length,
                                            itemBuilder: (context, index) {
                                              String url = postOrderOtherData[index];
                                              if (url.contains('.pdf')) {
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
                                                        color: color1,
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
                                                                color: color15,
                                                              ),
                                                              PoppinsRegular(
                                                                text: otherFileSize,
                                                                color: color16,
                                                              )
                                                            ],
                                                          )
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
