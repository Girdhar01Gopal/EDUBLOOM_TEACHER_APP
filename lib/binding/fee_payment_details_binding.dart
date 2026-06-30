import 'package:get/get.dart';
import '../controller/fee_payment_details_controller.dart';

class FeePaymentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FeePaymentDetailsController);
  }
}
