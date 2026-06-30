import 'package:get/get.dart';
import '../controller/stationary_inventory_controller.dart';

class StationaryInventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StationaryInventoryController>(
          () => StationaryInventoryController(),
    );
  }
}