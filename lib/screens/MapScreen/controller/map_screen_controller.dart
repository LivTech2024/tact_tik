import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import '../../../services/EmailService/EmailJs_fucntion.dart';

class MapScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static MapScreenController get instance => Get.find();

  /// variables
  MapboxMap? mapboxMapController;
  RxBool isServiceRunning = false.obs;
  PointAnnotation? pointAnnotation;
  PointAnnotationManager? pointAnnotationManager;
  Timer? locationTimer;
  Animation<double>? animation;
  AnimationController? controller;
  Image? snapshotImage;
  Snapshotter? _snapshotter;
  RxBool snapshotting = false.obs;
  Uint8List? resizedImageBytes;
  Uint8List? startMarker;
  RxBool isMapLoading = true.obs;
  List<Position> currentPolyline = [];
  File? finalFile;

  @override
  void onInit() {
    _requestPermissions();
    super.onInit();
  }

  @override
  void onClose() {
    controller?.dispose();
    super.onClose();
  }

  void _requestPermissions() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      var statusAlways = await Permission.locationAlways.request();
      if (statusAlways.isGranted) {
      } else {}
    } else if (status.isDenied) {
    } else if (status.isPermanentlyDenied) {}
  }

  void createOneAnnotation(Uint8List list, Position position) {
    pointAnnotationManager
        ?.create(PointAnnotationOptions(
            geometry: Point(coordinates: position),
            textOffset: [0.0, -2.0],
            textColor: Colors.red.value,
            iconSize: 2,
            textSize: 16.0,
            iconOffset: [0.0, -5.0],
            symbolSortKey: 10,
            image: list))
        .then((value) => pointAnnotation = value);
  }

  onMapCreated(MapboxMap mapboxMap) async {
    mapboxMapController = mapboxMap;

    // Initialize the Snapshotter
    final screenSize = MediaQuery.of(Get.context!).size;
    _snapshotter = await Snapshotter.create(
      options: MapSnapshotOptions(
          size: Size(width: screenSize.width, height: screenSize.height),
          pixelRatio: Get.context!.devicePixelRatio),
    );
    await _snapshotter?.style.setStyleURI(MapboxStyles.MAPBOX_STREETS);

    // initialize the point annotation manager
    mapboxMap.annotations.createPointAnnotationManager().then((value) async {
      pointAnnotationManager = value;
      resizedImageBytes = await resizeImage('assets/images/guard.png');
      startMarker = await resizeImage('assets/images/start_marker.png');
    });
  }

  onStyleLoadedCallback(StyleLoadedEventData data) async {
    print('onStyleLoadedCallback');
    await fetchLocationsFromFirestore();
  }

  Future<void> fetchLocationsFromFirestore() async {
    print('fetchLocationsFromFirestore===>');
    try {
      var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
      if (userInfo != null) {
        String employeeId = userInfo['EmployeeId'];

        QuerySnapshot routeSnapshot = await FirebaseFirestore.instance
            .collection('EmployeeRoutes')
            .where('EmpRouteEmpId', isEqualTo: employeeId)
            .where('EmpRouteShiftStatus', isEqualTo: 'started')
            .get();

        if (routeSnapshot.docs.isNotEmpty) {
          // Assuming you only get one active route document per employee
          DocumentReference routeDocRef = routeSnapshot.docs.first.reference;
          Map<String, dynamic> routeData =
              routeSnapshot.docs.first.data() as Map<String, dynamic>;

          // Check if EmpRouteLocations exists
          if (routeData.containsKey('EmpRouteLocations') &&
              routeData['EmpRouteLocations'] != null) {
            final locations = routeData['EmpRouteLocations'] as List<dynamic>;
            List<Position> polyline = locations.map((loc) {
              final locMap = loc as Map<String, dynamic>;
              final geoPoint = locMap['LocationCoordinates'] as GeoPoint;
              return Position(
                geoPoint.longitude,
                geoPoint.latitude,
              );
            }).toList();

            final lastLocation = locations.last as Map<String, dynamic>;
            final firstLocation = locations.first as Map<String, dynamic>;
            final lastGeoPoint =
                lastLocation['LocationCoordinates'] as GeoPoint;
            final firstGeoPoint =
                firstLocation['LocationCoordinates'] as GeoPoint;
            currentPolyline = polyline;
            drawRouteLowLevel(polyline);
            if (mapboxMapController != null) {
              mapboxMapController?.setCamera(CameraOptions(
                  center: Point(
                      coordinates: Position(
                          lastGeoPoint.longitude, lastGeoPoint.latitude)),
                  zoom: 14,
                  pitch: 0));
              createOneAnnotation(resizedImageBytes!,
                  Position(lastGeoPoint.longitude, lastGeoPoint.latitude));
              createOneAnnotation(startMarker!,
                  Position(firstGeoPoint.longitude, firstGeoPoint.latitude));
            }
          } else {
            print('Mapbox controller is null');
          }
        }
      } else {
        print('No user info found');
      }
    } catch (e) {
      isMapLoading.value = false;
      print('Error fetching locations from Firestore: $e');
    } finally {
      isMapLoading.value = false;
    }
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

  drawRouteLowLevel(List<Position> polyline) async {
    if (mapboxMapController == null) return;
    final line = LineString(coordinates: polyline);
    mapboxMapController!.style.styleSourceExists("source").then((exists) async {
      if (exists) {
        // if source exists - just update it
        final source = await mapboxMapController!.style.getSource("source");
        (source as GeoJsonSource).updateGeoJSON(json.encode(line));
      } else {
        await mapboxMapController!.style.addSource(GeoJsonSource(
            id: "source", data: json.encode(line), lineMetrics: true));

        await mapboxMapController!.style.addLayer(LineLayer(
          id: 'layer',
          sourceId: 'source',
          lineCap: LineCap.ROUND,
          lineJoin: LineJoin.ROUND,
          lineColor: Colors.black.value, // Set the line color to black
          lineWidth: 5.0,
        ));
      }
      // query line layer
      final lineLayer =
          await mapboxMapController!.style.getLayer('layer') as LineLayer;

      // draw layer with gradient
      // mapboxMapController!.style.setStyleLayerProperty("layer", "line-gradient",
      //     '["interpolate",["linear"],["line-progress"],0.0,["rgb",255,0,0],0.4,["rgb",0,255,0],1.0,["rgb",0,0,255]]');

      controller?.stop();

      controller = AnimationController(
          duration: const Duration(seconds: 1), vsync: this);

      animation = Tween<double>(begin: 0, end: 1.0).animate(controller!)
        ..addListener(() async {
          lineLayer.lineTrimOffset = [animation?.value, 1.0];
          mapboxMapController!.style.updateLayer(lineLayer);
        });
      controller?.forward();
    });
  }

  Future<Uint8List> resizeImage(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    Uint8List imageBytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return imageBytes;
  }

  // Add the onMapIdle method to capture the snapshot when the map becomes idle
  onMapIdle(MapIdleEventData data) async {
    await takeSnapshot();
  }

  Future<void> takeSnapshot() async {
    if (snapshotting.value) {
      return;
    }
    snapshotting.value = true;

    if (mapboxMapController == null) {
      snapshotting.value = false;
      return;
    }

    // Set the camera options for the snapshotter
    final cameraOptions = await mapboxMapController!.getCameraState();
    _snapshotter?.setCamera(cameraOptions.toCameraOptions());

    // Apply the same style to the snapshotter
    final style = await mapboxMapController!.style.getStyleURI();
    await _snapshotter?.style.setStyleURI(style);

    // Add the polyline source and layer manually
    final line = LineString(coordinates: currentPolyline);
    await _snapshotter?.style.addSource(GeoJsonSource(
        id: "source", data: json.encode(line), lineMetrics: true));
    await _snapshotter?.style.addLayer(LineLayer(
      id: 'layer',
      sourceId: 'source',
      lineCap: LineCap.ROUND,
      lineJoin: LineJoin.ROUND,
      lineColor: Colors.black.value, // Set the line color to black
      lineWidth: 5.0,
    ));

    // Start the snapshot
    final snapshot = await _snapshotter?.start();

    if (snapshot != null) {
      // Manually draw the annotation on the snapshot image
      final annotatedSnapshot = await _drawAnnotationsOnSnapshot(snapshot);
      // snapshotImage = Image.memory(annotatedSnapshot);
      // Encode the annotated image back to Uint8List
      // final Uint8List finals =
      //     Uint8List.fromList(img.encodePng(img.decodeImage(snapshot)!));
      // Get the directory to save the file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/annotated_map.png';

      // Write the annotated image to a file
      final file = File(filePath);
      await file.writeAsBytes(annotatedSnapshot);

      finalFile = file;

      update(); // Update the UI
    }
    snapshotting.value = false;
  }

  Future<Uint8List> _drawAnnotationsOnSnapshot(Uint8List snapshot) async {
    // Decode the snapshot image
    final img.Image originalImage = img.decodeImage(snapshot)!;

    // Draw the annotation
    if (pointAnnotation != null) {
      // Load and resize the annotation image
      final annotationImage =
          img.decodeImage(await resizeImage('assets/images/guard.png'))!;

      // Resize the annotation image to increase its size
      final resizedAnnotationImage =
          img.copyResize(annotationImage, width: 40, height: 100);

      // Calculate the position to place the annotation
      final x = (originalImage.width / 2) - (resizedAnnotationImage.width / 2);
      final y =
          (originalImage.height / 2) - (resizedAnnotationImage.height / 2);

      // Composite the resized annotation image onto the original snapshot
      img.compositeImage(originalImage, resizedAnnotationImage,
          dstX: x.toInt(), dstY: y.toInt());
    }

    // Encode the annotated image back to Uint8List
    final Uint8List annotatedSnapshot =
        Uint8List.fromList(img.encodePng(originalImage));
    return annotatedSnapshot;
  }
}
