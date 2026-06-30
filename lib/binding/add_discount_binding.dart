import 'package:get/get.dart';

import '../controller/add_discount_controller.dart';

class DiscountBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => AddDiscountController());
  }

}