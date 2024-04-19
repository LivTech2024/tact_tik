enum LogBookEnum { shift, end , patrolCount, Break }

extension ConvertMessage on String {
  LogBookEnum toEnum() {
    switch (this) {
      case 'shift':
        return LogBookEnum.shift;
      case 'end':
        return LogBookEnum.end;
      case 'patrolCount':
        return LogBookEnum.patrolCount;
      case 'Break':
        return LogBookEnum.Break;
      default:
        return LogBookEnum.shift;
    }
  }
}
