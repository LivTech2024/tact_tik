import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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

class SiteTourScreen extends StatelessWidget {
  final double height;
  final double width;
  final LatLng _center = LatLng(37.7749, -122.4194); // Example coordinates
  final double _zoom = 12.0;
  late final GoogleMapController mapController;
  final List<DocumentSnapshot> schedulesList;

  SiteTourScreen({
    required this.height,
    required this.width,
    required this.schedulesList,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SiteTourScreenController(schedulesList));
    return SafeArea(
      child: Obx(
        () => Scaffold(
          body: controller.isLoading.value

              /// loading widget
              ? const SiteTourLoadingWidget()
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(controller.currentLocation!.latitude,
                            controller.currentLocation!.longitude),
                        zoom: _zoom,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                      },
                      markers: controller.markers,
                      polylines: controller.polylines.values.toSet(),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: height / 5,
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: height / height25,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              height: height / height48,
                              width: width / width48,
                              child: Image.asset(
                                'assets/images/site_tour.png',
                                fit: BoxFit.cover,
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
                              icon: const Icon(
                                Icons.cancel_outlined,
                                size: 30,
                                color: Colors.white, // Assuming color1 is red
                              ),
                              padding: const EdgeInsets.only(right: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                            height: height / height180,
                            child: PageView.builder(
                                onPageChanged: (index) {
                                  controller.onPageChanged(
                                      index, mapController);
                                },
                                clipBehavior: Clip.antiAlias,
                                scrollDirection: Axis.horizontal,
                                itemCount: schedulesList.length,
                                itemBuilder: (context, index) {
                                  var schedule = schedulesList[index];

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
                                                  SizedBox(
                                                    width: width / width15,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      PoppinsBold(
                                                        text: schedule[
                                                                'ShiftName'] ??
                                                            'No Name', // Example name, replace with your data

                                                        color: Colors.white,
                                                        fontsize:
                                                            width / width16,
                                                      ),
                                                      SizedBox(
                                                        width: width / width180,
                                                        child: RobotoMedium(
                                                          text: schedule[
                                                                  'ShiftLocationAddress'] ??
                                                              'No Address',
                                                          color: color10,
                                                          fontsize:
                                                              width / width16,
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
                                                  controller
                                                      .launchUrlToOpenGoogleMap(
                                                          Uri.parse(
                                                              'http://maps.apple.com/?q=$location'));
                                                } else {
                                                  controller
                                                      .launchUrlToOpenGoogleMap(
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
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    width / width16,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
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
                                            )
                                          ]));
                                })))
                  ],
                ),
        ),
      ),
    );
  }
}
