import 'package:get/get.dart';
import '../controller/feedurationcontroller.dart';

class FeeDurationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeeDurationController>(() => FeeDurationController());
  }
}
