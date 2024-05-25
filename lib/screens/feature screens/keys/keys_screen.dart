import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
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
        backgroundColor: Secondarycolor,
        body: CustomScrollView(
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
                text: 'Keys',
                fontsize: width / width18,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
              centerTitle: true,
              floating: true,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _keyAllocationStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final documents = snapshot.data?.docs;
                final groupedDocuments = groupDocumentsByDate(documents);

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dateKeys = groupedDocuments.keys.toList();
                      if (index >= dateKeys.length) {
                        return SizedBox.shrink();
                      }

                      final date = dateKeys[index];
                      final isToday = date.day == DateTime.now().day &&
                          date.month == DateTime.now().month &&
                          date.year == DateTime.now().year;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width / width30),
                            child: InterBold(
                              text: isToday
                                  ? 'Today'
                                  : DateFormat.yMMMd().format(date),
                              fontsize: width / width20,
                              color: Primarycolor,
                            ),
                          ),
                          SizedBox(
                            height: height / height30,
                          ),
                          ...groupedDocuments[date]!.map(
                            (doc) {
                              final allocationDate =
                                  (doc['KeyAllocationDate'] as Timestamp)
                                      .toDate();
                              final time =
                                  '${allocationDate.hour.toString().padLeft(2, '0')} : ${allocationDate.minute.toString().padLeft(2, '0')}';

                              final startDate =
                                  (doc['KeyAllocationStartTime'] as Timestamp)
                                      .toDate();
                              final endDate =
                                  (doc['KeyAllocationEndTime'] as Timestamp)
                                      .toDate();
                              final viewTime =
                                  (doc['KeyAllocationDate'] as Timestamp)
                                      .toDate();
                              final keyAllocationId = doc['KeyAllocationId'];

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / width30),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ViewKeysScreen(
                                                  startDate: DateFormat.yMd()
                                                      .format(startDate),
                                                  endDate: DateFormat.yMd()
                                                      .format(endDate),
                                                  keyAllocationId:
                                                      keyAllocationId,
                                                  time: DateFormat('hh:mm:ss a')
                                                      .format(viewTime),
                                                  keyId: widget.keyId,
                                                )));
                                  },
                                  child: Container(
                                    height: width / width60,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width / width10),
                                    width: double.maxFinite,
                                    margin: EdgeInsets.only(
                                        bottom: height / height10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          width / width10),
                                      color: WidgetColor,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: height / height44,
                                              width: width / width44,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        width / width10),
                                                color: Primarycolorlight,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.home_repair_service,
                                                  color: Primarycolor,
                                                  size: width / width24,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: width / width20),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('Keys')
                                                  .where('KeyId',
                                                      isEqualTo: widget.keyId)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                String keyName =
                                                    'Key Not Available';
                                                if (snapshot.hasData) {
                                                  final documents =
                                                      snapshot.data!.docs;
                                                  keyName = documents.isNotEmpty
                                                      ? (documents.first.data()
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              'KeyName'] ??
                                                          'Equipment Not Available'
                                                      : 'Equipment Not Available';
                                                }
                                                return InterMedium(
                                                  text: keyName,
                                                  fontsize: width / width16,
                                                  color: color1,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        InterMedium(
                                          text: time,
                                          color: color17,
                                          fontsize: width / width16,
                                        ),
                                        SizedBox(width: width / width20),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ],
                      );
                    },
                    childCount: groupedDocuments.keys.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
