import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showSuccessToast(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
  toastification.show(
    context: context,
    type: ToastificationType.success,
    title: Text(message),
    autoCloseDuration: duration,
  );
}