import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class SiteTourScreenController extends GetxController {
  final List<DocumentSnapshot> schedulesList;
  SiteTourScreenController(this.schedulesList);

  static SiteTourScreenController get instance => Get.find();

  Position? currentLocation;
  RxBool isLoading = true.obs;
  Set<Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void onInit() {
    super.onInit();
    _requestLocationPermission();
    _getCurrentLocation();
  }

  void _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      var statusAlways = await Permission.locationAlways.request();
      if (statusAlways.isGranted) {
      } else {
        // LocationAlways permission denied, navigate to the previous screen or open settings
        Get.snackbar('LocationAlways permission denied',
            'Please enable permission in settings.');
        Get.back();
        // openAppSettings();
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // LocationWhenInUse permission denied, navigate to the previous screen or open settings
      Get.snackbar('LocationWhenInUse permission denied',
          'Please enable LocationWhenInUse permission in settings.');
      Get.back();
      // openAppSettings();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return early.
      Get.snackbar('Location services are not enabled',
          'Please enable location permissions in settings.');
      Get.back();
    }
    // Check for location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, return early.
        Get.snackbar('Permissions are denied',
            'Please enable location permissions in settings.');
        Get.back();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Permissions are denied forever',
          'Please enable location permissions in settings.');
      Get.back();
    }
    currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);

    // Get the current location.
    if (currentLocation != null) {
      /// adding markers to the shift locations
      await _addShiftMarkers();

      /// adding marker to current location
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position:
              LatLng(currentLocation!.latitude, currentLocation!.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: await _addMarkerToCurrentLocation(),
        ),
      );
      if (schedulesList.isNotEmpty) {
        GeoPoint firstLocation = schedulesList.first['ShiftLocation'];
        LatLng firstPosition =
            LatLng(firstLocation.latitude, firstLocation.longitude);
        // await _getPolyline();
      }
      isLoading.value = false;
    }
  }

  void onPageChanged(int index, GoogleMapController mapController) {
    var schedule = schedulesList[index];
    GeoPoint geoPoint = schedule['ShiftLocation'];
    LatLng position = LatLng(geoPoint.latitude, geoPoint.longitude);

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 12.0,
        ),
      ),
    );
  }

  Future<BitmapDescriptor> _addMarkerToCurrentLocation() async {
    try {
      return BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 20, size: Size(20, 20)),
        'assets/images/guard.png',
      );
    } catch (e) {
      print('error: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<BitmapDescriptor> _addMarkerToShiftLocation() async {
    try {
      return BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 20, size: Size(20, 20)),
        'assets/images/guard.png',
      );
    } catch (e) {
      print('error: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<void> _addShiftMarkers() async {
    if (schedulesList.isEmpty) return;
    for (var schedule in schedulesList) {
      GeoPoint geoPoint = schedule['ShiftLocation'];
      LatLng position = LatLng(geoPoint.latitude, geoPoint.longitude);

      BitmapDescriptor customMarker = await _addMarkerToShiftLocation();
      markers.add(
        Marker(
          markerId: MarkerId(schedule.id),
          position: position,
          infoWindow: InfoWindow(title: schedule['ShiftName']),
          icon: customMarker,
        ),
      );
    }
  }

  // Future<void> _getPolyline() async {
  //   List<LatLng> polylineCoordinates = [];
  //
  //   if (schedulesList.isNotEmpty) {
  //     GeoPoint firstLocation = schedulesList.first['ShiftLocation'];
  //     // LatLng firstPosition = LatLng(firstLocation.latitude, firstLocation.longitude);
  //
  //     final result = await polylinePoints.getRouteBetweenCoordinates(
  //       "AIzaSyDd_MBd7IV8MRQKpyrhW9O1BGLlp-mlOSc", // Replace with your actual API key
  //       PointLatLng(currentLocation!.latitude, currentLocation!.longitude),
  //       PointLatLng(firstPosition.latitude, firstPosition.longitude),
  //       travelMode: TravelMode.driving,
  //     );
  //
  //     if (result.points.isNotEmpty) {
  //       result.points.forEach((PointLatLng point) {
  //         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //       });
  //     } else {
  //       print(result.errorMessage);
  //     }
  //     _addPolyLine(polylineCoordinates);
  //   }
  // }

  // void _addPolyLine(List<LatLng> polylineCoordinates) {
  //   PolylineId id = const PolylineId("poly");
  //   Polyline polyline = Polyline(
  //     polylineId: id,
  //     points: polylineCoordinates,
  //     width: 8,
  //     color: Colors.red,
  //   );
  //   polylines[id] = polyline;
  // }
  Future<void> launchUrlToOpenGoogleMap(_url) async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
