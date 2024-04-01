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
    final LocalStorage storage = LocalStorage('currentUserEmail');
    // Directly retrieve the role from local storage
    final role = storage.getItem("Role");
    //CurrentUser
    final currentUser = storage.getItem("CurrentUser");
    List items = [];
    toJSONEncodable() {
      return items.map((item) {
        return item.toJSONEncodable();
      }).toList();
    }

    print("User  ${items}");
    print("Role ${role}");
    print("currentUser ${currentUser}");
    if (currentUser != null) {
      if (currentUser) {
        HomeScreen();
      } else {
        GetStartedScreens();
      }
    }
    return role != null ? _handleAuthenticatedUser(role) : GetStartedScreens();
  }

  Widget _handleAuthenticatedUser(String role) {
    switch (role) {
      case 'SUPERVISOR':
        return const SHomeScreen();
      default:
        return const HomeScreen();
    }
  }
}
