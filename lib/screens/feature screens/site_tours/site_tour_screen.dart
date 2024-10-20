import 'package:bounce/bounce.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/site_tours/controller/site_tour_controller.dart';
import 'package:tact_tik/screens/feature%20screens/site_tours/widgets/site_tour_loading_widget.dart';
import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/poppins_bold.dart';
import '../../../fonts/roboto_bold.dart';
import '../../../fonts/roboto_medium.dart';
import '../../../utils/colors.dart';
import '../../../utils/utils.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class SiteTourScreen extends StatelessWidget {
  final List<DocumentSnapshot> schedulesList;

  SiteTourScreen({
    required this.schedulesList,
  });

  final LatLng _center = LatLng(37.7749, -122.4194);

  // Example coordinates
  final double _zoom = 12.0;

  late final GoogleMapController mapController;

  // GoogleMap(
  //                   initialCameraPosition: CameraPosition(
  //                     target: LatLng(controller.currentLocation!.latitude,
  //                         controller.currentLocation!.longitude),
  //                     zoom: _zoom,
  //                   ),
  //                   onMapCreated: (GoogleMapController controller) {
  //                     mapController = controller;
  //                   },
  //                   markers: controller.markers,
  //                   polylines: controller.polylines.values.toSet(),
  //                 ),
  void _updateMapLocation(int index) {
    GeoPoint geoPoint = schedulesList[index]['ShiftLocation'];
    mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(geoPoint.latitude, geoPoint.longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SiteTourScreenController(schedulesList));
    return Obx(
      () => controller.isLoading.value

          /// loading widget
          ? SiteTourLoadingWidget()
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 470.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.r),
                        color: Theme.of(context).canvasColor),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              40.r,
                            ),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  controller.currentLocation!.latitude,
                                  controller.currentLocation!.longitude,
                                ),
                                zoom: _zoom,
                              ),
                              onMapCreated: (GoogleMapController controller) {
                                mapController = controller;
                              },
                              markers: controller.markers,
                              polylines: controller.polylines.values.toSet(),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: IgnorePointer(
                            ignoring: true,
                            child: Container(
                              height: 470.h,
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0, -1.5),
                                  end: Alignment.bottomCenter,
                                  colors: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? [Colors.black, Colors.transparent]
                                      : [Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 40.h,
                            margin: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 25.w,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 60.h,
                                  width: 60.w,
                                  child: Image.asset(
                                    'assets/images/site_tour.png',
                                    fit: BoxFit.fitWidth,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                                InterBold(
                                  text: 'Site Tours',
                                  fontsize: 18.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    size: 30.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                  padding: EdgeInsets.zero,
                                )
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: 180.h,
                            child: PageView.builder(
                              controller: controller.pageController,
                              onPageChanged: (index) {
                                controller.onPageChanged(index, mapController);
                              },
                              clipBehavior: Clip.antiAlias,
                              scrollDirection: Axis.horizontal,
                              itemCount: schedulesList.length,
                              itemBuilder: (context, index) {
                                var schedule = schedulesList[
                                    controller.currentIndex.value];

                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: 24.h,
                                    left: 40.w,
                                    right: 30.w,
                                  ),
                                  width: 300.w,
                                  height: 160.h,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 14.h,
                                    horizontal: 15.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.circular(
                                      20.r,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        height: 55.h,
                                        child: Row(
                                          children: [
                                            // Container(
                                            //   decoration: BoxDecoration(
                                            //     borderRadius:
                                            //         BorderRadius.circular(
                                            //       12.r,
                                            //     ),
                                            //     color: Theme.of(context).textTheme.bodyMedium!.color,
                                            //   ),
                                            //   height: 55.h,
                                            //   width: 55.w,
                                            //   child: Center(
                                            //     child: Container(
                                            //       alignment: Alignment.center,
                                            //       height: 40.h,
                                            //       width: 45.w,
                                            //       decoration: BoxDecoration(
                                            //         borderRadius:
                                            //             BorderRadius.circular(
                                            //                 4.r),
                                            //         color: Theme.of(context).textTheme.bodyMedium!.color,
                                            //         border: Border.all(
                                            //           color: Theme.of(context).textTheme.bodySmall!.color as Color,
                                            //           width: 1,
                                            //         ),
                                            //       ),
                                            //       child: MyNetworkImage(
                                            //         'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                            SizedBox(
                                              width: 15.w,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                PoppinsBold(
                                                  text: schedule['ShiftName'] ??
                                                      'No Name',
                                                  // Example name, replace with your data

                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color,
                                                  fontsize: 16.sp,
                                                ),
                                                SizedBox(
                                                  width: 180.w,
                                                  child: RobotoMedium(
                                                    text: schedule[
                                                            'ShiftLocationAddress'] ??
                                                        'No Address',
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .color,
                                                    fontsize: 16.sp,
                                                    maxLines: 1,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          GeoPoint geoPoint =
                                              schedule['ShiftLocation'];
                                          var location =
                                              '${geoPoint.latitude},${geoPoint.longitude}';
                                          if (Platform.isIOS) {
                                            controller.launchUrlToOpenGoogleMap(
                                                Uri.parse(
                                                    'http://maps.apple.com/?q=$location'));
                                          } else {
                                            controller.launchUrlToOpenGoogleMap(
                                                Uri.parse(
                                                    'https://maps.google.com/?q=$location'));
                                          }
                                        },
                                        child: Container(
                                          height: 55.h,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              16.r,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              RobotoBold(
                                                text: 'Get Direction',
                                                color: Colors.white,
                                                fontsize: 16.sp,
                                              ),
                                              Icon(
                                                Icons.arrow_forward_sharp,
                                                color: Colors.white,
                                                size: 24.sp,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      bottom: 20.h,
                      left: 20.w,
                      right: 20.w,
                    ),
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        16.r,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            int newIndex = (controller.currentIndex.value - 1) %
                                schedulesList.length;

                            controller.pageController.jumpToPage(newIndex);
                            controller.onPageChanged(newIndex, mapController);
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_left,
                            size: 24.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                        Bounce(
                          onTap: () {
                            controller.onPageChanged(
                                controller.currentIndex.value, mapController);
                          },
                          child: InterBold(
                            text: 'Go to shift',
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: 18.sp,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            int newIndex = (controller.currentIndex.value + 1) %
                                schedulesList.length;
                            controller.pageController.jumpToPage(newIndex);
                            controller.onPageChanged(newIndex, mapController);
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_right,
                            size: 24.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
