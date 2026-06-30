import 'package:get/get.dart';
import '../controller/stationary_fee_action_controller.dart';

class StationaryFeeActionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StationaryFeeActionController>(
          () => StationaryFeeActionController(),
    );
  }
}