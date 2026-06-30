import 'package:get/get.dart';
import '../controller/addroutemaster_controller.dart';

class RouteMasterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RouteMasterController>(() => RouteMasterController());
  }
}
