import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/s_home_screen.dart';
import 'package:tact_tik/services/auth/auth.dart';
import 'package:tact_tik/utils/colors.dart';

import 'common/sizes.dart';
import 'common/widgets/button1.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailcontrller = TextEditingController();

  TextEditingController _passwordcontrller = TextEditingController();

  final LocalStorage storage = LocalStorage('currentUserEmail');
  String _errorMessage = '';
  Future<void> signInEmailPassword(BuildContext context) async {
    try {
      var data = await Auth().signInWithEmailAndPassword(
          _emailcontrller.text, _passwordcontrller.text, context);
      // String role = await storage.getItem("Role");
      final Future<String?> currentUserFuture =
          storage.ready.then((_) => storage.getItem("Role"));
      print("Future ${currentUserFuture}");

      final String? role = storage.getItem("Role");
      print("Normal Role  ${role}");

      if (role == "SUPERVISOR") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SHomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException here
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    } catch (e) {
      // Handle other errors
      print('Error signing in: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    }
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width / width30, vertical: height / height20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: width / width18,
                  color: Colors.white, // Change text color to white
                ),
                controller: _emailcontrller,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: height / height10),
              TextField(
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: width / width18,
                  color: Colors.white, // Change text color to white
                ),
                controller: _passwordcontrller,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      size: width / width24,
                      color: color6,
                    ),
                  ),
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
              ),
              SizedBox(height: height / height20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: width / width24,
                  ),
                ),
              Button1(
                backgroundcolor: Primarycolor,
                text: 'Login',
                color: color1,
                borderRadius: 10,
                onPressed: () {
                  Auth().signInWithEmailAndPassword(
                      _emailcontrller.text, _passwordcontrller.text, context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
