import 'package:get/get.dart';
import '../controller/fee_head_master_controller.dart';

class AddFeeHeadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddFeeHeadController>(() => AddFeeHeadController());
  }
}
