enum LogBookEnum {
  ShiftStarted,
  ShiftEnd,
  PatrolStart,
  PatrolEnd,
  TotalWorkTime,
  CheckPoint, shift, end, patrolCount
}

extension ConvertMessage on String {
  LogBookEnum toEnum() {
    switch (this) {
      case 'shift_start':
        return LogBookEnum.ShiftStarted;
      case 'shift_end':
        return LogBookEnum.ShiftEnd;
      case 'patrol_start':
        return LogBookEnum.PatrolStart;
      case 'patrol_end':
        return LogBookEnum.PatrolEnd;
      case 'TotalWorkTime':
        return LogBookEnum.TotalWorkTime;
      case 'check_point':
        return LogBookEnum.CheckPoint;
      default:
        return LogBookEnum.ShiftStarted;
    }
  }
}
