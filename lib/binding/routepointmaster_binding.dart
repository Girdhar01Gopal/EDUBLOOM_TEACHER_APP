import 'package:get/get.dart';
import '../controller/routepointmaster_controller.dart';

class RoutePointBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoutePointController>(() => RoutePointController());
  }
}
