import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String _resetCode = ''; // Reset code from email link

  // Step 1: Send password reset email
  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter a valid email");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(msg: "Password reset email sent! Check your inbox.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  // Step 2: Verify reset link and set new password
  Future<void> _confirmPasswordReset() async {
    final newPassword = _passwordController.text.trim();
    if (newPassword.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter a new password");
      return;
    }

    try {
      // Confirm the password reset with the code and new password
      await _auth.confirmPasswordReset(
        code: _resetCode, // The reset code received in the reset email
        newPassword: newPassword,
      );
      Fluttertoast.showToast(msg: "Password reset successfully!");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Enter your email for reset'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendPasswordResetEmail,
              child: Text("Send Reset Email"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Enter your new password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmPasswordReset,
              child: Text("Confirm New Password"),
            ),
          ],
        ),
      ),
    );
  }
}
