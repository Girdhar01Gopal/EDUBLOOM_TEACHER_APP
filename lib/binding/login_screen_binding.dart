import 'package:get/get.dart';

import '../controller/login_page_controller.dart';

class LoginScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(
      () => LogInPageController(),
    );
  }
}
