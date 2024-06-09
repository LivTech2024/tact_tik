import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/keys/view_keys_screen.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import '../../supervisor screens/features screens/key management/s_key_manag_create_screen.dart';

class KeysScreen extends StatefulWidget {
  final String keyId;
  final String companyId;

  const KeysScreen({super.key, required this.keyId, required this.companyId});

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
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).canvasColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO Pass Values
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SCreateKeyManagScreen(
                    keyId: widget.keyId,
                    companyId: '',
                  ),
                ));
          },
          backgroundColor:
              Theme.of(context).primaryColor,
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
            size: 24.sp,
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
             
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                 
                ),
                padding: EdgeInsets.only(left: 20.w),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigator debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterMedium(
                text: 'Keys',
                
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
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: InterBold(
                              text: isToday
                                  ? 'Today'
                                  : DateFormat.yMMMd().format(date),
                              fontsize: 20.sp,
                              color: Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
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
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
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
                                    height: 60.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                    ),
                                    width: double.maxFinite,
                                    margin: EdgeInsets.only(
                                      bottom: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: Theme.of(context).cardColor,
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
                                              height: 44.h,
                                              width: 44.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                color: isDark
                                                    ? DarkColor
                                                        .Primarycolorlight
                                                    : LightColor
                                                        .Primarycolorlight,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.home_repair_service,
                                                  color: isDark
                                                      ? DarkColor.Primarycolor
                                                      : LightColor.Primarycolor,
                                                  size: 24.sp,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20.w),
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
                                                  fontsize: 16.sp,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        InterMedium(
                                          text: time,
                                          color: isDark
                                              ? DarkColor.color17
                                              : LightColor.color2,
                                          fontsize: 16.sp,
                                        ),
                                        SizedBox(width: 20.w),
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
