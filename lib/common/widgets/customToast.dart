import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showSuccessToast(BuildContext context, String message) {
  toastification.show(
    context: context,
    type: ToastificationType.success,
    title: Text(message),
    autoCloseDuration: const Duration(seconds: 5),
  );
}
