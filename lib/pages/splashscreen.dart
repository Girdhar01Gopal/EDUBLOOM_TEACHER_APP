import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/splash_screen_controller.dart';
import '../infrastructures/constant/image_constant.dart';

// Same wine/maroon brand gradient used across the app bar and login screen.
const Color _kBrandDeep = Color(0xFF5E0E29);
const Color _kBrandDark = Color(0xFF7A1236);
const Color _kBrandMid = Color(0xFF8F1542);
const Color _kBrandLight = Color(0xFFC75080);
const Color _kBrandPale = Color(0xFFE8B8CC);

class SplashScreen extends GetView<SplashScreenController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashScreenController());
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kBrandDeep, _kBrandDark, _kBrandMid],
                ),
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            child: _GlowBlob(size: 220, color: _kBrandPale),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: _GlowBlob(size: 260, color: _kBrandLight),
          ),
          const SafeArea(child: _SplashContent()),
        ],
      ),
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
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0, 1),
                child: Transform.scale(scale: value, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  ImageConstants.logo,
                  height: 110.w,
                  width: 110.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "EduBloom",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Teacher App",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(height: 46.h),
          SizedBox(
            height: 26.w,
            width: 26.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
