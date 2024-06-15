import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/home%20screens/widgets/home_screen_part1.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SelectLocationDar extends StatefulWidget {
  final String companyId;
  final Function(String) onLocationSelected;

  SelectLocationDar(
      {super.key, required this.companyId, required this.onLocationSelected});

  @override
  State<SelectLocationDar> createState() => _SelectLocationDarState();
}

class _SelectLocationDarState extends State<SelectLocationDar> {
  get suggestionsCallback => null;

  List<QueryDocumentSnapshot> _locationDocs = [];
  List<QueryDocumentSnapshot> _filteredLocationDocs = [];

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    print('Company ID: ${widget.companyId}');

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Locations')
        .where('LocationCompanyId', isEqualTo: widget.companyId)
        .get();

    setState(() {
      _locationDocs = querySnapshot.docs;
      _filteredLocationDocs = _locationDocs;
    });

    print('Fetched Documents:');
    for (QueryDocumentSnapshot doc in _locationDocs) {
      print(doc.data());
    }
  }

  void filterLocations(String query) {
    List<QueryDocumentSnapshot> filteredDocs = _locationDocs.where((doc) {
      String locationName = doc['LocationName'].toLowerCase();
      return locationName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredLocationDocs = filteredDocs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

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
          title: const InterMedium(
            text: 'Locations',
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                SearchBar(
                  hintText: 'Search Location',
                  onChanged: (value) {
                    filterLocations(value);
                  },
                  // shape:WidgetStatePropertyAll(value),
                  backgroundColor:
                      WidgetStatePropertyAll(Theme.of(context).cardColor),

                  trailing: [
                    Container(
                      height: 43.h,
                      width: 43.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.search,
                          size: 19.sp,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.h),
                _filteredLocationDocs.isNotEmpty
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _filteredLocationDocs.length,
                        itemBuilder: (context, index) {
                          QueryDocumentSnapshot locationDoc =
                              _filteredLocationDocs[index];
                          String locationName = locationDoc['LocationName'];
                          String locationId = locationDoc.id;
                          String locationAddress =
                              locationDoc['LocationAddress'];
                          return GestureDetector(
                              onTap: () {
                                widget.onLocationSelected(locationAddress);
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12.h),
                                ),
                                height: 60.h,
                                margin: EdgeInsets.only(bottom: 10.h),
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 48.h,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                              ),
                                              SizedBox(width: 20.w),
                                              InterBold(
                                                text: locationName,
                                                letterSpacing: -.3,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                                fontsize: 12.sp,
                                              ),
                                            ],
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                        },
                      )
                    : Center(
                        child: PoppinsBold(
                          text: 'No Location Found',
                          color: DarkColor.color2,
                          fontsize: 16.sp,
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
