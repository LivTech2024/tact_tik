import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/assets/view_assets_screen.dart';
import 'package:tact_tik/screens/feature%20screens/keys/view_keys_screen.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class KeysScreen extends StatefulWidget {
  final String keyId;
  const KeysScreen({super.key, required this.keyId});

  @override
  State<KeysScreen> createState() => _KeysScreenState();
}

class _KeysScreenState extends State<KeysScreen> {
  late Stream<QuerySnapshot> _keyAllocationStream;

  Map<DateTime, List<QueryDocumentSnapshot>> groupDocumentsByDate(
      List<QueryDocumentSnapshot>? documents) {
    documents?.sort((a, b) {
      final timestampA = a['KeyAllocationDate'] as Timestamp;
      final timestampB = b['KeyAllocationDate'] as Timestamp;
      return timestampB.compareTo(timestampA);
    });

    final Map<DateTime, List<QueryDocumentSnapshot>> documentsByDate = {};

    if (documents != null) {
      for (final document in documents) {
        final allocationDate =
            (document['KeyAllocationDate'] as Timestamp).toDate();
        final date = DateTime(
            allocationDate.year, allocationDate.month, allocationDate.day);

        documentsByDate.putIfAbsent(date, () => []).add(document);
      }
    }

    return documentsByDate;
  }

  @override
  void initState() {
    super.initState();
    _keyAllocationStream = FirebaseFirestore.instance
        .collection('KeyAllocations')
        .where('KeyAllocationKeyId', isEqualTo: widget.keyId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
              elevation: 5,
              shadowColor: isDark ? DarkColor.color1 : LightColor.color3.withOpacity(.1),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? DarkColor.color1 : LightColor.color3,
                  size: width / width24,
                ),
                padding: EdgeInsets.only(left: width / width20),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigator debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterRegular(
                text: 'Keys',
                fontsize: width / width18,
                color: isDark ? DarkColor.color1 : LightColor.color3,
                letterSpacing: -0.3,
              ),
              centerTitle: true,
              floating: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height / height30,
                    ),
                    InterBold(
                      text: 'Today',
                      fontsize: width / width20,
                      color: DarkColor. Primarycolor,
                    ),
                    SizedBox(
                      height: height / height30,
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / width30),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewKeysScreen(startDate: "", endDate: "", keyId: widget.keyId,time: "",keyAllocationId: "",)));
                      },
                      child: Container(
                        height: width / width60,
                        padding:
                        EdgeInsets.symmetric(horizontal: width / width10),
                        width: double.maxFinite,
                        margin: EdgeInsets.only(bottom: height / height10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width / width10),
                          color: DarkColor.WidgetColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: height / height44,
                                  width: width / width44,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(width / width10),
                                    color: DarkColor. Primarycolorlight,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.home_repair_service,
                                      color: DarkColor. Primarycolor,
                                      size: width / width24,
                                    ),
                                  ),
                                ),
                                SizedBox(width: width / width20),
                                InterMedium(
                                  text: 'Equipment Title',
                                  fontsize: width / width16,
                                  color: DarkColor. color1,
                                ),
                              ],
                            ),
                            InterMedium(
                              text: '11 : 36 pm',
                              color: DarkColor.color17,
                              fontsize: width / width16,
                            ),
                            // SizedBox(width: width / width10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
