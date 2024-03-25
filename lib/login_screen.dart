import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/utils/colors.dart';

import 'common/widgets/button1.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  TextEditingController _emailcontrller = TextEditingController();
  TextEditingController _passwordcontrller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0 , vertical: 20.0),
          child: Column(
            children: [
              TextFormField(
                controller: _emailcontrller,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _passwordcontrller,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
              ),
              SizedBox(height: 20),
              Button1(
                backgroundcolor: Primarycolor,
                text: 'Login',
                color: color1,
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}
