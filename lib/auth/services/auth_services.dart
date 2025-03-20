import 'package:chat_app/auth/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // create account

  Future<void> createAccount(
    String emailAddress,
    String password,
    BuildContext context,
  ) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil("homePage", (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  // sign in
  Future<void> signInWithEmailAndPassword(
    String emailAddress,
    String password,
    BuildContext context,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil("homePage", (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  // sign out
  Future signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
