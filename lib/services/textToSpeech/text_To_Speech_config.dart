import 'package:speech_to_text/speech_to_text.dart';

class TextToSpeechConfig {
  SpeechToText speechToText = SpeechToText();
  bool isListening = false;
  //check mic
  void checkMic() async {
    bool isMicAvailable = await speechToText.initialize();
    if (isMicAvailable) {
      print("Mic Avaiable");
    } else {
      print("Mic not Avaiable");
    }
  }
}
