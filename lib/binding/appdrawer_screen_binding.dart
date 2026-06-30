import 'package:get/get.dart';

import '../controller/app_drawer_controller.dart';

class AppDrawerScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(
      () => AppDrawerController(),
    );
  }
}
