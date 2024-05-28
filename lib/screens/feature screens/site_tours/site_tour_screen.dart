import 'package:bounce/bounce.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
  final double height;
  final double width;
  final List<DocumentSnapshot> schedulesList;

  SiteTourScreen({
    required this.height,
    required this.width,
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
          ? SiteTourLoadingWidget(width: width, height: height)
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: width / width30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height / height470,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width / width40),
                      color: Secondarycolor,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(width / width40),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              width / width40,
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
                            child: Container(
                              height: height / height470,
                              width: double.maxFinite,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0, -1.5),
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.black, Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: height / height40,
                            margin: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: height / height25,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: height / height60,
                                  width: width / width60,
                                  child: Image.asset(
                                    'assets/images/site_tour.png',
                                    fit: BoxFit.fitWidth,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                                InterBold(
                                  text: 'Site Tours',
                                  fontsize: width / width18,
                                  color: Colors.white,
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    size: width / width30,
                                    color: color1,
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
                            height: height / height180,
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
                                      bottom: height / height24,
                                      left: width / width40,
                                      right: width / width30),
                                  width: width / width300,
                                  height: height / height160,
                                  padding: EdgeInsets.symmetric(
                                    vertical: height / height14,
                                    horizontal: width / width15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Secondarycolor,
                                    borderRadius: BorderRadius.circular(
                                      width / width20,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        height: height / height55,
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  width / width12,
                                                ),
                                                color: color9,
                                              ),
                                              height: height / height55,
                                              width: width / width55,
                                              child: Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: height / height40,
                                                  width: width / width45,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            width / width4),
                                                    color: color9,
                                                    border: Border.all(
                                                      color: Primarycolor,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: MyNetworkImage(
                                                    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
                                                    width / width40,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: width / width15,
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

                                                  color: Colors.white,
                                                  fontsize: width / width16,
                                                ),
                                                SizedBox(
                                                  width: width / width180,
                                                  child: RobotoMedium(
                                                    text: schedule[
                                                            'ShiftLocationAddress'] ??
                                                        'No Address',
                                                    color: color10,
                                                    fontsize: width / width16,
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
                                          height: height / height55,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: width / width16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Primarycolor,
                                            borderRadius: BorderRadius.circular(
                                              width / width16,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const RobotoBold(
                                                text: 'Get Direction',
                                                color: color1,
                                                fontsize: 16,
                                              ),
                                              Icon(
                                                Icons.arrow_forward_sharp,
                                                color: color1,
                                                size: width / width24,
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
                    height: height / height30,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      bottom: height / height20,
                      left: width / width20,
                      right: width / width20,
                    ),
                    height: height / height60,
                    decoration: BoxDecoration(
                      color: WidgetColor,
                      borderRadius: BorderRadius.circular(
                        width / width16,
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
                            size: width / width24,
                            color: color1,
                          ),
                        ),
                        Bounce(
                          onTap: () {
                            controller.onPageChanged(
                                controller.currentIndex.value, mapController);
                          },
                          child: InterBold(
                            text: 'Go to shift',
                            color: color1,
                            fontsize: width / width18,
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
                            size: width / width24,
                            color: color1,
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