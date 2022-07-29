import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../provider/authentication_service.dart';
import 'home_screen.dart';
import 'signin_form.dart';

class AuthStateChangeScreen extends StatelessWidget {
  const AuthStateChangeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: AuthenticationService().auth,
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const SignInForm();
        }));
  }
}
