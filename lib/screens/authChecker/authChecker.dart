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
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (data) {
        if (data != null) {
          print(data);
          String role =
              storage.getItem("Role"); // Get the user's role from local storage
          switch (role) {
            case 'SUPERVISOR':
              return const SHomeScreen();
            default:
              return const HomeScreen();
          }
        } else {
          return GetStartedScreens();
        }
      },
      error: (error, stackTrace) {
        print(stackTrace);
        return SizedBox.shrink(); // Return an empty SizedBox for now
      },
      loading: () {
        return const CircularProgressIndicator(); // Show a loading indicator
      },
    );
  }
}
