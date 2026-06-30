import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'infrastructures/routes/page_constants.dart';


class OTPService {
  // Method to send OTP
  Future<void> sendOtp(String mobileno, var captcha, String schtm) async {
    // Construct the OTP message
    String message = "Dear Sir, $captcha is one time password(OTP) for your EDU Bloom Portal Login. please do not share with anyone. it is valid for 5 min from the request. Regards,Edu BLOOM";
    
    // Construct the URL with query parameters
    String url = "http://164.52.195.161/API/SendMsg.aspx?uname=20143153&pass=9H9Hr999&send=MONTEG&dest=$mobileno&msg=$message&priority=1";
    print(url);
    try {
      // Send the GET request to the API
      final response = await http.get(Uri.parse(url));

      // Check if the request was successful
      if (response.statusCode == 200) {
        // If the response is successful, navigate to OTP login screen with the phone number and OTP

        Get.offAllNamed(RouteName.otp, arguments: {'phoneNumber': mobileno, 'otp': captcha});
        Get.snackbar('Success', 'OTP sent successfully to $mobileno');
        print('OTP sent successfully');
        print('Response: ${response.body}');
      } else {
        // If the response code is not 200, show an error
        print('Failed to send OTP: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to send OTP: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      print('Error occurred while sending OTP: $e');
      Get.snackbar('Error', 'Error occurred while sending OTP: $e');
    }
  }
}
