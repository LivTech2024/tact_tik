enum GuardHomeScreenEnum {
  text('text'),
  image('image'),
  audio('audio'),
  video('video'),
  gif('gif');

  const GuardHomeScreenEnum(this.type);

  final String type;
}

extension ConvertMessage on String {
  GuardHomeScreenEnum toEnum() {
    switch (this) {
      case 'audio':
        return GuardHomeScreenEnum.audio;
      case 'image':
        return GuardHomeScreenEnum.image;
      case 'video':
        return GuardHomeScreenEnum.video;
      case 'gif':
        return GuardHomeScreenEnum.gif;
      case 'text':
        return GuardHomeScreenEnum.text;
      default:
        return GuardHomeScreenEnum.text;
    }
  }
}