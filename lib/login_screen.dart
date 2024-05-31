import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tact_tik/screens/client%20screens/client_home_screen.dart';
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
  bool _isLoading = false;
  final LocalStorage storage = LocalStorage('currentUserEmail');
  String? _errorMessage = '';

  Future<void> signInEmailPassword(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      var data = await Auth().signInWithEmailAndPassword(
          _emailcontrller.text, _passwordcontrller.text, context);

      await storage.ready;
      final String? role = storage.getItem("Role");
      print('hear is the role of emp');
      print(role);
      if (role == "SUPERVISOR") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SHomeScreen()));
      } else if (role == "CLIENT") {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ClientHomeScreen()));
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
      print('Error signing in login screen: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

/*
  Future<void> signInEmailPassword(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      var data = await Auth().signInWithEmailAndPassword(
          _emailcontrller.text, _passwordcontrller.text, context);

      await storage.ready;
      final String? role = storage.getItem("Role");
      _showSnackBar(context, 'An unexpected error occurred');
      if (role == "SUPERVISOR") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SHomeScreen()));
      } else if (role == "CLIENT") {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ClientHomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      }
      _showSnackBar(context, errorMessage);
    } catch (e) {
      print('Error signing in login screen: $e');
      _showSnackBar(context, 'An unexpected error occurred');
    }
    setState(() {
      _isLoading = false;
    });
  }
*/

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // final double height = MediaQuery.of(context).size.height;
    // final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30.w,
                vertical: 20.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      fontSize: 15.sp,
                      color: Colors.white, // Change text color to white
                    ),
                    controller: _emailcontrller,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 30.h),
                  TextField(
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      fontSize: 15.sp,
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
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 24.sp,
                          color: color6,
                        ),
                      ),
                      labelText: 'Password',
                      hintText: 'Enter your password',
                    ),
                  ),
                  SizedBox(height: 20.h),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 24.sp,
                      ),
                    ),
                  Button1(
                    height: 50.57.h,
                    backgroundcolor: Primarycolor,
                    text: 'Login',
                    fontsize: 18.sp,
                    color: Colors.black,
                    borderRadius: 5.r,
                    onPressed: () {
                      Auth().signInWithEmailAndPassword(_emailcontrller.text,
                          _passwordcontrller.text, context);
                    },
                  ),
                  if (_isLoading)
                    Align(
                      alignment: Alignment.center,
                      child: Visibility(
                        visible: _isLoading,
                        child: const CircularProgressIndicator(
                          color: Primarycolor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
