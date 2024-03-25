import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tact_tik/services/auth/auth.dart';

final authenticationProvider = Provider<Auth>((ref) {
  return Auth();
});
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authenticationProvider).authStateChanges;
});
