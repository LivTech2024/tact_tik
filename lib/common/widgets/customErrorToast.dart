import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showErrorToast(BuildContext context, String message,
    {Duration? duration}) {
  toastification.show(
    context: context,
    type: ToastificationType.error,
    title: Text(message),
    autoCloseDuration: duration ?? const Duration(seconds: 5),
  );
}
