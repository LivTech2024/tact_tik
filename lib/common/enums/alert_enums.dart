enum AlertEnum {
  newOffer,
  newExchange,
  exchange,
  shiftEnded
}

extension ConvertMessage on String {
  AlertEnum toEnum() {
    switch (this) {
      case 'exchange':
        return AlertEnum.exchange;
      case 'newExchange':
        return AlertEnum.newExchange;
      case 'newOffer':
        return AlertEnum.newOffer;
      case 'shiftEnded':
        return AlertEnum.shiftEnded;
      default:
        return AlertEnum.exchange;
    }
  }
}
