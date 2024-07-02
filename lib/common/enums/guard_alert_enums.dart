enum GuardAlertEnum {
  newOffer,
  newExchange,
  ShiftStatusNotification,
}

extension ConvertMessage on String {
  GuardAlertEnum toEnum() {
    switch (this) {
      case 'ShiftStatusNotification':
        return GuardAlertEnum.ShiftStatusNotification;
      case 'newExchange':
        return GuardAlertEnum.newExchange;
      case 'newOffer':
        return GuardAlertEnum.newOffer;
      default:
        return GuardAlertEnum.ShiftStatusNotification;
    }
  }
}
