import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final _auth = FirebaseAuth.instance;
  String _errorMessage = '';

  // Check if the email is valid
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }
void resetlink(BuildContext context) async {
  if (!isValidEmail(emailController.text)) {
    Fluttertoast.showToast(msg: "Please enter a valid email");
    return;
  }

  isLoading.value = true;
  _errorMessage = '';  // Reset previous error messages

  try {
    // Request password reset email without ActionCodeSettings
    await _auth.sendPasswordResetEmail(
      email: emailController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Password reset email sent! Please check your inbox."),
    ));
  } on FirebaseAuthException catch (e) {
    _errorMessage = e.message ?? 'An error occurred';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_errorMessage),
    ));
  } finally {
    isLoading.value = false;
  }
}

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
