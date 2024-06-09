import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/TrackingScreen/widgets/custom_bottom_sheet_widget.dart';
import 'package:tact_tik/screens/supervisor%20screens/TrackingScreen/widgets/filter_all_widget.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import 'controller/s_tracking_screen_controller.dart';

class SupervisorTrackingScreen extends StatelessWidget {
  final List<DocumentSnapshot<Object?>> guardsInfo;
  final String companyId;
  const SupervisorTrackingScreen(
      {super.key, required this.companyId, required this.guardsInfo});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final controller = Get.put(SupervisorTrackingScreenController(guardsInfo));
    return Scaffold(
      
      appBar: AppBar(
       
        leading: IconButton(
          icon:  Icon(
            Icons.arrow_back_ios,
          
          ),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: isDark? Color(0xff252525):LightColor.AppBarcolor,
        centerTitle: true,
        title: InterMedium(
          text: 'Live Tracking',
        
        ),
      ),
      body: Stack(
        children: [
          /// -- map area
          MapWidget(
            key: const ValueKey("mapWidget"),
            onMapCreated: controller.onMapCreated,
          ),

          Positioned(
              top: kToolbarHeight,
              right: 5,
              child:
                  FilterAllWidget()), // Filter widget placed directly in the stack

          /// -- bottom sheet
          Obx(() {
            return CustomBottomSheetWidget(
              shiftDetailsList: controller.employeeShiftDetailsList,
              isLoading: controller.isLoading.value,
            );
          }),
        ],
      ),
    );
  }
}
