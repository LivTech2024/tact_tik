import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/services/auth/auth.dart';
import 'package:tact_tik/utils/colors.dart';

import 'common/widgets/button1.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  TextEditingController _emailcontrller = TextEditingController();
  TextEditingController _passwordcontrller = TextEditingController();

  Future<void> signInEmailPassword(BuildContext context) async {
    try {
      await Auth()
          .signInWithEmailAndPassword(
              _emailcontrller.text, _passwordcontrller.text, context)
          .whenComplete(() => Auth().authStateChanges.listen((event) async {
                if (event == null) {
                  return;
                } else {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                }
              }));
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
                  color: Colors.white, // Change text color to white
                ),
                controller: _emailcontrller,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10.0),
              TextField(
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
                  color: Colors.white, // Change text color to white
                ),
                controller: _passwordcontrller,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
              ),
              SizedBox(height: 10),
              Button1(
                backgroundcolor: Primarycolor,
                text: 'Login',
                color: color1,
                onPressed: () => signInEmailPassword(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}
