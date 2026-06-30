import 'dart:math';
import 'package:fetch_mobile_numbers/fetch_mobile_numbers.dart';
import 'package:fetch_mobile_numbers/sim_card/sim_card_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controller/phonenumbercontroller.dart';

class PhoneNumberInputScreen extends StatefulWidget {
  @override
  _PhoneNumberInputScreenState createState() => _PhoneNumberInputScreenState();
}

class _PhoneNumberInputScreenState extends State<PhoneNumberInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getSimPhoneNumber();
  }

  Future<void> _getSimPhoneNumber() async {
    try {
      final PermissionStatus status = await Permission.phone.request();

      if (status.isGranted) {
        final fetchMobileNumbers = FetchMobileNumbers();
        List<SimCard>? simCards = await fetchMobileNumbers.getMobileNumbers();

        if (simCards != null && simCards.isNotEmpty) {
          if (simCards.length == 1) {
            setState(() {
              String phoneNumber = simCards[0].number ?? '';
              _phoneController.text = _cleanPhoneNumber(phoneNumber);
            });
          } else {
            _showPhoneNumberDialog(simCards);
          }
        } else {
          print('No SIM cards found.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No SIM card found or unable to fetch number.'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission to access phone state is denied.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } catch (e) {
      print('Error getting SIM number: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not fetch SIM number'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  String _cleanPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('91')) {
      cleaned = cleaned.substring(2);
    }
    return cleaned.length >= 10 ? cleaned.substring(cleaned.length - 10) : cleaned;
  }

  Future<void> _showPhoneNumberDialog(List<SimCard> simCards) async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.phone_in_talk, size: 50.w, color: Colors.white),
                      SizedBox(height: 12.h),
                      Text(
                        "Select Phone Number",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Multiple SIM cards detected",
                        style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxHeight: 300.h),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: simCards.length,
                    itemBuilder: (context, index) {
                      String phoneNumber = _cleanPhoneNumber(simCards[index].number ?? '');
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          leading: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.sim_card,
                              color: Colors.teal.shade700,
                              size: 24.w,
                            ),
                          ),
                          title: Text(
                            phoneNumber,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'SIM ${index + 1}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.w,
                            color: Colors.teal.shade700,
                          ),
                          onTap: () {
                            setState(() {
                              _phoneController.text = phoneNumber;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int generateOtp() {
    Random random = Random();
    return 100000 + random.nextInt(900000);
  }

  String generateDynamicSchtm() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd HH:mm').format(now);
  }

  void _showSuccessDialog(String phoneNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          elevation: 10,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, size: 60.w, color: Colors.green.shade600),
                ),
                SizedBox(height: 16.h),
                Text(
                  "OTP Sent Successfully",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "We've sent a verification code to",
                  style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    phoneNumber,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Phonenumbercontroller());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Mobile Verification",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.1),
                          blurRadius: 10.r,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.phone_android, size: 60.w, color: Colors.teal.shade700),
                        SizedBox(height: 16.h),
                        Text(
                          "Enter your mobile number",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "We'll send you a verification code",
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  TextFormField(
                    controller: _phoneController,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      labelStyle: TextStyle(fontSize: 14.sp, color: Colors.teal.shade700),
                      prefixIcon: Icon(Icons.phone, color: Colors.teal.shade700),
                      hintText: '10-digit number',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.teal.shade200, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.teal.shade200, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.teal.shade700, width: 2.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a mobile number';
                      }
                      if (value.length != 10) {
                        return 'Mobile number must be exactly 10 digits';
                      }
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                        return 'Please enter only numbers';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.h),
                  Obx(() {
                    return controller.isLoading.value
                        ? Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.teal.shade700, Colors.teal.shade900],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: SizedBox(
                                height: 24.w,
                                width: 24.w,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 56.h,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  String mobileno = _phoneController.text;
                                  int captcha = generateOtp();
                                  String schtm = generateDynamicSchtm();
                                  controller.sendOtp(mobileno, captcha, schtm);
                                  _showSuccessDialog(mobileno);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.teal.shade700, Colors.teal.shade900],
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Send OTP',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                  }),
                  SizedBox(height: 20.h),
                  Text(
                    "We never share your information with anyone",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
