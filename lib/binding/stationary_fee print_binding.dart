// ─────────────────────────────────────────────────────────────
// FILE: stationary_fee_print_binding.dart
// ─────────────────────────────────────────────────────────────
import 'package:get/get.dart';
import '../controller/stationary_fee_print_controller.dart';

class StationaryFeePrintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StationaryFeePrintController>(
          () => StationaryFeePrintController(),
    );
  }
}

