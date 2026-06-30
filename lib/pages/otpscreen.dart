import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../infrastructures/routes/page_constants.dart';

class OTPLoginScreen extends StatefulWidget {
  const OTPLoginScreen({Key? key}) : super(key: key);

  @override
  _OTPLoginScreenState createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> with SingleTickerProviderStateMixin {
  var phoneNumber = ''.obs;
  var otp = ''.obs;
  bool _isLoading = false;
  String? _otpError;
  int _resendCountdown = 0;
  // Generate a 6-digit OTP
  int generateOtp() {
    Random random = Random();
    return 100000 + random.nextInt(900000); // Generate a number between 100000 and 999999
  }

  // Generate dynamic schedule time
  String generateDynamicSchtm() {
    // Get the current DateTime
    DateTime now = DateTime.now();
    // Format the DateTime in the required format (yyyy-MM-dd HH:mm)
    return DateFormat('yyyy-MM-dd HH:mm').format(now);
  }

  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    phoneNumber.value = Get.arguments?['phoneNumber'] ?? '';
    otp.value = Get.arguments?['otp'] ?? '';
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    String enteredOtp = _otpControllers.map((controller) => controller.text).join();

    if (enteredOtp.isEmpty) {
      setState(() {
        _otpError = 'Please enter OTP';
      });
      return;
    }

    if (enteredOtp.length != 6) {
      setState(() {
        _otpError = 'Please enter complete 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _otpError = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (enteredOtp == otp.value.toString()) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('OTP Verified Successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );

          Get.offAllNamed(RouteName.registerview, arguments: {
            'mobile': phoneNumber.value,
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _otpError = 'Invalid OTP. Please try again.';
          });
          _clearOTPFields();
          _focusNodes[0].requestFocus();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpError = 'An error occurred. Please try again.';
        });
      }
    }
  }

  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
  }

  // Method to send OTP
  Future<void> resendsendOtp(String mobileno, var captcha) async {
    // Construct the OTP message
    String message = "Dear Sir, $captcha is one time password(OTP) for your EDU Bloom Portal Login. please do not share with anyone. it is valid for 5 min from the request. Regards,Edu BLOOM";
    
    // Construct the URL with query parameters
    String url = "http://164.52.195.161/API/SendMsg.aspx?uname=20143153&pass=9H9Hr999&send=MONTEG&dest=$mobileno&msg=$message&priority=1";

    try {
    //  isLoading(true); // Set loading state to true

      // Send the GET request to the API
      final response = await http.get(Uri.parse(url));

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Navigate to OTP login screen with the phone number and OTP
     //   Get.offAllNamed(RouteName.otp, arguments: {'phoneNumber': mobileno, 'otp': captcha.toString()});
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
    } finally {
      //isLoading(false); // Set loading state to false after the request completes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "OTP Verification",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  
                  // Icon
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 60.sp,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  
                  SizedBox(height: 30.h),
                  
                  // Title
                  Text(
                    "Verification Code",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // Subtitle
                  Text(
                    "Enter the 6-digit code sent to",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  SizedBox(height: 6.h),
                  
                  Text(
                    phoneNumber.value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  
                  SizedBox(height: 40.h),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return _buildOTPField(index);
                    }),
                  ),
                  
                  SizedBox(height: 24.h),

                  // Error Message
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _otpError != null ? 24.h : 0,
                    child: _otpError != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 18.sp),
                              SizedBox(width: 6.w),
                              Text(
                                _otpError!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  
                  SizedBox(height: 32.h),

                  // Verify Button
                  SizedBox(
                    height: 52.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 2,
                        shadowColor: Colors.teal.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 28.h),

                  // Resend OTP Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (_resendCountdown > 0)
                        Text(
                          "Resend in ${_resendCountdown}s",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        InkWell(
                            onTap: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              String mobileno = phoneNumber.value;
                              int captcha = generateOtp();
                              String schtm = generateDynamicSchtm();
                              resendsendOtp(mobileno, captcha); // Call the controller method
                            }},
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                            child: Text(
                              "Resend",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 48.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
            
            if (_otpError != null) {
              setState(() {
                _otpError = null;
              });
            }
          }
        },
        onTap: () {
          _otpControllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _otpControllers[index].text.length),
          );
        },
      ),
    );
  }
}
