import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/login_page_controller.dart';
import '../infrastructures/constant/image_constant.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../view_model/login_view_model.dart';

// Brand palette — matches the dashboard app bar's wine/maroon gradient.
const Color kBrandDeep = Color(0xFF5E0E29);
const Color kBrandDark = Color(0xFF7A1236);
const Color kBrandMid = Color(0xFF8F1542);
const Color kBrandAccent = Color(0xFFA11A4D);
const Color kBrandLight = Color(0xFFC75080);
const Color kBrandPale = Color(0xFFE8B8CC);
const Color kInk = Color(0xFF1A2847);

class LoginScreen extends GetView<LogInPageController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            const _PlayfulGradientBackground(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 22.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(height: 28.h),
                            const _BrandHeader(),
                            SizedBox(height: 34.h),
                            _LoginCard(controller: controller),
                            const Spacer(),
                            Padding(
                              padding: EdgeInsets.only(bottom: 18.h, top: 20.h),
                              child: Text(
                                "© ${DateTime.now().year} EduBloom • Teacher Panel",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
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

/// Vibrant diagonal gradient with soft playful blobs (no images).
class _PlayfulGradientBackground extends StatelessWidget {
  const _PlayfulGradientBackground();

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
                colors: [kBrandDeep, kBrandAccent, kBrandMid],
              ),
            ),
          ),
        ),
        Positioned(
          top: -50,
          left: -50,
          child: _GlowBlob(size: 220, color: kBrandPale),
        ),
        Positioned(
          top: 140,
          right: -70,
          child: _GlowBlob(size: 200, color: kBrandLight),
        ),
        Positioned(
          bottom: -80,
          left: -60,
          child: _GlowBlob(size: 260, color: kBrandMid),
        ),
        Positioned(
          bottom: 60,
          right: -40,
          child: _GlowBlob(size: 150, color: Colors.white),
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
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
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
        Text(
          "EduBloom",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          "Teacher App",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// Hero-style card: gradient header band inside the card, with a
/// floating circular logo badge straddling the header/body seam.
class _LoginCard extends StatelessWidget {
  final LogInPageController controller;
  const _LoginCard({required this.controller});

  static const double _avatarSize = 76;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: _avatarSize / 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: kInk.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gradient hero header band
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    22.w,
                    _avatarSize / 2 + 14.h,
                    22.w,
                    20.h,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kBrandDeep, kBrandAccent, kBrandMid],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Welcome back 👋",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Sign in to manage your classroom, fees and updates.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form body
                Padding(
                  padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 22.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              color: kInk.withValues(alpha: 0.4),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),

                      SizedBox(height: 26.h),

                      _GradientButton(
                        label: "Sign In",
                        onPressed: () => _onSignIn(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating avatar badge straddling the header/body seam
        Container(
          height: _avatarSize,
          width: _avatarSize,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kInk.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
              ImageConstants.logo,
              fit: BoxFit.contain
          ),
        ),
      ],
    );
  }

  void _onSignIn() {
    if (controller.userNamecontroller.text.trim().isEmpty ||
        controller.userPasswordcontroller.text.trim().isEmpty) {
      ShortMessage.toast(title: "Please fill all fields");
      return;
    }

    PrefManager().writeValue(
      key: PrefConst.username,
      value: controller.userNamecontroller.text.trim(),
    );
    PrefManager().writeValue(
      key: PrefConst.password,
      value: controller.userPasswordcontroller.text.trim(),
    );

    Map data = {
      "userName": controller.userNamecontroller.text.trim(),
      "password": controller.userPasswordcontroller.text.trim(),
      "rememberMe": true,
    };

    LoginViewModel().loginApi(data);

    if (kDebugMode) {
      print("Login payload => $data");
    }
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54.h,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [kBrandDeep, kBrandAccent, kBrandMid],
          ),
          boxShadow: [
            BoxShadow(
              color: kBrandAccent.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
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
        color: kInk,
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w800,
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
      style: TextStyle(color: kInk, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: kBrandAccent),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: TextStyle(
          color: kInk.withValues(alpha: 0.35),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: kBrandPale.withValues(alpha: 0.28),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: kBrandAccent, width: 1.8),
        ),
      ),
    );
  }
}
