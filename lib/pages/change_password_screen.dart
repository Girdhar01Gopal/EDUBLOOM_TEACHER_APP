import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/change_password_controller.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.teal.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Change Password",
          style: TextStyle(fontSize: 18.sp, color: Colors.white),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12,
                  offset: Offset(0, 6),
                  color: Colors.black12,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Update your password",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6.h),
                Text(
                  "After changing password, you’ll be logged out for security purpose.",
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
                SizedBox(height: 14.h),

                // ✅ shows what controller picked (for debug)
               
                /// Old Password
                Obx(() => _passwordField(
                  label: "Current Password",
                  textCtrl: controller.oldPasswordCtrl,
                  obscure: !controller.showOld.value,
                  onToggle: controller.toggleOld,
                  validator: controller.validateOld,
                )),
                SizedBox(height: 14.h),

                /// New Password
                Obx(() => _passwordField(
                  label: "New Password",
                  textCtrl: controller.newPasswordCtrl,
                  obscure: !controller.showNew.value,
                  onToggle: controller.toggleNew,
                  validator: controller.validateNew,
                  onChanged: controller.onNewPasswordChanged,
                )),
                SizedBox(height: 10.h),

                /// Strength Meter
                Obx(() => _strengthMeter(
                  score: controller.strengthScore.value,
                  label: controller.strengthLabel.value,
                )),
                SizedBox(height: 14.h),

                /// Confirm Password
                Obx(() => _passwordField(
                  label: "Confirm New Password",
                  textCtrl: controller.confirmPasswordCtrl,
                  obscure: !controller.showConfirm.value,
                  onToggle: controller.toggleConfirm,
                  validator: controller.validateConfirm,
                )),
                SizedBox(height: 22.h),

                /// Submit
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      "Update Password",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController textCtrl,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: textCtrl,
      obscureText: obscure,
      validator: validator,
      onChanged: onChanged,
      decoration: _dec(label).copyWith(
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }

  Widget _strengthMeter({required double score, required String label}) {
    final value = score.clamp(0.0, 1.0);

    Color barColor;
    if (value < 0.35) {
      barColor = Colors.red;
    } else if (value < 0.7) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password Strength: $label",
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LinearProgressIndicator(
            minHeight: 8.h,
            value: value,
            backgroundColor: Colors.black12,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
