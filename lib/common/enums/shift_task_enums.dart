enum ShiftTaskEnum {
  scan,
  upload,
}

extension ConvertMessage on String {
  ShiftTaskEnum toEnum() {
    switch (this) {
      case 'scan':
        return ShiftTaskEnum.scan;
      case 'upload':
        return ShiftTaskEnum.upload;
      default:
        return ShiftTaskEnum.scan;
    }
  }
}

// void main() {
//   // Example usage
//   MessageEnum messageType = MessageEnum.audio;
//   Widget messageWidget = messageType.toWidget();
//
//   runApp(MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(title: Text('Message Widget Example')),
//       body: Center(child: messageWidget),
//     ),
//   ));
// }
