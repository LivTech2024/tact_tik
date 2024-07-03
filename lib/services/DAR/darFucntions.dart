import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

class DarFunctions {
  List<Map<String, dynamic>> hourlyShiftDetails = [];
  List<Map<String, dynamic>> hourlyShiftDetails2 = [];

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

      DateTime startDateTime = DateTime(2024, 1, 1, startHour, startMinute);
      DateTime endDateTime = DateTime(2024, 1, 1, endHour, endMinute);

      // If endDateTime is before startDateTime, add one day to endDateTime
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(Duration(days: 1));
      }

      // Handle shift details for the first day
      DateTime current = startDateTime;
      DateTime endOfDay = DateTime(
          startDateTime.year,
          startDateTime.month,
          startDateTime.day,
          endDateTime.day > startDateTime.day ? 24 : endHour,
          endDateTime.day > startDateTime.day ? startMinute : endMinute);

      while (current.isBefore(endOfDay)) {
        final next =
            current.add(Duration(minutes: 60)); // Interval of 60 minute

        if (next.isAfter(endOfDay)) {
          break;
        }

        hourlyShiftDetails.add({
          'startTime':
              '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}',
          'endTime':
              '${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}',
        });

        current = next;
      }

      // Handle shift details for the next day if the shift ends after midnight
      if (endDateTime.day > startDateTime.day) {
        DateTime nextDayStart = DateTime(
            endDateTime.year, endDateTime.month, endDateTime.day, 0, endMinute);

        current = nextDayStart;
        while (current.isBefore(endDateTime)) {
          final next =
              current.add(Duration(minutes: 60)); // Interval of 60 minutes

          if (next.isAfter(endDateTime)) {
            break;
          }

          hourlyShiftDetails2.add({
            'startTime':
                '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}',
            'endTime':
                '${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}',
          });

          current = next;
        }
      }
    }
  }

  void _processTiles(List<Map<String, dynamic>> tiles) {
    List<Map<String, dynamic>> hourlyShiftDetails = [];
    List<Map<String, dynamic>> hourlyShiftDetails2 = [];

    for (var tile in tiles) {
      final tileTime = tile['TileTime'] as String; // Extract TileTime
      final tileDate = tile['TileDate'] as Timestamp; // Extract TileDate

      final tileDateTime = DateTime.parse(tileDate.toDate().toString());
      final tileStartTimeParts = tileTime.split(' - ')[0].split(':');
      final tileEndTimeParts = tileTime.split(' - ')[1].split(':');

      final startHour = int.parse(tileStartTimeParts[0]);
      final startMinute = int.parse(tileStartTimeParts[1]);
      final endHour = int.parse(tileEndTimeParts[0]);
      final endMinute = int.parse(tileEndTimeParts[1]);

      DateTime startDateTime = DateTime(tileDateTime.year, tileDateTime.month,
          tileDateTime.day, startHour, startMinute);
      DateTime endDateTime = DateTime(tileDateTime.year, tileDateTime.month,
          tileDateTime.day, endHour, endMinute);

      // Handle shift crossing midnight
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime =
            endDateTime.add(Duration(days: 1)); // Shift crosses midnight
      }

      // Process the current day (up to midnight)
      DateTime endOfDay = DateTime(
          startDateTime.year, startDateTime.month, startDateTime.day, 23, 59);
      DateTime current = startDateTime;

      while (current.isBefore(endOfDay)) {
        final next =
            current.add(Duration(minutes: 60)); // Interval of 60 minutes

        if (next.isAfter(endOfDay)) {
          break;
        }

        hourlyShiftDetails.add({
          'TileContent': tile['TileContent'],
          'TileDate': tile['TileDate'],
          'TileTime':
              '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')} - ${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}',
          'TileLocation': tile['TileLocation'],
          'TileImages': tile['TileImages'],
        });

        current = next;
      }

      // Process the next day (after midnight)
      if (endDateTime.day > startDateTime.day) {
        DateTime nextDayStart = DateTime(
            endDateTime.year, endDateTime.month, endDateTime.day, 0, 0);
        current = nextDayStart;

        while (current.isBefore(endDateTime)) {
          final next =
              current.add(Duration(minutes: 60)); // Interval of 60 minutes

          if (next.isAfter(endDateTime)) {
            break;
          }

          hourlyShiftDetails2.add({
            'TileContent': tile['TileContent'],
            'TileDate': tile['TileDate'],
            'TileTime':
                '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')} - ${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}',
          });

          current = next;
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
          final data = dar.data() as Map<String, dynamic>;
          if (data['EmpDarId'] == DarId) {
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

          darTiles.add({
            'TileContent': '',
            'TileImages': [],
            'TileLocation': '',
            'TileTime': '$startTime - $endTime',
            'TileDate': Timestamp.fromDate(date),
          });
        }

        for (var shift in hourlyShiftDetails2) {
          final String startTime = shift['startTime']!;
          final String endTime = shift['endTime']!;
          print("shiftStartTime $startTime");
          print("shiftEndTime $endTime");

          darTiles2.add({
            'TileContent': '',
            'TileImages': [],
            'TileLocation': '',
            'TileTime': '$startTime - $endTime',
            'TileDate': Timestamp.fromDate(date.add(Duration(days: 1))),
          });
        }

        if (docRef != null) {
          if (!isDarlistPresent) {
            await docRef.set({'EmpDarTile': darTiles}, SetOptions(merge: true));
            if (darTiles2.isNotEmpty) {
              var id = await _submitDAR2();
              await id?.set({'EmpDarTile': darTiles2}, SetOptions(merge: true));
            }
          }
        } else {
          print('No document reference found.');
        }
      } else {
        print('No document found with the matching employeeId.');
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
        'EmpDarCreatedAt': Timestamp.fromDate(DateTime.now()),
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

  Future<DocumentReference?> _submitDAR2() async {
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
          DocumentReference? docRef;
          for (var dar in querySnapshot.docs) {
            final data = dar.data() as Map<String, dynamic>;
            if (data['EmpDarShiftId'] == _userService.ShiftId &&
                data['EmpDarDate'] != date) {
              print('Updating existing DAR with tiles.');
              docRef = dar.reference;
              break;
            }
          }
          if (docRef != null) {
            await _createBlankDARCards(
                FirebaseAuth.instance.currentUser!.uid, docRef.id);
          } else {
            await _createBlankDARCards(
                FirebaseAuth.instance.currentUser!.uid, _userService.ShiftId!);
          }
        } else {
          print('Creating new DAR and adding tiles.');
          var id = await _submitDAR();
          if (id != null) {
            await _createBlankDARCards(
                FirebaseAuth.instance.currentUser!.uid, id.id);
          }
        }
      } else {
        print('Shift start time or end time is null.');
      }
    } catch (e) {
      print('Error fetching shift details and submitting DAR: $e');
    }
  }
}
