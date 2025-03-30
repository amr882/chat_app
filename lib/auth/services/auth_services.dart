// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  // create account

  Future<void> createAccount(
    String userName,
    String emailAddress,
    String password,
    BuildContext context,
    String pfp,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      _firebaseFirestore.collection("users").doc(credential.user!.uid).set({
        "Uname": userName,
        "Uid": credential.user!.uid,
        "Uemail": credential.user!.email,
        "pfp": pfp,
      }, SetOptions(merge: true));
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
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      _firebaseFirestore.collection("users").doc(credential.user!.uid).set({
        "Uid": credential.user!.uid,
        "Uemail": credential.user!.email,
      }, SetOptions(merge: true));
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
