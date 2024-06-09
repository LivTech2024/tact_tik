import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';
import '../Models/shift_model.dart';
import '../controller/s_tracking_screen_controller.dart';

class CustomBottomSheetWidget extends StatelessWidget {
  const CustomBottomSheetWidget({
    super.key,
    required this.shiftDetailsList,
    required this.isLoading,
  });

  final List<ShiftDetails> shiftDetailsList;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final controller = SupervisorTrackingScreenController.instance;
    final DraggableScrollableController draggableScrollableController =
        DraggableScrollableController();
    return DraggableScrollableSheet(
      snap: true,
      controller: draggableScrollableController,
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color:  Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xff343434),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? ListView.separated(
                        shrinkWrap: true,
                        controller: scrollController,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[600]!,
                            highlightColor: Colors.grey[100]!,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 16.0,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            width: double.infinity,
                                            height: 14.0,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            color: Colors.white,
                                            width: double.infinity,
                                            height: 10.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(
                            thickness: 0.5,
                            color: Color(0xffD9D9D9),
                          );
                        },
                      )
                    : Obx(() {
                        final employeeList =
                            controller.filteredEmployeeShiftDetailsList.isEmpty
                                ? controller.employeeShiftDetailsList
                                : controller.filteredEmployeeShiftDetailsList;
                        return ListView.separated(
                          shrinkWrap: true,
                          controller: scrollController,
                          itemCount: employeeList.length,
                          itemBuilder: (context, index) {
                            final shiftDetails = employeeList[index];
                            bool isSelected = index == controller.selectedIndex;
                            return GestureDetector(
                              onTap: () async {
                                // Fetch the current route for the specific employee
                                final routeSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('EmployeeRoutes')
                                    .where('EmpRouteEmpId',
                                        isEqualTo: shiftDetails.id)
                                    .where('EmpRouteShiftStatus',
                                        isEqualTo: 'started')
                                    .get();

                                if (routeSnapshot.docs.isNotEmpty) {
                                  // Assuming there is only one active route document per employee
                                  final routeData =
                                      routeSnapshot.docs.first.data();

                                  if (routeData
                                      .containsKey('EmpRouteLocations')) {
                                    final locations =
                                        routeData['EmpRouteLocations']
                                            as List<dynamic>;
                                    List<Position> polyline =
                                        locations.map((loc) {
                                      final geoPoint =
                                          loc['LocationCoordinates']
                                              as GeoPoint;
                                      return Position(
                                        geoPoint.longitude,
                                        geoPoint.latitude,
                                      );
                                    }).toList();

                                    // Draw the polyline on the map
                                    if (shiftDetails.role != 'GUARD') {
                                      await controller.drawRouteLowLevel(
                                        polyline,
                                      );
                                    }
                                    controller.flyToLocation(polyline);
                                  }
                                }

                                // Move the DraggableScrollableSheet to its minimum position
                                draggableScrollableController.animateTo(
                                  0.2,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );

                                scrollController.jumpTo(0);

                                // Move the tapped card to the top of the list
                                controller.moveCardToTop(index);
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                clipBehavior: Clip.none,
                                color:isDark?( isSelected
                                    ? const Color(0xff252525)
                                    : Colors.black):(isSelected?Color(0xffeaeaea):LightColor.WidgetColor),
                                child: Padding(
                                  padding: isSelected
                                      ? const EdgeInsets.only(right: 10.0)
                                      : const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      isSelected
                                          ? Container(
                                              height: 100,
                                              width: 10,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                      isSelected
                                          ? const SizedBox(
                                              width: 10,
                                            )
                                          : const SizedBox.shrink(),
                                      Stack(
                                        children: [
                                          Center(
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  backgroundColor:isDark?
                                                      const Color(0xff252525):LightColor.color3,
                                                  radius: 32,
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          shiftDetails.imageUrl,
                                                      placeholder: (context,
                                                              url) =>
                                                          Shimmer.fromColors(
                                                        baseColor:
                                                            Colors.grey[600]!,
                                                        highlightColor:
                                                            Colors.grey[100]!,
                                                        child: Container(
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error,
                                                              color:
                                                                  Colors.white),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                )),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: CachedNetworkImage(
                                                  imageUrl: shiftDetails
                                                      .companyLogoUrl,
                                                  placeholder: (context, url) =>
                                                      Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[600]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  fit: BoxFit.cover,
                                                  width: 17,
                                                  height: 17,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  shiftDetails.name,
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 16,
                                                    color:isDark?
                                                        const Color(0xffD9D9D9):LightColor.color3,
                                                  ),
                                                ),
                                                Text(
                                                  ' | ',
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color:isDark?
                                                        const Color(0xffD9D9D9):LightColor.color3,
                                                    letterSpacing: -0.2,
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    shiftDetails.shiftName,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                      color:isDark? const Color(
                                                          0xffD9D9D9):LightColor.color3,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'In time',
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 16,
                                                        color: isDark?DarkColor.color1:LightColor.color3,
                                                      ),
                                                    ),
                                                    Text(
                                                      shiftDetails.inTime,
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                        color: isDark
                                                            ? DarkColor.color1
                                                            : LightColor.color3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Out time',
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 16,
                                                        color: isDark
                                                            ? DarkColor.color1
                                                            : LightColor.color3,
                                                      ),
                                                    ),
                                                    Text(
                                                      shiftDetails.outTime,
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                        color: isDark
                                                            ? DarkColor.color1
                                                            : LightColor.color3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return  Divider(
                              thickness: 0.5,
                              color: isDark ? DarkColor.color1 : LightColor.color3,
                            );
                          },
                        );
                      }),
              ),
            ],
          ),
        );
      },
    );
  }

  double _parseCoordinate(dynamic coordinate) {
    if (coordinate is int) {
      return coordinate.toDouble();
    } else if (coordinate is String) {
      return double.parse(coordinate);
    } else if (coordinate is double) {
      return coordinate;
    } else {
      throw Exception('Unsupported coordinate type');
    }
  }
}
