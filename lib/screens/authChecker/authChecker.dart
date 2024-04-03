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
    final LocalStorage storage = LocalStorage('currentUserEmail');
    final Future<String?> currentUserFuture =
        storage.ready.then((_) => storage.getItem("CurrentUser"));
    // final String? role = storage.getItem("Role");
    // print("Role ${role}");

    return FutureBuilder<String?>(
      future: currentUserFuture,
      builder: (context, snapshot) {
        final String? role = storage.getItem("Role");
        print("Role $role");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          return _handleAuthenticatedUser(role);
        } else {
          return GetStartedScreens();
        }
      },
    );
  }

  Widget _handleAuthenticatedUser(String? role) {
    switch (role) {
      case 'SUPERVISOR':
        return const SHomeScreen();
      default:
        return const HomeScreen();
    }
  }
}
