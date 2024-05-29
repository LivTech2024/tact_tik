import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'controller/map_screen_controller.dart';

class MapScreen extends StatelessWidget {
  final Function(File) onDone;
  const MapScreen({Key? key, required this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MapScreenController());
    return PopScope(
        canPop: true,
        child: Scaffold(
          body: Stack(
            children: [
              MapWidget(
                key: const ValueKey("mapWidget"),
                onMapCreated: controller.onMapCreated,
                onStyleLoadedListener: controller.onStyleLoadedCallback,
                // onMapIdleListener: controller.onMapIdle,
              ),
              Obx(() {
                return controller.isMapLoading.value
                    ? Center(
                        child: SizedBox(
                            height: 70,
                            child: Lottie.asset(
                                'assets/images/location_loader.json')),
                      )
                    : const SizedBox.shrink();
              }),
            ],
          ),
          floatingActionButton: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 30),
            child: FloatingActionButton.extended(
              onPressed: () async {
                try {
                  await controller.takeSnapshot();
                  onDone(controller.finalFile!);
                  Get.back();
                } catch (e) {
                  print('Error: $e');
                }
              },
              backgroundColor: const Color(0xffCBA769),
              label: Obx(() => !controller.snapshotting.value
                  ? Text(
                      'Done',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    )
                  : const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )),
            ),
          ),
        ));
  }
}
