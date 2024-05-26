import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class SiteTourScreenController extends GetxController {
  final List<DocumentSnapshot> schedulesList;
  SiteTourScreenController(this.schedulesList);

  static SiteTourScreenController get instance => Get.find();

  Position? currentLocation;
  RxBool isLoading = true.obs;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

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
        openAppSettings();
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // LocationWhenInUse permission denied, navigate to the previous screen or open settings
      Get.snackbar('LocationWhenInUse permission denied',
          'Please enable LocationWhenInUse permission in settings.');
      Get.back();
      openAppSettings();
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
      await _addShiftMarkers();
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
        _addRoute();
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
        'assets/images/guard_current_marker.png',
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

  Future<void> _addRoute() async {
    if (schedulesList.isNotEmpty) {
      GeoPoint firstLocation = schedulesList.first['ShiftLocation'];
      LatLng firstPosition = LatLng(18.585337398793033, 73.98480327852225);

      final directions = await _fetchRoute(
        LatLng(currentLocation!.latitude, currentLocation!.longitude),
        firstPosition,
      );

      if (directions != null) {
        final List<LatLng> polylineCoordinates = [];
        for (var point in directions['routes'][0]['overview_polyline']
            ['points']) {
          polylineCoordinates.add(LatLng(point['lat'], point['lng']));
        }

        polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        );
      } else {
        Get.snackbar('Failed to fetch route', 'Failed to fetch route');
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchRoute(
      LatLng origin, LatLng destination) async {
    const String apiKey =
        'AIzaSyDd_MBd7IV8MRQKpyrhW9O1BGLlp-mlOSc'; // Replace with your API key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to fetch route: ${response.statusCode}');
      return null;
    }
  }
}
