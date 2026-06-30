import 'package:get/get.dart';

import '../controller/daycare_feepayment_view_controller.dart';

class DaycareFeePaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaycareFeePaymentviewController>(() => DaycareFeePaymentviewController());
  }
}
