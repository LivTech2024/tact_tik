import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../services/EmailService/EmailJs_fucntion.dart';
import '../Models/shift_model.dart';

class Company {
  final String companyId;
  final String companyLogo;
  final String companyName;
  bool selected;

  Company({
    required this.companyId,
    required this.companyLogo,
    required this.companyName,
    this.selected = false,
  });
}

class SupervisorTrackingScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final List<DocumentSnapshot<Object?>> guardsInfo;
  SupervisorTrackingScreenController(this.guardsInfo);

  static SupervisorTrackingScreenController get instance => Get.find();

  /// variables
  MapboxMap? mapboxMapController;
  PointAnnotationManager? pointAnnotationManager;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<ShiftDetails> employeeShiftDetailsList = <ShiftDetails>[].obs;
  RxList<ShiftDetails> filteredEmployeeShiftDetailsList = <ShiftDetails>[].obs;
  var isLoading = true.obs;
  List<PointAnnotation> currentAnnotations = [];
  Animation<double>? animation;
  AnimationController? controller;
  int count = 0;
  int? selectedIndex;
  String? selectedEmployeeId;
  RxList<Company> companies = <Company>[].obs;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    print('onInit called');
    super.onInit();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    fetchCompanies();
    // Start listening to location changes for all employees
    for (var guard in guardsInfo) {
      listenToEmployeeLocations(guard['EmployeeId']);
    }
  }

  @override
  void onClose() {
    print('onClose called');
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.onClose();
    Get.delete<SupervisorTrackingScreenController>();
    pointAnnotationManager?.deleteAll();
    employeeShiftDetailsList.clear();
    filteredEmployeeShiftDetailsList.clear();
    currentAnnotations.clear();
    mapboxMapController = null; // Set to null to avoid further usage
    companies.clear();
  }

  // Fetch companies from the Companies collection
  void fetchCompanies() async {
    print('fetchCompanies called');
    try {
      QuerySnapshot snapshot = await _firestore.collection('Companies').get();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        companies.add(Company(
          companyName: data['CompanyName'] ?? '',
          companyId: doc.id,
          companyLogo: data['CompanyLogo'] ?? '',
        ));
      }
      fetchActiveGuards(); // Fetch guards after fetching companies
    } catch (e) {
      print('Error fetching companies: $e');
    }
  }

  void filterEmployees() {
    filteredEmployeeShiftDetailsList.value =
        employeeShiftDetailsList.where((employee) {
      return companies.any((company) =>
          company.selected && company.companyId == employee.companyId);
    }).toList();
    print(filteredEmployeeShiftDetailsList);
  }

  // fetch active locations of guards
  void fetchActiveGuards() async {
    print('fetchActiveGuards called');
    try {
      Map<String, String> companyLogoCache = {};
      List<Future<void>> tasks = [];

      for (var guard in guardsInfo) {
        final employeeId = guard['EmployeeId'];
        print('Processing guard with EmployeeId: $employeeId');

        tasks.add(FirebaseFirestore.instance
            .collection('EmployeeRoutes')
            .where('EmpRouteEmpId', isEqualTo: employeeId)
            .where('EmpRouteShiftStatus', isEqualTo: 'started')
            .get()
            .then((routeSnapshot) async {
          if (routeSnapshot.docs.isNotEmpty) {
            // Process each active guard
            for (var doc in routeSnapshot.docs) {
              var routeData = doc.data() as Map<String, dynamic>;
              print('Active guard found: ${routeData['EmpRouteEmpId']}');
              String shiftStartTime =
                  routeData['EmployeeShiftStartTime'].toString() ?? '05:00';
              String startEndTime =
                  routeData['EmployeeShiftEndTime'].toString() ?? '17:00';
              String shiftName =
                  routeData['EmployeeShiftShiftName'].toString() ??
                      'Shift Name...';
              QuerySnapshot snapshot = await _firestore
                  .collection('Employees')
                  .where('EmployeeId', isEqualTo: routeData['EmpRouteEmpId'])
                  .get();
              for (var doc in snapshot.docs) {
                var data = doc.data() as Map<String, dynamic>;
                String companyId = data['EmployeeCompanyId'] ?? '';
                String EmployeeRole = data['EmployeeRole'] ?? 'GUARD';
                String companyLogoUrl = companyLogoCache[companyId] ??
                    (await _firestore
                        .collection('Companies')
                        .doc(companyId)
                        .get()
                        .then((companyDoc) {
                      return companyDoc.exists &&
                              companyDoc['CompanyLogo'] != null
                          ? companyDoc['CompanyLogo']
                          : 'https://w0.peakpx.com/wallpaper/30/235/HD-wallpaper-adidas-brand-logo-originals-sport-thumbnail.jpg';
                    }));

                companyLogoCache[companyId] = companyLogoUrl;

                employeeShiftDetailsList.add(ShiftDetails(
                  imageUrl: data['EmployeeImg'] ??
                      'https://img.freepik.com/free-psd/3d-illustration-human-avatar-profile_23-2150671122.jpg',
                  name: data['EmployeeName'] ?? '',
                  shiftName: shiftName,
                  inTime: shiftStartTime,
                  outTime: startEndTime,
                  id: doc.id,
                  companyLogoUrl: companyLogoUrl,
                  companyId: companyId,
                  role: EmployeeRole,
                ));
              }
            }
          } else {}
        }).catchError((e) {
          print('Error fetching routes for employee $employeeId: $e');
        }));
      }
      await Future.wait(tasks);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error fetching active guards: $e');
    }
  }

  void listenToEmployeeLocations(String employeeId) {
    var subscription = _firestore
        .collection('EmployeeRoutes')
        .where('EmpRouteEmpId', isEqualTo: employeeId)
        .where('EmpRouteShiftStatus', isEqualTo: 'started')
        .snapshots()
        .listen((snapshot) async {
      // Process each document in the snapshot
      for (var doc in snapshot.docs) {
        var routeData = doc.data() as Map<String, dynamic>;
        if (routeData.containsKey('EmpRouteLocations')) {
          var locations = routeData['EmpRouteLocations'] as List<dynamic>;
          List<Position> polyline = locations.map((loc) {
            final geoPoint = loc['LocationCoordinates'] as GeoPoint;
            return Position(
              geoPoint.longitude,
              geoPoint.latitude,
            );
          }).toList();

          // Draw the polyline on the map
          if (employeeId == selectedEmployeeId) {
            // Draw the polyline on the map for the selected employee
            await drawRouteLowLevel(polyline);
          }
          if (count == 0) {
            flyToLocation(polyline);
            count++;
          }
          // Optionally, update annotations (markers)
          await updateAnnotations(snapshot, selectedEmployeeId == employeeId);
        }
      }
    });
    _subscriptions.add(subscription);
  }

  Future<void> updateAnnotations(
      QuerySnapshot snapshot, bool isSelectedEmployee) async {
    print('update annotations called');
    if (pointAnnotationManager == null) {
      pointAnnotationManager =
          await mapboxMapController?.annotations.createPointAnnotationManager();
    }

    var newAnnotations = <PointAnnotationOptions>[];
    var annotationsToRemove = <PointAnnotation>[];

    for (var document in snapshot.docs) {
      var data = document.data() as Map<String, dynamic>;
      final bytes = data['EmpRouteEmpRole'] == 'GUARD'
          ? await rootBundle.load('assets/images/guard.png')
          : await rootBundle.load('assets/images/car_marker.png');
      Uint8List? imageData = bytes.buffer.asUint8List();
      if (data.containsKey('EmpRouteLocations')) {
        var locations = data['EmpRouteLocations'] as List<dynamic>?;
        if (locations != null && locations.isNotEmpty) {
          var lastLocation = locations.last as Map<dynamic, dynamic>;
          var geoPoint = lastLocation['LocationCoordinates'] as GeoPoint;
          var employeeId = data['EmpRouteEmpId'];

          // Find the annotation for the current employee and mark it for removal
          annotationsToRemove.addAll(currentAnnotations.where((annotation) =>
              annotation.textField == (data['EmployeeName'] ?? 'Guard Name')));

          newAnnotations.add(PointAnnotationOptions(
            geometry: Point(
                coordinates: Position(
              geoPoint.longitude,
              geoPoint.latitude,
            )),
            textField: data['EmployeeName'] ?? 'Guard Name',
            textOffset: [0.0, -3.002],
            iconTextFitPadding: [12, 12, 12, 12],
            textColor: Colors.black.value,
            iconSize: 2.0,
            iconOffset: [0.0, -5.0],
            symbolSortKey: 10,
            image: imageData,
          ));
        }
      }
    }

    // Remove old annotations for the current employee
    for (var annotation in annotationsToRemove) {
      await pointAnnotationManager?.delete(annotation);
    }

    // Add new annotations
    if (newAnnotations.isNotEmpty) {
      var currentAnno =
          await pointAnnotationManager?.createMulti(newAnnotations) ?? [];
      currentAnnotations = currentAnnotations
          .where((annotation) => !annotationsToRemove.contains(annotation))
          .toList();
      currentAnnotations.addAll(currentAnno.whereType<PointAnnotation>());
    }
  }

  void updateMapLocation(double longitude, double latitude) {
    mapboxMapController?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: 15,
        pitch: 0,
      ),
      MapAnimationOptions(
        duration: 4000,
      ),
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

  void moveCardToTop(int index) {
    if (index != selectedIndex) {
      final item = employeeShiftDetailsList.removeAt(index);
      employeeShiftDetailsList.insert(0, item);
      selectedEmployeeId = item.id;
      selectedIndex = 0;
    }
  }

  /// ---- map related
  onMapCreated(MapboxMap mapboxMap) async {
    // set mapboxMapController
    mapboxMapController = mapboxMap;
    // create point annotation manager
    pointAnnotationManager =
        await mapboxMapController?.annotations.createPointAnnotationManager();
  }

  flyToLocation(List<Position> polyline) {
    print('fly to location function');
    if (polyline.isNotEmpty) {
      Position endPoint = polyline.last;
      mapboxMapController?.flyTo(
        CameraOptions(
          center: Point(coordinates: endPoint),
          zoom: 15,
          pitch: 0,
        ),
        MapAnimationOptions(
          duration: 4000,
        ),
      );
    } else {
      print('polyline is empty');
    }
  }

  Future<void> drawRouteLowLevel(List<Position> polyline) async {
    print('drawRouteLowLevel called');

    // Add new start marker annotation
    // final bytesStartMarker =
    //     await rootBundle.load('assets/images/start_marker.png');
    // Uint8List? imageDataStartMarker = bytesStartMarker.buffer.asUint8List();
    // var newAnnotations = <PointAnnotationOptions>[];
    // newAnnotations.add(PointAnnotationOptions(
    //   geometry: Point(coordinates: polyline.first),
    //   iconSize: 2.0,
    //   iconOffset: [0.0, -5.0],
    //   symbolSortKey: 10,
    //   image: imageDataStartMarker,
    // ));
    // var currentAnno =
    //     await pointAnnotationManager?.createMulti(newAnnotations) ?? [];
    // currentAnnotations = currentAnno.whereType<PointAnnotation>().toList();

    print('draw route called');

    if (mapboxMapController == null) {
      print('maboxMapController is null');
      return;
    }

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

      // animate layer to reveal it from start to end
      // animate layer to reveal it from start to end
      if (controller!.isAnimating) {
        controller?.stop();
      }
      animation = Tween<double>(begin: 0, end: 1.0).animate(controller!)
        ..addListener(() async {
          // set the animated value of lineTrim and update the layer
          lineLayer.lineTrimOffset = [animation?.value, 1.0];
          mapboxMapController!.style.updateLayer(lineLayer);
        });
      controller?.forward();
    });
  }

  var brands = <String, bool>{
    'Puma': false,
    'Nike': false,
    'Adidas': false,
    'Volkswagen': false,
  }.obs;
}
