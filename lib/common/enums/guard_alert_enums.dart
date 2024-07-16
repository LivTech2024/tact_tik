enum GuardAlertEnum {
  newOffer,
  newExchange,
  ShiftStatusNotification,
}

// extension ConvertMessage on String {
//   GuardAlertEnum toEnum() {
//     switch (this) {
//       case 'Notification':
//         return GuardAlertEnum.ShiftStatusNotification;
//       case 'SHIFTEXCHANGE':
//         return GuardAlertEnum.newExchange;
//       case 'SHIFTOFFER':
//         return GuardAlertEnum.newOffer;
//       default:
//         return GuardAlertEnum.ShiftStatusNotification;
//     }
//   }
// }
