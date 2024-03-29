import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/services/auth/auth.dart';
import 'package:tact_tik/utils/colors.dart';

import 'common/sizes.dart';
import 'common/widgets/button1.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  TextEditingController _emailcontrller = TextEditingController();
  TextEditingController _passwordcontrller = TextEditingController();

  Future<void> signInEmailPassword(BuildContext context) async {
    try {
      await Auth().signInWithEmailAndPassword(
          _emailcontrller.text, _passwordcontrller.text);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30, vertical: height / height20),
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
                decoration: InputDecoration(
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
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
              ),
              SizedBox(height: height / height10),
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
