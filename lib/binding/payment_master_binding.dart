import 'package:get/get.dart';
import '../controller/payment_master_controller.dart';

class PaymentMasterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentMasterController>(() => PaymentMasterController());
  }
}
