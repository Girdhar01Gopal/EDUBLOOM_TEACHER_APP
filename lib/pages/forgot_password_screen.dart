import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/forgot_password_controller.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller =
    Get.put(ForgotPasswordController(), permanent: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white), // white back arrow
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your registered email to reset your password",
              style: TextStyle(fontSize: 16.sp, color: Colors.black87),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            SizedBox(height: 30.h),
            Center(
              child: Obx(
                    () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.w, vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                   controller.resetlink(  context);
                    final email = controller.emailController.text.trim();

                    if (email.isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Email field cannot be empty",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.all(10),
                      );
                      return;
                    }

                    final regex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!regex.hasMatch(email)) {
                      Get.snackbar(
                        "Invalid Email",
                        "Please enter a valid email address",
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.all(10),
                      );
                      return;
                    }

                    controller.isLoading.value = true;
                    Future.delayed(const Duration(seconds: 2), () {
                      controller.isLoading.value = false;

                      // ✅ Green & white snackbar for success
                      Get.snackbar(
                        "Success",
                        "Reset link shared successfully!",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.all(10),
                        borderRadius: 10,
                        duration: const Duration(seconds: 2),
                      );

                      // Go back after short delay
                      Future.delayed(const Duration(seconds: 2), () {
                        Get.back();
                      });
                    });
                  },
                  child: controller.isLoading.value
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    "Send Reset Link",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
