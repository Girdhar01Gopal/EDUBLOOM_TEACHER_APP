import 'package:get/get.dart';
import '../controller/descriptors_controller.dart';

class DescriptorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DescriptorsController>(() => DescriptorsController());
  }
}