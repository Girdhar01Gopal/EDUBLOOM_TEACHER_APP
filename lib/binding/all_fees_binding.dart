import 'package:get/get.dart';

import '../controller/all_fees_controller.dart';

class AllFeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AllFeesController());
  }
}
