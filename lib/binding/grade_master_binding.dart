import 'package:get/get.dart';
import '../controller/grade_master_controller.dart';
import '../controller/payment_master_controller.dart';

class gradeMasterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GradeMasterController>(() => GradeMasterController());
  }
}
