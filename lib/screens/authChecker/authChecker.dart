import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tact_tik/login_screen.dart';
import 'package:tact_tik/riverpod/auth_provider.dart';
import 'package:tact_tik/screens/get%20started/getstarted_screen.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/s_home_screen.dart';
import 'package:tact_tik/services/auth/auth.dart';

class AuthChecker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _authState = ref.watch(authStateProvider);
    final LocalStorage storage = LocalStorage('currentUserEmail');
    final Future<String?> currentUserFuture =
        storage.ready.then((_) => storage.getItem("CurrentUser"));

    return FutureBuilder<String?>(
      future: currentUserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && _authState != null) {
          final String? role = storage.getItem("Role");
          print("Role: $role");
          return _handleAuthenticatedUser(role);
        } else {
          return LoginScreen();
        }
      },
    );
  }

  Widget _handleAuthenticatedUser(String? role) {
    if (role != null) {
      switch (role) {
        case 'SUPERVISOR':
          return const SHomeScreen(); // Navigate to supervisor screen
        default:
          return const HomeScreen(); // Navigate to home screen
      }
    } else {
      return const CircularProgressIndicator(); // Or any other loading indicator
    }
  }
}
