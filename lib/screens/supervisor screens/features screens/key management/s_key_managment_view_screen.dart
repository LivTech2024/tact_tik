import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/key%20management/s_key_manag_create_screen.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import 's_key_manag_create_screen.dart';

class SKeyManagementViewScreen extends StatefulWidget {
  final String companyId;

  const SKeyManagementViewScreen({super.key, required this.companyId});

  @override
  _SKeyManagementViewScreenState createState() =>
      _SKeyManagementViewScreenState();
}

class _SKeyManagementViewScreenState extends State<SKeyManagementViewScreen> {
  Map<String, List<QueryDocumentSnapshot>> groupedKeys = {};

  @override
  void initState() {
    super.initState();
    fetchKeys();
  }

  Future<void> fetchKeys() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Keys')
        .where('KeyCompanyId', isEqualTo: widget.companyId)
        .get();

    groupKeysByDate(querySnapshot.docs);
  }

  void groupKeysByDate(List<QueryDocumentSnapshot> keys) {
    final Map<String, List<QueryDocumentSnapshot>> tempGroupedKeys = {};

    for (var key in keys) {
      final createdAt = key['KeyCreatedAt'].toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(createdAt);

      if (!tempGroupedKeys.containsKey(dateKey)) {
        tempGroupedKeys[dateKey] = [];
      }
      tempGroupedKeys[dateKey]!.add(key);
    }

    setState(() {
      groupedKeys = Map.fromEntries(
        tempGroupedKeys.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SCreateKeyManagScreen(keyId: '', companyId: widget.companyId,),
              ),
            );
          },
          backgroundColor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
            size: width / width24,
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              shadowColor: isDark ? Colors.transparent : LightColor.color3.withOpacity(.1),
              backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
              elevation: 5,
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
                      text: 'Keys',
                      fontsize: width / width20,
                      color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                    ),
                    SizedBox(
                      height: height / height30,
                    ),
                  ],
                ),
              ),
            ),
            ...groupedKeys.entries.map((entry) {
              final date = entry.key;
              final keysForDate = entry.value;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / width30,
                            vertical: height / height30),
                        child: InterBold(
                          text: getDateHeader(date),
                          fontsize: width / width20,
                          color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                        ),
                      );
                    }
                    final key = keysForDate[index - 1];
                    final createdAt = key['KeyCreatedAt'].toDate();
                    final formattedTime =
                    DateFormat('hh:mm a').format(createdAt);
                    final keyId = key.id; // Get the document ID

                    return Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: width / width30),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SCreateKeyManagScreen(
                                keyId: keyId,
                                companyId: widget.companyId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: width / width60,
                          width: double.maxFinite,
                          margin: EdgeInsets.only(bottom: height / height10),
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(width / width10),
                            color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width / width10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          width / width10),
                                      color: isDark
                                          ? DarkColor.Primarycolorlight
                                          : LightColor.Primarycolorlight,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.vpn_key,
                                        color: isDark
                                            ? DarkColor.Primarycolor
                                            : LightColor.Primarycolor,
                                        size: width / width24,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width / width20),
                                  InterMedium(
                                    text: key['KeyName'],
                                    fontsize: width / width16,
                                    color: isDark
                                        ? DarkColor.color1
                                        : LightColor.color3,
                                  ),
                                ],
                              ),
                              InterMedium(
                                text: formattedTime,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                                fontsize: width / width16,
                              ),
                              SizedBox(width: width / width20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: keysForDate.length + 1,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String getDateHeader(String date) {
    final today = DateTime.now().toUtc().toLocal();
    final dateTime = DateTime.parse(date);

    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      return 'Today';
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
    }
  }
}
