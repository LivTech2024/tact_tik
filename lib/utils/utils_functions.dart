import 'package:cloud_firestore/cloud_firestore.dart';

class UtilsFuctions {
  static List convertDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return [date.day, date.month, date.year];
  }
}
