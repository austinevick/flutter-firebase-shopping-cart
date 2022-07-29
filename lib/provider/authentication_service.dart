import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constant.dart';
import '../screen/signin_form.dart';

final authProvider = Provider((ref) => AuthenticationService());

class AuthenticationService {
  final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get auth => _auth.authStateChanges();

  Future<User?> login(String email, String password) async {
    final user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.user;
  }

  Future<User?> signup(String email, String password) async {
    final user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return user.user;
  }

  Future<void> signout(BuildContext context) async {
    await pushAndRemoveUntil(context, const SignInForm());
    return await _auth.signOut();
  }
}
