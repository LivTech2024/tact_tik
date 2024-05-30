import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';

class ViewCheckpointScreen extends StatefulWidget {
  final String reportedAt;
  final String comment;
  final List<String> images;
  const ViewCheckpointScreen({super.key, required this.comment, required this.images, required this.reportedAt});

  @override
  State<ViewCheckpointScreen> createState() => _ViewCheckpointScreenState();
}

class _ViewCheckpointScreenState extends State<ViewCheckpointScreen> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height / height30),
                InterBold(
                  text: 'Details',
                  fontsize: width / width18,
                  color: color1,
                ),
                SizedBox(height: height / height20),
                InterMedium(
                  text: 'Time: ' + widget.reportedAt,
                  fontsize: width / width14,
                  color: color21,
                ),
                SizedBox(height: height / height50),
                InterBold(
                  text: 'Comments',
                  fontsize: width / width18,
                  color: color1,
                ),
                SizedBox(height: height / height10),
                InterMedium(
                  text: widget.comment,
                  fontsize: width / width14,
                  color: color21,
                  maxLines: 3,
                ),
                SizedBox(height: height / height50),
                InterBold(
                  text: 'Images',
                  fontsize: width / width18,
                  color: color1,
                ),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: width / width10,
                    mainAxisSpacing: height / height10,
                    crossAxisCount: 3,
                  ),
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    final imageUrl = widget.images[index];
                    return Container(
                      height: height / height66,
                      width: width / width66,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(width / width10),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: height / height50),
                InterBold(
                  text: 'Reports',
                  fontsize: width / width18,
                  color: color1,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: height / height30),
                      height: height / height25,
                      color: WidgetColor,
                      child: Row(
                        children: [
                          Container(
                            width: width / width20,
                            height: double.infinity,
                            color: Colors.red,
                          ),
                          SizedBox(width: width / width2),
                          SizedBox(
                            width: width / width230,
                            child: InterMedium(
                              text: '#334AH6 Qr Missing',
                              color: color6,
                              fontsize: width / width16,
                            ),
                          ),
                          SizedBox(width: width / width2),
                          InterBold(text: '11.36pm' , color: color6,fontsize: width / width16,)
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
