enum LogBookEnum { ShiftStarted, ShiftEnd , PatrolStart, PatrolEnd , TotalWorkTime , CheckPoint }

extension ConvertMessage on String {
  LogBookEnum toEnum() {
    switch (this) {
      case 'ShiftStarted':
        return LogBookEnum.ShiftStarted;
      case 'ShiftEnd':
        return LogBookEnum.ShiftEnd;
      case 'PatrolStart':
        return LogBookEnum.PatrolStart;
      case 'PatrolEnd':
        return LogBookEnum.PatrolEnd;
      case 'TotalWorkTime':
        return LogBookEnum.TotalWorkTime;
      case 'CheckPoint':
        return LogBookEnum.CheckPoint;
      default:
        return LogBookEnum.ShiftStarted;
    }
  }
}
