import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/splash_screen_controller.dart';
import '../utils/image.dart';

class SplashScreen extends GetView<SplashScreenController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashScreenController());
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                ImageConstants.backgroun,
              ),
              fit: BoxFit.cover),
        ),
        child: Center(
            child: Image.asset(
          ImageConstants.backgroundl,
          height: 400.h,
          width: 400.w,
        )
            ),
        // child: Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       Image.asset(
        //         "assets/image/eduagent_logo.png",
        //         height: 400,
        //         width: 400,
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
