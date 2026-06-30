import 'package:get/get.dart';

import '../controller/home_page_controller.dart';

class DashboardScreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(
      () => DashboardScreenController(),
    );
  }
}
