import 'package:get/get.dart';
import '../controller/daycare_durationmaster _controller.dart';


class DaycareDurationmasterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayCareDurationController>(() => DayCareDurationController());
  }
}
