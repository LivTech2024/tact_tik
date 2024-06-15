import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:filter_list/filter_list.dart';
import 'package:tact_tik/fonts/inter_medium.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../utils/colors.dart';

class SelectLocationShift {
  static Future<void> showLocationDialog(BuildContext context, String companyId, Function(List<dynamic>) onLocationSelected) async {
    List<QueryDocumentSnapshot> locationDocs = [];
    List<QueryDocumentSnapshot> filteredLocationDocs = [];

    void _openFilterDialog() async {
      await FilterListDialog.display<String>(
        context,
        hideSelectedTextCount: true,
        headlineText: 'Select Location',
        height: 500.h,
        listData: filteredLocationDocs.map((doc) => doc['LocationName'] as String).toList(),
        selectedListData: [],
        choiceChipLabel: (item) => item,
        validateSelectedItem: (list, val) => list!.contains(val),
        controlButtons: [ControlButtonType.All, ControlButtonType.Reset],
        onItemSearch: (item, query) {
          return item.toLowerCase().contains(query.toLowerCase());
        },
        onApplyButtonClick: (list) {
          if (list == null || list.isEmpty) {
            onLocationSelected([]);
          } else {
            onLocationSelected(list.map((selectedLocation) {
              return locationDocs.firstWhere((doc) => doc['LocationName'] == selectedLocation)['LocationAddress'];
            }).toList());
          }
          Navigator.pop(context);
        },
        onCloseWidgetPress: () {
          Navigator.pop(context, null);
        },
        choiceChipBuilder: (context, item, isSelected) {
          return Container(
            constraints: BoxConstraints(minWidth: 10.w),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected! ? Colors.blue[300]! : Colors.grey[300]!,
                )),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: isSelected ? Colors.blue[300] : Colors.grey[500],
                  size: 24.sp,
                ),
                SizedBox(width: 10.w),
                InterMedium(
                  text: item,
                  color: isSelected ? Colors.blue[300] : Colors.grey[500],
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> fetchLocations() async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Locations')
          .where('LocationCompanyId', isEqualTo: companyId)
          .get();

      locationDocs = querySnapshot.docs;
      filteredLocationDocs = locationDocs;

      _openFilterDialog();
    }

    await fetchLocations();
  }
}