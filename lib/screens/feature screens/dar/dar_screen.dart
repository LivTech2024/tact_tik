import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';

class DarDisplayScreen extends StatelessWidget {
  DarDisplayScreen({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('DAR')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final documents = snapshot.data?.docs;
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
                      },
                    ),
                    title: InterRegular(
                      text: 'DAR',
                      fontsize: width / width18,
                      color: Colors.white,
                      letterSpacing: -.3,
                    ),
                    centerTitle: true,
                    floating: true,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: width / width20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (documents != null && index < documents.length) {
                            final document = documents[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: height / height20),
                                InterBold(
                                  text: document['title'],
                                  fontsize: width / width20,
                                  color: Primarycolor,
                                  letterSpacing: -.3,
                                ),
                                SizedBox(height: height / height30),
                                Container(
                                  width: double.maxFinite,
                                  height: height / height200,
                                  decoration: BoxDecoration(
                                    color: WidgetColor,
                                    borderRadius:
                                        BorderRadius.circular(width / width20),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width / width20,
                                    vertical: height / height10,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InterBold(
                                        text: document['userName'],
                                        fontsize: width / width18,
                                        color: Primarycolor,
                                      ),
                                      SizedBox(height: height / height10),
                                      Flexible(
                                        child: InterRegular(
                                          text: document['content'],
                                          fontsize: width / width16,
                                          color: color26,
                                          maxLines: 4,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {},
                                            padding: EdgeInsets.zero,
                                            icon: SvgPicture.asset(
                                              'assets/images/pdf.svg',
                                              height: height / height16,
                                              color: color2,
                                            ),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / width10),
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.image,
                                              size: width / width18,
                                              color: color2,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.video_collection,
                                              size: width / width18,
                                              color: color2,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: height / height10),
                              ],
                            );
                          }
                          return SizedBox.shrink();
                        },
                        childCount: documents?.length ?? 0,
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
