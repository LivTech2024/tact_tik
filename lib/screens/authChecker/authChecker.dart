import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tact_tik/login_screen.dart';
import 'package:tact_tik/riverpod/auth_provider.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/services/auth/auth.dart';

class AuthChecker extends ConsumerWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    final _authState = ref.watch(authStateProvider);
    return _authState.when(data: (data) {
      if (data != null) {
        print(data);
        Auth().signOut();
        return const HomeScreen();
      } else {
        return LoginScreen();
      }
    }, error: (error, stackTrace) {
      print(stackTrace);
      return SizedBox.shrink(); // Return an empty SizedBox for now
    }, loading: () {
      return SizedBox.shrink(); // Return an empty SizedBox for now
    });
  }
}
