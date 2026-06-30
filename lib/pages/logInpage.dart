import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teacher_app_edubloom/pages/phonenumberscreen.dart';

import '../controller/login_page_controller.dart';
import '../infrastructures/constant/image_constant.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../view_model/login_view_model.dart';

class LoginScreen extends GetView<LogInPageController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            const AuroraTextureBackground(),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(height: 24.h),

                            // Brand (centered)
                            const _BrandHeader(),

                            SizedBox(height: 28.h),

                            // Main card
                            _FrostCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Admin Login",
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "Manage classes, staff, fees and updates securely.",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                      height: 1.35,
                                    ),
                                  ),
                                  SizedBox(height: 22.h),

                                  const _FieldLabel("Username"),
                                  SizedBox(height: 8.h),
                                  _TextFieldX(
                                    controller: controller.userNamecontroller,
                                    hint: "Enter username",
                                    icon: Icons.person_rounded,
                                    textInputAction: TextInputAction.next,
                                  ),

                                  SizedBox(height: 16.h),

                                  const _FieldLabel("Password"),
                                  SizedBox(height: 8.h),
                                  Obx(
                                    () => _TextFieldX(
                                      controller: controller.userPasswordcontroller,
                                      hint: "Enter password",
                                      icon: Icons.lock_rounded,
                                      obscureText: controller.isObscure.value,
                                      suffix: IconButton(
                                        onPressed: controller.togglePasswordVisibility,
                                        icon: Icon(
                                          controller.isObscure.value
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ),

                                  SizedBox(height: 8.h),

                                  // Align(
                                  //   alignment: Alignment.centerRight,
                                  //   child: TextButton(
                                  //     onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                                  //     style: TextButton.styleFrom(
                                  //       foregroundColor: Colors.white,
                                  //       padding: EdgeInsets.zero,
                                  //     ),
                                  //     child: Text(
                                  //       "Forgot password?",
                                  //       style: TextStyle(
                                  //         fontSize: 13.sp,
                                  //         color: Colors.white70,
                                  //         fontWeight: FontWeight.w700,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  SizedBox(height: 10.h),

                                  // Primary CTA
                                  SizedBox(
                                    height: 52.h,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (controller.userNamecontroller.text.trim().isEmpty ||
                                            controller.userPasswordcontroller.text.trim().isEmpty) {
                                          ShortMessage.toast(title: "Please fill all fields");
                                          return;
                                        }
                                         PrefManager().writeValue(
                            key: PrefConst.username,
                            value: controller.userNamecontroller.text.trim());
                        PrefManager().writeValue(
                            key: PrefConst.password,
                            value: controller.userPasswordcontroller.text.trim());

                        Map data = {
                          "userName": controller.userNamecontroller.text.trim(),
                          "password": controller.userPasswordcontroller.text.trim(),
                          "rememberMe": true
                        };

                        LoginViewModel().loginApi(data);

                        if (kDebugMode) {
                          print("Login payload => $data");
                        }
                      
                                        // TODO: call your login API here
                                        
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: const Color(0xFF2D7CFF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14.r),
                                        ),
                                      ),
                                      child: Text(
                                        "Sign In",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 14.h),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(color: Colors.white.withOpacity(0.25)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                        child: Text(
                                          "or",
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(color: Colors.white.withOpacity(0.25)),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 14.h),

                                  // Secondary CTA
                                  SizedBox(
                                    height: 52.h,
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => Get.to(() => PhoneNumberInputScreen()),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.white.withOpacity(0.35)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14.r),
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.sms_rounded),
                                      label: Text(
                                        "Register Your School With OTP",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            Padding(
                              padding: EdgeInsets.only(bottom: 18.h, top: 16.h),
                              child: Text(
                                "© ${DateTime.now().year} Your Playschool • Admin Panel",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Texture / Gradient background (NO IMAGE)
class AuroraTextureBackground extends StatelessWidget {
  const AuroraTextureBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 127, 219, 119),
                  Color(0xFF1A0F2E),
                ],
              ),
            ),
          ),
        ),

        // glow blobs
        Positioned(top: -60, left: -40, child: _GlowBlob(size: 240, color: Color(0xFF2D7CFF))),
        Positioned(bottom: -90, right: -70, child: _GlowBlob(size: 290, color: Color(0xFFFFB15A))),
        Positioned(top: 220, right: -60, child: _GlowBlob(size: 190, color: Color(0xFF46E6A3))),

        // vignette overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.70),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            ImageConstants.logo,
            height: 96,
            width: 96,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "EduBloom",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Playschool Admin",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FrostCard extends StatelessWidget {
  final Widget child;
  const _FrostCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _TextFieldX extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction? textInputAction;

  const _TextFieldX({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.white.withOpacity(0.14),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFF2D7CFF), width: 1.6),
        ),
      ),
    );
  }
}
