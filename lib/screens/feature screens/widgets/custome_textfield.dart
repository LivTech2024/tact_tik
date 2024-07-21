import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

class CustomeTextField extends StatefulWidget {
  const CustomeTextField({
    super.key,
    required this.hint,
    this.isExpanded = false,
    this.showIcon = true,
    this.isEnabled = true,
    this.controller,
    this.textInputType,
    this.maxlength,
  });

  final String hint;
  final int? maxlength;
  final bool isExpanded;
  final bool showIcon;
  final bool isEnabled;
  final TextInputType? textInputType;
  final TextEditingController? controller;

  @override
  _CustomeTextFieldState createState() => _CustomeTextFieldState();
}

class _CustomeTextFieldState extends State<CustomeTextField> {
  late SpeechToText _speechToText;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speechToText = SpeechToText();
    _initializeSpeechRecognizer();
  }

  Future<void> _initializeSpeechRecognizer() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );
    if (available) {
      print("Speech recognizer available");
    } else {
      print("Speech recognizer not available");
    }
  }

  void _startListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      await _speechToText.listen(onResult: _onSpeechResult);
    }
  }

  void _stopListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
      await _speechToText.stop();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      setState(() {
        widget.controller?.text += result.recognizedWords;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        top: 5.h,
        bottom: 5.h,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: _isListening ? Colors.red : Colors.transparent,
          width: 2.0,
        ),
      ),
      constraints: widget.isExpanded
          ? BoxConstraints()
          : BoxConstraints(
              minHeight: 60.h,
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              onTapOutside: (event) {
                print('onTapOutside');
                FocusManager.instance.primaryFocus?.unfocus();
              },
              maxLength: widget.maxlength,
              controller: widget.controller,
              maxLines: widget.isExpanded ? null : 1,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w300,
                fontSize: 18.sp,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.r),
                  ),
                ),
                focusedBorder: InputBorder.none,
                hintStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: 18.sp,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                hintText: widget.hint,
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
              keyboardType: widget.textInputType,
              cursorColor: DarkColor.Primarycolor,
              enabled: widget.isEnabled,
            ),
          ),
          if (widget.showIcon)
            IconButton(
              onPressed: () {
                if (_isListening) {
                  _stopListening();
                } else {
                  _startListening();
                }
              },
              icon: Icon(
                _isListening ? Icons.mic_off : Icons.mic,
                color: DarkColor.color33,
                size: 24.sp,
              ),
            )
        ],
      ),
    );
  }
}
