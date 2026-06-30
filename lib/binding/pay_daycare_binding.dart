import 'package:get/get.dart';

import '../controller/pay_daycare_controller.dart';

class PayDayCBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => PayDayCController());
  }

}