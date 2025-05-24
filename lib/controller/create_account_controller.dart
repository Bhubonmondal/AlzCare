import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> createAccountController(
    context,
    String email,
    String password,
    String cpassword,
    bool isCareGiver,
    ) async {
  if (email.isEmpty || password.isEmpty || cpassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please fill all the fields")),
    );

    return;
  }

  if (password != cpassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Passwords do not match")),
    );

    return;
  }

  try {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 🔐 Get user ID
    String uid = cred.user!.uid;

    // ✅ Save to Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'isCareGiver': isCareGiver,
      'createdAt': Timestamp.now(),
    });

    // ✅ Also store locally
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCareGiver', isCareGiver);


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Account created successfully")),
    );

    Navigator.pushReplacementNamed(context, '/login');
  } on FirebaseAuthException catch (e) {
    String errorMessage;

    switch (e.code) {
      case 'invalid-email':
        errorMessage = "The email address is not valid.";
        break;
      case 'email-already-in-use':
        errorMessage = "This email is already registered. Try logging in.";
        break;
      case 'weak-password':
        errorMessage = "Password is too weak. Please use at least 6 characters.";
        break;
      case 'operation-not-allowed':
        errorMessage = "Email/password accounts are not enabled.";
        break;
      default:
        errorMessage = "An error occurred: ${e.message}";
        debugPrint(e.message);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );

  }
}
