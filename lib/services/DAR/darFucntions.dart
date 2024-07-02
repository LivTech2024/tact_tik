import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

class DarFunctions {
  List<Map<String, dynamic>> hourlyShiftDetails = [];
  List<Map<String, dynamic>> hourlyShiftDetails2 = [];

  // void _processShiftDetails(List<Map<String, dynamic>> shiftDetails) {
  //   hourlyShiftDetails.clear(); // Clear previous details
  //   for (var shift in shiftDetails) {
  //     final startTime = shift['startTime']; // Extract startTime
  //     final endTime = shift['endTime']; // Extract endTime

  //     final startTimeParts = startTime.split(':');
  //     final endTimeParts = endTime.split(':');

  //     final startHour = int.parse(startTimeParts[0]);
  //     final startMinute = int.parse(startTimeParts[1]);
  //     final endHour = int.parse(endTimeParts[0]);
  //     final endMinute = int.parse(endTimeParts[1]);

  //     // Handle shifts starting before and ending after midnight
  //     if (endHour > startHour ||
  //         (endHour == startHour && endMinute > startMinute)) {
  //       // Shift doesn't cross midnight
  //       for (int hour = startHour; hour < 24; hour++) {
  //         if (hour < 24) {
  //           // Ensure hours are within a day
  //           final hourStart =
  //               '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  //           final hourEnd =
  //               '${(hour + 1).toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  //           hourlyShiftDetails.add({
  //             'startTime': hourStart,
  //             'endTime': hourEnd,
  //           });
  //           print("process 1 ${hourlyShiftDetails}");
  //         }
  //       }
  //     } else {
  //       // Shift crosses midnight
  //       for (int hour = startHour; hour < 24; hour++) {
  //         if (hour < 24) {
  //           // Ensure hours are within a day
  //           final hourStart =
  //               '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  //           final hourEnd =
  //               '${(hour + 1).toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  //           hourlyShiftDetails.add({
  //             'startTime': hourStart,
  //             'endTime': hourEnd,
  //           });
  //           print("process 2 ${hourlyShiftDetails}");
  //         }
  //       }
  //       // Add tiles for remaining hours after midnight (if any)
  //       final remainingEndHour = endHour < startHour ? endHour + 24 : endHour;

  //       for (int hour = 0; hour <= remainingEndHour; hour++) {
  //         if (hour < endHour) {
  //           // Ensure hours are within a day
  //           final hourStart =
  //               '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  //           final hourEnd =
  //               '${(hour + 1).toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  //           hourlyShiftDetails2.add({
  //             'startTime': hourStart,
  //             'endTime': hourEnd,
  //           });
  //           print("process 3 ${hourlyShiftDetails2}");
  //         }
  //       }
  //     }
  //   }
  // }
  void _processShiftDetails(List<Map<String, dynamic>> shiftDetails) {
    hourlyShiftDetails.clear(); // Clear previous details
    hourlyShiftDetails2.clear(); // Clear previous details for second list

    for (var shift in shiftDetails) {
      final startTime = shift['startTime']; // Extract startTime
      final endTime = shift['endTime']; // Extract endTime

      final startTimeParts = startTime.split(':');
      final endTimeParts = endTime.split(':');

      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

      // Handle shifts starting before and ending after midnight
      if (endHour > startHour ||
          (endHour == startHour && endMinute > startMinute)) {
        // Shift doesn't cross midnight
        for (int hour = startHour; hour < endHour; hour++) {
          // Ensure hours are within a day
          final hourStart =
              '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
          final hourEnd =
              '${(hour + 1).toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

          hourlyShiftDetails.add({
            'startTime': hourStart,
            'endTime': hourEnd,
          });
          print("process 1 ${hourlyShiftDetails}");
        }
      } else {
        // Shift crosses midnight
        final remainingEndHour = endHour < startHour ? endHour + 24 : endHour;

        for (int hour = startHour; hour <= remainingEndHour; hour++) {
          // Ensure hours are within a day
          final hourStart =
              '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
          final hourEnd =
              '${(hour + 1).toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

          hourlyShiftDetails.add({
            'startTime': hourStart,
            'endTime': hourEnd,
          });
          print("process 2 ${hourlyShiftDetails}");
        }
      }
    }
  }

  Future<void> _createBlankDARCards(String employeeId, String DarId) async {
    try {
      final CollectionReference employeesDARCollection =
          FirebaseFirestore.instance.collection('EmployeesDAR');

      final QuerySnapshot querySnapshot = await employeesDARCollection
          .where('EmpDarEmpId', isEqualTo: employeeId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference? docRef;
        final date = DateTime.now();
        bool isDarlistPresent = false;

        for (var dar in querySnapshot.docs) {
          print('DarID ${DarId}');
          final data = dar.data() as Map<String, dynamic>;
          if (data['EmpDarId'] == DarId) {
            // Assuming YOUR_EMPDARID_HERE is the EmpDarId you're checking for
            docRef = dar.reference;
            if (data['EmpDarTile'] == null || data['EmpDarTile'] == "") {
              isDarlistPresent = false; // Tile does not exist
            } else {
              isDarlistPresent = true; // Tile exists
            }
            break; // Exit the loop once the DAR is found
          }
        }

        final List<Map<String, dynamic>> darTiles = [];
        final List<Map<String, dynamic>> darTiles2 = [];

        for (var shift in hourlyShiftDetails) {
          final String startTime = shift['startTime']!;
          final String endTime = shift['endTime']!;
          print("shiftStartTime $startTime");
          print("shiftEndTime $endTime");

          final int startHour = int.parse(startTime.split(':')[0]);
          final int endHour = int.parse(endTime.split(':')[0]);
          print("startHour $startHour");
          print("endHour $endHour");

          if (endHour < startHour) {
            // Handle shifts that span across midnight
            for (int hour = startHour; hour < 24; hour++) {
              darTiles.add({
                'TileContent': '',
                'TileImages': [],
                'TileLocation': '',
                'TileTime': '$hour:00 - ${(hour + 1) % 24}:00',
                'TileDate': Timestamp.fromDate(date),
              });
            }
          } else {
            for (int hour = startHour; hour < endHour; hour++) {
              darTiles.add({
                'TileContent': '',
                'TileImages': [],
                'TileLocation': '',
                'TileTime': '$hour:00 - ${(hour + 1) % 24}:00',
                'TileDate': Timestamp.fromDate(date),
              });
            }
          }
        }
        // final DateTime date = DateTime.now();
        final DateTime nextDate = date.add(Duration(days: 1)); // Next day
        for (var shift in hourlyShiftDetails2) {
          final String startTime = shift['startTime']!;
          final String endTime = shift['endTime']!;
          print("shiftStartTime $startTime");
          print("shiftEndTime $endTime");

          final int startHour = int.parse(startTime.split(':')[0]);
          final int endHour = int.parse(endTime.split(':')[0]);
          print("startHour $startHour");
          print("endHour $endHour");

          for (int hour = startHour; hour < endHour; hour++) {
            darTiles2.add({
              'TileContent': '',
              'TileImages': [],
              'TileLocation': '',
              'TileTime': '$hour:00 - ${(hour + 1) % 24}:00',
              'TileDate': Timestamp.fromDate(nextDate),
            });
          }
        }
        // var id = await _submitDAR();
        // await id?.set({'EmpDarTile': darTiles2}, SetOptions(merge: true));

        if (docRef != null) {
          if (!isDarlistPresent) {
            await docRef.set({'EmpDarTile': darTiles}, SetOptions(merge: true));
            if (darTiles2.isNotEmpty) {
              var id = await _submitDAR();
              await id?.set({'EmpDarTile': darTiles2}, SetOptions(merge: true));
            }
          }
        } else {
          // await
        }
      } else {
        print('No document found with the matching _employeeId.');
      }
    } catch (e) {
      print('Error creating blank DAR cards: $e');
    }
  }

  Future<DocumentReference?> _submitDAR() async {
    final _userService = UserService(firestoreService: FireStoreService());
    await _userService.getShiftInfo();

    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      var docRef = await _firestore.collection('EmployeesDAR').add({
        'EmpDarLocationId': _userService.shiftLocationId,
        'EmpDarLocationName': _userService.shiftLocation,
        'EmpDarShiftId': _userService.ShiftId,
        'EmpDarDate': _userService.shiftDate,
        'EmpDarCreatedAt':
            Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
        'EmpDarEmpName': _userService.userName,
        'EmpDarEmpId': FirebaseAuth.instance.currentUser!.uid,
        'EmpDarCompanyId': _userService.shiftCompanyId,
        'EmpDarCompanyBranchId': _userService.shiftCompanyBranchId,
        'EmpDarClientId': _userService.shiftClientId,
        'EmpDarShiftName': _userService.shiftName
      });
      await docRef.update({'EmpDarId': docRef.id});
      return docRef;
    } catch (e) {
      print('error = $e');
      return null;
    }
  }

  final _userService = UserService(firestoreService: FireStoreService());
  // Future<void> _fetchShiftDetails() async {
  //   try {
  //     await _userService.getShiftInfo();
  //     String? shiftStartTime = _userService.shiftStartTime;
  //     print("shiftStartTime :$shiftStartTime");
  //     String? shiftEndTime = _userService.shiftEndTime;
  //     print("shiftEndTime :$shiftEndTime");
  //     if (shiftStartTime != null && shiftEndTime != null) {
  //       final List<Map<String, dynamic>> shiftDetails = [
  //         {
  //           'startTime': shiftStartTime,
  //           'endTime': shiftEndTime,
  //         },
  //       ];
  //       print("_fetchShiftDetails startTime&endTime ${shiftDetails}");
  //       _processShiftDetails(shiftDetails);
  //       _createBlankDARCards();
  //     } else {
  //       print('Shift data is null.');
  //     }
  //   } catch (e) {
  //     print('Error fetching shift details: $e');
  //   }
  // }

  Future<void> fetchShiftDetailsAndSubmitDAR() async {
    try {
      await _userService.getShiftInfo();
      String? shiftStartTime = _userService.shiftStartTime;
      print("shiftStartTime :$shiftStartTime");
      String? shiftEndTime = _userService.shiftEndTime;
      print("shiftEndTime :$shiftEndTime");
      if (shiftStartTime != null && shiftEndTime != null) {
        final List<Map<String, dynamic>> shiftDetails = [
          {
            'startTime': shiftStartTime,
            'endTime': shiftEndTime,
          },
        ];
        print("_fetchShiftDetails startTime&endTime ${shiftDetails}");
        _processShiftDetails(shiftDetails);

        // Submit DAR
        final date = DateTime.now();
        final CollectionReference employeesDARCollection =
            FirebaseFirestore.instance.collection('EmployeesDAR');

        final QuerySnapshot querySnapshot = await employeesDARCollection
            .where('EmpDarEmpId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where('EmpDarShiftId', isEqualTo: _userService.ShiftId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          print(
              'Document with EmpDarShiftId ${_userService.ShiftId} already exists.');
          // return null;
        }

        var docRef = await employeesDARCollection.add({
          'EmpDarLocationId:': _userService.shiftLocationId,
          'EmpDarLocationName': _userService.shiftLocation,
          'EmpDarShiftId': _userService.ShiftId,
          'EmpDarDate': _userService.shiftDate,
          'EmpDarCreatedAt': FieldValue.serverTimestamp(),
          'EmpDarEmpName': _userService.userName,
          'EmpDarEmpId': FirebaseAuth.instance.currentUser!.uid,
          'EmpDarCompanyId': _userService.shiftCompanyId,
          'EmpDarCompanyBranchId': _userService.shiftCompanyBranchId,
          'EmpDarClientId': _userService.shiftClientId,
          'EmpDarShiftName': _userService.shiftName
        });
        await docRef.update({'EmpDarId': docRef.id});
        print(
            'Document with EmpDarShiftId ${_userService.ShiftId} created successfully.');

        // Process shift details for tile creation
        // _processShiftDetails(_userService.shiftDetails);

        final List<Map<String, dynamic>> darTiles = [];
        final List<Map<String, dynamic>> darTiles2 = [];

        // Create DAR tiles for shifts
        for (var shift in hourlyShiftDetails) {
          final String startTime = shift['startTime']!;
          final String endTime = shift['endTime']!;
          // Create DAR tiles based on shift start and end times
          // ...

          final int startHour = int.parse(startTime.split(':')[0]);
          final int endHour = int.parse(endTime.split(':')[0]);
          print("startHour $startHour");
          print("endHour $endHour");

          if (endHour < startHour) {
            // Handle shifts that span across midnight
            for (int hour = startHour; hour < 24; hour++) {
              darTiles.add({
                'TileContent': '',
                'TileImages': [],
                'TileLocation': '',
                'TileTime': '$hour:00 - ${(hour + 1) % 24}:00',
                'TileDate': Timestamp.fromDate(date),
              });
            }
          } else {
            for (int hour = startHour; hour < endHour; hour++) {
              darTiles.add({
                'TileContent': '',
                'TileImages': [],
                'TileLocation': '',
                'TileTime': '$hour:00 - ${(hour + 1) % 24}:00',
                'TileDate': Timestamp.fromDate(date),
              });
            }
          }
        }
        final DateTime nextDate = date.add(Duration(days: 1));

        // Create DAR tiles for shifts that cross midnight
        // if (hourlyShiftDetails2.isNotEmpty) {
        for (var shift in hourlyShiftDetails2) {
          final String startTime = shift['startTime']!;
          final String endTime = shift['endTime']!;
          // Create DAR tiles based on shift start and end times
          // ...
          final int startHour = int.parse(startTime.split(':')[0]);
          final int endHour = int.parse(endTime.split(':')[0]);
          print("startHour $startHour");
          print("endHour $endHour");

          for (int hour = startHour; hour < endHour; hour++) {
            darTiles2.add({
              'TileContent': '',
              'TileImages': [],
              'TileLocation': '',
              'TileTime': '$hour:00 - ${(hour + 1) % 24}:00',
              'TileDate': Timestamp.fromDate(nextDate),
            });
          }
        }
        // }
        // Update the DAR document with the created tiles
        if (!querySnapshot.docs.isNotEmpty) {
          await docRef.set({'EmpDarTile': darTiles}, SetOptions(merge: true));
          if (darTiles2.isNotEmpty) {
            var id = await _submitDAR();
            await id?.set({'EmpDarTile': darTiles2}, SetOptions(merge: true));
          }
        }
      } else {
        print('Shift data is null.');
      }
    } catch (e) {
      print('Error fetching shift details and submitting DAR: $e');
    }
  }
}
