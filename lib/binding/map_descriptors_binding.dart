import 'package:get/get.dart';
import '../controller/map_descriptors_controller.dart';

class MapDescriptorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapDescriptorsController>(() => MapDescriptorsController());
  }
}