import 'package:get/get.dart';

import '../controller/splash_screen_controller.dart';

class SpalshScreenBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => SplashScreenController(),);
  }

}