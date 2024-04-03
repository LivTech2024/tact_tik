import 'package:emailjs/emailjs.dart';

Future<bool> sendEmail(dynamic templateParams) async {
  try {
    await EmailJS.send(
      'service_6mmak1z',
      'template_lm9ftk9',
      templateParams,
      const Options(
        publicKey: 'DAtUR9kGOvEyWhbq-',
      ),
    );
    print('SUCCESS!');
    return true;
  } catch (error) {
    if (error is EmailJSResponseStatus) {
      print('ERROR... ${error.status}: ${error.text}');
    }
    print(error.toString());
    return false;
  }
}
